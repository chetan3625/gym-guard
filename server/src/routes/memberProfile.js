const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const authMiddleware = require('../middleware/auth');
const config = require('../config');
const { dbGet, dbRun } = require('../database/db');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, config.uploadsDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.png';
    cb(null, `avatar_${req.user.id}_${Date.now()}${ext}`);
  },
});
const upload = multer({ storage });

// GET /profile/api/v1/member/search-member/:by_phone
router.get('/search-member/:by_phone', authMiddleware, async (req, res) => {
  try {
    const targetPhone = (req.query.phone || req.params.by_phone || '').trim();
    const user = await dbGet('SELECT * FROM users WHERE phone = ?', [targetPhone]);
    if (!user) {
      return res.status(404).json({ detail: 'Member not found' });
    }

    const parts = (user.name || '').split(' ');
    const firstName = parts[0] || '';
    const lastName = parts.slice(1).join(' ') || '';

    return res.status(200).json({
      user_id: user.id,
      first_name: firstName,
      last_name: lastName,
      phone: user.phone,
      email: null,
    });
  } catch (error) {
    console.error('Search member error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /profile/api/v1/member/get-profile
router.get('/get-profile', authMiddleware, async (req, res) => {
  try {
    const targetUserId = req.query.user_id || req.user.id;
    const user = await dbGet('SELECT * FROM users WHERE id = ?', [targetUserId]);
    if (!user) {
      return res.status(404).json({ detail: 'Member profile not found' });
    }

    const parts = (user.name || '').split(' ');
    const firstName = parts[0] || '';
    const lastName = parts.slice(1).join(' ') || '';

    const membership = await dbGet('SELECT * FROM memberships WHERE user_id = ? ORDER BY created_at DESC LIMIT 1', [user.id]);
    const membershipInfo = membership ? {
      gym_id: membership.gym_id,
      branch_id: membership.branch_id,
      plan_id: membership.plan_id,
      status: membership.status || 'Active',
    } : null;

    return res.status(200).json({
      user_id: user.id,
      first_name: firstName,
      last_name: lastName,
      email: null,
      phone: user.phone,
      dob: user.dob || null,
      gender: user.gender || null,
      height_cm: user.height_cm || null,
      weight_kg: user.weight_kg || null,
      membership: membershipInfo,
    });
  } catch (error) {
    console.error('Get profile error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// PATCH /profile/api/v1/member/update-profile
router.patch('/update-profile', authMiddleware, async (req, res) => {
  try {
    const { first_name, last_name, dob, gender, height_cm, weight_kg } = req.body;

    let updatedName = req.user.name;
    if (first_name !== undefined || last_name !== undefined) {
      const first = first_name !== undefined ? first_name : (req.user.name.split(' ')[0] || '');
      const last = last_name !== undefined ? last_name : (req.user.name.split(' ').slice(1).join(' ') || '');
      updatedName = `${first} ${last}`.trim();
    }

    const updatedDob = dob !== undefined ? dob : req.user.dob;
    const updatedGender = gender !== undefined ? gender : req.user.gender;
    const updatedHeight = height_cm !== undefined ? height_cm : req.user.height_cm;
    const updatedWeight = weight_kg !== undefined ? weight_kg : req.user.weight_kg;

    await dbRun(
      'UPDATE users SET name = ?, dob = ?, gender = ?, height_cm = ?, weight_kg = ? WHERE id = ?',
      [updatedName, updatedDob, updatedGender, updatedHeight, updatedWeight, req.user.id]
    );

    const parts = updatedName.split(' ');
    const firstName = parts[0] || '';
    const lastName = parts.slice(1).join(' ') || '';

    return res.status(200).json({
      first_name: firstName,
      last_name: lastName,
      dob: updatedDob || null,
      gender: updatedGender || null,
      height_cm: updatedHeight || null,
      weight_kg: updatedWeight || null,
    });
  } catch (error) {
    console.error('Update profile error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /profile/api/v1/member/upload-avatar
router.post('/upload-avatar', authMiddleware, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ detail: 'Avatar image file is required' });
    }

    const avatarUrl = `/media/${req.file.filename}`;
    await dbRun('UPDATE users SET avatar_url = ? WHERE id = ?', [avatarUrl, req.user.id]);

    return res.status(200).json({
      message: 'Avatar uploaded successfully',
      avatar_url: avatarUrl,
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /profile/api/v1/member/get-avatar
router.get('/get-avatar', authMiddleware, async (req, res) => {
  try {
    if (!req.user.avatar_url) {
      return res.status(200).json({ avatar_url: '' });
    }

    const filename = path.basename(req.user.avatar_url);
    const filePath = path.join(config.uploadsDir, filename);

    if (fs.existsSync(filePath)) {
      return res.sendFile(filePath);
    }

    return res.status(200).json({ avatar_url: req.user.avatar_url });
  } catch (error) {
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
