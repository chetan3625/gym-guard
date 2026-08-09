const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const gymSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  owner_id: { type: String, required: true, index: true },
  name: { type: String, required: true },
  email: { type: String, required: true },
  description: { type: String, default: 'Premium Strength and Conditioning Gym' },
  logo_url: { type: String, default: null },
  trial_days: { type: Number, default: 7, min: 0 },
  qr_code: { type: String, default: () => uuidv4().replace(/-/g, '') },
  is_active: { type: Boolean, default: true },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

gymSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    ret.gym_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Gym', gymSchema);
