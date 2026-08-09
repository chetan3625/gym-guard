const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const authMiddleware = require('../middleware/auth');
const { dbGet, dbAll, dbRun } = require('../database/db');

// POST /profile/api/v1/attendance/checkin
router.post('/checkin', authMiddleware, async (req, res) => {
  try {
    const { gym_id, branch_id } = req.body;
    if (!gym_id || !branch_id) {
      return res.status(400).json({ detail: 'gym_id and branch_id are required' });
    }

    const attendanceId = uuidv4();
    const checkinTime = new Date().toISOString();

    await dbRun(
      'INSERT INTO attendances (id, user_id, gym_id, branch_id, checkin_time, status) VALUES (?, ?, ?, ?, ?, ?)',
      [attendanceId, req.user.id, gym_id, branch_id, checkinTime, 'CheckedIn']
    );

    return res.status(200).json({
      id: attendanceId,
      gym_id,
      branch_id,
      checkin_time: checkinTime,
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

    const checkoutTime = new Date().toISOString();

    const attendance = await dbGet(
      `SELECT * FROM attendances WHERE user_id = ? AND gym_id = ? AND branch_id = ? AND status = 'CheckedIn'
       ORDER BY checkin_time DESC LIMIT 1`,
      [req.user.id, gym_id, branch_id]
    );

    let attendanceId;
    let checkinTime;

    if (!attendance) {
      attendanceId = uuidv4();
      checkinTime = checkoutTime;
      await dbRun(
        'INSERT INTO attendances (id, user_id, gym_id, branch_id, checkin_time, checkout_time, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [attendanceId, req.user.id, gym_id, branch_id, checkinTime, checkoutTime, 'CheckedOut']
      );
    } else {
      attendanceId = attendance.id;
      checkinTime = attendance.checkin_time;
      await dbRun(
        `UPDATE attendances SET checkout_time = ?, status = 'CheckedOut' WHERE id = ?`,
        [checkoutTime, attendanceId]
      );
    }

    return res.status(200).json({
      id: attendanceId,
      gym_id,
      branch_id,
      checkin_time: checkinTime,
      checkout_time: checkoutTime,
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
    const records = await dbAll(
      'SELECT * FROM attendances WHERE user_id = ? ORDER BY checkin_time DESC',
      [req.user.id]
    );

    const results = records.map((a) => ({
      id: a.id,
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
