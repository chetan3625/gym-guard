const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { dbGet } = require('../database/db');

// POST /profile/api/v1/membership/enrolled-plan
router.post('/enrolled-plan', authMiddleware, async (req, res) => {
  try {
    const { user_id, plan_id } = req.body;
    const targetUserId = user_id || req.user.id;

    let sql = 'SELECT * FROM memberships WHERE user_id = ?';
    const params = [targetUserId];

    if (plan_id) {
      sql += ' AND plan_id = ?';
      params.push(plan_id);
    }
    sql += ' ORDER BY created_at DESC LIMIT 1';

    let membership = await dbGet(sql, params);
    if (!membership) {
      membership = await dbGet('SELECT * FROM memberships WHERE user_id = ? ORDER BY created_at DESC LIMIT 1', [req.user.id]);
    }

    if (!membership) {
      return res.status(404).json({ detail: 'No active plan enrollment found for member' });
    }

    const plan = await dbGet('SELECT * FROM plans WHERE id = ?', [membership.plan_id]);
    const planName = plan ? plan.name : 'Membership Plan';

    let expiresOn = membership.end_date || null;
    if (!expiresOn && membership.start_date && plan) {
      const start = new Date(membership.start_date);
      start.setDate(start.getDate() + (plan.duration_days || 30));
      expiresOn = start.toISOString();
    }

    return res.status(200).json({
      plan_name: planName,
      status: membership.status || 'Active',
      expires_on: expiresOn,
    });
  } catch (error) {
    console.error('Enrolled plan error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
