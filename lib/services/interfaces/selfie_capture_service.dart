import 'dart:io';
import 'dart:ui';

/// Interface for selfie capture services
abstract class SelfieCaptureService {
  /// Initialize the selfie capture service
  Future<void> initialize(SelfieCaptureConfig config);
  
  /// Start the selfie capture process
  Future<void> startCapture();
  
  /// Stop the selfie capture process
  Future<void> stopCapture();
  
  /// Check if capture is in progress
  bool get isCaptureInProgress;
  
  /// Check if countdown is active
  bool get isCountdownActive;
  
  /// Get current countdown value
  int get countdownValue;
  
  /// Stream of capture states
  Stream<SelfieCaptureState> get captureStateStream;
  
  /// Stream of countdown updates
  Stream<int> get countdownStream;
  
  /// Get the last capture result
  Future<SelfieCaptureResult?> getLastCaptureResult();
  
  /// Dispose of resources
  void dispose();
}

/// Selfie capture configuration
class SelfieCaptureConfig {
  final int countdownDuration;
  final bool requireFaceDetection;
  final bool requireFacePositioning;
  final double minFaceSize;
  final bool enableFallback;
  final Duration fallbackTimeout;
  final bool cropToFace;
  final bool saveOriginal;

  const SelfieCaptureConfig({
    this.countdownDuration = 5,
    this.requireFaceDetection = true,
    this.requireFacePositioning = false,
    this.minFaceSize = 0.1,
    this.enableFallback = true,
    this.fallbackTimeout = const Duration(seconds: 10),
    this.cropToFace = true,
    this.saveOriginal = false,
  });
}

/// Selfie capture state
enum SelfieCaptureState {
  idle,
  waitingForFace,
  faceDetected,
  countdownStarted,
  capturing,
  processing,
  completed,
  error,
  cancelled,
}

/// Selfie capture result
class SelfieCaptureResult {
  final File? originalImage;
  final File? croppedImage;
  final Rect? faceRect;
  final SelfieCaptureState state;
  final String? error;
  final DateTime timestamp;

  SelfieCaptureResult({
    this.originalImage,
    this.croppedImage,
    this.faceRect,
    required this.state,
    this.error,
    required this.timestamp,
  });

  bool get isSuccess => state == SelfieCaptureState.completed && (originalImage != null || croppedImage != null);
  bool get hasError => error != null || state == SelfieCaptureState.error;
}

/// Selfie capture event
class SelfieCaptureEvent {
  final SelfieCaptureState state;
  final int? countdown;
  final String? message;
  final SelfieCaptureResult? result;
  final DateTime timestamp;

  SelfieCaptureEvent({
    required this.state,
    this.countdown,
    this.message,
    this.result,
    required this.timestamp,
  });
}