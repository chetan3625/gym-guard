const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const authMiddleware = require('../middleware/auth');
const { dbGet, dbAll, dbRun } = require('../database/db');

// GET /profile/api/v1/workout/get-categories
router.get('/get-categories', authMiddleware, async (req, res) => {
  try {
    let categories = await dbAll('SELECT * FROM workout_categories');
    if (!categories || categories.length === 0) {
      const defaultCats = [
        ['Upper Body Focus', 'Chest, shoulders, arms and upper back exercises'],
        ['Lower Body Focus', 'Quads, hamstrings, calves and glutes exercises'],
        ['Core & Cardio', 'Abs, endurance and aerobic cardiovascular training'],
      ];
      for (const [name, desc] of defaultCats) {
        await dbRun('INSERT INTO workout_categories (id, name, description) VALUES (?, ?, ?)', [
          uuidv4(),
          name,
          desc,
        ]);
      }
      categories = await dbAll('SELECT * FROM workout_categories');
    }

    const results = categories.map((c) => ({
      category_id: c.id,
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

    const categoryId = uuidv4();
    await dbRun('INSERT INTO workout_categories (id, name, description) VALUES (?, ?, ?)', [
      categoryId,
      name.trim(),
      (description || '').trim(),
    ]);

    return res.status(201).json({
      category_id: categoryId,
      name: name.trim(),
      description: (description || '').trim(),
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
    let parts = await dbAll('SELECT * FROM workout_body_parts WHERE category_id = ?', [category_id]);

    if (!parts || parts.length === 0) {
      const category = await dbGet('SELECT * FROM workout_categories WHERE id = ?', [category_id]);
      const names = category && category.name.includes('Upper')
        ? ['Chest', 'Shoulders', 'Biceps', 'Triceps']
        : ['Legs', 'Abs', 'Back'];

      for (const name of names) {
        await dbRun('INSERT INTO workout_body_parts (id, category_id, name) VALUES (?, ?, ?)', [
          uuidv4(),
          category_id,
          name,
        ]);
      }
      parts = await dbAll('SELECT * FROM workout_body_parts WHERE category_id = ?', [category_id]);
    }

    const results = parts.map((p) => ({
      body_part_id: p.id,
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

    const bodyPartId = uuidv4();
    await dbRun('INSERT INTO workout_body_parts (id, category_id, name) VALUES (?, ?, ?)', [
      bodyPartId,
      category_id.trim(),
      name.trim(),
    ]);

    return res.status(201).json({
      body_part_id: bodyPartId,
      name: name.trim(),
      category_id: category_id.trim(),
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
    let exercises = await dbAll('SELECT * FROM workout_exercises WHERE body_part_id = ?', [body_part_id]);

    if (!exercises || exercises.length === 0) {
      const bp = await dbGet('SELECT * FROM workout_body_parts WHERE id = ?', [body_part_id]);
      const bpName = bp ? bp.name : 'Default';
      const defaultExs = [
        [`Standard ${bpName} Press`, 'Lower bar to target area and push vertically', 3, 10],
        [`Incline ${bpName} Flyes`, 'Maintain slight elbow bend and squeeze at top', 3, 12],
      ];

      for (const [name, desc, sets, reps] of defaultExs) {
        await dbRun(
          'INSERT INTO workout_exercises (id, body_part_id, name, description, default_sets, default_reps) VALUES (?, ?, ?, ?, ?, ?)',
          [uuidv4(), body_part_id, name, desc, sets, reps]
        );
      }
      exercises = await dbAll('SELECT * FROM workout_exercises WHERE body_part_id = ?', [body_part_id]);
    }

    const results = exercises.map((e) => ({
      exercise_id: e.id,
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

    const exerciseId = uuidv4();
    await dbRun(
      `INSERT INTO workout_exercises (id, body_part_id, name, description, media_url, default_sets, default_reps)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        exerciseId,
        body_part_id.trim(),
        name.trim(),
        (description || '').trim(),
        (media_url || '').trim(),
        default_sets || 3,
        default_reps || 10,
      ]
    );

    return res.status(201).json({
      exercise_id: exerciseId,
      name: name.trim(),
      body_part_id: body_part_id.trim(),
      description: (description || '').trim(),
      media_url: (media_url || '').trim(),
      default_sets: default_sets || 3,
      default_reps: default_reps || 10,
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

    const trackingId = uuidv4();
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const logId = `log_${dateStr}`;

    await dbRun(
      `INSERT INTO workout_trackings (id, log_id, user_id, exercise_id, sets_completed, reps_completed, is_completed)
       VALUES (?, ?, ?, ?, ?, ?, 0)`,
      [trackingId, logId, req.user.id, exercise_id.trim(), sets_completed, reps_completed.trim()]
    );

    return res.status(200).json({
      tracking_id: trackingId,
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

    const tracking = await dbGet('SELECT * FROM workout_trackings WHERE id = ?', [tracking_id]);
    if (!tracking) {
      return res.status(404).json({ detail: 'Tracking record not found' });
    }

    const completed = is_completed !== undefined ? (is_completed ? 1 : 0) : 1;
    const completedAt = completed ? new Date().toISOString() : null;

    await dbRun(
      'UPDATE workout_trackings SET is_completed = ?, completed_at = ? WHERE id = ?',
      [completed, completedAt, tracking_id]
    );

    const allLogs = await dbAll('SELECT * FROM workout_trackings WHERE log_id = ?', [tracking.log_id]);

    const exercises = allLogs.map((item) => ({
      tracking_id: item.id,
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
    const allLogs = await dbAll('SELECT * FROM workout_trackings WHERE log_id = ?', [log_id]);

    const exercises = allLogs.map((item) => ({
      tracking_id: item.id,
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
