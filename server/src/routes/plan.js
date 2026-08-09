const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const authMiddleware = require('../middleware/auth');
const { dbGet, dbAll, dbRun } = require('../database/db');

// POST /gym-branch/api/v1/plan/create-plan
router.post('/create-plan', authMiddleware, async (req, res) => {
  try {
    const { gym_id, branch_id, name, description, duration_days, base_price, is_active } = req.body;
    if (!gym_id || !branch_id || !name || duration_days === undefined || base_price === undefined) {
      return res.status(400).json({ detail: 'gym_id, branch_id, name, duration_days, and base_price are required' });
    }

    const planId = uuidv4();
    const active = is_active !== undefined ? (is_active ? 1 : 0) : 1;

    await dbRun(
      `INSERT INTO plans (id, gym_id, branch_id, name, description, duration_days, base_price, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [planId, gym_id, branch_id, name.trim(), description || '', duration_days, base_price, active]
    );

    return res.status(201).json({
      id: planId,
      gym_id,
      branch_id,
      name: name.trim(),
      description: description || '',
      duration_days: Number(duration_days),
      base_price: Number(base_price),
      is_active: Boolean(active),
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

    let sql = 'SELECT * FROM plans WHERE gym_id = ?';
    const params = [gym_id];

    if (branch_id) {
      sql += ' AND branch_id = ?';
      params.push(branch_id);
    }

    const plans = await dbAll(sql, params);
    const results = plans.map((p) => ({
      id: p.id,
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
    const plan = await dbGet('SELECT * FROM plans WHERE id = ?', [req.params.plan_id]);
    if (!plan) {
      return res.status(404).json({ detail: 'Plan not found' });
    }

    return res.status(200).json({
      id: plan.id,
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

    const plan = await dbGet('SELECT * FROM plans WHERE id = ?', [plan_id]);
    if (!plan) {
      return res.status(404).json({ detail: 'Plan not found' });
    }

    const updatedName = name ? name.trim() : plan.name;
    const updatedDesc = description !== undefined ? description : plan.description;
    const updatedDays = duration_days !== undefined ? duration_days : plan.duration_days;
    const updatedPrice = base_price !== undefined ? base_price : plan.base_price;
    const updatedActive = is_active !== undefined ? (is_active ? 1 : 0) : plan.is_active;

    await dbRun(
      'UPDATE plans SET name = ?, description = ?, duration_days = ?, base_price = ?, is_active = ? WHERE id = ?',
      [updatedName, updatedDesc, updatedDays, updatedPrice, updatedActive, plan_id]
    );

    return res.status(200).json({
      id: plan_id,
      gym_id: plan.gym_id,
      branch_id: plan.branch_id,
      name: updatedName,
      description: updatedDesc,
      duration_days: Number(updatedDays),
      base_price: Number(updatedPrice),
      is_active: Boolean(updatedActive),
    });
  } catch (error) {
    console.error('Update plan error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
