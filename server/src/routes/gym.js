const express = require('express');
const router = express.Router();
const path = require('path');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const authMiddleware = require('../middleware/auth');
const config = require('../config');
const { dbGet, dbAll, dbRun } = require('../database/db');

// Setup multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, config.uploadsDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.png';
    cb(null, `gym_logo_${req.params.gym_id || uuidv4()}_${Date.now()}${ext}`);
  },
});
const upload = multer({ storage });

// POST /gym-branch/api/v1/gym/onboardNewGym
router.post('/gym/onboardNewGym', authMiddleware, async (req, res) => {
  try {
    const { name, email, is_active, isActive } = req.body;
    if (!name || !email) {
      return res.status(400).json({ detail: 'Gym name and email are required' });
    }

    const gymId = uuidv4();
    const active = isActive !== undefined ? (isActive ? 1 : 0) : (is_active !== undefined ? (is_active ? 1 : 0) : 1);

    await dbRun(
      'INSERT INTO gyms (id, owner_id, name, email, is_active) VALUES (?, ?, ?, ?, ?)',
      [gymId, req.user.id, name.trim(), email.trim(), active]
    );

    return res.status(201).json({
      id: gymId,
      gym_id: gymId,
      name: name.trim(),
      email: email.trim(),
      is_active: Boolean(active),
    });
  } catch (error) {
    console.error('Onboard gym error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/getGym
router.get('/gym/getGym', authMiddleware, async (req, res) => {
  try {
    const gym = await dbGet('SELECT * FROM gyms WHERE owner_id = ? LIMIT 1', [req.user.id]);
    if (!gym) {
      return res.status(200).json([]);
    }

    return res.status(200).json({
      id: gym.id,
      gym_id: gym.id,
      name: gym.name,
      email: gym.email,
      description: gym.description || 'Premium Strength and Conditioning Gym',
      is_active: Boolean(gym.is_active),
      logo_url: gym.logo_url || null,
    });
  } catch (error) {
    console.error('Get gym error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// PATCH /gym-branch/api/v1/gym/updateGymDetails/:gym_id
router.patch('/gym/updateGymDetails/:gym_id', authMiddleware, async (req, res) => {
  try {
    const { gym_id } = req.params;
    const { name, email, description, is_active } = req.body;

    const gym = await dbGet('SELECT * FROM gyms WHERE id = ? AND owner_id = ?', [gym_id, req.user.id]);
    if (!gym) {
      return res.status(404).json({ detail: 'Gym not found' });
    }

    const updatedName = name ? name.trim() : gym.name;
    const updatedEmail = email ? email.trim() : gym.email;
    const updatedDesc = description !== undefined ? description : gym.description;
    const updatedActive = is_active !== undefined ? (is_active ? 1 : 0) : gym.is_active;

    await dbRun(
      'UPDATE gyms SET name = ?, email = ?, description = ?, is_active = ? WHERE id = ?',
      [updatedName, updatedEmail, updatedDesc, updatedActive, gym_id]
    );

    return res.status(200).json({
      id: gym_id,
      name: updatedName,
      email: updatedEmail,
      description: updatedDesc,
      is_active: Boolean(updatedActive),
    });
  } catch (error) {
    console.error('Update gym error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /gym-branch/api/v1/gym/upload-logo/:gym_id
router.post('/gym/upload-logo/:gym_id', authMiddleware, upload.single('file'), async (req, res) => {
  try {
    const { gym_id } = req.params;
    if (!req.file) {
      return res.status(400).json({ detail: 'Image file is required' });
    }

    const logoUrl = `/media/${req.file.filename}`;
    await dbRun('UPDATE gyms SET logo_url = ? WHERE id = ?', [logoUrl, gym_id]);

    return res.status(200).json({ logo_url: logoUrl });
  } catch (error) {
    console.error('Upload logo error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/get-logo/:gym_id
router.get('/gym/get-logo/:gym_id', authMiddleware, async (req, res) => {
  try {
    const gym = await dbGet('SELECT logo_url FROM gyms WHERE id = ?', [req.params.gym_id]);
    return res.status(200).json({ logo_url: gym ? gym.logo_url || '' : '' });
  } catch (error) {
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /gym-branch/api/v1/gym/branch/addbranch
router.post('/gym/branch/addbranch', authMiddleware, async (req, res) => {
  try {
    const {
      gym_id,
      name,
      address,
      city,
      state,
      country,
      pincode,
      latitude,
      longitude,
      is_active,
      opening_time,
      closing_time,
    } = req.body;

    if (!gym_id || !name || !address || !city) {
      return res.status(400).json({ detail: 'gym_id, name, address, and city are required' });
    }

    const branchId = uuidv4();
    const active = is_active !== undefined ? (is_active ? 1 : 0) : 1;

    await dbRun(
      `INSERT INTO gym_branches (id, gym_id, name, address, city, state, country, pincode, latitude, longitude, is_active, opening_time, closing_time)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        branchId,
        gym_id,
        name.trim(),
        address.trim(),
        city.trim(),
        (state || '').trim(),
        (country || '').trim(),
        (pincode || '').trim(),
        latitude || 0.0,
        longitude || 0.0,
        active,
        opening_time || '06:00:00.000Z',
        closing_time || '22:00:00.000Z',
      ]
    );

    return res.status(201).json({
      branch_id: branchId,
      gym_id,
      name: name.trim(),
      address: address.trim(),
      city: city.trim(),
      state: (state || '').trim(),
      pincode: (pincode || '').trim(),
      opening_time: opening_time || '06:00:00.000Z',
      closing_time: closing_time || '22:00:00.000Z',
      total_members: 0,
      active_members: 0,
    });
  } catch (error) {
    console.error('Add branch error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/get-all-branches/:gym_id
router.get('/gym/get-all-branches/:gym_id', authMiddleware, async (req, res) => {
  try {
    const branches = await dbAll('SELECT * FROM gym_branches WHERE gym_id = ?', [req.params.gym_id]);
    const results = [];

    for (const b of branches) {
      const countRow = await dbGet('SELECT COUNT(*) as count FROM memberships WHERE branch_id = ?', [b.id]);
      results.push({
        branch_id: b.id,
        gym_id: b.gym_id,
        name: b.name,
        address: b.address,
        city: b.city,
        state: b.state,
        pincode: b.pincode,
        opening_time: b.opening_time,
        closing_time: b.closing_time,
        total_members: countRow ? countRow.count : 0,
        active_members: countRow ? countRow.count : 0,
      });
    }

    return res.status(200).json(results);
  } catch (error) {
    console.error('Get branches error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/branch/getbranchdetails/:branch_id
router.get('/gym/branch/getbranchdetails/:branch_id', authMiddleware, async (req, res) => {
  try {
    const branch = await dbGet('SELECT * FROM gym_branches WHERE id = ?', [req.params.branch_id]);
    if (!branch) {
      return res.status(404).json({ detail: 'Branch not found' });
    }

    const countRow = await dbGet('SELECT COUNT(*) as count FROM memberships WHERE branch_id = ?', [branch.id]);

    return res.status(200).json({
      branch_id: branch.id,
      gym_id: branch.gym_id,
      name: branch.name,
      address: branch.address,
      city: branch.city,
      state: branch.state,
      pincode: branch.pincode,
      opening_time: branch.opening_time,
      closing_time: branch.closing_time,
      total_members: countRow ? countRow.count : 0,
      active_members: countRow ? countRow.count : 0,
    });
  } catch (error) {
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/branch/getallbranchmembers/:branch_id
router.get('/gym/branch/getallbranchmembers/:branch_id', authMiddleware, async (req, res) => {
  try {
    const memberships = await dbAll('SELECT * FROM memberships WHERE branch_id = ?', [req.params.branch_id]);
    const results = [];

    for (const m of memberships) {
      const u = await dbGet('SELECT * FROM users WHERE id = ?', [m.user_id]);
      const p = await dbGet('SELECT * FROM plans WHERE id = ?', [m.plan_id]);

      results.push({
        user_id: m.user_id,
        name: u ? u.name : 'Member',
        phone: u ? u.phone : '',
        email: null,
        plan_name: p ? p.name : 'Standard Plan',
        start_date: m.start_date,
        end_date: m.end_date,
        status: m.status || 'Active',
      });
    }

    return res.status(200).json(results);
  } catch (error) {
    console.error('Get branch members error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /gym-branch/api/v1/gym/branch/addmember
router.post('/gym/branch/addmember', authMiddleware, async (req, res) => {
  try {
    const { gym_id, branch_id, plan_id, user_id, amount, payment_mode } = req.body;
    if (!gym_id || !branch_id || !plan_id || !user_id) {
      return res.status(400).json({ detail: 'gym_id, branch_id, plan_id, and user_id are required' });
    }

    const membershipId = uuidv4();
    const paymentId = `pay_${uuidv4().replace(/-/g, '').substring(0, 8)}`;

    await dbRun(
      `INSERT INTO memberships (id, gym_id, branch_id, plan_id, user_id, amount, payment_mode, payment_id, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Active')`,
      [membershipId, gym_id, branch_id, plan_id, user_id, amount || 0.0, payment_mode || 'cash', paymentId]
    );

    return res.status(200).json({
      message: 'Member added and plan assigned successfully',
      membership_id: membershipId,
      status: 'Active',
    });
  } catch (error) {
    console.error('Add member error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
