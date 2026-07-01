class MomentClipSelection {
  MomentClipSelection({
    required this.sourcePath,
    required this.start,
    required this.duration,
  }) {
    if (sourcePath.trim().isEmpty) {
      throw ArgumentError.value(sourcePath, 'sourcePath', 'Path is required.');
    }
    if (start.isNegative) {
      throw ArgumentError.value(start, 'start', 'Start cannot be negative.');
    }
    if (duration < minimumDuration || duration > maximumDuration) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Moment clips must be between 5 and 10 seconds.',
      );
    }
  }

  static const minimumDuration = Duration(seconds: 5);
  static const defaultDuration = Duration(seconds: 7);
  static const maximumDuration = Duration(seconds: 10);

  final String sourcePath;
  final Duration start;
  final Duration duration;

  Duration get end => start + duration;
}
