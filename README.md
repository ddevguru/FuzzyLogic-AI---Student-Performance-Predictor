# 🎓 FuzzyLogic Student Performance Predictor

[![Flutter](https://img.shields.io/badge/Flutter-3.38.3-blue.svg)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-v22.13.1-green.svg)](https://nodejs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.3-blue.svg)](https://www.postgresql.org)
[![Mamdani Fuzzy Logic](https://img.shields.io/badge/Inference-Mamdani-gold.svg)](https://en.wikipedia.org/wiki/Fuzzy_inference_system)

A modern, production-quality academic analytics application that uses a genuine **Mamdani Fuzzy Inference System** to evaluate student performance, calculate academic risk levels, identify weak areas, and generate personalized recommendations.

---

## 📌 1. Project Overview

The **FuzzyLogic Student Performance Predictor** bridges artificial intelligence and educational analytics. Rather than relying on simple linear weighted averages ($0.25 \times \text{att} + 0.35 \times \text{test} + \dots$), the application implements an authentic fuzzy logic pipeline with:
- **Overlapping Membership Functions** (Triangular & Trapezoidal)
- **20 Mamdani Fuzzy Rules** evaluated via $\text{AND} = \text{MIN}$ and $\text{OR} = \text{MAX}$
- **Aggregated Output Fuzzy Sets**
- **Centroid Defuzzification** ($\text{Score} = \frac{\sum x \cdot \mu_{agg}(x)}{\sum \mu_{agg}(x)}$)

---

## 🚀 2. System Architecture

```text
Flutter Mobile App (Material 3)
      │
      ▼ REST API (HTTP / Dio + JWT)
Node.js + Express Server
      │
      ├── Fuzzification Module
      ├── Fuzzy Rule Engine (20 Rules)
      ├── Rule Aggregator
      ├── Centroid Defuzzification Engine
      └── Dynamic Recommendation Engine
      │
      ▼ PostgreSQL Database / pg Store
 (users, student_profiles, performance_records, fuzzy_results)
```

---

## 🧮 3. Fuzzy Logic Pipeline Explanation

```text
Student Crisp Inputs (Attendance, Test, Assignment, Study Hours)
                       ↓
Fuzzification (Triangular & Trapezoidal Membership Functions)
                       ↓
Evaluated Membership Degrees (Low, Medium, High)
                       ↓
Fuzzy Rule Inference (MIN Antecedents, 20 Rules)
                       ↓
Consequent Aggregation (MAX Output Degrees)
                       ↓
Centroid Defuzzification (0–100 Score Domain)
                       ↓
Crisp Performance Score & Risk Classification
                       ↓
Dynamic Recommendation Generation
```

### 1. Fuzzification Curves
- **Attendance (%)**: Range `0–100`
  - `Low`: Trapezoidal `[0, 0, 25, 45]`
  - `Medium`: Triangular `[30, 52.5, 75]`
  - `High`: Trapezoidal `[65, 85, 100, 100]`
- **Test Score**: Range `0–100`
  - `Low`: Trapezoidal `[0, 0, 25, 45]`
  - `Medium`: Triangular `[30, 52.5, 75]`
  - `High`: Trapezoidal `[65, 85, 100, 100]`
- **Assignment Performance**: Range `0–100`
  - `Poor`: Trapezoidal `[0, 0, 25, 45]`
  - `Average`: Triangular `[30, 52.5, 75]`
  - `Good`: Trapezoidal `[65, 85, 100, 100]`
- **Study Hours**: Range `0–12 hrs/day`
  - `Low`: Trapezoidal `[0, 0, 1.5, 3.5]`
  - `Medium`: Triangular `[2, 4.5, 7]`
  - `High`: Trapezoidal `[5.5, 8.5, 12, 12]`

### 2. Output & Risk Classification
- **Performance Score Categories**:
  - `0–39`: Poor
  - `40–59`: Average
  - `60–74`: Good
  - `75–89`: Very Good
  - `90–100`: Excellent
- **Academic Risk Categories**:
  - `0–39`: High Risk
  - `40–59`: Moderate Risk
  - `60–74`: Low Risk
  - `75–100`: Very Low Risk

### 3. Centroid Defuzzification Formula
$$\text{Performance Score} = \frac{\int_{0}^{100} x \cdot \mu_{agg}(x) \, dx}{\int_{0}^{100} \mu_{agg}(x) \, dx} \approx \frac{\sum_{x=0}^{100} x \cdot \mu_{agg}(x)}{\sum_{x=0}^{100} \mu_{agg}(x)}$$

---

## 🗄️ 4. Database Schema (PostgreSQL)

```sql
-- 1. users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. student_profiles
CREATE TABLE student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    roll_number VARCHAR(50),
    course VARCHAR(100),
    semester INTEGER,
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. performance_records
CREATE TABLE performance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    attendance DECIMAL(5,2),
    test_score DECIMAL(5,2),
    assignment_score DECIMAL(5,2),
    study_hours DECIMAL(5,2),
    performance_score DECIMAL(5,2),
    performance_level VARCHAR(30),
    risk_level VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. fuzzy_results
CREATE TABLE fuzzy_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    performance_id UUID REFERENCES performance_records(id) ON DELETE CASCADE,
    attendance_low DECIMAL(5,4),
    attendance_medium DECIMAL(5,4),
    attendance_high DECIMAL(5,4),
    test_low DECIMAL(5,4),
    test_medium DECIMAL(5,4),
    test_high DECIMAL(5,4),
    assignment_low DECIMAL(5,4),
    assignment_medium DECIMAL(5,4),
    assignment_high DECIMAL(5,4),
    study_low DECIMAL(5,4),
    study_medium DECIMAL(5,4),
    study_high DECIMAL(5,4),
    defuzzified_score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📡 5. REST API Documentation

### Auth Endpoints
- `POST /api/auth/register` - Create student account & profile
- `POST /api/auth/login` - Authenticate & return JWT token
- `GET /api/auth/me` - Get current student session details

### Prediction & Analytics Endpoints
- `POST /api/predictions` - Run fuzzy logic inference on input payload
- `GET /api/predictions` - Retrieve prediction history (filterable by `level`)
- `GET /api/predictions/:id` - Fetch single prediction with full pipeline breakdown
- `GET /api/dashboard` - Get overall student analytics, distributions, and history trends

#### Sample Prediction Request:
```json
{
  "attendance": 82,
  "testScore": 76,
  "assignmentScore": 88,
  "studyHours": 5
}
```

#### Sample Response:
```json
{
  "success": true,
  "predictionId": "3a7b9c1d-...",
  "prediction": {
    "performanceScore": 88.62,
    "performanceLevel": "Very Good",
    "riskLevel": "Very Low Risk"
  },
  "fuzzification": {
    "attendance": { "low": 0, "medium": 0.0, "high": 1.0 },
    "testScore": { "low": 0, "medium": 0.0, "high": 1.0 },
    "assignmentScore": { "poor": 0, "average": 0.0, "good": 1.0 },
    "studyHours": { "low": 0, "medium": 0.57, "high": 0.0 }
  },
  "rules": [
    {
      "rule": "R7",
      "text": "IF Test IS High AND Assignment IS Good THEN Performance IS Very Good",
      "strength": 1.0,
      "output": "VERY_GOOD"
    }
  ],
  "recommendations": [...]
}
```

---

## 🛠️ 6. Installation & Execution Guide

### Prerequisites
- Node.js `v18+` or `v22+`
- PostgreSQL `14+` or `18+`
- Flutter SDK `3.19+` or `3.38+`

### Backend Setup (`backend/`)
```bash
cd backend
npm install
npm run seed     # Seeds demo data and initializes tables
npm start        # Launches API server at http://localhost:5000
```

### Flutter Setup (`flutter_app/`)
```bash
cd flutter_app
flutter pub get
flutter run      # Launches app on connected device / web
```

---

## 🧪 7. Test Cases & Verification Results

| Case | Attendance | Test Score | Assignment | Study Hours | Defuzzified Score | Level | Risk Level |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Rahul (Sample)** | 82% | 76 | 88% | 5 hrs | **88.62%** | Very Good | Very Low Risk |
| **High Risk** | 42% | 35 | 40% | 1.5 hrs | **25.49%** | Poor | High Risk |
| **Moderate Risk**| 68% | 58 | 62% | 3 hrs | **52.75%** | Average | Moderate Risk |
| **Excellent** | 95% | 92 | 94% | 7 hrs | **89.60%** | Very Good | Very Low Risk |

---

## 🔮 8. Future Enhancements
- Support Sugeno fuzzy inference model for comparison
- Parent & Academic Counselor Dashboard role-based access
- Automated weekly email notifications for students in High Risk category
- Machine Learning hybrid ANFIS (Adaptive Neuro-Fuzzy Inference System) tuning
