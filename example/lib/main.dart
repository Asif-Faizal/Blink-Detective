import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:blink_detection/blink_detection.dart';

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late FaceCameraController faceCameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    faceCameraController = FaceCameraController(
      cameraLensDirection: CameraLensDirection.front,
      onSuccess: _showSuccessSnackbar,
      noFaceDetected: _showNoFaceSnackbar,
      onFaceDetected: _showFaceDetectedSnackbar,  // Added callback
      onBlinkDetected: _showBlinkSnackbar,  // For each blink
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await faceCameraController.initialize(CameraLensDirection.front);
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    faceCameraController.dispose();
    super.dispose();
  }

  void _showSuccessSnackbar() {
    _showSnackbar('You blinked twice! Success!');
  }

  void _showNoFaceSnackbar() {
    _showSnackbar('No face detected! Please position your face in view.');
  }

  void _showBlinkSnackbar(int blinkCount) {
    _showSnackbar('Blink detected! Total blinks: $blinkCount');
  }

  void _showFaceDetectedSnackbar() {
    _showSnackbar('Face detected!');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blink Detection')),
      body: Column(
        children: [
          if (isCameraInitialized) ...[
            Expanded(
              flex: 2,
              child: CameraPreview(faceCameraController.cameraController),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!faceCameraController.value.isDetecting) {
                  faceCameraController.initialize(CameraLensDirection.front);
                }
              },
              child: const Text('Restart Detection'),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await availableCameras();
  runApp(MaterialApp(
    home: FaceDetectionScreen(),
  ));
}
