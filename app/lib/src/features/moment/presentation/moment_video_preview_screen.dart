import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/data/moment_video_controller.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_exporter.dart';
import 'package:kendo_companion/src/features/moment/domain/moment_clip_selection.dart';

class MomentVideoPreviewScreen extends ConsumerStatefulWidget {
  const MomentVideoPreviewScreen({
    required this.sessionId,
    required this.sourcePath,
    super.key,
  });

  final String sessionId;
  final String sourcePath;

  @override
  ConsumerState<MomentVideoPreviewScreen> createState() =>
      _MomentVideoPreviewScreenState();
}

class _MomentVideoPreviewScreenState
    extends ConsumerState<MomentVideoPreviewScreen> {
  late final MomentVideoController _controller;
  double _startMs = 0;
  double _durationSeconds = 7;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(momentVideoControllerFactoryProvider).create();
    unawaited(_controller.open(widget.sourcePath));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Moment')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final totalMs = _controller.duration.inMilliseconds.toDouble();
          final hasMinimumLength =
              _controller.duration >= MomentClipSelection.minimumDuration;
          final maxDurationSeconds = math.min(
            10.0,
            _controller.duration.inSeconds.toDouble(),
          );
          if (hasMinimumLength && _durationSeconds > maxDurationSeconds) {
            _durationSeconds = maxDurationSeconds;
          }
          final selectedMs = _durationSeconds * 1000;
          final maxStartMs = math.max(0.0, totalMs - selectedMs);
          if (_startMs > maxStartMs) {
            _startMs = maxStartMs;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _controller.buildVideo(),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: IconButton.filledTonal(
                  key: const ValueKey('previewPlayButton'),
                  onPressed: _controller.playOrPause,
                  icon: Icon(
                    _controller.playing ? Icons.pause : Icons.play_arrow,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                key: const ValueKey('momentStartSlider'),
                value: _startMs.clamp(0, maxStartMs),
                max: math.max(1, maxStartMs),
                onChanged: hasMinimumLength && maxStartMs > 0
                    ? (value) {
                        setState(() => _startMs = value);
                        unawaited(
                          _controller.seek(
                            Duration(milliseconds: value.round()),
                          ),
                        );
                      }
                    : null,
              ),
              Text(_format(Duration(milliseconds: _startMs.round()))),
              const SizedBox(height: 20),
              Text('Duration', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                key: const ValueKey('momentDurationSlider'),
                value: _durationSeconds,
                min: 5,
                max: math.max(6, maxDurationSeconds),
                divisions: math.max(1, maxDurationSeconds.round() - 5),
                label: '${_durationSeconds.round()} seconds',
                onChanged: hasMinimumLength && maxDurationSeconds > 5
                    ? (value) => setState(() => _durationSeconds = value)
                    : null,
              ),
              Text('${_durationSeconds.round()} seconds'),
              if (!hasMinimumLength && _controller.duration > Duration.zero)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('The source video must be at least 5 seconds.'),
                ),
              if (_error case final error?)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const ValueKey('createMomentClipButton'),
                onPressed: hasMinimumLength && !_creating
                    ? _createMoment
                    : null,
                icon: _creating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.content_cut),
                label: const Text('Create Moment'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createMoment() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    final selection = MomentClipSelection(
      sourcePath: widget.sourcePath,
      start: Duration(milliseconds: _startMs.round()),
      duration: Duration(seconds: _durationSeconds.round()),
    );
    try {
      final moment = await ref
          .read(momentActionsProvider)
          .exportAndCreate(sessionId: widget.sessionId, selection: selection);
      if (mounted) {
        context.pushReplacement(
          AppRoutes.momentDetailLocation(
            sessionId: widget.sessionId,
            momentId: moment.id,
          ),
        );
      }
    } on MomentClipExportUnsupported {
      if (mounted) {
        setState(() {
          _creating = false;
          _error = 'Clip export is not available in this build.';
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _creating = false;
          _error = 'The Moment clip could not be created.';
        });
      }
    }
  }

  String _format(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
