const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

module.exports = {
  port: process.env.PORT || 8000,
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'azanto-super-secret-jwt-key-2026',
  accessTokenExpire: process.env.ACCESS_TOKEN_EXPIRE || '7d',
  refreshTokenExpire: process.env.REFRESH_TOKEN_EXPIRE || '30d',
  dbFile: path.resolve(__dirname, '../../', process.env.DATABASE_FILE || './azanto.db'),
  uploadsDir: path.resolve(__dirname, '../../uploads'),
};
