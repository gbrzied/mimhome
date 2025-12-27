import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Interface for face detection services
abstract class FaceDetectionService {
  /// Initialize the face detection service
  Future<void> initialize();
  
  /// Process camera image and detect faces
  Future<List<Face>> detectFaces(InputImage inputImage);
  
  /// Check if a face is detected in the current frame
  bool get hasFaceDetected;
  
  /// Get the bounding rectangle of the detected face
  Rect? get faceRect;
  
  /// Get the absolute screen coordinates of the face
  Rect? get absoluteFaceRect;
  
  /// Dispose of resources
  void dispose();
  
  /// Stream of face detection results
  Stream<FaceDetectionResult> get faceDetectionStream;
}

/// Result of face detection
class FaceDetectionResult {
  final List<Face> faces;
  final Rect? primaryFaceRect;
  final Rect? absoluteRect;
  final bool hasValidFace;
  final DateTime timestamp;

  FaceDetectionResult({
    required this.faces,
    this.primaryFaceRect,
    this.absoluteRect,
    required this.hasValidFace,
    required this.timestamp,
  });
}

/// Face detection configuration
class FaceDetectionConfig {
  final double minFaceSize;
  final bool enableTracking;
  final bool enableClassification;
  final bool enableLandmarks;
  final int maxFailureCount;
  final Duration fallbackTimeout;

  const FaceDetectionConfig({
    this.minFaceSize = 0.1,
    this.enableTracking = true,
    this.enableClassification = false,
    this.enableLandmarks = false,
    this.maxFailureCount = 10,
    this.fallbackTimeout = const Duration(seconds: 5),
  });
}