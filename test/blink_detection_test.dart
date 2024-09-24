import 'package:blink_detection/src/face_camera_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FaceCameraController initializes correctly', () async {
    final controller = FaceCameraController(cameraLensDirection: CameraLensDirection.front);
    // await controller.
    expect(controller.value.isDetecting, false);
  });

  // Add more tests for blink detection, camera state, etc.
}
