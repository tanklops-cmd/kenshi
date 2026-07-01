import 'package:kendo_companion/src/features/moment/domain/moment_clip_selection.dart';

abstract interface class MomentClipExporter {
  Future<String> export(MomentClipSelection selection);
}

class MomentClipExportUnsupported implements Exception {
  const MomentClipExportUnsupported();

  @override
  String toString() {
    return 'Clip export is not available in this build.';
  }
}
