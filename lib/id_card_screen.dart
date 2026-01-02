import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nexus_kyt/face_verification_screen.dart';
import 'package:nexus_kyt/services/api_service.dart';
import 'package:nexus_kyt/auth_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Mark that user is on IdCardUploadScreen
    Future.microtask(() {
      context.read<AuthProvider>().setCurrentScreen('id_card');
    });
  }

  /// Build image widget that works on both web and mobile platforms
  Widget _buildImageWidget(File imageFile) {
    if (kIsWeb) {
      // On web, read file as bytes and use Image.memory
      return FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    } else {
      // On mobile, use Image.file directly
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      // Skip permission request on web platform
      if (!kIsWeb) {
        // Request photo/gallery permissions (mobile only)
        PermissionStatus photoStatus;
        
        // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
        // For older Android, use READ_EXTERNAL_STORAGE
        try {
          photoStatus = await Permission.photos.request();
        } catch (e) {
          // Fallback to READ_EXTERNAL_STORAGE if photos permission fails
          photoStatus = await Permission.storage.request();
        }

        if (photoStatus.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please allow gallery access to upload images"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        } else if (photoStatus.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Gallery permission is permanently denied. Please enable it in settings."),
                backgroundColor: Colors.red,
              ),
            );
          }
          openAppSettings();
          return;
        }
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        if (kIsWeb) {
          // For web, use the File constructor differently
          // The image path on web is a URL, so we store it as is
          setState(() {
            if (isFront) {
              _frontImage = File(image.path);
            } else {
              _backImage = File(image.path);
            }
          });
        } else {
          // For mobile platforms
          setState(() {
            if (isFront) {
              _frontImage = File(image.path);
            } else {
              _backImage = File(image.path);
            }
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isFront ? "Front image selected" : "Back image selected"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<BackgroundVideoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body:

          // 🖊️ Foreground form
          BlockchainBackground(
        child: SafeArea(
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.white70,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Tap to Upload Front Side",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImageWidget(_frontImage!),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.white70,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Tap to Upload Back Side",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImageWidget(_backImage!),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
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
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Ensure the picture is clear and not blurry.",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Both front and back sides must be uploaded.",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Make sure all text on the ID card is readable.",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
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
                                  // Upload documents
                                  final result =
                                      await ApiService.uploadDocuments(
                                    documents: [_frontImage!, _backImage!],
                                    token: authProvider.token,
                                  );

                                  if (result['success']) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Documents uploaded successfully!'),
                                        backgroundColor: Colors.green.shade700,
                                      ),
                                    );

                                    // Navigate to next screen
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 250),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const FaceVerificationScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;

                                            final tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            final offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result['error'] ??
                                              'Failed to upload documents',
                                        ),
                                        backgroundColor: Colors.red.shade700,
                                      ),
                                    );
                                  }
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
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
