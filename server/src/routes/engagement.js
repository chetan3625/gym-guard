const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const { Gym, Membership, User, Plan, Attendance, GymEnrollment, EngagementLog } = require('../models');

async function ownerGym(gymId, ownerId) {
  return Gym.findOne({ _id: gymId, owner_id: ownerId });
}

function dayDiff(date) {
  if (!date) return null;
  return Math.max(0, Math.floor((Date.now() - new Date(date).getTime()) / 86400000));
}

// Retention worklist: owners can filter inactive members, expiring plans and trials.
router.get('/gym/:gym_id/member-health', authMiddleware, async (req, res) => {
  try {
    const { gym_id } = req.params;
    const branchId = req.query.branch_id;
    const inactiveDays = Math.max(1, Number(req.query.inactive_days) || 7);
    const filter = req.query.filter || 'all';
    if (!branchId || !(await ownerGym(gym_id, req.user._id))) return res.status(403).json({ detail: 'Owner access to this gym branch is required' });

    const [memberships, enrollments, attendance] = await Promise.all([
      Membership.find({ gym_id, branch_id: branchId }).sort({ created_at: -1 }).lean(),
      GymEnrollment.find({ gym_id, branch_id: branchId }).lean(),
      Attendance.aggregate([{ $match: { gym_id, branch_id: branchId } }, { $group: { _id: '$user_id', last_checkin: { $max: '$checkin_time' }, visits: { $sum: 1 } } }]),
    ]);
    const latestMembership = new Map();
    memberships.forEach((m) => { if (!latestMembership.has(m.user_id)) latestMembership.set(m.user_id, m); });
    const latestEnrollment = new Map(enrollments.map((e) => [e.user_id, e]));
    const ids = [...new Set([...latestMembership.keys(), ...latestEnrollment.keys()])];
    const users = await User.find({ _id: { $in: ids } }).lean();
    const userMap = new Map(users.map((u) => [u._id, u]));
    const attendanceMap = new Map(attendance.map((a) => [a._id, a]));
    const plans = await Plan.find({ _id: { $in: [...latestMembership.values()].map((m) => m.plan_id) } }).lean();
    const planMap = new Map(plans.map((p) => [p._id, p]));
    const now = Date.now();
    const rows = ids.map((id) => {
      const membership = latestMembership.get(id);
      const enrollment = latestEnrollment.get(id);
      const checkin = attendanceMap.get(id);
      const lastCheckin = checkin?.last_checkin || null;
      const inactiveFor = dayDiff(lastCheckin) ?? dayDiff(enrollment?.trial_started_at || membership?.start_date) ?? 0;
      const endDate = membership?.end_date || enrollment?.trial_ends_at || null;
      const daysToEnd = endDate ? Math.ceil((new Date(endDate).getTime() - now) / 86400000) : null;
      const risk = inactiveFor >= 10 ? 'high' : inactiveFor >= inactiveDays ? 'medium' : 'healthy';
      return { member_id: id, name: userMap.get(id)?.name || 'Member', phone: userMap.get(id)?.phone || '', plan_name: planMap.get(membership?.plan_id)?.name || (enrollment ? 'Free trial' : 'No plan'), status: membership?.status || enrollment?.status || 'active', last_checkin: lastCheckin, inactive_days: inactiveFor, visits: checkin?.visits || 0, ends_on: endDate, days_to_end: daysToEnd, risk };
    }).filter((row) => filter === 'inactive' ? row.inactive_days >= inactiveDays : filter === 'red' ? row.inactive_days >= 10 : filter === 'expiring' ? row.days_to_end !== null && row.days_to_end >= 0 && row.days_to_end <= 7 : true)
      .sort((a, b) => b.inactive_days - a.inactive_days);
    return res.json({ inactive_threshold: inactiveDays, summary: { total: rows.length, red: rows.filter((r) => r.inactive_days >= 10).length, inactive: rows.filter((r) => r.inactive_days >= inactiveDays).length, expiring: rows.filter((r) => r.days_to_end !== null && r.days_to_end >= 0 && r.days_to_end <= 7).length }, members: rows });
  } catch (error) {
    console.error('Member health error:', error);
    return res.status(500).json({ detail: 'Unable to load member health' });
  }
});

// Clients open the native dialer/WhatsApp/SMS composer. This endpoint records
// owner outreach for follow-up without claiming a message was delivered.
router.post('/gym/:gym_id/member-health/:member_id/outreach', authMiddleware, async (req, res) => {
  try {
    const { channel, branch_id, message = '' } = req.body;
    if (!['call', 'sms', 'whatsapp'].includes(channel) || !branch_id) return res.status(400).json({ detail: 'A branch and valid outreach channel are required' });
    if (!(await ownerGym(req.params.gym_id, req.user._id))) return res.status(403).json({ detail: 'Owner access is required' });
    const log = await EngagementLog.create({ gym_id: req.params.gym_id, branch_id, member_id: req.params.member_id, owner_id: req.user._id, channel, message });
    return res.status(201).json({ id: log._id, delivery_status: log.delivery_status });
  } catch (error) {
    return res.status(500).json({ detail: 'Unable to record outreach' });
  }
});

module.exports = router;
