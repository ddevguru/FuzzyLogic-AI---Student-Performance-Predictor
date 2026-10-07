const { processFuzzyPrediction } = require('../services/fuzzyLogicService');
const { generateRecommendations } = require('../utils/recommendationEngine');
const dbStore = require('../services/dbStore');

const createPrediction = async (req, res, next) => {
  try {
    const { attendance, testScore, assignmentScore, studyHours } = req.body;

    // Input validation
    if (
      attendance === undefined ||
      testScore === undefined ||
      assignmentScore === undefined ||
      studyHours === undefined
    ) {
      return res.status(400).json({
        success: false,
        message: 'Please provide attendance, testScore, assignmentScore, and studyHours.',
      });
    }

    const att = Number(attendance);
    const tst = Number(testScore);
    const asg = Number(assignmentScore);
    const std = Number(studyHours);

    if (att < 0 || att > 100 || tst < 0 || tst > 100 || asg < 0 || asg > 100 || std < 0 || std > 24) {
      return res.status(400).json({
        success: false,
        message: 'Invalid input range. Attendance, Test, Assignment: 0-100. Study Hours: 0-24.',
      });
    }

    const inputs = { attendance: att, testScore: tst, assignmentScore: asg, studyHours: std };

    // 1. Run Fuzzy Logic Pipeline
    const fuzzyResult = processFuzzyPrediction(inputs);

    // 2. Generate Recommendations
    const recommendations = generateRecommendations(
      inputs,
      fuzzyResult.performanceScore,
      fuzzyResult.riskLevel
    );

    // 3. Save Prediction Record in DB
    const savedRecord = await dbStore.savePrediction({
      studentId: req.user.id,
      inputs,
      fuzzyResult,
    });

    res.status(201).json({
      success: true,
      predictionId: savedRecord.id,
      prediction: {
        performanceScore: fuzzyResult.performanceScore,
        performanceLevel: fuzzyResult.performanceLevel,
        riskLevel: fuzzyResult.riskLevel,
        createdAt: savedRecord.created_at,
      },
      inputs: fuzzyResult.inputs,
      fuzzification: fuzzyResult.fuzzification,
      rules: fuzzyResult.ruleResults,
      aggregated: fuzzyResult.aggregated,
      recommendations,
    });
  } catch (err) {
    next(err);
  }
};

const getPredictions = async (req, res, next) => {
  try {
    const { level } = req.query;
    const predictions = await dbStore.getPredictionsByStudent(req.user.id, level || 'All');

    res.json({
      success: true,
      count: predictions.length,
      predictions,
    });
  } catch (err) {
    next(err);
  }
};

const getPredictionById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const predictionRecord = await dbStore.getPredictionById(id);

    if (!predictionRecord) {
      return res.status(404).json({
        success: false,
        message: 'Prediction record not found.',
      });
    }

    const inputs = {
      attendance: Number(predictionRecord.attendance),
      testScore: Number(predictionRecord.test_score),
      assignmentScore: Number(predictionRecord.assignment_score),
      studyHours: Number(predictionRecord.study_hours),
    };

    const fuzzyResult = processFuzzyPrediction(inputs);
    const recommendations = generateRecommendations(
      inputs,
      Number(predictionRecord.performance_score),
      predictionRecord.risk_level
    );

    res.json({
      success: true,
      predictionRecord,
      fuzzification: fuzzyResult.fuzzification,
      rules: fuzzyResult.ruleResults,
      aggregated: fuzzyResult.aggregated,
      recommendations,
    });
  } catch (err) {
    next(err);
  }
};

const getDashboardAnalytics = async (req, res, next) => {
  try {
    const analytics = await dbStore.getDashboardData(req.user.id);
    res.json({
      success: true,
      dashboard: analytics,
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  createPrediction,
  getPredictions,
  getPredictionById,
  getDashboardAnalytics,
};
