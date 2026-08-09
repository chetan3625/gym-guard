const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const engagementLogSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  gym_id: { type: String, required: true, index: true },
  branch_id: { type: String, required: true, index: true },
  member_id: { type: String, required: true, index: true },
  owner_id: { type: String, required: true },
  channel: { type: String, enum: ['call', 'sms', 'whatsapp'], required: true },
  message: { type: String, default: '' },
  delivery_status: { type: String, default: 'opened_in_app' },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

module.exports = mongoose.model('EngagementLog', engagementLogSchema);
