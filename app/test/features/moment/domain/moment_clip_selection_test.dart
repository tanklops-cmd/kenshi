import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/features/moment/data/unsupported_moment_clip_exporter.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_exporter.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_selection.dart';

void main() {
  test('defines a seven-second default within the five-to-ten rule', () {
    expect(MomentClipSelection.minimumDuration, const Duration(seconds: 5));
    expect(MomentClipSelection.defaultDuration, const Duration(seconds: 7));
    expect(MomentClipSelection.maximumDuration, const Duration(seconds: 10));
  });

  test('accepts inclusive duration boundaries', () {
    for (final duration in const [
      Duration(seconds: 5),
      Duration(seconds: 10),
    ]) {
      final selection = MomentClipSelection(
        sourcePath: 'source.mp4',
        start: const Duration(seconds: 3),
        duration: duration,
      );
      expect(selection.end, const Duration(seconds: 3) + duration);
    }
  });

  test('rejects clips shorter than five or longer than ten seconds', () {
    for (final duration in const [
      Duration(seconds: 4),
      Duration(seconds: 11),
    ]) {
      expect(
        () => MomentClipSelection(
          sourcePath: 'source.mp4',
          start: Duration.zero,
          duration: duration,
        ),
        throwsArgumentError,
      );
    }
  });

  test('production fallback does not fake successful extraction', () async {
    final selection = MomentClipSelection(
      sourcePath: 'source.mp4',
      start: Duration.zero,
      duration: MomentClipSelection.defaultDuration,
    );

    expect(
      () => const UnsupportedMomentClipExporter().export(selection),
      throwsA(isA<MomentClipExportUnsupported>()),
    );
  });
}
