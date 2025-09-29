import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideoProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  BackgroundVideoProvider() {
    _initVideo();
  }

  void _initVideo() async {
    _controller =
        VideoPlayerController.asset("assets/videos/blockchain_animation.mp4");

    await _controller!.initialize();
    _controller!
      ..setLooping(true)
      ..setPlaybackSpeed(0.9)
      ..play();

    _isInitialized = true;
    notifyListeners(); // notify widgets that video is ready
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
