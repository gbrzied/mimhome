import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/utils/image_processing_utils.dart';
import '../interfaces/selfie_capture_service.dart';
import '../interfaces/camera_service.dart';
import '../interfaces/face_detection_service.dart';

/// Implementation of selfie capture service
class SelfieCaptureServiceImpl implements SelfieCaptureService {
  final CameraService _cameraService;
  final FaceDetectionService _faceDetectionService;
  
  SelfieCaptureConfig? _config;
  SelfieCaptureState _currentState = SelfieCaptureState.idle;
  int _countdownValue = 0;
  bool _isInitialized = false;
  
  Timer? _countdownTimer;
  StreamSubscription? _faceDetectionSubscription;
  StreamSubscription? _cameraImageSubscription;
  
  final StreamController<SelfieCaptureState> _stateController = StreamController<SelfieCaptureState>.broadcast();
  final StreamController<int> _countdownController = StreamController<int>.broadcast();
  
  // Store the last capture result
  SelfieCaptureResult? _lastCaptureResult;

  SelfieCaptureServiceImpl({
    required CameraService cameraService,
    required FaceDetectionService faceDetectionService,
  }) : _cameraService = cameraService,
       _faceDetectionService = faceDetectionService;

  @override
  Future<void> initialize(SelfieCaptureConfig config) async {
    if (_isInitialized) return;
    
    _config = config;
    _countdownValue = config.countdownDuration;
    
    try {
      // Initialize services
      await _faceDetectionService.initialize();
      await _cameraService.initialize(
        direction: CameraLensDirection.front,
        resolution: ResolutionPreset.medium,
      );
      
      // Set up face detection stream
      _faceDetectionSubscription = _faceDetectionService.faceDetectionStream.listen(_onFaceDetectionResult);
      
      // Set up camera image stream for face detection
      _cameraImageSubscription = _cameraService.inputImageStream.listen(_onCameraImage);
      
      _isInitialized = true;
      _updateState(SelfieCaptureState.idle);
      
      debugPrint('✅ Selfie Capture Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Selfie Capture Service: $e');
      _updateState(SelfieCaptureState.error);
      throw Exception('Failed to initialize selfie capture service: $e');
    }
  }

  @override
  Future<void> startCapture() async {
    if (!_isInitialized || _config == null) {
      throw Exception('Service not initialized');
    }
    
    if (_currentState == SelfieCaptureState.capturing || 
        _currentState == SelfieCaptureState.countdownStarted) {
      debugPrint('⚠️ Capture already in progress');
      return;
    }
    
    try {
      // Start camera preview
      await _cameraService.startPreview();
      
      if (_config!.requireFaceDetection) {
        _updateState(SelfieCaptureState.waitingForFace);
        debugPrint('👁️ Waiting for face detection...');
      } else {
        _startCountdown();
      }
    } catch (e) {
      debugPrint('❌ Failed to start capture: $e');
      _updateState(SelfieCaptureState.error);
    }
  }

  @override
  Future<void> stopCapture() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    
    try {
      await _cameraService.stopPreview();
      _updateState(SelfieCaptureState.cancelled);
      debugPrint('🛑 Capture stopped');
    } catch (e) {
      debugPrint('❌ Failed to stop capture: $e');
    }
  }

  void _onFaceDetectionResult(FaceDetectionResult result) {
    if (!_isInitialized || _config == null) return;
    
    if (result.hasValidFace) {
      if (_currentState == SelfieCaptureState.waitingForFace) {
        _updateState(SelfieCaptureState.faceDetected);
        debugPrint('👤 Face detected, starting countdown...');
        _startCountdown();
      }
    } else {
      if (_currentState == SelfieCaptureState.faceDetected || 
          _currentState == SelfieCaptureState.countdownStarted) {
        if (_config!.requireFaceDetection) {
          _stopCountdown();
          _updateState(SelfieCaptureState.waitingForFace);
          debugPrint('❌ Face lost, stopping countdown');
        }
      }
    }
  }

  void _onCameraImage(inputImage) {
    if (!_isInitialized) return;
    
    // Process image for face detection with error handling
    _faceDetectionService.detectFaces(inputImage).catchError((e) {
      debugPrint('❌ Face detection error: $e');
      // Don't let face detection errors crash the app
      return <Face>[];
    });
  }

  void _startCountdown() {
    if (_countdownTimer != null) return;
    
    _countdownValue = _config!.countdownDuration;
    _updateState(SelfieCaptureState.countdownStarted);
    _countdownController.add(_countdownValue);
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownValue--;
      _countdownController.add(_countdownValue);
      
      debugPrint('⏰ Countdown: $_countdownValue');
      
      if (_countdownValue <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _capturePhoto();
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownValue = _config!.countdownDuration;
  }

  Future<void> _capturePhoto() async {
    _updateState(SelfieCaptureState.capturing);
    
    try {
      final photo = await _cameraService.takePicture();
      
      if (photo != null) {
        _updateState(SelfieCaptureState.processing);
        
        // Process the captured image
        final result = await _processImage(File(photo.path));
        
        // Store the result for later retrieval
        _lastCaptureResult = result;
        
        if (result.isSuccess) {
          _updateState(SelfieCaptureState.completed);
          debugPrint('✅ Selfie captured successfully: ${result.originalImage?.path}');
        } else {
          _updateState(SelfieCaptureState.error);
          debugPrint('❌ Failed to process captured image');
        }
      } else {
        _updateState(SelfieCaptureState.error);
        debugPrint('❌ Failed to capture photo');
      }
    } catch (e) {
      _updateState(SelfieCaptureState.error);
      debugPrint('❌ Error during photo capture: $e');
    }
  }

  Future<SelfieCaptureResult> _processImage(File originalImage) async {
    try {
      File? croppedImage;
      Rect? faceRect;
      
      if (_config!.cropToFace && _faceDetectionService.hasFaceDetected) {
        faceRect = _faceDetectionService.faceRect;
        
        if (faceRect != null) {
          debugPrint('🖼️ Starting face cropping with rect: $faceRect');
          
          try {
            // Get original image dimensions
            final imageSize = await ImageProcessingUtils.getImageSize(originalImage);
            
            // Validate face for cropping
            if (ImageProcessingUtils.isValidFaceForCropping(faceRect, imageSize)) {
              // Apply face cropping with padding and optimal sizing
              final croppedFile = await ImageProcessingUtils.cropImageToFace(
                originalImage,
                faceRect,
                padding: 80, // Increased padding for better framing
                outputSize: const Size(400, 400), // Standard square output for selfies
              );
              
              croppedImage = croppedFile;
              debugPrint('✅ Image cropped successfully to face region');
            } else {
              debugPrint('⚠️ Face coordinates not suitable for cropping, using original');
              croppedImage = originalImage;
            }
          } catch (cropError) {
            debugPrint('❌ Cropping failed: $cropError, using original image');
            croppedImage = originalImage;
          }
        } else {
          debugPrint('⚠️ No valid face rectangle found, using original image');
          croppedImage = originalImage;
        }
      } else {
        croppedImage = originalImage;
        debugPrint('🖼️ Face cropping disabled, using original image');
      }
      
      return SelfieCaptureResult(
        originalImage: _config!.saveOriginal ? originalImage : null,
        croppedImage: croppedImage ?? originalImage,
        faceRect: faceRect,
        state: SelfieCaptureState.completed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Image processing error: $e');
      return SelfieCaptureResult(
        state: SelfieCaptureState.error,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  void _updateState(SelfieCaptureState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  bool get isCaptureInProgress => 
      _currentState == SelfieCaptureState.capturing ||
      _currentState == SelfieCaptureState.processing ||
      _currentState == SelfieCaptureState.countdownStarted;

  @override
  bool get isCountdownActive => _countdownTimer != null;

  @override
  int get countdownValue => _countdownValue;

  @override
  Stream<SelfieCaptureState> get captureStateStream => _stateController.stream;

  @override
  Stream<int> get countdownStream => _countdownController.stream;

  @override
  Future<SelfieCaptureResult?> getLastCaptureResult() async {
    return _lastCaptureResult;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _faceDetectionSubscription?.cancel();
    _cameraImageSubscription?.cancel();
    _stateController.close();
    _countdownController.close();
    _faceDetectionService.dispose();
    _cameraService.dispose();
    _isInitialized = false;
    debugPrint('🗑️ Selfie Capture Service disposed');
  }
}