const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const {
  WorkoutCategory,
  WorkoutBodyPart,
  WorkoutExercise,
  WorkoutTracking,
} = require('../models');

// GET /profile/api/v1/workout/get-categories
router.get('/get-categories', authMiddleware, async (req, res) => {
  try {
    let categories = await WorkoutCategory.find();
    if (!categories || categories.length === 0) {
      const defaultCats = [
        { name: 'Upper Body Focus', description: 'Chest, shoulders, arms and upper back exercises' },
        { name: 'Lower Body Focus', description: 'Quads, hamstrings, calves and glutes exercises' },
        { name: 'Core & Cardio', description: 'Abs, endurance and aerobic cardiovascular training' },
      ];
      categories = await WorkoutCategory.insertMany(defaultCats);
    }

    const results = categories.map((c) => ({
      category_id: c._id,
      name: c.name,
      description: c.description || '',
    }));

    return res.status(200).json(results);
  } catch (error) {
    console.error('Get categories error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /profile/api/v1/workout/create-categories
router.post('/create-categories', authMiddleware, async (req, res) => {
  try {
    const { name, description } = req.body;
    if (!name) {
      return res.status(400).json({ detail: 'Category name is required' });
    }

    const cat = await WorkoutCategory.create({
      name: name.trim(),
      description: (description || '').trim(),
    });

    return res.status(201).json({
      category_id: cat._id,
      name: cat.name,
      description: cat.description,
    });
  } catch (error) {
    console.error('Create category error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /profile/api/v1/workout/categories/:category_id/body-parts
router.get('/categories/:category_id/body-parts', authMiddleware, async (req, res) => {
  try {
    const { category_id } = req.params;
    let parts = await WorkoutBodyPart.find({ category_id });

    if (!parts || parts.length === 0) {
      const category = await WorkoutCategory.findById(category_id);
      const names = category && category.name.includes('Upper')
        ? ['Chest', 'Shoulders', 'Biceps', 'Triceps']
        : ['Legs', 'Abs', 'Back'];

      const docs = names.map((n) => ({ category_id, name: n }));
      parts = await WorkoutBodyPart.insertMany(docs);
    }

    const results = parts.map((p) => ({
      body_part_id: p._id,
      name: p.name,
      category_id: p.category_id,
    }));

    return res.status(200).json(results);
  } catch (error) {
    console.error('Get body parts error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /profile/api/v1/workout/create-body-part
router.post('/create-body-part', authMiddleware, async (req, res) => {
  try {
    const { name, category_id } = req.body;
    if (!name || !category_id) {
      return res.status(400).json({ detail: 'name and category_id are required' });
    }

    const bp = await WorkoutBodyPart.create({
      category_id: category_id.trim(),
      name: name.trim(),
    });

    return res.status(201).json({
      body_part_id: bp._id,
      name: bp.name,
      category_id: bp.category_id,
    });
  } catch (error) {
    console.error('Create body part error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /profile/api/v1/workout/body-parts/:body_part_id/exercises
router.get('/body-parts/:body_part_id/exercises', authMiddleware, async (req, res) => {
  try {
    const { body_part_id } = req.params;
    let exercises = await WorkoutExercise.find({ body_part_id });

    if (!exercises || exercises.length === 0) {
      const bp = await WorkoutBodyPart.findById(body_part_id);
      const bpName = bp ? bp.name : 'Default';
      const defaultExs = [
        { body_part_id, name: `Standard ${bpName} Press`, description: 'Lower bar to target area and push vertically', default_sets: 3, default_reps: 10 },
        { body_part_id, name: `Incline ${bpName} Flyes`, description: 'Maintain slight elbow bend and squeeze at top', default_sets: 3, default_reps: 12 },
      ];
      exercises = await WorkoutExercise.insertMany(defaultExs);
    }

    const results = exercises.map((e) => ({
      exercise_id: e._id,
      name: e.name,
      body_part_id: e.body_part_id,
      description: e.description || '',
      media_url: e.media_url || '',
      default_sets: e.default_sets || 3,
      default_reps: e.default_reps || 10,
    }));

    return res.status(200).json(results);
  } catch (error) {
    console.error('Get exercises error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /profile/api/v1/workout/create-exercise
router.post('/create-exercise', authMiddleware, async (req, res) => {
  try {
    const { name, body_part_id, description, media_url, default_sets, default_reps } = req.body;
    if (!name || !body_part_id) {
      return res.status(400).json({ detail: 'name and body_part_id are required' });
    }

    const ex = await WorkoutExercise.create({
      body_part_id: body_part_id.trim(),
      name: name.trim(),
      description: (description || '').trim(),
      media_url: (media_url || '').trim(),
      default_sets: default_sets || 3,
      default_reps: default_reps || 10,
    });

    return res.status(201).json({
      exercise_id: ex._id,
      name: ex.name,
      body_part_id: ex.body_part_id,
      description: ex.description || '',
      media_url: ex.media_url || '',
      default_sets: ex.default_sets,
      default_reps: ex.default_reps,
    });
  } catch (error) {
    console.error('Create exercise error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// POST /profile/api/v1/workout/track-exercise
router.post('/track-exercise', authMiddleware, async (req, res) => {
  try {
    const { exercise_id, sets_completed, reps_completed } = req.body;
    if (!exercise_id || sets_completed === undefined || !reps_completed) {
      return res.status(400).json({ detail: 'exercise_id, sets_completed, and reps_completed are required' });
    }

    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const logId = `log_${dateStr}`;

    const tracking = await WorkoutTracking.create({
      log_id: logId,
      user_id: req.user._id,
      exercise_id: exercise_id.trim(),
      sets_completed,
      reps_completed: reps_completed.trim(),
      is_completed: false,
    });

    return res.status(200).json({
      tracking_id: tracking._id,
      log_id: logId,
      exercise_id: exercise_id.trim(),
      sets_completed: Number(sets_completed),
      reps_completed: reps_completed.trim(),
      is_completed: false,
      completed_at: null,
    });
  } catch (error) {
    console.error('Track exercise error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// PATCH /profile/api/v1/workout/complete-exercise/:tracking_id
router.patch('/complete-exercise/:tracking_id', authMiddleware, async (req, res) => {
  try {
    const { tracking_id } = req.params;
    const { is_completed } = req.body;

    const tracking = await WorkoutTracking.findById(tracking_id);
    if (!tracking) {
      return res.status(404).json({ detail: 'Tracking record not found' });
    }

    const completed = is_completed !== undefined ? Boolean(is_completed) : true;
    tracking.is_completed = completed;
    tracking.completed_at = completed ? new Date() : null;
    await tracking.save();

    const allLogs = await WorkoutTracking.find({ log_id: tracking.log_id });

    const exercises = allLogs.map((item) => ({
      tracking_id: item._id,
      exercise_id: item.exercise_id,
      sets_completed: item.sets_completed,
      reps_completed: item.reps_completed,
      is_completed: Boolean(item.is_completed),
      completed_at: item.completed_at || null,
    }));

    return res.status(200).json({
      log_id: tracking.log_id,
      exercises,
    });
  } catch (error) {
    console.error('Complete exercise error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

// GET /profile/api/v1/workout/logs/:log_id/history
router.get('/logs/:log_id/history', authMiddleware, async (req, res) => {
  try {
    const { log_id } = req.params;
    const allLogs = await WorkoutTracking.find({ log_id });

    const exercises = allLogs.map((item) => ({
      tracking_id: item._id,
      exercise_id: item.exercise_id,
      sets_completed: item.sets_completed,
      reps_completed: item.reps_completed,
      is_completed: Boolean(item.is_completed),
      completed_at: item.completed_at || null,
    }));

    return res.status(200).json({
      log_id,
      exercises,
    });
  } catch (error) {
    console.error('Log history error:', error);
    return res.status(500).json({ detail: 'Internal server error' });
  }
});

module.exports = router;
