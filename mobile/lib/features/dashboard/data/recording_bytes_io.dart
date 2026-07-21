import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> readRecordingBytes(String path) {
  return File(path).readAsBytes();
}
