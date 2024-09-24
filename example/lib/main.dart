import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:blink_detection/blink_detection.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late Future<void> _initializeCameraFuture;
  late FaceCameraController _faceCameraController;

  @override
  void initState() {
    super.initState();
    _faceCameraController = FaceCameraController(
      cameraLensDirection: CameraLensDirection.front,
    );
    _initializeCameraFuture = _faceCameraController.initialize(CameraLensDirection.front);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection')),
      body: FutureBuilder<void>(
        future: _initializeCameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _faceCameraController.cameraController.value.isInitialized
                ? CameraPreview(_faceCameraController.cameraController)
                : const Center(child: Text('Camera not initialized'));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _faceCameraController.dispose();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await availableCameras(); // Ensures that cameras are initialized
  runApp(const MaterialApp(
    home: FaceDetectionScreen(),
  ));
}
