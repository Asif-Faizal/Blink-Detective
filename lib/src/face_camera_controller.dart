import 'package:blink_detection/blink_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'util/image_utils.dart';

class FaceCameraController extends ValueNotifier<FaceCameraState> {
  late CameraController cameraController;
  final FaceDetector faceDetector;
  final VoidCallback? onBlinkDetected;

  bool eyesClosed = false;
  DateTime? lastBlinkTime;

  FaceCameraController({
    required CameraLensDirection cameraLensDirection,
    this.onBlinkDetected,
  })  : faceDetector = GoogleMlKit.vision.faceDetector(
          FaceDetectorOptions(
            enableClassification: true,
            performanceMode: FaceDetectorMode.fast,
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
      // Handle initialization errors
      debugPrint('Error initializing camera: $e');
    }
  }

  void _startImageStream() {
    cameraController.startImageStream((CameraImage cameraImage) async {
      if (value.isDetecting) return;
      value = value.copyWith(isDetecting: true);
      await _processImage(cameraImage);
    });
  }
Future<void> _processImage(CameraImage cameraImage) async {
  final inputImage = ImageUtils.buildInputImage(cameraImage);

  try {
    final faces = await faceDetector.processImage(inputImage);
    debugPrint('Detected faces: ${faces.length}');
    _handleFaceDetection(faces);
  } catch (e) {
    debugPrint('Error processing image: $e');
  }

  value = value.copyWith(isDetecting: false);
}
void _handleFaceDetection(List<Face> faces) {
  if (faces.isNotEmpty) {
    final face = faces.first;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

    debugPrint('Left eye open: $leftEyeOpen, Right eye open: $rightEyeOpen');

    if (leftEyeOpen < 0.3 && rightEyeOpen < 0.3) {
      eyesClosed = true;
    } else if (eyesClosed && leftEyeOpen > 0.7 && rightEyeOpen > 0.7) {
      eyesClosed = false;
      final now = DateTime.now();
      if (lastBlinkTime == null ||
          now.difference(lastBlinkTime!).inMilliseconds > 300) {
        lastBlinkTime = now;
        onBlinkDetected?.call();
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
