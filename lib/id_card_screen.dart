import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus_kyt/face_verification_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'background_video_provider.dart';

class IdCardUploadScreen extends StatefulWidget {
  const IdCardUploadScreen({super.key});

  @override
  State<IdCardUploadScreen> createState() => _IdCardUploadScreenState();
}

class _IdCardUploadScreenState extends State<IdCardUploadScreen> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    var status = await Permission.photos.request(); // android gallery
    if (status.isGranted) {
      // ✅ Permission granted → open gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(image.path);
          } else {
            _backImage = File(image.path);
          }
        });
      }
    } else if (status.isDenied) {
      // ❌ User denied → can ask again later
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please allow gallery access to upload images"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<BackgroundVideoProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 🎬 Background video
          if (videoProvider.isInitialized && videoProvider.controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoProvider.controller!.value.size.width,
                  height: videoProvider.controller!.value.size.height,
                  child: VideoPlayer(videoProvider.controller!),
                ),
              ),
            ),

          // 🖊️ Foreground form
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      value: 0.66,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Step 2 of 3",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),

                  const Text(
                    "Upload Your ID Card",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Front ID
                  GestureDetector(
                    onTap: () => _pickImage(true),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _frontImage == null
                          ? const Center(
                              child: Text(
                                "Tap to Upload Front Side",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_frontImage!,
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Back ID
                  GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _backImage == null
                          ? const Center(
                              child: Text(
                                "Tap to Upload Back Side",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_backImage!,
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                              "Ensure the picture is clear and not blurry.",
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
                              "Both front and back sides must be uploaded.",
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
                              "Make sure all text on the ID card is readable.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_frontImage == null || _backImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                      "Both front and back ID images are required"),
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 250),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const FaceVerificationScreen(),
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
                        padding: EdgeInsets.zero, // remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // rounded corners
                        ),
                        backgroundColor:
                            Colors.transparent, // remove default solid color
                        shadowColor: Colors
                            .transparent, // remove shadow to see gradient clearly
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
