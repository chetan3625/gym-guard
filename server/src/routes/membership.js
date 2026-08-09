const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { Membership, Plan } = require('../models');

// POST /profile/api/v1/membership/enrolled-plan
router.post('/enrolled-plan', authMiddleware, async (req, res) => {
  try {
    const { user_id, plan_id } = req.body;
    const targetUserId = user_id || req.user._id;

    const filter = { user_id: targetUserId };
    if (plan_id) filter.plan_id = plan_id;

    let membership = await Membership.findOne(filter).sort({ created_at: -1 });
    if (!membership) {
      membership = await Membership.findOne({ user_id: req.user._id }).sort({ created_at: -1 });
    }

    if (!membership) {
      return res.status(404).json({ detail: 'No active plan enrollment found for member' });
    }

    const plan = await Plan.findById(membership.plan_id);
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
