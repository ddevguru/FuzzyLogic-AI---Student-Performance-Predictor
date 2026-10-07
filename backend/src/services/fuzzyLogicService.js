/**
 * Mamdani Fuzzy Inference Engine for Student Performance Prediction
 */

// 1. Membership Functions

/**
 * Triangular Membership Function
 * @param {number} x - Crisp value
 * @param {number} a - Left point
 * @param {number} b - Peak point
 * @param {number} c - Right point
 */
function triangularMembership(x, a, b, c) {
  if (x <= a || x >= c) return 0;
  if (x === b) return 1;
  if (x < b) return (x - a) / (b - a);
  return (c - x) / (c - b);
}

/**
 * Trapezoidal Membership Function
 * @param {number} x - Crisp value
 * @param {number} a - Left point
 * @param {number} b - Left plateau point
 * @param {number} c - Right plateau point
 * @param {number} d - Right point
 */
function trapezoidalMembership(x, a, b, c, d) {
  if (x <= a || x >= d) return 0;
  if (x >= b && x <= c) return 1;
  if (x < b) return (x - a) / (b - a);
  return (d - x) / (d - c);
}

// 2. Input Fuzzification Functions

function fuzzifyAttendance(val) {
  return {
    low: trapezoidalMembership(val, -10, 0, 25, 45),
    medium: triangularMembership(val, 30, 52.5, 75),
    high: trapezoidalMembership(val, 65, 85, 100, 110),
  };
}

function fuzzifyTestScore(val) {
  return {
    low: trapezoidalMembership(val, -10, 0, 25, 45),
    medium: triangularMembership(val, 30, 52.5, 75),
    high: trapezoidalMembership(val, 65, 85, 100, 110),
  };
}

function fuzzifyAssignmentScore(val) {
  return {
    poor: trapezoidalMembership(val, -10, 0, 25, 45),
    average: triangularMembership(val, 30, 52.5, 75),
    good: trapezoidalMembership(val, 65, 85, 100, 110),
  };
}

function fuzzifyStudyHours(val) {
  return {
    low: trapezoidalMembership(val, -2, 0, 1.5, 3.5),
    medium: triangularMembership(val, 2, 4.5, 7),
    high: trapezoidalMembership(val, 5.5, 8.5, 12, 14),
  };
}

// 3. Output Fuzzy Sets Definition
const outputSets = {
  POOR: (x) => trapezoidalMembership(x, -10, 0, 20, 40),
  AVERAGE: (x) => triangularMembership(x, 35, 50, 65),
  GOOD: (x) => triangularMembership(x, 60, 67.5, 77.5),
  VERY_GOOD: (x) => triangularMembership(x, 75, 82.5, 90),
  EXCELLENT: (x) => trapezoidalMembership(x, 87.5, 95, 100, 110),
};

// 4. Fuzzy Rules Definition (20 Rules)
const rulesDefinition = [
  {
    id: 'R1',
    text: 'IF Attendance IS Low AND Test IS Low AND Assignment IS Poor AND Study IS Low THEN Performance IS Poor',
    output: 'POOR',
    eval: (att, tst, asg, std) => Math.min(att.low, tst.low, asg.poor, std.low),
  },
  {
    id: 'R2',
    text: 'IF Attendance IS High AND Test IS High AND Assignment IS Good AND Study IS High THEN Performance IS Excellent',
    output: 'EXCELLENT',
    eval: (att, tst, asg, std) => Math.min(att.high, tst.high, asg.good, std.high),
  },
  {
    id: 'R3',
    text: 'IF Attendance IS High AND Test IS Medium THEN Performance IS Good',
    output: 'GOOD',
    eval: (att, tst, asg, std) => Math.min(att.high, tst.medium),
  },
  {
    id: 'R4',
    text: 'IF Attendance IS Low AND Test IS Low THEN Performance IS Poor',
    output: 'POOR',
    eval: (att, tst, asg, std) => Math.min(att.low, tst.low),
  },
  {
    id: 'R5',
    text: 'IF Attendance IS Medium AND Test IS Medium AND Assignment IS Average THEN Performance IS Average',
    output: 'AVERAGE',
    eval: (att, tst, asg, std) => Math.min(att.medium, tst.medium, asg.average),
  },
  {
    id: 'R6',
    text: 'IF Attendance IS High AND Test IS Medium AND Study IS High THEN Performance IS Very Good',
    output: 'VERY_GOOD',
    eval: (att, tst, asg, std) => Math.min(att.high, tst.medium, std.high),
  },
  {
    id: 'R7',
    text: 'IF Test IS High AND Assignment IS Good THEN Performance IS Very Good',
    output: 'VERY_GOOD',
    eval: (att, tst, asg, std) => Math.min(tst.high, asg.good),
  },
  {
    id: 'R8',
    text: 'IF Study IS Low AND Test IS Low THEN Performance IS Poor',
    output: 'POOR',
    eval: (att, tst, asg, std) => Math.min(std.low, tst.low),
  },
  {
    id: 'R9',
    text: 'IF Attendance IS Low AND Study IS High AND Test IS Medium THEN Performance IS Average',
    output: 'AVERAGE',
    eval: (att, tst, asg, std) => Math.min(att.low, std.high, tst.medium),
  },
  {
    id: 'R10',
    text: 'IF Attendance IS High AND Assignment IS Good AND Test IS High THEN Performance IS Excellent',
    output: 'EXCELLENT',
    eval: (att, tst, asg, std) => Math.min(att.high, asg.good, tst.high),
  },
  {
    id: 'R11',
    text: 'IF Attendance IS Medium AND Test IS High AND Assignment IS Good THEN Performance IS Very Good',
    output: 'VERY_GOOD',
    eval: (att, tst, asg, std) => Math.min(att.medium, tst.high, asg.good),
  },
  {
    id: 'R12',
    text: 'IF Test IS Low AND Assignment IS Poor THEN Performance IS Poor',
    output: 'POOR',
    eval: (att, tst, asg, std) => Math.min(tst.low, asg.poor),
  },
  {
    id: 'R13',
    text: 'IF Study IS High AND Test IS High THEN Performance IS Excellent',
    output: 'EXCELLENT',
    eval: (att, tst, asg, std) => Math.min(std.high, tst.high),
  },
  {
    id: 'R14',
    text: 'IF Attendance IS High AND Study IS Medium AND Test IS Medium THEN Performance IS Good',
    output: 'GOOD',
    eval: (att, tst, asg, std) => Math.min(att.high, std.medium, tst.medium),
  },
  {
    id: 'R15',
    text: 'IF Assignment IS Average AND Test IS Medium THEN Performance IS Average',
    output: 'AVERAGE',
    eval: (att, tst, asg, std) => Math.min(asg.average, tst.medium),
  },
  {
    id: 'R16',
    text: 'IF Attendance IS Low AND Test IS High THEN Performance IS Average',
    output: 'AVERAGE',
    eval: (att, tst, asg, std) => Math.min(att.low, tst.high),
  },
  {
    id: 'R17',
    text: 'IF Test IS High AND Study IS Low THEN Performance IS Good',
    output: 'GOOD',
    eval: (att, tst, asg, std) => Math.min(tst.high, std.low),
  },
  {
    id: 'R18',
    text: 'IF Attendance IS High AND Test IS Low THEN Performance IS Average',
    output: 'AVERAGE',
    eval: (att, tst, asg, std) => Math.min(att.high, tst.low),
  },
  {
    id: 'R19',
    text: 'IF Assignment IS Good AND Study IS High AND Test IS Medium THEN Performance IS Very Good',
    output: 'VERY_GOOD',
    eval: (att, tst, asg, std) => Math.min(asg.good, std.high, tst.medium),
  },
  {
    id: 'R20',
    text: 'IF Attendance IS Medium AND Test IS Low AND Study IS Low THEN Performance IS Poor',
    output: 'POOR',
    eval: (att, tst, asg, std) => Math.min(att.medium, tst.low, std.low),
  },
];

/**
 * Centroid Defuzzification Method
 * Formula: Performance Score = Σ(x * μ_agg(x)) / Σ(μ_agg(x))
 * @param {Object} aggregated - Aggregated degrees per category
 */
function defuzzifyCentroid(aggregated) {
  let numerator = 0;
  let denominator = 0;
  const step = 0.5;

  for (let x = 0; x <= 100; x += step) {
    // Aggregated membership value at point x
    const muPoor = Math.min(aggregated.POOR, outputSets.POOR(x));
    const muAvg = Math.min(aggregated.AVERAGE, outputSets.AVERAGE(x));
    const muGood = Math.min(aggregated.GOOD, outputSets.GOOD(x));
    const muVeryGood = Math.min(aggregated.VERY_GOOD, outputSets.VERY_GOOD(x));
    const muExcellent = Math.min(aggregated.EXCELLENT, outputSets.EXCELLENT(x));

    const muAgg = Math.max(muPoor, muAvg, muGood, muVeryGood, muExcellent);

    numerator += x * muAgg;
    denominator += muAgg;
  }

  if (denominator === 0) {
    // Fallback if no rules fired strongly
    return 50.0;
  }

  const result = numerator / denominator;
  return Number(result.toFixed(2));
}

/**
 * Classify Performance Level based on score
 * @param {number} score
 */
function classifyPerformanceLevel(score) {
  if (score < 40) return 'Poor';
  if (score < 60) return 'Average';
  if (score < 75) return 'Good';
  if (score < 90) return 'Very Good';
  return 'Excellent';
}

/**
 * Classify Academic Risk Level based on score
 * @param {number} score
 */
function classifyRiskLevel(score) {
  if (score < 40) return 'High Risk';
  if (score < 60) return 'Moderate Risk';
  if (score < 75) return 'Low Risk';
  return 'Very Low Risk';
}

/**
 * Execute Complete Fuzzy Logic Prediction Pipeline
 * @param {Object} inputs - { attendance, testScore, assignmentScore, studyHours }
 */
function processFuzzyPrediction(inputs) {
  const attendance = Number(inputs.attendance);
  const testScore = Number(inputs.testScore);
  const assignmentScore = Number(inputs.assignmentScore);
  const studyHours = Number(inputs.studyHours);

  // 1. Fuzzification
  const attFuzzy = fuzzifyAttendance(attendance);
  const testFuzzy = fuzzifyTestScore(testScore);
  const asgFuzzy = fuzzifyAssignmentScore(assignmentScore);
  const stdFuzzy = fuzzifyStudyHours(studyHours);

  // 2. Rule Evaluation
  const ruleResults = [];
  const aggregated = {
    POOR: 0,
    AVERAGE: 0,
    GOOD: 0,
    VERY_GOOD: 0,
    EXCELLENT: 0,
  };

  rulesDefinition.forEach((r) => {
    const strength = Number(r.eval(attFuzzy, testFuzzy, asgFuzzy, stdFuzzy).toFixed(4));
    ruleResults.push({
      rule: r.id,
      text: r.text,
      strength: strength,
      output: r.output,
    });

    // Rule Aggregation (MAX)
    if (strength > aggregated[r.output]) {
      aggregated[r.output] = strength;
    }
  });

  // 3. Defuzzification (Centroid)
  const defuzzifiedScore = defuzzifyCentroid(aggregated);

  // 4. Classifications
  const performanceLevel = classifyPerformanceLevel(defuzzifiedScore);
  const riskLevel = classifyRiskLevel(defuzzifiedScore);

  return {
    inputs: {
      attendance,
      testScore,
      assignmentScore,
      studyHours,
    },
    fuzzification: {
      attendance: attFuzzy,
      testScore: testFuzzy,
      assignmentScore: asgFuzzy,
      studyHours: stdFuzzy,
    },
    ruleResults: ruleResults.sort((a, b) => b.strength - a.strength),
    aggregated,
    performanceScore: defuzzifiedScore,
    performanceLevel,
    riskLevel,
  };
}

module.exports = {
  triangularMembership,
  trapezoidalMembership,
  fuzzifyAttendance,
  fuzzifyTestScore,
  fuzzifyAssignmentScore,
  fuzzifyStudyHours,
  processFuzzyPrediction,
  classifyPerformanceLevel,
  classifyRiskLevel,
};
