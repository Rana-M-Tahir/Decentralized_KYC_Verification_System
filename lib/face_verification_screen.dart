import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nexus_kyt/camera_capture_provider.dart';
import 'package:nexus_kyt/dashboard_screen.dart';
import 'package:provider/provider.dart';

import 'background_video_provider.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  File? _faceImage;

  Future<void> _captureFace() async {
    final File? faceFile = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );

    if (faceFile != null) {
      setState(() {
        _faceImage = faceFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<BackgroundVideoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (videoProvider.isInitialized)
            Positioned.fill(
              child: Video(
                controller: videoProvider.controller,
                fit: BoxFit.cover,
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // 🖊️ Foreground UI
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress Bar
                  SizedBox(
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      value: 1.0, // Final step
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Step 3 of 3",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),

                  const Text(
                    "Face Verification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Face Capture Section
                  GestureDetector(
                    onTap: _captureFace,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _faceImage == null
                          ? Center(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final circleSize =
                                      constraints.maxHeight * 0.6;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: circleSize,
                                        height: circleSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.blue, width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 80,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Tap to Capture Your Face",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: ClipOval(
                                child: Image.file(
                                  _faceImage!,
                                  fit: BoxFit.cover,
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  height:
                                      MediaQuery.of(context).size.width * 0.55,
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ Instructions
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Make sure your face is well-lit and visible.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Avoid hats, sunglasses, or face coverings.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ✅ Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_faceImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Face image is required"),
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 250),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const DashboardScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 18, 18, 111), // Dark Blue
                              Color(0xFF1cb5e0), // Light Blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
