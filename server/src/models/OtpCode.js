const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const otpCodeSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  phone: { type: String, required: true, index: true },
  code: { type: String, required: true },
  reset_token: { type: String, default: null },
  is_verified: { type: Boolean, default: false },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

module.exports = mongoose.model('OtpCode', otpCodeSchema);
