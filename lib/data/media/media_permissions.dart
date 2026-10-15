import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

enum MediaAccess { granted, denied, permanentlyDenied }

/// Microphone and camera access. The camera is declared for the upcoming
/// eye-contact and gesture analysis (see docs/media-roadmap.md).
class MediaPermissions {
  const MediaPermissions();

  Future<MediaAccess> requestMicrophone() async {
    // permission_handler has no web implementation; the browser prompt is
    // triggered by the recorder itself.
    if (kIsWeb) {
      final recorder = AudioRecorder();
      try {
        return await recorder.hasPermission()
            ? MediaAccess.granted
            : MediaAccess.denied;
      } finally {
        await recorder.dispose();
      }
    }
    return _map(await Permission.microphone.request());
  }

  Future<MediaAccess> requestCamera() async {
    if (kIsWeb) return MediaAccess.denied;
    return _map(await Permission.camera.request());
  }

  Future<bool> openSettings() => openAppSettings();

  static MediaAccess _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return MediaAccess.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MediaAccess.permanentlyDenied;
    }
    return MediaAccess.denied;
  }
}

final mediaPermissionsProvider = Provider<MediaPermissions>(
  (ref) => const MediaPermissions(),
);
