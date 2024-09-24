# FaceCameraController

`FaceCameraController` is a Flutter package that provides a controller for detecting faces and blinks using the camera feed and Google's ML Kit. It uses `google_ml_kit` for face detection and classification, and `camera` for capturing real-time images.

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
