const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

module.exports = {
  port: process.env.PORT || 8000,
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'azanto-super-secret-jwt-key-2026',
  accessTokenExpire: process.env.ACCESS_TOKEN_EXPIRE || '7d',
  refreshTokenExpire: process.env.REFRESH_TOKEN_EXPIRE || '30d',
  mongoUri: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/gymguard',
  uploadsDir: path.resolve(__dirname, '../../uploads'),
};
