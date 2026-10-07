/**
 * Dynamic Recommendation Engine based on student performance indicators
 */

function generateRecommendations(inputs, performanceScore, riskLevel) {
  const recommendations = [];
  const { attendance, testScore, assignmentScore, studyHours } = inputs;

  // 1. Attendance Analysis
  if (attendance < 60) {
    recommendations.push({
      id: 'rec_att_1',
      category: 'Attendance',
      priority: 'High Priority',
      title: 'Critical Attendance Deficit',
      message: `Your current attendance is ${attendance}%. Try to maintain at least 75% attendance to avoid academic penalties and stay on track with lectures.`,
      icon: 'event_busy',
    });
  } else if (attendance < 75) {
    recommendations.push({
      id: 'rec_att_2',
      category: 'Attendance',
      priority: 'Medium Priority',
      title: 'Attendance Improvement Needed',
      message: `Your attendance is ${attendance}%. Attending a few more classes will push you above the recommended 75% benchmark.`,
      icon: 'event_repeat',
    });
  } else {
    recommendations.push({
      id: 'rec_att_3',
      category: 'Attendance',
      priority: 'Low Priority',
      title: 'Strong Attendance Record',
      message: `Great job maintaining ${attendance}% attendance! Regular class participation builds a strong foundation for exams.`,
      icon: 'event_available',
    });
  }

  // 2. Test Score Analysis
  if (testScore < 50) {
    recommendations.push({
      id: 'rec_test_1',
      category: 'Test Performance',
      priority: 'High Priority',
      title: 'Targeted Exam Preparation Required',
      message: `Your test score is ${testScore}/100. Take at least 2 practice tests every week and analyze incorrect answers to bridge core concept gaps.`,
      icon: 'assignment_late',
    });
  } else if (testScore < 75) {
    recommendations.push({
      id: 'rec_test_2',
      category: 'Test Performance',
      priority: 'Medium Priority',
      title: 'Practice & Revision',
      message: `Your test score is ${testScore}/100. Focused revision on weak topics can easily elevate your grade to Very Good.`,
      icon: 'edit_note',
    });
  } else {
    recommendations.push({
      id: 'rec_test_3',
      category: 'Test Performance',
      priority: 'Low Priority',
      title: 'Solid Exam Performance',
      message: `Excellent test score of ${testScore}/100. Keep reviewing mock tests to sustain top marks.`,
      icon: 'stars',
    });
  }

  // 3. Assignment Score Analysis
  if (assignmentScore < 60) {
    recommendations.push({
      id: 'rec_asg_1',
      category: 'Assignments',
      priority: 'High Priority',
      title: 'Regular Assignment Submissions',
      message: `Your assignment score is ${assignmentScore}%. Complete and submit coursework on time to reinforce continuous learning.`,
      icon: 'menu_book',
    });
  } else if (assignmentScore < 80) {
    recommendations.push({
      id: 'rec_asg_2',
      category: 'Assignments',
      priority: 'Medium Priority',
      title: 'Refine Coursework Quality',
      message: `Your assignment score is ${assignmentScore}%. Review assignment feedback and reference rubrics for higher scores.`,
      icon: 'fact_check',
    });
  } else {
    recommendations.push({
      id: 'rec_asg_3',
      category: 'Assignments',
      priority: 'Low Priority',
      title: 'Outstanding Coursework',
      message: `Impressive assignment score of ${assignmentScore}%. Your submitted projects show strong conceptual understanding.`,
      icon: 'verified',
    });
  }

  // 4. Study Hours Analysis
  if (studyHours < 2) {
    recommendations.push({
      id: 'rec_std_1',
      category: 'Study Routine',
      priority: 'High Priority',
      title: 'Increase Daily Study Time',
      message: `You are currently studying ${studyHours} hrs/day. Gradually increase study time to at least 3-4 hours daily for effective subject retention.`,
      icon: 'schedule',
    });
  } else if (studyHours < 4) {
    recommendations.push({
      id: 'rec_std_2',
      category: 'Study Routine',
      priority: 'Medium Priority',
      title: 'Optimize Study Schedule',
      message: `Studying ${studyHours} hrs/day is decent. Use structured techniques like Pomodoro to boost efficiency.`,
      icon: 'timer',
    });
  } else {
    recommendations.push({
      id: 'rec_std_3',
      category: 'Study Routine',
      priority: 'Low Priority',
      title: 'Consistent Study Discipline',
      message: `Studying ${studyHours} hrs/day demonstrates great commitment! Maintain study-life balance to prevent burnout.`,
      icon: 'auto_awesome',
    });
  }

  // Overall Advice
  if (performanceScore >= 85) {
    recommendations.unshift({
      id: 'rec_overall_top',
      category: 'Overall Strategy',
      priority: 'Low Priority',
      title: 'Maintain Stellar Strategy',
      message: 'Excellent performance! Maintain your current study strategy and consider mentoring peers.',
      icon: 'emoji_events',
    });
  } else if (riskLevel === 'High Risk' || riskLevel === 'Moderate Risk') {
    recommendations.unshift({
      id: 'rec_overall_warn',
      category: 'Overall Strategy',
      priority: 'High Priority',
      title: 'Academic Action Plan Recommended',
      message: 'Focus immediately on High Priority areas to reduce your academic risk level before the final assessment.',
      icon: 'warning_amber',
    });
  }

  return recommendations;
}

module.exports = {
  generateRecommendations,
};
