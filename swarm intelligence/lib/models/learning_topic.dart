class LearningTopic {
  final int id;
  final String title;
  final String category;
  final String definition;
  final String simpleExplanation;
  final String practicalExample;
  final String? formula;
  final String visualExplanation;
  final String relationToApp;

  const LearningTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.definition,
    required this.simpleExplanation,
    required this.practicalExample,
    this.formula,
    required this.visualExplanation,
    required this.relationToApp,
  });
}
