const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const gymBranchSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  gym_id: { type: String, required: true, index: true },
  name: { type: String, required: true },
  address: { type: String, required: true },
  city: { type: String, required: true },
  state: { type: String, default: '' },
  country: { type: String, default: '' },
  pincode: { type: String, default: '' },
  latitude: { type: Number, default: 0.0 },
  longitude: { type: Number, default: 0.0 },
  is_active: { type: Boolean, default: true },
  opening_time: { type: String, default: '06:00:00.000Z' },
  closing_time: { type: String, default: '22:00:00.000Z' },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

gymBranchSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.branch_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('GymBranch', gymBranchSchema);
