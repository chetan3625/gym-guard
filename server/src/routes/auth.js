const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const config = require('../config');
const { User, OtpCode } = require('../models');

// POST /auth/api/v1/login
router.post('/login', async (req, res) => {
  try {
    const { username, password, role } = req.body;
    const phone = (username || '').trim();

    if (!phone || !password) {
      return res.status(400).json({ detail: 'Username (phone) and password are required' });
    }

    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(401).json({ detail: 'Invalid phone number or password' });
    }

    const passwordMatches = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatches) {
      return res.status(401).json({ detail: 'Invalid phone number or password' });
    }

    const targetRole = role || user.role;
    if (role && user.role !== role) {
      user.role = role;
      await user.save();
    }

    const tokenPayload = { sub: user._id, phone: user.phone, role: targetRole };
    const accessToken = jwt.sign(tokenPayload, config.jwtSecret, { expiresIn: config.accessTokenExpire });
    const refreshToken = jwt.sign({ ...tokenPayload, type: 'refresh' }, config.jwtSecret, { expiresIn: config.refreshTokenExpire });

    return res.status(200).json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'bearer',
      role: targetRole,
      user: {
        id: user._id,
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

    const existingUser = await User.findOne({ phone: trimmedPhone });
    if (existingUser) {
      return res.status(400).json({ detail: 'User with this phone number already exists' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const userRole = role || 'gym_owner';

    const user = await User.create({
      name: name.trim(),
      phone: trimmedPhone,
      password_hash: passwordHash,
      role: userRole,
    });

    return res.status(201).json({
      message: 'User registered successfully',
      user_id: user._id,
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

    await OtpCode.create({
      phone: trimmedPhone,
      code: otpCode,
      reset_token: resetToken,
      is_verified: false,
    });

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

    const otpRecord = await OtpCode.findOne({ phone: trimmedPhone, code: trimmedOtp, is_verified: false }).sort({ created_at: -1 });

    if (!otpRecord) {
      return res.status(400).json({ detail: 'Invalid or expired OTP code' });
    }

    otpRecord.is_verified = true;
    await otpRecord.save();

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

    const otpRecord = await OtpCode.findOne({ reset_token, is_verified: true });
    if (!otpRecord) {
      return res.status(400).json({ detail: 'Invalid or unverified reset token' });
    }

    const user = await User.findOne({ phone: otpRecord.phone });
    if (!user) {
      return res.status(404).json({ detail: 'User associated with OTP not found' });
    }

    user.password_hash = await bcrypt.hash(new_password, 10);
    await user.save();
    await OtpCode.findByIdAndDelete(otpRecord._id);

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

    const user = await User.findById(decoded.sub);
    if (!user) {
      return res.status(401).json({ detail: 'User not found' });
    }

    const tokenPayload = { sub: user._id, phone: user.phone, role: user.role };
    const newAccessToken = jwt.sign(tokenPayload, config.jwtSecret, { expiresIn: config.accessTokenExpire });

    return res.status(200).json({ access_token: newAccessToken });
  } catch (error) {
    return res.status(401).json({ detail: 'Invalid or expired refresh token' });
  }
});

module.exports = router;
