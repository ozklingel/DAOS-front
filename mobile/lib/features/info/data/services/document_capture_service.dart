import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CapturedImage {
  const CapturedImage({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}

class DocumentCaptureService {
  DocumentCaptureService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Opens the camera on mobile; falls back to gallery on web or if camera fails.
  Future<CapturedImage?> captureDocument({bool preferGallery = false}) async {
    final source = (kIsWeb || preferGallery) ? ImageSource.gallery : ImageSource.camera;
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file == null) return null;
      return _fromXFile(file);
    } catch (_) {
      if (source == ImageSource.camera) {
        final file = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (file == null) return null;
        return _fromXFile(file);
      }
      rethrow;
    }
  }

  Future<CapturedImage> _fromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final name = file.name.isNotEmpty ? file.name : 'document.jpg';
    final mime = file.mimeType ?? _guessMime(name);
    return CapturedImage(bytes: bytes, filename: name, mimeType: mime);
  }

  String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
