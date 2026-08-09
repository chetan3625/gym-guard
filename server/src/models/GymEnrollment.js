const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// A membership is a paid plan. An enrollment records the relationship even
// while a person is still trying the gym or has not chosen a plan yet.
const gymEnrollmentSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  gym_id: { type: String, required: true, index: true },
  branch_id: { type: String, required: true, index: true },
  user_id: { type: String, required: true, index: true },
  source: { type: String, default: 'qr' },
  trial_started_at: { type: Date, default: Date.now },
  trial_ends_at: { type: Date, required: true },
  status: { type: String, enum: ['trial', 'active', 'expired'], default: 'trial' },
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

gymEnrollmentSchema.index({ gym_id: 1, user_id: 1 }, { unique: true });

module.exports = mongoose.model('GymEnrollment', gymEnrollmentSchema);
