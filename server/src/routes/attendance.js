const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { Attendance } = require('../models');

// POST /profile/api/v1/attendance/checkin
router.post('/checkin', authMiddleware, async (req, res) => {
  try {
    const { gym_id, branch_id } = req.body;
    if (!gym_id || !branch_id) {
      return res.status(400).json({ detail: 'gym_id and branch_id are required' });
    }

    const checkinTime = new Date();
    const attendance = await Attendance.create({
      user_id: req.user._id,
      gym_id,
      branch_id,
      checkin_time: checkinTime,
      status: 'CheckedIn',
    });

    return res.status(200).json({
      id: attendance._id,
      gym_id,
      branch_id,
      checkin_time: attendance.checkin_time,
      checkout_time: null,
      status: 'CheckedIn',
    });
  } catch (error) {
    console.error('Checkin error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /profile/api/v1/attendance/checkout
router.post('/checkout', authMiddleware, async (req, res) => {
  try {
    const { gym_id, branch_id } = req.body;
    if (!gym_id || !branch_id) {
      return res.status(400).json({ detail: 'gym_id and branch_id are required' });
    }

    const checkoutTime = new Date();
    let attendance = await Attendance.findOne({
      user_id: req.user._id,
      gym_id,
      branch_id,
      status: 'CheckedIn',
    }).sort({ checkin_time: -1 });

    if (!attendance) {
      attendance = await Attendance.create({
        user_id: req.user._id,
        gym_id,
        branch_id,
        checkin_time: checkoutTime,
        checkout_time: checkoutTime,
        status: 'CheckedOut',
      });
    } else {
      attendance.checkout_time = checkoutTime;
      attendance.status = 'CheckedOut';
      await attendance.save();
    }

    return res.status(200).json({
      id: attendance._id,
      gym_id,
      branch_id,
      checkin_time: attendance.checkin_time,
      checkout_time: attendance.checkout_time,
      status: 'CheckedOut',
    });
  } catch (error) {
    console.error('Checkout error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /profile/api/v1/attendance/my-attendance
router.get('/my-attendance', authMiddleware, async (req, res) => {
  try {
    const records = await Attendance.find({ user_id: req.user._id }).sort({ checkin_time: -1 });
    const results = records.map((a) => ({
      id: a._id,
      gym_id: a.gym_id,
      branch_id: a.branch_id,
      checkin_time: a.checkin_time,
      checkout_time: a.checkout_time || null,
      status: a.status || 'CheckedOut',
    }));

    return res.status(200).json(results);
  } catch (error) {
    console.error('My attendance error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
