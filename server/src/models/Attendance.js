const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const attendanceSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  user_id: { type: String, required: true, index: true },
  gym_id: { type: String, required: true },
  branch_id: { type: String, required: true },
  checkin_time: { type: Date, default: Date.now },
  checkout_time: { type: Date, default: null },
  status: { type: String, default: 'CheckedIn' },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

attendanceSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Attendance', attendanceSchema);
