const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const workoutExerciseSchema = new mongoose.Schema({
  _id: { type: String, default: uuidv4 },
  body_part_id: { type: String, required: true, index: true },
  name: { type: String, required: true },
  description: { type: String, default: '' },
  media_url: { type: String, default: '' },
  default_sets: { type: Number, default: 3 },
  default_reps: { type: Number, default: 10 },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

workoutExerciseSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.exercise_id = ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('WorkoutExercise', workoutExerciseSchema);
