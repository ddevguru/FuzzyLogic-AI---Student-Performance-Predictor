const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const { initDb } = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const studentRoutes = require('./routes/studentRoutes');
const predictionRoutes = require('./routes/predictionRoutes');
const errorMiddleware = require('./middleware/errorMiddleware');

const app = express();
const PORT = process.env.PORT || 5000;

// Security & Parsing Middleware
app.use(helmet());
app.use(cors({ origin: '*', credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'FuzzyLogic Student Performance Predictor API',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/student', studentRoutes);
app.use('/api', predictionRoutes);

// Global Error Handler
app.use(errorMiddleware);

// Initialize DB and start server
initDb().then(() => {
  app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`🎓 FuzzyLogic Predictor Backend Server running on port ${PORT}`);
    console.log(`   Health Check: http://localhost:${PORT}/api/health`);
    console.log(`====================================================`);
  });
});
