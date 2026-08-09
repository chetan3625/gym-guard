const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const config = require('../config');
const { dbGet, dbRun } = require('../database/db');

// POST /auth/api/v1/login
router.post('/login', async (req, res) => {
  try {
    const { username, password, role } = req.body;
    const phone = (username || '').trim();

    if (!phone || !password) {
      return res.status(400).json({ detail: 'Username (phone) and password are required' });
    }

    const user = await dbGet('SELECT * FROM users WHERE phone = ?', [phone]);
    if (!user) {
      return res.status(401).json({ detail: 'Invalid phone number or password' });
    }

    const passwordMatches = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatches) {
      return res.status(401).json({ detail: 'Invalid phone number or password' });
    }

    // Update role if explicitly passed
    const targetRole = role || user.role;
    if (role && user.role !== role) {
      await dbRun('UPDATE users SET role = ? WHERE id = ?', [role, user.id]);
    }

    const tokenPayload = { sub: user.id, phone: user.phone, role: targetRole };
    const accessToken = jwt.sign(tokenPayload, config.jwtSecret, { expiresIn: config.accessTokenExpire });
    const refreshToken = jwt.sign({ ...tokenPayload, type: 'refresh' }, config.jwtSecret, { expiresIn: config.refreshTokenExpire });

    return res.status(200).json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'bearer',
      role: targetRole,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /auth/api/v1/register
router.post('/register', async (req, res) => {
  try {
    const { name, phone, password, role } = req.body;
    const trimmedPhone = (phone || '').trim();

    if (!name || !trimmedPhone || !password) {
      return res.status(400).json({ detail: 'Name, phone, and password are required' });
    }

    const existingUser = await dbGet('SELECT id FROM users WHERE phone = ?', [trimmedPhone]);
    if (existingUser) {
      return res.status(400).json({ detail: 'User with this phone number already exists' });
    }

    const userId = uuidv4();
    const passwordHash = await bcrypt.hash(password, 10);
    const userRole = role || 'gym_owner';

    await dbRun(
      'INSERT INTO users (id, name, phone, password_hash, role) VALUES (?, ?, ?, ?, ?)',
      [userId, name.trim(), trimmedPhone, passwordHash, userRole]
    );

    return res.status(201).json({
      message: 'User registered successfully',
      user_id: userId,
    });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /auth/api/v1/request-otp
router.post('/request-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    const trimmedPhone = (phone || '').trim();
    if (!trimmedPhone) {
      return res.status(400).json({ detail: 'Phone number is required' });
    }

    const otpCode = '123456';
    const resetToken = `rst_${uuidv4().replace(/-/g, '')}`;
    const id = uuidv4();

    await dbRun(
      'INSERT INTO otp_codes (id, phone, code, reset_token, is_verified) VALUES (?, ?, ?, ?, 0)',
      [id, trimmedPhone, otpCode, resetToken]
    );

    return res.status(200).json({ message: `OTP sent successfully to ${trimmedPhone}` });
  } catch (error) {
    console.error('Request OTP error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /auth/api/v1/verify-otp
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    const trimmedPhone = (phone || '').trim();
    const trimmedOtp = (otp || '').trim();

    const otpRecord = await dbGet(
      'SELECT * FROM otp_codes WHERE phone = ? AND code = ? AND is_verified = 0 ORDER BY created_at DESC LIMIT 1',
      [trimmedPhone, trimmedOtp]
    );

    if (!otpRecord) {
      return res.status(400).json({ detail: 'Invalid or expired OTP code' });
    }

    await dbRun('UPDATE otp_codes SET is_verified = 1 WHERE id = ?', [otpRecord.id]);

    return res.status(200).json({
      message: 'OTP verified successfully',
      reset_token: otpRecord.reset_token,
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /auth/api/v1/reset-password
router.post('/reset-password', async (req, res) => {
  try {
    const { reset_token, new_password } = req.body;

    const otpRecord = await dbGet(
      'SELECT * FROM otp_codes WHERE reset_token = ? AND is_verified = 1 LIMIT 1',
      [reset_token]
    );

    if (!otpRecord) {
      return res.status(400).json({ detail: 'Invalid or unverified reset token' });
    }

    const user = await dbGet('SELECT * FROM users WHERE phone = ?', [otpRecord.phone]);
    if (!user) {
      return res.status(404).json({ detail: 'User associated with OTP not found' });
    }

    const passwordHash = await bcrypt.hash(new_password, 10);
    await dbRun('UPDATE users SET password_hash = ? WHERE id = ?', [passwordHash, user.id]);
    await dbRun('DELETE FROM otp_codes WHERE id = ?', [otpRecord.id]);

    return res.status(200).json({ message: 'Password reset successfully' });
  } catch (error) {
    console.error('Reset password error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /auth/api/v1/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.status(401).json({ detail: 'Refresh token is required' });
    }

    const decoded = jwt.verify(refresh_token, config.jwtSecret);
    if (decoded.type !== 'refresh') {
      return res.status(401).json({ detail: 'Invalid refresh token type' });
    }

    const user = await dbGet('SELECT * FROM users WHERE id = ?', [decoded.sub]);
    if (!user) {
      return res.status(401).json({ detail: 'User not found' });
    }

    const tokenPayload = { sub: user.id, phone: user.phone, role: user.role };
    const newAccessToken = jwt.sign(tokenPayload, config.jwtSecret, { expiresIn: config.accessTokenExpire });

    return res.status(200).json({ access_token: newAccessToken });
  } catch (error) {
    return res.status(401).json({ detail: 'Invalid or expired refresh token' });
  }
});

module.exports = router;
