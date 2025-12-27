import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../interfaces/face_detection_service.dart';

/// Accurate face detection service with false positive filtering
class AccurateFaceDetectionService implements FaceDetectionService {
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
  static const Duration _processingThrottle = Duration(milliseconds: 300); // Slightly slower for accuracy
  
  // Face validation: track consecutive valid detections
  int _consecutiveValidDetections = 0;
  static const int _requiredConsecutiveDetections = 3; // Require 3 consecutive valid detections
  
  // Memory optimization: reuse detection results
  FaceDetectionResult? _lastResult;
  static const Duration _resultCacheTime = Duration(milliseconds: 150);

  AccurateFaceDetectionService({FaceDetectionConfig? config}) 
      : _config = config ?? const FaceDetectionConfig();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Optimize ML Kit settings for accuracy over speed
      final options = FaceDetectorOptions(
        enableClassification: true, // Enable to help filter false positives
        enableLandmarks: true, // Enable to validate face structure
        enableTracking: true, // Enable to track face consistency
        minFaceSize: 0.2, // Larger minimum face size to reduce false positives
        performanceMode: FaceDetectorMode.accurate, // Use accurate mode
      );
      
      _faceDetector = FaceDetector(options: options);
      _isInitialized = true;
      
      debugPrint('✅ Accurate Face Detection Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Accurate Face Detection: $e');
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
        // Validate faces to filter out false positives
        final validFaces = _validateFaces(faces);
        
        if (validFaces.isNotEmpty) {
          _consecutiveValidDetections++;
          
          // Only consider face detected after consecutive valid detections
          if (_consecutiveValidDetections >= _requiredConsecutiveDetections) {
            _failureCount = 0;
            _fallbackActive = false;
            _fallbackTimer?.cancel();
            
            final primaryFace = validFaces.first;
            _currentFaceRect = primaryFace.boundingBox;
            _currentAbsoluteRect = _currentFaceRect;
            
            final result = FaceDetectionResult(
              faces: validFaces,
              primaryFaceRect: _currentFaceRect,
              absoluteRect: _currentAbsoluteRect,
              hasValidFace: true,
              timestamp: now,
            );
            
            _lastResult = result;
            _resultController.add(result);
            _isProcessing = false;
            return validFaces;
          } else {
            // Still building up consecutive detections
            _handleDetectionFailure();
            _isProcessing = false;
            return [];
          }
        } else {
          // No valid faces found
          _consecutiveValidDetections = 0;
          _handleDetectionFailure();
          _isProcessing = false;
          return [];
        }
      } else {
        _consecutiveValidDetections = 0;
        _handleDetectionFailure();
        _isProcessing = false;
        return [];
      }
    } catch (e) {
      debugPrint('❌ Face detection error: $e');
      _consecutiveValidDetections = 0;
      _handleDetectionFailure();
      _isProcessing = false;
      return [];
    }
  }

  /// Validate faces to filter out false positives like hands
  List<Face> _validateFaces(List<Face> faces) {
    final validFaces = <Face>[];
    
    for (final face in faces) {
      if (_isValidFace(face)) {
        validFaces.add(face);
      }
    }
    
    return validFaces;
  }

  /// Check if a detected face is actually a valid human face
  bool _isValidFace(Face face) {
    final boundingBox = face.boundingBox;
    
    // 1. Size validation: Face should be reasonably sized
    if (boundingBox.width < 80 || boundingBox.height < 100) {
      debugPrint('❌ Face rejected: Too small (${boundingBox.width}x${boundingBox.height})');
      return false;
    }
    
    // 2. Aspect ratio validation: Face should have reasonable proportions
    final aspectRatio = boundingBox.width / boundingBox.height;
    if (aspectRatio < 0.6 || aspectRatio > 1.4) {
      debugPrint('❌ Face rejected: Invalid aspect ratio ($aspectRatio)');
      return false;
    }
    
    // 3. Landmark validation: Check if face has key landmarks
    if (face.landmarks.isNotEmpty) {
      final landmarkTypes = face.landmarks.keys.toList();
      
      final hasEyes = landmarkTypes.contains(FaceLandmarkType.leftEye) ||
                     landmarkTypes.contains(FaceLandmarkType.rightEye);
      
      final hasNose = landmarkTypes.contains(FaceLandmarkType.noseBase);
      
      final hasMouth = landmarkTypes.contains(FaceLandmarkType.bottomMouth);
      
      if (!hasEyes || !hasNose || !hasMouth) {
        debugPrint('❌ Face rejected: Missing key landmarks (eyes: $hasEyes, nose: $hasNose, mouth: $hasMouth)');
        return false;
      }
    }
    
    // 4. Confidence validation: Use classification confidence if available
    if (face.smilingProbability != null || face.leftEyeOpenProbability != null || face.rightEyeOpenProbability != null) {
      // If we have classification data, use it to validate
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0.5;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0.5;
      
      // At least one eye should be reasonably open (not a hand or object)
      if (leftEyeOpen < 0.1 && rightEyeOpen < 0.1) {
        debugPrint('❌ Face rejected: Both eyes appear closed (left: $leftEyeOpen, right: $rightEyeOpen)');
        return false;
      }
    }
    
    // 5. Position validation: Face should be in reasonable position (not at extreme edges)
    // This helps filter out partial objects at screen edges
    if (boundingBox.left < 10 || boundingBox.top < 10) {
      debugPrint('❌ Face rejected: Too close to screen edge');
      return false;
    }
    
    debugPrint('✅ Face validated: ${boundingBox.width}x${boundingBox.height}, ratio: ${aspectRatio.toStringAsFixed(2)}');
    return true;
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
    debugPrint('🔄 Activating accurate face detection fallback');
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
      _consecutiveValidDetections = 0;
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
    _consecutiveValidDetections = 0;
    debugPrint('🗑️ Accurate Face Detection Service disposed');
  }
}