class ApplicationModel {
  final int id;
  final String title;
  final String category;
  final String iconName;
  final String problemStatement;
  final String whyOptimizationNeeded;
  final String howSwarmHelps;
  final String candidateRepresentation;
  final String objectiveFunction;
  final String expectedOutput;
  final List<String> advantages;
  final List<String> limitations;
  final List<String> exampleWorkflow;

  const ApplicationModel({
    required this.id,
    required this.title,
    required this.category,
    required this.iconName,
    required this.problemStatement,
    required this.whyOptimizationNeeded,
    required this.howSwarmHelps,
    required this.candidateRepresentation,
    required this.objectiveFunction,
    required this.expectedOutput,
    required this.advantages,
    required this.limitations,
    required this.exampleWorkflow,
  });
}
