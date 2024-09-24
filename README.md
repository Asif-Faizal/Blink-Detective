# Flutter Blink Detection

`Flutter Blink Detection` is a Flutter package that provides a controller for detecting faces and blinks using the camera feed and Google's ML Kit. It uses `google_ml_kit` for face detection and classification, and `camera` for capturing real-time images.

## Features

- Detects faces using Google's ML Kit.
- Detects blink events and counts the number of blinks.
- Callsbacks for success, no face detected, blink detected, and face detected.
- Simple to use and integrate.

## Getting Started

### Prerequisites

Before using this package, make sure you have the following dependencies in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.0+4
  google_ml_kit: ^0.10.0+1
```
### Also, ensure you have enabled the appropriate camera permissions in your AndroidManifest.xml and Info.plist files:

## Android
In your AndroidManifest.xml, add the following permissions:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

## iOS

In your Info.plist, add the following:
```plist
<key>NSCameraUsageDescription</key>
<string>We need access to your camera for face detection</string>
```

Run flutter pub get to install the dependencies.

# Usage

## Initialization

You need to initialize the FaceCameraController with a specified CameraLensDirection, such as front or back:

```dart
FaceCameraController faceCameraController = FaceCameraController(
  cameraLensDirection: CameraLensDirection.front,
  onSuccess: () {
    print('Blink detected 2 times. Success callback triggered.');
  },
  noFaceDetected: () {
    print('No face detected.');
  },
  onBlinkDetected: (blinkCount) {
    print('Blinks detected: $blinkCount');
  },
  onFaceDetected: () {
    print('Face detected.');
  },
);
```

## Start Camera Stream

Call initialize() to start the camera and begin face detection:

```dart
await faceCameraController.initialize(CameraLensDirection.front);
```

## Handling Face and Blink Detection

Once the camera feed is active, the controller will detect faces and blinks in real-time. You can use the provided callbacks to handle events:

* onSuccess: Triggered when a specified number of blinks (default is 2) are detected.
* noFaceDetected: Called when no face is detected in the camera feed.
* onBlinkDetected: Returns the count of detected blinks.
* onFaceDetected: Called when a face is detected.

# Example

```dart
class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late FaceCameraController faceCameraController;

  @override
  void initState() {
    super.initState();

    faceCameraController = FaceCameraController(
      cameraLensDirection: CameraLensDirection.front,
      onSuccess: () {
        print('Blink detected. Success callback triggered.');
      },
      noFaceDetected: () {
        print('No face detected.');
      },
      onBlinkDetected: (blinkCount) {
        print('Blinks detected: $blinkCount');
      },
      onFaceDetected: () {
        print('Face detected.');
      },
    );

    faceCameraController.initialize(CameraLensDirection.front);
  }

  @override
  void dispose() {
    faceCameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: Center(
        child: CameraPreview(faceCameraController.cameraController),
      ),
    );
  }
}
```
