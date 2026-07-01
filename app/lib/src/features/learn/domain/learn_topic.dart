enum LearnCategory {
  fundamentals('Fundamentals'),
  footwork('Footwork'),
  kamae('Kamae'),
  seme('Seme'),
  maai('Maai'),
  tenouchi('Tenouchi'),
  shikakeWaza('Shikake-waza'),
  ojiWaza('Oji-waza'),
  hikiWaza('Hiki-waza'),
  tsuki('Tsuki'),
  kihon('Kihon'),
  drills('Drills'),
  kata('Kata'),
  shinpan('Shinpan'),
  shiai('Shiai'),
  reiho('Reiho'),
  equipment('Equipment'),
  grading('Grading'),
  terminology('Terminology'),
  history('History');

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
    this.difficulty,
    this.relatedTopics,
    this.references,
  });

  final String id;
  final LearnCategory category;
  final String title;
  final String summary;
  final String body;
  final String? relatedPracticeTopicName;

  /// Optional difficulty label (e.g. 'Beginner', 'Intermediate', 'Advanced').
  /// Not populated in initial seed content.
  final String? difficulty;

  /// Optional list of related topic IDs for cross-linking.
  /// Not populated in initial seed content.
  final List<String>? relatedTopics;

  /// Optional source references (books, videos, instructors).
  /// Not populated in initial seed content.
  final List<String>? references;
}
