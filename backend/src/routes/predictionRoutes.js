const express = require('express');
const {
  createPrediction,
  getPredictions,
  getPredictionById,
  getDashboardAnalytics,
} = require('../controllers/predictionController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.post('/predictions', createPrediction);
router.get('/predictions', getPredictions);
router.get('/predictions/:id', getPredictionById);
router.get('/dashboard', getDashboardAnalytics);

module.exports = router;
