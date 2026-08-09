const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const workoutCategorySchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  name: { type: String, required: true },
  description: { type: String, default: '' },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

workoutCategorySchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.category_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('WorkoutCategory', workoutCategorySchema);
