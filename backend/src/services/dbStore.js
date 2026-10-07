const { pool, isPgConnected, inMemoryStore } = require('../config/database');
const crypto = require('crypto');

function generateUuid() {
  return crypto.randomUUID();
}

/**
 * DB Data Access Object with automatic PG & Fallback handling
 */
const dbStore = {
  // Users
  async findUserByEmail(email) {
    if (isPgConnected()) {
      const res = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      return res.rows[0] || null;
    } else {
      return inMemoryStore.users.find((u) => u.email.toLowerCase() === email.toLowerCase()) || null;
    }
  },

  async findUserById(id) {
    if (isPgConnected()) {
      const res = await pool.query('SELECT id, name, email, role, created_at FROM users WHERE id = $1', [id]);
      return res.rows[0] || null;
    } else {
      const u = inMemoryStore.users.find((user) => user.id === id);
      if (!u) return null;
      const { password_hash, ...userWithoutPass } = u;
      return userWithoutPass;
    }
  },

  async createUser({ name, email, password_hash, role = 'student' }) {
    if (isPgConnected()) {
      const res = await pool.query(
        `INSERT INTO users (name, email, password_hash, role)
         VALUES ($1, $2, $3, $4)
         RETURNING id, name, email, role, created_at`,
        [name, email, password_hash, role]
      );
      return res.rows[0];
    } else {
      const newUser = {
        id: generateUuid(),
        name,
        email,
        password_hash,
        role,
        created_at: new Date(),
      };
      inMemoryStore.users.push(newUser);
      const { password_hash: _, ...safeUser } = newUser;
      return safeUser;
    }
  },

  // Student Profile
  async getStudentProfile(userId) {
    if (isPgConnected()) {
      const res = await pool.query(
        `SELECT sp.*, u.name, u.email, u.role
         FROM student_profiles sp
         JOIN users u ON sp.user_id = u.id
         WHERE sp.user_id = $1`,
        [userId]
      );
      return res.rows[0] || null;
    } else {
      const profile = inMemoryStore.student_profiles.find((p) => p.user_id === userId);
      const user = inMemoryStore.users.find((u) => u.id === userId);
      if (!profile) return null;
      return {
        ...profile,
        name: user ? user.name : '',
        email: user ? user.email : '',
        role: user ? user.role : 'student',
      };
    }
  },

  async upsertStudentProfile({ userId, rollNumber, course, semester, department }) {
    if (isPgConnected()) {
      const existing = await pool.query(
        'SELECT id FROM student_profiles WHERE user_id = $1',
        [userId]
      );
      if (existing.rowCount > 0) {
        const res = await pool.query(
          `UPDATE student_profiles
           SET roll_number = $1, course = $2, semester = $3, department = $4
           WHERE user_id = $5
           RETURNING *`,
          [rollNumber, course, semester, department, userId]
        );
        return res.rows[0];
      } else {
        const res = await pool.query(
          `INSERT INTO student_profiles (user_id, roll_number, course, semester, department)
           VALUES ($1, $2, $3, $4, $5)
           RETURNING *`,
          [userId, rollNumber, course, semester, department]
        );
        return res.rows[0];
      }
    } else {
      let profile = inMemoryStore.student_profiles.find((p) => p.user_id === userId);
      if (profile) {
        profile.roll_number = rollNumber;
        profile.course = course;
        profile.semester = semester;
        profile.department = department;
      } else {
        profile = {
          id: generateUuid(),
          user_id: userId,
          roll_number: rollNumber,
          course,
          semester,
          department,
          created_at: new Date(),
        };
        inMemoryStore.student_profiles.push(profile);
      }
      return profile;
    }
  },

  // Performance Records & Fuzzy Results
  async savePrediction({ studentId, inputs, fuzzyResult }) {
    const { attendance, testScore, assignmentScore, studyHours } = inputs;
    const { performanceScore, performanceLevel, riskLevel, fuzzification } = fuzzyResult;

    if (isPgConnected()) {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');

        // Insert into performance_records
        const perfRes = await client.query(
          `INSERT INTO performance_records
           (student_id, attendance, test_score, assignment_score, study_hours, performance_score, performance_level, risk_level)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
           RETURNING *`,
          [
            studentId,
            attendance,
            testScore,
            assignmentScore,
            studyHours,
            performanceScore,
            performanceLevel,
            riskLevel,
          ]
        );
        const perfRecord = perfRes.rows[0];

        // Insert into fuzzy_results
        await client.query(
          `INSERT INTO fuzzy_results
           (performance_id,
            attendance_low, attendance_medium, attendance_high,
            test_low, test_medium, test_high,
            assignment_low, assignment_medium, assignment_high,
            study_low, study_medium, study_high,
            defuzzified_score)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
          [
            perfRecord.id,
            fuzzification.attendance.low,
            fuzzification.attendance.medium,
            fuzzification.attendance.high,
            fuzzification.testScore.low,
            fuzzification.testScore.medium,
            fuzzification.testScore.high,
            fuzzification.assignmentScore.poor,
            fuzzification.assignmentScore.average,
            fuzzification.assignmentScore.good,
            fuzzification.studyHours.low,
            fuzzification.studyHours.medium,
            fuzzification.studyHours.high,
            performanceScore,
          ]
        );

        await client.query('COMMIT');
        return perfRecord;
      } catch (e) {
        await client.query('ROLLBACK');
        throw e;
      } finally {
        client.release();
      }
    } else {
      const perfRecord = {
        id: generateUuid(),
        student_id: studentId,
        attendance,
        test_score: testScore,
        assignment_score: assignmentScore,
        study_hours: studyHours,
        performance_score: performanceScore,
        performance_level: performanceLevel,
        risk_level: riskLevel,
        created_at: new Date(),
      };
      inMemoryStore.performance_records.push(perfRecord);

      const fuzzyRec = {
        id: generateUuid(),
        performance_id: perfRecord.id,
        attendance_low: fuzzification.attendance.low,
        attendance_medium: fuzzification.attendance.medium,
        attendance_high: fuzzification.attendance.high,
        test_low: fuzzification.testScore.low,
        test_medium: fuzzification.testScore.medium,
        test_high: fuzzification.testScore.high,
        assignment_low: fuzzification.assignmentScore.poor,
        assignment_medium: fuzzification.assignmentScore.average,
        assignment_high: fuzzification.assignmentScore.good,
        study_low: fuzzification.studyHours.low,
        study_medium: fuzzification.studyHours.medium,
        study_high: fuzzification.studyHours.high,
        defuzzified_score: performanceScore,
        created_at: new Date(),
      };
      inMemoryStore.fuzzy_results.push(fuzzyRec);

      return perfRecord;
    }
  },

  async getPredictionsByStudent(studentId, filterLevel = 'All') {
    if (isPgConnected()) {
      let sql = `
        SELECT pr.*, fr.attendance_low, fr.attendance_medium, fr.attendance_high,
               fr.test_low, fr.test_medium, fr.test_high,
               fr.assignment_low, fr.assignment_medium, fr.assignment_high,
               fr.study_low, fr.study_medium, fr.study_high, fr.defuzzified_score
        FROM performance_records pr
        LEFT JOIN fuzzy_results fr ON pr.id = fr.performance_id
        WHERE pr.student_id = $1
      `;
      const params = [studentId];
      if (filterLevel && filterLevel !== 'All') {
        sql += ` AND pr.performance_level = $2`;
        params.push(filterLevel);
      }
      sql += ` ORDER BY pr.created_at DESC`;

      const res = await pool.query(sql, params);
      return res.rows;
    } else {
      let records = inMemoryStore.performance_records.filter((r) => r.student_id === studentId);
      if (filterLevel && filterLevel !== 'All') {
        records = records.filter((r) => r.performance_level.toLowerCase() === filterLevel.toLowerCase());
      }
      records.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      return records.map((r) => {
        const fr = inMemoryStore.fuzzy_results.find((f) => f.performance_id === r.id) || {};
        return { ...r, ...fr };
      });
    }
  },

  async getPredictionById(id) {
    if (isPgConnected()) {
      const res = await pool.query(
        `SELECT pr.*, fr.attendance_low, fr.attendance_medium, fr.attendance_high,
                fr.test_low, fr.test_medium, fr.test_high,
                fr.assignment_low, fr.assignment_medium, fr.assignment_high,
                fr.study_low, fr.study_medium, fr.study_high, fr.defuzzified_score
         FROM performance_records pr
         LEFT JOIN fuzzy_results fr ON pr.id = fr.performance_id
         WHERE pr.id = $1`,
        [id]
      );
      return res.rows[0] || null;
    } else {
      const r = inMemoryStore.performance_records.find((rec) => rec.id === id);
      if (!r) return null;
      const fr = inMemoryStore.fuzzy_results.find((f) => f.performance_id === r.id) || {};
      return { ...r, ...fr };
    }
  },

  async getDashboardData(studentId) {
    const predictions = await this.getPredictionsByStudent(studentId, 'All');
    
    let latest = null;
    let averageScore = 0;
    let riskDistribution = { 'High Risk': 0, 'Moderate Risk': 0, 'Low Risk': 0, 'Very Low Risk': 0 };
    let levelDistribution = { Poor: 0, Average: 0, Good: 0, 'Very Good': 0, Excellent: 0 };

    if (predictions.length > 0) {
      latest = predictions[0];
      const sumScore = predictions.reduce((acc, p) => acc + Number(p.performance_score), 0);
      averageScore = Number((sumScore / predictions.length).toFixed(1));

      predictions.forEach((p) => {
        if (riskDistribution[p.risk_level] !== undefined) riskDistribution[p.risk_level]++;
        if (levelDistribution[p.performance_level] !== undefined) levelDistribution[p.performance_level]++;
      });
    }

    return {
      totalPredictions: predictions.length,
      latestPrediction: latest,
      averageScore,
      riskDistribution,
      levelDistribution,
      historyTrend: predictions.slice(0, 10).reverse().map((p) => ({
        date: new Date(p.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        score: Number(p.performance_score),
        level: p.performance_level,
        risk: p.risk_level,
      })),
    };
  },
};

module.exports = dbStore;
