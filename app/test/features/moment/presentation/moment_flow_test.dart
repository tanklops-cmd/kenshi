import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/data/moment_media_services.dart';
import 'package:kendo_companion/src/features/moment/data/moment_video_controller.dart';
import 'package:kendo_companion/src/features/moment/domain/moment.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_exporter.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_selection.dart';
import 'package:kendo_companion/src/features/session/application/session_providers.dart';
import 'package:kendo_companion/src/features/session/domain/session.dart';

import '../../../helpers/fake_moment_repository.dart';
import '../../../helpers/fake_session_repository.dart';

void main() {
  testWidgets('adds, edits, views, and archives a photo Moment', (
    tester,
  ) async {
    final moments = FakeMomentRepository();
    final picker = _FakeMomentMediaPicker(r'C:\media\strike.jpg');
    final fileStore = _FakeMomentFileStore();
    await _pumpSession(
      tester,
      moments: moments,
      picker: picker,
      fileStore: fileStore,
    );

    expect(find.text('No Moments yet.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('addMomentButton')));
    await tester.pumpAndSettle();
    expect(find.text('Pick Photo'), findsOneWidget);
    expect(find.text('Pick Video'), findsOneWidget);

    await tester.tap(find.text('Pick Photo'));
    await tester.pumpAndSettle();

    expect(picker.lastType, MomentType.photo);
    expect(find.text('Moment'), findsOneWidget);
    expect(find.byKey(const ValueKey('momentTitleField')), findsOneWidget);
    expect(find.byKey(const ValueKey('momentNoteField')), findsOneWidget);
    expect(find.text('What does this Moment show?'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('momentTitleField')),
      'Committed men',
    );
    await tester.enterText(
      find.byKey(const ValueKey('momentNoteField')),
      'I finished forward without hesitation.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final stored = (await moments.readForSession('session-1')).single;
    expect(stored.title, 'Committed men');
    expect(stored.note, 'I finished forward without hesitation.');

    final detailScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('deleteMomentButton')),
      160,
      scrollable: detailScroll,
    );
    await tester.tap(find.byKey(const ValueKey('deleteMomentButton')));
    await tester.pumpAndSettle();
    expect(find.text('Keep File'), findsOneWidget);
    expect(find.text('Delete File'), findsOneWidget);
    await tester.tap(find.text('Delete File'));
    await tester.pumpAndSettle();

    expect(await moments.readForSession('session-1'), isEmpty);
    expect(fileStore.deletedPaths, [r'C:\media\strike.jpg']);
    expect(find.text('No Moments yet.'), findsOneWidget);
  });

  testWidgets('supports selecting a video Moment', (tester) async {
    final moments = FakeMomentRepository();
    final picker = _FakeMomentMediaPicker(r'C:\media\keiko.mp4');
    final exporter = _FakeMomentClipExporter(r'C:\moments\keiko-clip.mp4');
    final videoFactory = _FakeMomentVideoControllerFactory();
    await _pumpSession(
      tester,
      moments: moments,
      picker: picker,
      exporter: exporter,
      videoFactory: videoFactory,
    );

    await tester.tap(find.byKey(const ValueKey('addMomentButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick Video'));
    await tester.pumpAndSettle();

    expect(picker.lastType, MomentType.video);
    expect(find.text('Choose Moment'), findsOneWidget);
    final previewScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('momentStartSlider')),
      160,
      scrollable: previewScroll,
    );
    expect(find.byKey(const ValueKey('momentStartSlider')), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('momentStartSlider')),
      const Offset(120, 0),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('createMomentClipButton')),
      180,
      scrollable: previewScroll,
    );
    expect(find.text('7 seconds'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('createMomentClipButton')));
    await tester.pumpAndSettle();

    final stored = (await moments.readForSession('session-1')).single;
    expect(stored.type, MomentType.video);
    expect(stored.localPath, r'C:\moments\keiko-clip.mp4');
    expect(stored.sourcePath, r'C:\media\keiko.mp4');
    expect(stored.clipStartMs, isNotNull);
    expect(stored.clipEndMs! - stored.clipStartMs!, 7000);
    expect(exporter.selection, isNotNull);
    expect(find.text('Moment'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('slowPlaybackButton')));
    await tester.pump();
    expect(videoFactory.controllers.last.rate, 0.25);
  });
}

Future<void> _pumpSession(
  WidgetTester tester, {
  required FakeMomentRepository moments,
  required MomentMediaPicker picker,
  MomentFileStore? fileStore,
  MomentClipExporter? exporter,
  MomentVideoControllerFactory? videoFactory,
}) async {
  final sessions = FakeSessionRepository();
  await sessions.create(_summarySession());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(sessions),
        momentRepositoryProvider.overrideWithValue(moments),
        momentMediaPickerProvider.overrideWithValue(picker),
        if (fileStore != null)
          momentFileStoreProvider.overrideWithValue(fileStore),
        if (exporter != null)
          momentClipExporterProvider.overrideWithValue(exporter),
        if (videoFactory != null)
          momentVideoControllerFactoryProvider.overrideWithValue(videoFactory),
      ],
      child: const KendoCompanionApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reflect').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Wednesday keiko'));
  await tester.pumpAndSettle();
  final scrollable = find
      .descendant(
        of: find.byKey(const ValueKey('sessionWorkspaceList')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('addMomentButton')),
    180,
    scrollable: scrollable,
  );
  await tester.drag(scrollable, const Offset(0, -80));
  await tester.pumpAndSettle();
}

Session _summarySession() {
  return Session(
    id: 'session-1',
    createdAt: DateTime.utc(2026, 7, 1, 9),
    trainingDate: DateTime(2026, 7, 1),
    sessionType: SessionType.clubKeiko,
    title: 'Wednesday keiko',
    freshNotes: 'I stayed present.',
    reviewNotes: 'I created the opportunity.',
    nextFocus: 'Commit forward.',
    updatedAt: DateTime.utc(2026, 7, 1, 9),
  );
}

class _FakeMomentMediaPicker implements MomentMediaPicker {
  _FakeMomentMediaPicker(this.path);

  final String? path;
  MomentType? lastType;

  @override
  Future<String?> pick(MomentType type) async {
    lastType = type;
    return path;
  }
}

class _FakeMomentFileStore implements MomentFileStore {
  final List<String> deletedPaths = [];

  @override
  Future<void> delete(String path) async {
    deletedPaths.add(path);
  }
}

class _FakeMomentClipExporter implements MomentClipExporter {
  _FakeMomentClipExporter(this.outputPath);

  final String outputPath;
  MomentClipSelection? selection;

  @override
  Future<String> export(MomentClipSelection selection) async {
    this.selection = selection;
    return outputPath;
  }
}

class _FakeMomentVideoControllerFactory
    implements MomentVideoControllerFactory {
  final List<_FakeMomentVideoController> controllers = [];

  @override
  MomentVideoController create() {
    final controller = _FakeMomentVideoController();
    controllers.add(controller);
    return controller;
  }
}

class _FakeMomentVideoController extends MomentVideoController {
  @override
  Duration duration = const Duration(seconds: 30);

  @override
  Duration position = Duration.zero;

  @override
  bool playing = false;

  double rate = 1;

  @override
  Widget buildVideo({bool controls = false}) {
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> open(String path) async {}

  @override
  Future<void> playOrPause() async {
    playing = !playing;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) async {
    this.position = position;
    notifyListeners();
  }

  @override
  Future<void> setRate(double rate) async {
    this.rate = rate;
  }
}
