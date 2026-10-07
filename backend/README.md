# 🎓 FuzzyLogic Student Predictor - Backend API

Express.js + Node.js + PostgreSQL backend implementing Mamdani Fuzzy Inference Engine.

## Quick Start

1. Copy `.env.example` to `.env`
2. Run database seed & table initializer:
   ```bash
   npm run seed
   ```
3. Start API server:
   ```bash
   npm start
   ```

Server listens on `http://localhost:5000/api`.
Health check: `http://localhost:5000/api/health`.
