const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const workoutBodyPartSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  category_id: { type: String, required: true, index: true },
  name: { type: String, required: true },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

workoutBodyPartSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.body_part_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('WorkoutBodyPart', workoutBodyPartSchema);
