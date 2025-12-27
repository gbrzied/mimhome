import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../interfaces/face_detection_service.dart';

/// Optimized ML Kit implementation with performance improvements
class OptimizedFaceDetectionService implements FaceDetectionService {
  late FaceDetector _faceDetector;
  final FaceDetectionConfig _config;
  final StreamController<FaceDetectionResult> _resultController = StreamController<FaceDetectionResult>.broadcast();
  
  Rect? _currentFaceRect;
  Rect? _currentAbsoluteRect;
  bool _isInitialized = false;
  int _failureCount = 0;
  bool _fallbackActive = false;
  Timer? _fallbackTimer;
  
  // Performance optimization: throttle face detection
  bool _isProcessing = false;
  DateTime _lastProcessTime = DateTime.now();
  static const Duration _processingThrottle = Duration(milliseconds: 200); // Limit to 5 FPS max
  
  // Memory optimization: reuse detection results
  FaceDetectionResult? _lastResult;
  static const Duration _resultCacheTime = Duration(milliseconds: 100);

  OptimizedFaceDetectionService({FaceDetectionConfig? config}) 
      : _config = config ?? const FaceDetectionConfig();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Optimize ML Kit settings for performance
      final options = FaceDetectorOptions(
        enableClassification: false, // Disable to improve performance
        enableLandmarks: false, // Disable to improve performance
        enableTracking: false, // Disable to improve performance
        minFaceSize: 0.15, // Slightly larger minimum face size
        performanceMode: FaceDetectorMode.fast, // Use fast mode
      );
      
      _faceDetector = FaceDetector(options: options);
      _isInitialized = true;
      
      debugPrint('✅ Optimized Face Detection Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Optimized Face Detection: $e');
      throw Exception('Failed to initialize face detection: $e');
    }
  }

  @override
  Future<List<Face>> detectFaces(InputImage inputImage) async {
    if (!_isInitialized) {
      throw Exception('Face detection service not initialized');
    }

    // Performance throttling: skip processing if too frequent
    final now = DateTime.now();
    if (_isProcessing || now.difference(_lastProcessTime) < _processingThrottle) {
      // Return cached result if available and recent
      if (_lastResult != null && now.difference(_lastResult!.timestamp) < _resultCacheTime) {
        return _lastResult!.faces;
      }
      return [];
    }

    _isProcessing = true;
    _lastProcessTime = now;

    try {
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isNotEmpty) {
        _failureCount = 0;
        _fallbackActive = false;
        _fallbackTimer?.cancel();
        
        final primaryFace = faces.first;
        _currentFaceRect = primaryFace.boundingBox;
        _currentAbsoluteRect = _currentFaceRect;
        
        final result = FaceDetectionResult(
          faces: faces,
          primaryFaceRect: _currentFaceRect,
          absoluteRect: _currentAbsoluteRect,
          hasValidFace: true,
          timestamp: now,
        );
        
        _lastResult = result;
        _resultController.add(result);
        _isProcessing = false;
        return faces;
      } else {
        _handleDetectionFailure();
        _isProcessing = false;
        return [];
      }
    } catch (e) {
      debugPrint('❌ Face detection error: $e');
      _handleDetectionFailure();
      _isProcessing = false;
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
      
      _lastResult = result;
      _resultController.add(result);
    }
  }

  void _activateFallback() {
    debugPrint('🔄 Activating optimized face detection fallback');
    _fallbackActive = true;
    
    // Create a simulated face in the center of the screen
    _currentFaceRect = const Rect.fromLTWH(100, 200, 200, 250);
    _currentAbsoluteRect = _currentFaceRect;
    
    final result = FaceDetectionResult(
      faces: [], // Empty but we simulate detection
      primaryFaceRect: _currentFaceRect,
      absoluteRect: _currentAbsoluteRect,
      hasValidFace: true,
      timestamp: DateTime.now(),
    );
    
    _lastResult = result;
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
    _isProcessing = false;
    _lastResult = null;
    debugPrint('🗑️ Optimized Face Detection Service disposed');
  }
}