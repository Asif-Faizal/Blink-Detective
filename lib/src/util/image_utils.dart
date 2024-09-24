import 'dart:typed_data';
import 'dart:ui';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';

class ImageUtils {
  static InputImage buildInputImage(CameraImage image) {
    final size = Size(image.width.toDouble(), image.height.toDouble());
    const InputImageRotation rotation = InputImageRotation.rotation90deg;
    final InputImageMetadata metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: InputImageFormat.yuv_420_888,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
    final Uint8List bytes = _convertYUV420ToBytes(image);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }
  static Uint8List _convertYUV420ToBytes(CameraImage image) {
    final int ySize = image.planes[0].bytes.length;
    final int uvSize = image.planes[1].bytes.length + image.planes[2].bytes.length;

    final Uint8List yuvBytes = Uint8List(ySize + uvSize);

    yuvBytes.setAll(0, image.planes[0].bytes);
    yuvBytes.setAll(ySize, image.planes[1].bytes);
    yuvBytes.setAll(ySize + image.planes[1].bytes.length, image.planes[2].bytes);

    return yuvBytes;
  }
}
