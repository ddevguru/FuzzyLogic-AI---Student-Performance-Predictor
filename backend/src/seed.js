const bcrypt = require('bcrypt');
const { initDb } = require('./config/database');
const dbStore = require('./services/dbStore');
const { processFuzzyPrediction } = require('./services/fuzzyLogicService');

async function seedDemoData() {
  console.log('Seeding demo student and prediction records...');
  await initDb();

  const email = 'rahul@student.edu';
  let user = await dbStore.findUserByEmail(email);

  if (!user) {
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash('Password123', salt);

    user = await dbStore.createUser({
      name: 'Rahul Sharma',
      email,
      password_hash,
      role: 'student',
    });

    await dbStore.upsertStudentProfile({
      userId: user.id,
      rollNumber: 'CS2026-088',
      course: 'B.Tech Computer Science & Engineering',
      semester: 6,
      department: 'School of Computing',
    });

    console.log(`Created user: ${user.name} (${user.email})`);
  }

  // Demo test cases
  const cases = [
    {
      label: 'Sample Case (Rahul)',
      inputs: { attendance: 82, testScore: 76, assignmentScore: 88, studyHours: 5 },
    },
    {
      label: 'Case 1 - High Risk',
      inputs: { attendance: 42, testScore: 35, assignmentScore: 40, studyHours: 1.5 },
    },
    {
      label: 'Case 2 - Moderate',
      inputs: { attendance: 68, testScore: 58, assignmentScore: 62, studyHours: 3 },
    },
    {
      label: 'Case 3 - Excellent',
      inputs: { attendance: 95, testScore: 92, assignmentScore: 94, studyHours: 7 },
    },
  ];

  for (const c of cases) {
    const fuzzyResult = processFuzzyPrediction(c.inputs);
    const rec = await dbStore.savePrediction({
      studentId: user.id,
      inputs: c.inputs,
      fuzzyResult,
    });
    console.log(
      `[SEED] ${c.label} -> Score: ${fuzzyResult.performanceScore}% | Level: ${fuzzyResult.performanceLevel} | Risk: ${fuzzyResult.riskLevel}`
    );
  }

  console.log('Seeding completed successfully!');
  process.exit(0);
}

seedDemoData().catch((err) => {
  console.error('Seed Error:', err);
  process.exit(1);
});
