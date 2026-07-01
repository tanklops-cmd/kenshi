import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/features/moment/application/moment_providers.dart';
import 'package:kendo_companion/src/features/moment/data/moment_video_controller.dart';

class MomentVideoPlayer extends ConsumerStatefulWidget {
  const MomentVideoPlayer({required this.path, super.key});

  final String path;

  @override
  ConsumerState<MomentVideoPlayer> createState() => _MomentVideoPlayerState();
}

class _MomentVideoPlayerState extends ConsumerState<MomentVideoPlayer> {
  late final MomentVideoController _controller;
  bool _slowPlayback = false;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(momentVideoControllerFactoryProvider).create();
    unawaited(_controller.open(widget.path));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _controller.buildVideo(controls: true),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilterChip(
            key: const ValueKey('slowPlaybackButton'),
            label: const Text('0.25×'),
            selected: _slowPlayback,
            onSelected: (selected) async {
              await _controller.setRate(selected ? 0.25 : 1);
              if (mounted) {
                setState(() => _slowPlayback = selected);
              }
            },
          ),
        ),
      ],
    );
  }
}
