import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List> readRecordingBytes(String path) async {
  final request = await html.HttpRequest.request(
    path,
    method: 'GET',
    responseType: 'arraybuffer',
  );
  final buffer = request.response as ByteBuffer?;
  if (buffer == null) {
    throw StateError('Failed to read recorded audio');
  }
  return buffer.asUint8List();
}
