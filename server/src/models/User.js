const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const userSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  name: { type: String, required: true },
  phone: { type: String, required: true, unique: true, index: true },
  password_hash: { type: String, required: true },
  role: { type: String, default: 'gym_member' },
  dob: { type: String, default: null },
  gender: { type: String, default: null },
  height_cm: { type: Number, default: null },
  weight_kg: { type: Number, default: null },
  avatar_url: { type: String, default: null },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

userSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema);
