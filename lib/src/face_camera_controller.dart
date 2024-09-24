import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'face_camera_state.dart';
import 'util/image_utils.dart';

class FaceCameraController extends ValueNotifier<FaceCameraState> {
  late CameraController cameraController;
  final FaceDetector faceDetector;
  final VoidCallback? onSuccess;
  final VoidCallback? noFaceDetected;
  final ValueChanged<int>? onBlinkDetected;
  final VoidCallback? onFaceDetected;

  bool eyesClosed = false;
  DateTime? lastBlinkTime;
  int blinkCount = 0;
  bool isDetecting = false;

  FaceCameraController({
    required CameraLensDirection cameraLensDirection,
    this.onSuccess,
    this.noFaceDetected,
    this.onBlinkDetected,
    this.onFaceDetected, // New callback for face detection
  })  : faceDetector = GoogleMlKit.vision.faceDetector(
          FaceDetectorOptions(
            enableClassification: true,
            performanceMode: FaceDetectorMode.accurate,
          ),
        ),
        super(FaceCameraState.uninitialized());

  Future<void> initialize(CameraLensDirection cameraLensDirection) async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == cameraLensDirection,
      );
      cameraController = CameraController(camera, ResolutionPreset.high);
      await cameraController.initialize();
      _startImageStream();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _startImageStream() {
    cameraController.startImageStream((CameraImage cameraImage) async {
      if (isDetecting) return;
      isDetecting = true;

      await _processImage(cameraImage);
      isDetecting = false;
    });
  }

  Future<void> _processImage(CameraImage cameraImage) async {
    final inputImage = ImageUtils.buildInputImage(cameraImage);

    try {
      final faces = await faceDetector.processImage(inputImage);
      debugPrint('Detected faces: ${faces.length}');
      
      if (faces.isEmpty) {
        noFaceDetected?.call();  // No face found
      } else {
        onFaceDetected?.call();  // Notify that a face is detected
        _handleFaceDetection(faces);  // Handle blink detection
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }

    value = value.copyWith(isDetecting: false);
  }

  void _handleFaceDetection(List<Face> faces) {
    final face = faces.first;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

    debugPrint('Left eye open: $leftEyeOpen, Right eye open: $rightEyeOpen');

    if (leftEyeOpen < 0.4 && rightEyeOpen < 0.4) {
      eyesClosed = true;
    } else if (eyesClosed && leftEyeOpen > 0.7 && rightEyeOpen > 0.7) {
      eyesClosed = false;
      final now = DateTime.now();
      if (lastBlinkTime == null ||
          now.difference(lastBlinkTime!).inMilliseconds > 300) {
        lastBlinkTime = now;
        blinkCount++;
        debugPrint('Blinked $blinkCount times');
        onBlinkDetected?.call(blinkCount);  // Notify the blink count

        if (blinkCount >= 2) {
          onSuccess?.call();
        }
      }
    }
  }

  @override
  Future<void> dispose() async {
    await cameraController.dispose();
    await faceDetector.close();
    super.dispose();
  }
}
