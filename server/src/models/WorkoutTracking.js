const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const workoutTrackingSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  log_id: { type: String, required: true, index: true },
  user_id: { type: String, required: true, index: true },
  exercise_id: { type: String, required: true, index: true },
  sets_completed: { type: Number, default: 0 },
  reps_completed: { type: String, default: '' },
  is_completed: { type: Boolean, default: false },
  completed_at: { type: Date, default: null },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

workoutTrackingSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.tracking_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('WorkoutTracking', workoutTrackingSchema);
