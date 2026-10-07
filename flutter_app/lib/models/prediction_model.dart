class PredictionInputs {
  final double attendance;
  final double testScore;
  final double assignmentScore;
  final double studyHours;

  PredictionInputs({
    required this.attendance,
    required this.testScore,
    required this.assignmentScore,
    required this.studyHours,
  });

  factory PredictionInputs.fromJson(Map<String, dynamic> json) {
    return PredictionInputs(
      attendance: (json['attendance'] as num?)?.toDouble() ?? 0.0,
      testScore: (json['testScore'] as num? ?? json['test_score'] as num?)?.toDouble() ?? 0.0,
      assignmentScore: (json['assignmentScore'] as num? ?? json['assignment_score'] as num?)?.toDouble() ?? 0.0,
      studyHours: (json['studyHours'] as num? ?? json['study_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FuzzySetMemberships {
  final double low;
  final double medium;
  final double high;

  FuzzySetMemberships({
    required this.low,
    required this.medium,
    required this.high,
  });

  factory FuzzySetMemberships.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FuzzySetMemberships(low: 0, medium: 0, high: 0);
    return FuzzySetMemberships(
      low: (json['low'] as num? ?? json['poor'] as num?)?.toDouble() ?? 0.0,
      medium: (json['medium'] as num? ?? json['average'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num? ?? json['good'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FuzzificationData {
  final FuzzySetMemberships attendance;
  final FuzzySetMemberships testScore;
  final FuzzySetMemberships assignmentScore;
  final FuzzySetMemberships studyHours;

  FuzzificationData({
    required this.attendance,
    required this.testScore,
    required this.assignmentScore,
    required this.studyHours,
  });

  factory FuzzificationData.fromJson(Map<String, dynamic> json) {
    return FuzzificationData(
      attendance: FuzzySetMemberships.fromJson(json['attendance'] as Map<String, dynamic>?),
      testScore: FuzzySetMemberships.fromJson(json['testScore'] as Map<String, dynamic>?),
      assignmentScore: FuzzySetMemberships.fromJson(json['assignmentScore'] as Map<String, dynamic>?),
      studyHours: FuzzySetMemberships.fromJson(json['studyHours'] as Map<String, dynamic>?),
    );
  }
}

class FuzzyRuleResult {
  final String rule;
  final String text;
  final double strength;
  final String output;

  FuzzyRuleResult({
    required this.rule,
    required this.text,
    required this.strength,
    required this.output,
  });

  factory FuzzyRuleResult.fromJson(Map<String, dynamic> json) {
    return FuzzyRuleResult(
      rule: json['rule'] ?? '',
      text: json['text'] ?? '',
      strength: (json['strength'] as num?)?.toDouble() ?? 0.0,
      output: json['output'] ?? '',
    );
  }
}

class RecommendationItem {
  final String id;
  final String category;
  final String priority;
  final String title;
  final String message;
  final String icon;

  RecommendationItem({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.message,
    required this.icon,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      id: json['id'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium Priority',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      icon: json['icon'] ?? 'info',
    );
  }
}

class PredictionRecord {
  final String id;
  final String studentId;
  final PredictionInputs inputs;
  final double performanceScore;
  final String performanceLevel;
  final String riskLevel;
  final DateTime createdAt;
  final FuzzificationData? fuzzification;
  final List<FuzzyRuleResult> rules;
  final List<RecommendationItem> recommendations;

  PredictionRecord({
    required this.id,
    required this.studentId,
    required this.inputs,
    required this.performanceScore,
    required this.performanceLevel,
    required this.riskLevel,
    required this.createdAt,
    this.fuzzification,
    this.rules = const [],
    this.recommendations = const [],
  });

  factory PredictionRecord.fromJson(Map<String, dynamic> json) {
    final predData = json['prediction'] ?? json;
    final idVal = json['predictionId'] ?? json['id'] ?? '';
    final studentIdVal = json['student_id'] ?? json['studentId'] ?? '';

    PredictionInputs inputsObj;
    if (json.containsKey('inputs')) {
      inputsObj = PredictionInputs.fromJson(json['inputs']);
    } else {
      inputsObj = PredictionInputs.fromJson(json);
    }

    FuzzificationData? fuzz;
    if (json.containsKey('fuzzification')) {
      fuzz = FuzzificationData.fromJson(json['fuzzification']);
    } else if (json.containsKey('attendance_low')) {
      fuzz = FuzzificationData(
        attendance: FuzzySetMemberships(
          low: (json['attendance_low'] as num?)?.toDouble() ?? 0.0,
          medium: (json['attendance_medium'] as num?)?.toDouble() ?? 0.0,
          high: (json['attendance_high'] as num?)?.toDouble() ?? 0.0,
        ),
        testScore: FuzzySetMemberships(
          low: (json['test_low'] as num?)?.toDouble() ?? 0.0,
          medium: (json['test_medium'] as num?)?.toDouble() ?? 0.0,
          high: (json['test_high'] as num?)?.toDouble() ?? 0.0,
        ),
        assignmentScore: FuzzySetMemberships(
          low: (json['assignment_low'] as num?)?.toDouble() ?? 0.0,
          medium: (json['assignment_medium'] as num?)?.toDouble() ?? 0.0,
          high: (json['assignment_high'] as num?)?.toDouble() ?? 0.0,
        ),
        studyHours: FuzzySetMemberships(
          low: (json['study_low'] as num?)?.toDouble() ?? 0.0,
          medium: (json['study_medium'] as num?)?.toDouble() ?? 0.0,
          high: (json['study_high'] as num?)?.toDouble() ?? 0.0,
        ),
      );
    }

    List<FuzzyRuleResult> rulesList = [];
    if (json['rules'] is List) {
      rulesList = (json['rules'] as List)
          .map((r) => FuzzyRuleResult.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    List<RecommendationItem> recsList = [];
    if (json['recommendations'] is List) {
      recsList = (json['recommendations'] as List)
          .map((r) => RecommendationItem.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return PredictionRecord(
      id: idVal,
      studentId: studentIdVal,
      inputs: inputsObj,
      performanceScore: (predData['performanceScore'] as num? ?? predData['performance_score'] as num?)?.toDouble() ?? 0.0,
      performanceLevel: predData['performanceLevel'] ?? predData['performance_level'] ?? 'Average',
      riskLevel: predData['riskLevel'] ?? predData['risk_level'] ?? 'Moderate Risk',
      createdAt: DateTime.tryParse(predData['createdAt']?.toString() ?? predData['created_at']?.toString() ?? '') ?? DateTime.now(),
      fuzzification: fuzz,
      rules: rulesList,
      recommendations: recsList,
    );
  }
}
