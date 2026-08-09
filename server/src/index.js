const express = require('express');
const cors = require('cors');
const path = require('path');
const config = require('./config');

const authRoutes = require('./routes/auth');
const gymRoutes = require('./routes/gym');
const planRoutes = require('./routes/plan');
const memberProfileRoutes = require('./routes/memberProfile');
const attendanceRoutes = require('./routes/attendance');
const membershipRoutes = require('./routes/membership');
const workoutRoutes = require('./routes/workout');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static media files
app.use('/media', express.static(config.uploadsDir));
app.use('/assets', express.static(config.uploadsDir));

// Root Health Check Route
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    app: 'Azanto Gym Node.js Express API Server',
    version: '1.0.0',
  });
});

// Register API Routes
app.use('/auth/api/v1', authRoutes);
app.use('/gym-branch/api/v1', gymRoutes);
app.use('/gym-branch/api/v1/plan', planRoutes);
app.use('/profile/api/v1/member', memberProfileRoutes);
app.use('/profile/api/v1/attendance', attendanceRoutes);
app.use('/profile/api/v1/membership', membershipRoutes);
app.use('/profile/api/v1/workout', workoutRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  res.status(err.status || 500).json({
    message: err.message || 'Internal Server Error',
    detail: err.stack,
  });
});

// Start Listening
app.listen(config.port, config.host, () => {
  console.log(`Azanto Gym Node.js Server running on http://${config.host}:${config.port}`);
});
