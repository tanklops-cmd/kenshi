import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

abstract class MomentVideoController extends ChangeNotifier {
  Duration get duration;
  Duration get position;
  bool get playing;

  Future<void> open(String path);
  Future<void> seek(Duration position);
  Future<void> playOrPause();
  Future<void> setRate(double rate);
  Widget buildVideo({bool controls = false});
}

abstract interface class MomentVideoControllerFactory {
  MomentVideoController create();
}

class MediaKitMomentVideoControllerFactory
    implements MomentVideoControllerFactory {
  const MediaKitMomentVideoControllerFactory();

  @override
  MomentVideoController create() => MediaKitMomentVideoController();
}

class MediaKitMomentVideoController extends MomentVideoController {
  MediaKitMomentVideoController() : _player = Player(), _subscriptions = [] {
    _videoController = VideoController(_player);
    _subscriptions.addAll([
      _player.stream.duration.listen((value) {
        _duration = value;
        notifyListeners();
      }),
      _player.stream.position.listen((value) {
        _position = value;
        notifyListeners();
      }),
      _player.stream.playing.listen((value) {
        _playing = value;
        notifyListeners();
      }),
    ]);
  }

  final Player _player;
  final List<StreamSubscription<Object?>> _subscriptions;
  late final VideoController _videoController;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;

  @override
  Duration get duration => _duration;

  @override
  Duration get position => _position;

  @override
  bool get playing => _playing;

  @override
  Future<void> open(String path) => _player.open(Media(path), play: false);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> setRate(double rate) => _player.setRate(rate);

  @override
  Widget buildVideo({bool controls = false}) {
    if (controls) {
      return Video(controller: _videoController);
    }
    return Video(controller: _videoController, controls: null);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}
