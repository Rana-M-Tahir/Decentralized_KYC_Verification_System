import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class BackgroundVideoProvider extends ChangeNotifier {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;

  VideoController get controller => _controller;
  bool get isInitialized => _isInitialized;

  BackgroundVideoProvider() {
    _initVideo();
  }

  void _initVideo() async {
    _player = Player();
    _controller = VideoController(_player);

    await _player.open(
      Media("assets/videos/blockchain_animation.mp4"),
    );

    _player.setPlaylistMode(PlaylistMode.loop);
    _player.setRate(0.9); // playback speed

    _isInitialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
