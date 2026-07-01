import 'package:kendo_companion/src/features/moment/domain/moment_clip_exporter.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_selection.dart';

/// Cross-platform extraction remains behind this boundary until an exporter
/// with proven Android and Windows support and acceptable licensing is chosen.
class UnsupportedMomentClipExporter implements MomentClipExporter {
  const UnsupportedMomentClipExporter();

  @override
  Future<String> export(MomentClipSelection selection) {
    throw const MomentClipExportUnsupported();
  }
}
