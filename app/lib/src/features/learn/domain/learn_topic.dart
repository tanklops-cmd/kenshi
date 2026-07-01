enum LearnCategory {
  techniques('Techniques'),
  fundamentals('Fundamentals'),
  kata('Kata'),
  training('Training'),
  equipment('Equipment'),
  rules('Rules'),
  grading('Grading'),
  etiquette('Etiquette');

  const LearnCategory(this.label);

  final String label;
}

class LearnTopic {
  const LearnTopic({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.body,
    this.relatedPracticeTopicName,
  });

  final String id;
  final LearnCategory category;
  final String title;
  final String summary;
  final String body;
  final String? relatedPracticeTopicName;
}
