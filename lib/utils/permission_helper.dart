import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Request gallery/photo permissions with proper fallback for different Android versions
  static Future<bool> requestGalleryPermission() async {
    try {
      // First try photos permission (Android 13+)
      PermissionStatus status = await Permission.photos.request();

      // If photos permission fails or is not available, try storage
      if (status.isDenied || status.isRestricted) {
        status = await Permission.storage.request();
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting gallery permission: $e');
      // If all else fails, try storage as last resort
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Check if permission status is permanently denied
  static bool isPermanentlyDenied(PermissionStatus status) {
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return openAppSettings();
  }
}
