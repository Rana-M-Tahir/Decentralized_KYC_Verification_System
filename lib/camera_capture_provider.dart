import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  /// Returns a File when popping (captured image). Caller should await.
  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTaking = false;
  CameraLensDirection _currentLens = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // Handle app lifecycle so camera pauses/resumes properly
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initControllerForLens(_currentLens);
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Camera permission is required for face verification')));
      Navigator.of(context).pop();
      return;
    }

    try {
      _cameras = await availableCameras();
      await _initControllerForLens(_currentLens);
    } catch (e) {
      // fallback / error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Camera error: $e'),
        ));
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _initControllerForLens(CameraLensDirection lens) async {
    if (!mounted) return;
    final list = _cameras ?? await availableCameras();
    CameraDescription? cam;
    try {
      cam = list.firstWhere((c) => c.lensDirection == lens);
    } catch (_) {
      if (list.isNotEmpty) cam = list.first;
    }

    if (cam == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found on this device')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    _controller?.dispose();
    _controller =
        CameraController(cam, ResolutionPreset.medium, enableAudio: false);

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to initialize camera: $e'),
        ));
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    final newLens = _currentLens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    // Dispose the old controller first
    await _controller?.dispose();

    // Find the new camera description
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == newLens,
    );

    // Create a new controller
    final newController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Reinitialize
    await newController.initialize();

    // Update state only after initialization is done
    setState(() {
      _currentLens = newLens;
      _controller = newController;
      _isInitialized = true;
    });
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTaking)
      return;
    try {
      setState(() => _isTaking = true);
      final XFile file = await _controller!.takePicture();
      final File returned = File(file.path);
      if (!mounted) return;
      Navigator.of(context).pop(returned);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Capture failed: $e'),
        ));
      }
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = math.min(size.width * 0.62, size.height * 0.45);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitialized &&
                _controller != null &&
                _controller!.value.isInitialized
            ? Stack(
                children: [
                  // Camera preview
                  Positioned.fill(
                    child: CameraPreview(_controller!),
                  ),

                  // Semi-transparent overlay with circular hole
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CircleHolePainter(circleSize: circleSize),
                    ),
                  ),

                  // Circular border to emphasize the guide
                  Center(
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.9),
                          width: 4,
                        ),
                      ),
                    ),
                  ),

                  // Instruction text
                  Positioned(
                    top: size.height * 0.12,
                    left: 20,
                    right: 20,
                    child: const Center(
                      child: Text(
                        'Center your face inside the circle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                                blurRadius: 6,
                                color: Colors.black45,
                                offset: Offset(0, 2))
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom controls: flip camera and capture button
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Flip button
                        InkWell(
                          onTap: _flipCamera,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cameraswitch,
                                color: Colors.white, size: 28),
                          ),
                        ),

                        // Capture button
                        GestureDetector(
                          onTap: _takePicture,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // outer ring
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              // inner circle
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isTaking ? Colors.grey : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cancel button (close)
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Paints a translucent overlay with a circular "hole" in the center
class CircleHolePainter extends CustomPainter {
  final double circleSize;
  CircleHolePainter({required this.circleSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    // Full rect
    final Path outer = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Circle in center
    final center = Offset(size.width / 2, size.height / 2);
    final Path hole = Path()
      ..addOval(Rect.fromCircle(center: center, radius: circleSize / 2));

    // Subtract hole from outer
    final Path finalPath = Path.combine(PathOperation.difference, outer, hole);

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CircleHolePainter oldDelegate) {
    return oldDelegate.circleSize != circleSize;
  }
}
