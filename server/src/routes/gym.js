const express = require('express');
const router = express.Router();
const path = require('path');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const authMiddleware = require('../middleware/auth');
const config = require('../config');
const { Gym, GymBranch, Membership, User, Plan } = require('../models');

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

    const active = isActive !== undefined ? Boolean(isActive) : (is_active !== undefined ? Boolean(is_active) : true);

    const gym = await Gym.create({
      owner_id: req.user._id,
      name: name.trim(),
      email: email.trim(),
      is_active: active,
    });

    return res.status(201).json({
      id: gym._id,
      gym_id: gym._id,
      name: gym.name,
      email: gym.email,
      is_active: gym.is_active,
    });
  } catch (error) {
    console.error('Onboard gym error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/getGym
router.get('/gym/getGym', authMiddleware, async (req, res) => {
  try {
    const gym = await Gym.findOne({ owner_id: req.user._id });
    if (!gym) {
      return res.status(200).json([]);
    }

    return res.status(200).json({
      id: gym._id,
      gym_id: gym._id,
      name: gym.name,
      email: gym.email,
      description: gym.description || 'Premium Strength and Conditioning Gym',
      is_active: gym.is_active,
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

    const gym = await Gym.findOne({ _id: gym_id, owner_id: req.user._id });
    if (!gym) {
      return res.status(404).json({ detail: 'Gym not found' });
    }

    if (name) gym.name = name.trim();
    if (email) gym.email = email.trim();
    if (description !== undefined) gym.description = description;
    if (is_active !== undefined) gym.is_active = Boolean(is_active);

    await gym.save();

    return res.status(200).json({
      id: gym._id,
      name: gym.name,
      email: gym.email,
      description: gym.description,
      is_active: gym.is_active,
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
    await Gym.findByIdAndUpdate(gym_id, { logo_url: logoUrl });

    return res.status(200).json({ logo_url: logoUrl });
  } catch (error) {
    console.error('Upload logo error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/get-logo/:gym_id
router.get('/gym/get-logo/:gym_id', authMiddleware, async (req, res) => {
  try {
    const gym = await Gym.findById(req.params.gym_id);
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

    const branch = await GymBranch.create({
      gym_id,
      name: name.trim(),
      address: address.trim(),
      city: city.trim(),
      state: (state || '').trim(),
      country: (country || '').trim(),
      pincode: (pincode || '').trim(),
      latitude: latitude || 0.0,
      longitude: longitude || 0.0,
      is_active: is_active !== undefined ? Boolean(is_active) : true,
      opening_time: opening_time || '06:00:00.000Z',
      closing_time: closing_time || '22:00:00.000Z',
    });

    return res.status(201).json({
      branch_id: branch._id,
      gym_id,
      name: branch.name,
      address: branch.address,
      city: branch.city,
      state: branch.state,
      pincode: branch.pincode,
      opening_time: branch.opening_time,
      closing_time: branch.closing_time,
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
    const branches = await GymBranch.find({ gym_id: req.params.gym_id });
    const results = [];

    for (const b of branches) {
      const count = await Membership.countDocuments({ branch_id: b._id });
      results.push({
        branch_id: b._id,
        gym_id: b.gym_id,
        name: b.name,
        address: b.address,
        city: b.city,
        state: b.state,
        pincode: b.pincode,
        opening_time: b.opening_time,
        closing_time: b.closing_time,
        total_members: count,
        active_members: count,
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
    const branch = await GymBranch.findById(req.params.branch_id);
    if (!branch) {
      return res.status(404).json({ detail: 'Branch not found' });
    }

    const count = await Membership.countDocuments({ branch_id: branch._id });

    return res.status(200).json({
      branch_id: branch._id,
      gym_id: branch.gym_id,
      name: branch.name,
      address: branch.address,
      city: branch.city,
      state: branch.state,
      pincode: branch.pincode,
      opening_time: branch.opening_time,
      closing_time: branch.closing_time,
      total_members: count,
      active_members: count,
    });
  } catch (error) {
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/gym/branch/getallbranchmembers/:branch_id
router.get('/gym/branch/getallbranchmembers/:branch_id', authMiddleware, async (req, res) => {
  try {
    const memberships = await Membership.find({ branch_id: req.params.branch_id });
    const results = [];

    for (const m of memberships) {
      const u = await User.findById(m.user_id);
      const p = await Plan.findById(m.plan_id);

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

    const membership = await Membership.create({
      gym_id,
      branch_id,
      plan_id,
      user_id,
      amount: amount || 0.0,
      payment_mode: payment_mode || 'cash',
      status: 'Active',
    });

    return res.status(200).json({
      message: 'Member added and plan assigned successfully',
      membership_id: membership._id,
      status: 'Active',
    });
  } catch (error) {
    console.error('Add member error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
