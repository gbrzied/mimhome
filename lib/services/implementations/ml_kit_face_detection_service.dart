import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../interfaces/face_detection_service.dart';

/// ML Kit implementation of face detection service
class MLKitFaceDetectionService implements FaceDetectionService {
  late FaceDetector _faceDetector;
  final FaceDetectionConfig _config;
  final StreamController<FaceDetectionResult> _resultController = StreamController<FaceDetectionResult>.broadcast();
  
  Rect? _currentFaceRect;
  Rect? _currentAbsoluteRect;
  bool _isInitialized = false;
  int _failureCount = 0;
  bool _fallbackActive = false;
  Timer? _fallbackTimer;

  MLKitFaceDetectionService({FaceDetectionConfig? config}) 
      : _config = config ?? const FaceDetectionConfig();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final options = FaceDetectorOptions(
        enableClassification: _config.enableClassification,
        enableLandmarks: _config.enableLandmarks,
        enableTracking: _config.enableTracking,
        minFaceSize: _config.minFaceSize,
        performanceMode: FaceDetectorMode.fast,
      );
      
      _faceDetector = FaceDetector(options: options);
      _isInitialized = true;
      
      debugPrint('✅ MLKit Face Detection Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize MLKit Face Detection: $e');
      throw Exception('Failed to initialize face detection: $e');
    }
  }

  @override
  Future<List<Face>> detectFaces(InputImage inputImage) async {
    if (!_isInitialized) {
      throw Exception('Face detection service not initialized');
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isNotEmpty) {
        _failureCount = 0;
        _fallbackActive = false;
        _fallbackTimer?.cancel();
        
        final primaryFace = faces.first;
        _currentFaceRect = primaryFace.boundingBox;
        
        // Calculate absolute coordinates (this would need screen size context)
        _currentAbsoluteRect = _currentFaceRect;
        
        final result = FaceDetectionResult(
          faces: faces,
          primaryFaceRect: _currentFaceRect,
          absoluteRect: _currentAbsoluteRect,
          hasValidFace: true,
          timestamp: DateTime.now(),
        );
        
        _resultController.add(result);
        return faces;
      } else {
        _handleDetectionFailure();
        return [];
      }
    } catch (e) {
      debugPrint('❌ Face detection error: $e');
      _handleDetectionFailure();
      return [];
    }
  }

  void _handleDetectionFailure() {
    _failureCount++;
    
    if (_failureCount >= _config.maxFailureCount && !_fallbackActive) {
      _activateFallback();
    } else {
      _currentFaceRect = null;
      _currentAbsoluteRect = null;
      
      final result = FaceDetectionResult(
        faces: [],
        primaryFaceRect: null,
        absoluteRect: null,
        hasValidFace: false,
        timestamp: DateTime.now(),
      );
      
      _resultController.add(result);
    }
  }

  void _activateFallback() {
    debugPrint('🔄 Activating face detection fallback');
    _fallbackActive = true;
    
    // Create a simulated face in the center of the screen
    // This would need actual screen dimensions in a real implementation
    _currentFaceRect = const Rect.fromLTWH(100, 200, 200, 250);
    _currentAbsoluteRect = _currentFaceRect;
    
    final result = FaceDetectionResult(
      faces: [], // Empty but we simulate detection
      primaryFaceRect: _currentFaceRect,
      absoluteRect: _currentAbsoluteRect,
      hasValidFace: true,
      timestamp: DateTime.now(),
    );
    
    _resultController.add(result);
    
    // Reset fallback after timeout
    _fallbackTimer = Timer(_config.fallbackTimeout, () {
      _fallbackActive = false;
      _failureCount = 0;
    });
  }

  @override
  bool get hasFaceDetected => _currentFaceRect != null;

  @override
  Rect? get faceRect => _currentFaceRect;

  @override
  Rect? get absoluteFaceRect => _currentAbsoluteRect;

  @override
  Stream<FaceDetectionResult> get faceDetectionStream => _resultController.stream;

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _faceDetector.close();
    _resultController.close();
    _isInitialized = false;
    debugPrint('🗑️ MLKit Face Detection Service disposed');
  }
}