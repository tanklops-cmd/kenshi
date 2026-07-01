enum PracticeTopicCategory {
  fundamentals('Fundamentals'),
  shikakeWaza('Shikake-waza'),
  ojiWaza('Oji-waza'),
  hikiWaza('Hiki-waza'),
  tsuki('Tsuki'),
  footwork('Footwork'),
  kamae('Kamae'),
  kihon('Kihon'),
  other('Other');

  const PracticeTopicCategory(this.label);

  final String label;
}

class PracticeTopic {
  const PracticeTopic({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.name,
    required this.currentState,
    required this.mentalCues,
    required this.archived,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PracticeTopicCategory category;
  final String name;
  final String currentState;
  final String mentalCues;
  final bool archived;

  PracticeTopic copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    PracticeTopicCategory? category,
    String? name,
    String? currentState,
    String? mentalCues,
    bool? archived,
  }) {
    return PracticeTopic(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      name: name ?? this.name,
      currentState: currentState ?? this.currentState,
      mentalCues: mentalCues ?? this.mentalCues,
      archived: archived ?? this.archived,
    );
  }
}
