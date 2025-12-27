import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Interface for camera services
abstract class CameraService {
  /// Initialize the camera service
  Future<void> initialize({
    CameraLensDirection direction = CameraLensDirection.front,
    ResolutionPreset resolution = ResolutionPreset.medium,
  });
  
  /// Start the camera preview and image stream
  Future<void> startPreview();
  
  /// Stop the camera preview and image stream
  Future<void> stopPreview();
  
  /// Take a picture
  Future<XFile?> takePicture();
  
  /// Switch between front and back camera
  Future<void> switchCamera();
  
  /// Get the current camera controller
  CameraController? get controller;
  
  /// Check if camera is initialized
  bool get isInitialized;
  
  /// Check if camera is streaming
  bool get isStreaming;
  
  /// Stream of camera images for processing
  Stream<CameraImage> get imageStream;
  
  /// Stream of InputImage for ML Kit processing
  Stream<InputImage> get inputImageStream;
  
  /// Dispose of resources
  void dispose();
  
  /// Get camera configuration
  CameraConfig get config;
}

/// Camera configuration
class CameraConfig {
  final CameraLensDirection direction;
  final ResolutionPreset resolution;
  final bool enableAudio;
  final ImageFormatGroup? imageFormatGroup;

  const CameraConfig({
    this.direction = CameraLensDirection.front,
    this.resolution = ResolutionPreset.medium,
    this.enableAudio = false,
    this.imageFormatGroup = ImageFormatGroup.nv21,
  });
}

/// Camera state
enum CameraState {
  uninitialized,
  initializing,
  initialized,
  streaming,
  takingPicture,
  error,
  disposed,
}

/// Camera service result
class CameraResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  CameraResult.success(this.data) : error = null, isSuccess = true;
  CameraResult.error(this.error) : data = null, isSuccess = false;
}