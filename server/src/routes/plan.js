const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { Plan } = require('../models');

// POST /gym-branch/api/v1/plan/create-plan
router.post('/create-plan', authMiddleware, async (req, res) => {
  try {
    const { gym_id, branch_id, name, description, duration_days, base_price, is_active } = req.body;
    if (!gym_id || !branch_id || !name || duration_days === undefined || base_price === undefined) {
      return res.status(400).json({ detail: 'gym_id, branch_id, name, duration_days, and base_price are required' });
    }

    const plan = await Plan.create({
      gym_id,
      branch_id,
      name: name.trim(),
      description: description || '',
      duration_days,
      base_price,
      is_active: is_active !== undefined ? Boolean(is_active) : true,
    });

    return res.status(201).json({
      id: plan._id,
      gym_id,
      branch_id,
      name: plan.name,
      description: plan.description,
      duration_days: Number(plan.duration_days),
      base_price: Number(plan.base_price),
      is_active: Boolean(plan.is_active),
    });
  } catch (error) {
    console.error('Create plan error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/plan/get-all-plans/:gym_id
router.get('/get-all-plans/:gym_id', authMiddleware, async (req, res) => {
  try {
    const { gym_id } = req.params;
    const { branch_id } = req.query;

    const filter = { gym_id };
    if (branch_id) filter.branch_id = branch_id;

    const plans = await Plan.find(filter);
    const results = plans.map((p) => ({
      id: p._id,
      gym_id: p.gym_id,
      branch_id: p.branch_id,
      name: p.name,
      description: p.description || '',
      duration_days: p.duration_days,
      base_price: p.base_price,
      is_active: Boolean(p.is_active),
    }));

    return res.status(200).json(results);
  } catch (error) {
    console.error('Get all plans error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /gym-branch/api/v1/plan/get-plan-details/:plan_id
router.get('/get-plan-details/:plan_id', authMiddleware, async (req, res) => {
  try {
    const plan = await Plan.findById(req.params.plan_id);
    if (!plan) {
      return res.status(404).json({ detail: 'Plan not found' });
    }

    return res.status(200).json({
      id: plan._id,
      gym_id: plan.gym_id,
      branch_id: plan.branch_id,
      name: plan.name,
      description: plan.description || '',
      duration_days: plan.duration_days,
      base_price: plan.base_price,
      is_active: Boolean(plan.is_active),
    });
  } catch (error) {
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// PATCH /gym-branch/api/v1/plan/update-plans/:plan_id
router.patch('/update-plans/:plan_id', authMiddleware, async (req, res) => {
  try {
    const { plan_id } = req.params;
    const { name, description, duration_days, base_price, is_active } = req.body;

    const plan = await Plan.findById(plan_id);
    if (!plan) {
      return res.status(404).json({ detail: 'Plan not found' });
    }

    if (name) plan.name = name.trim();
    if (description !== undefined) plan.description = description;
    if (duration_days !== undefined) plan.duration_days = duration_days;
    if (base_price !== undefined) plan.base_price = base_price;
    if (is_active !== undefined) plan.is_active = Boolean(is_active);

    await plan.save();

    return res.status(200).json({
      id: plan._id,
      gym_id: plan.gym_id,
      branch_id: plan.branch_id,
      name: plan.name,
      description: plan.description,
      duration_days: Number(plan.duration_days),
      base_price: Number(plan.base_price),
      is_active: Boolean(plan.is_active),
    });
  } catch (error) {
    console.error('Update plan error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
