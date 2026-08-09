const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const membershipSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  gym_id: { type: String, required: true, index: true },
  branch_id: { type: String, required: true, index: true },
  plan_id: { type: String, required: true, index: true },
  user_id: { type: String, required: true, index: true },
  amount: { type: Number, required: true },
  payment_mode: { type: String, default: 'cash' },
  payment_id: { type: String, default: () => `pay_${uuidv4().replace(/-/g, '').substring(0, 8)}` },
  status: { type: String, default: 'Active' },
  start_date: { type: Date, default: Date.now },
  end_date: { type: Date, default: null },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

membershipSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.membership_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Membership', membershipSchema);
