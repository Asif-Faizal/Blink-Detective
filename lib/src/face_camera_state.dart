import 'package:flutter/material.dart';

@immutable
class FaceCameraState {
  final bool isDetecting;

  const FaceCameraState._({
    required this.isDetecting,
  });

  const FaceCameraState.uninitialized() : this._(isDetecting: false);

  FaceCameraState copyWith({
    bool? isDetecting,
  }) {
    return FaceCameraState._(
      isDetecting: isDetecting ?? this.isDetecting,
    );
  }
}
