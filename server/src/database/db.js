const mongoose = require('mongoose');
const fs = require('fs');
const config = require('../config');

// Ensure uploads directory exists
if (!fs.existsSync(config.uploadsDir)) {
  fs.mkdirSync(config.uploadsDir, { recursive: true });
}

async function connectDB() {
  try {
    await mongoose.connect(config.mongoUri);
    console.log('Connected to MongoDB database successfully');
  } catch (error) {
    console.error('Error connecting to MongoDB:', error.message);
  }
}

module.exports = {
  connectDB,
  mongoose,
};
