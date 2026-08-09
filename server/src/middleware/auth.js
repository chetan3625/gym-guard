const jwt = require('jsonwebtoken');
const config = require('../config');
const { dbGet } = require('../database/db');

async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ detail: 'Authorization header missing or invalid format' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json({ detail: 'Token missing' });
    }

    const decoded = jwt.verify(token, config.jwtSecret);
    const userId = decoded.sub || decoded.user_id || decoded.id;

    if (!userId) {
      return res.status(401).json({ detail: 'Invalid token payload' });
    }

    const user = await dbGet('SELECT * FROM users WHERE id = ?', [userId]);
    if (!user) {
      return res.status(401).json({ detail: 'User not found' });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ detail: 'Token has expired' });
    }
    return res.status(401).json({ detail: 'Could not validate credentials' });
  }
}

module.exports = authMiddleware;
