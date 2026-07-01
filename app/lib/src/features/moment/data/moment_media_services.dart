import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';

abstract interface class MomentMediaPicker {
  Future<String?> pick(MomentType type);
}

class FilePickerMomentMediaPicker implements MomentMediaPicker {
  const FilePickerMomentMediaPicker();

  @override
  Future<String?> pick(MomentType type) async {
    final result = await FilePicker.pickFiles(
      type: type == MomentType.photo ? FileType.image : FileType.video,
      allowMultiple: false,
      withData: false,
    );
    return result?.files.single.path;
  }
}

abstract interface class MomentFileStore {
  Future<void> delete(String path);
}

class LocalMomentFileStore implements MomentFileStore {
  const LocalMomentFileStore();

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
