import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../interfaces/camera_service.dart';

/// Optimized Flutter Camera implementation with memory management
class OptimizedCameraService implements CameraService {
  CameraController? _controller;
  final CameraConfig _config;
  CameraState _state = CameraState.uninitialized;
  
  final StreamController<CameraImage> _imageStreamController = StreamController<CameraImage>.broadcast();
  final StreamController<InputImage> _inputImageStreamController = StreamController<InputImage>.broadcast();
  
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  
  // Performance optimization: throttle image processing
  bool _isProcessingImage = false;
  DateTime _lastImageProcessTime = DateTime.now();
  static const Duration _imageProcessThrottle = Duration(milliseconds: 200); // 5 FPS max
  
  // Memory optimization: limit concurrent image processing
  int _activeImageProcessingCount = 0;
  static const int _maxConcurrentProcessing = 2;

  OptimizedCameraService({CameraConfig? config}) 
      : _config = config ?? const CameraConfig();

  @override
  Future<void> initialize({
    CameraLensDirection direction = CameraLensDirection.front,
    ResolutionPreset resolution = ResolutionPreset.medium,
  }) async {
    if (_state != CameraState.uninitialized) {
      dispose();
    }
    
    _state = CameraState.initializing;
    
    try {
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Find camera with specified direction
      _currentCameraIndex = _cameras.indexWhere((camera) => camera.lensDirection == direction);
      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0; // Fallback to first camera
      }
      
      final camera = _cameras[_currentCameraIndex];
      
      _controller = CameraController(
        camera,
        ResolutionPreset.low, // Use lower resolution for better performance
        enableAudio: false, // Always disable audio for selfie
        imageFormatGroup: ImageFormatGroup.nv21, // Optimized format
      );
      
      await _controller!.initialize();
      
      _state = CameraState.initialized;
      debugPrint('✅ Optimized Camera Service initialized with ${camera.lensDirection} camera');
      
    } catch (e) {
      _state = CameraState.error;
      debugPrint('❌ Failed to initialize camera: $e');
      throw Exception('Failed to initialize camera: $e');
    }
  }

  @override
  Future<void> startPreview() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    if (_state == CameraState.streaming) return;
    
    try {
      await _controller!.startImageStream(_onCameraImage);
      _state = CameraState.streaming;
      debugPrint('✅ Optimized camera preview started');
    } catch (e) {
      _state = CameraState.error;
      debugPrint('❌ Failed to start camera preview: $e');
      throw Exception('Failed to start camera preview: $e');
    }
  }

  @override
  Future<void> stopPreview() async {
    if (_controller == null || _state != CameraState.streaming) return;
    
    try {
      await _controller!.stopImageStream();
      _state = CameraState.initialized;
      debugPrint('✅ Optimized camera preview stopped');
    } catch (e) {
      debugPrint('❌ Failed to stop camera preview: $e');
    }
  }

  @override
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    if (_controller!.value.isTakingPicture) {
      debugPrint('⚠️ Camera is already taking a picture');
      return null;
    }
    
    _state = CameraState.takingPicture;
    
    try {
      // Stop image stream before taking picture to free memory
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      
      final XFile picture = await _controller!.takePicture();
      
      _state = CameraState.initialized;
      debugPrint('✅ Picture taken: ${picture.path}');
      
      return picture;
    } catch (e) {
      _state = CameraState.error;
      debugPrint('❌ Failed to take picture: $e');
      throw Exception('Failed to take picture: $e');
    }
  }

  @override
  Future<void> switchCamera() async {
    if (_cameras.length <= 1) {
      debugPrint('⚠️ Only one camera available, cannot switch');
      return;
    }
    
    try {
      await stopPreview();
      
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      final newCamera = _cameras[_currentCameraIndex];
      
      await _controller?.dispose();
      
      _controller = CameraController(
        newCamera,
        ResolutionPreset.low, // Keep low resolution for performance
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      
      await _controller!.initialize();
      _state = CameraState.initialized;
      
      debugPrint('✅ Switched to ${newCamera.lensDirection} camera');
    } catch (e) {
      _state = CameraState.error;
      debugPrint('❌ Failed to switch camera: $e');
      throw Exception('Failed to switch camera: $e');
    }
  }

  void _onCameraImage(CameraImage image) {
    // Performance throttling: skip processing if too frequent or too many concurrent
    final now = DateTime.now();
    if (_isProcessingImage || 
        _activeImageProcessingCount >= _maxConcurrentProcessing ||
        now.difference(_lastImageProcessTime) < _imageProcessThrottle) {
      return; // Skip this frame to maintain performance
    }

    _isProcessingImage = true;
    _lastImageProcessTime = now;
    _activeImageProcessingCount++;

    // Add to image stream (non-blocking)
    _imageStreamController.add(image);
    
    // Convert to InputImage for ML Kit (async to avoid blocking)
    _convertToInputImageAsync(image).then((inputImage) {
      if (inputImage != null) {
        _inputImageStreamController.add(inputImage);
      }
    }).catchError((e) {
      debugPrint('❌ Failed to convert camera image: $e');
    }).whenComplete(() {
      _isProcessingImage = false;
      _activeImageProcessingCount--;
    });
  }

  Future<InputImage?> _convertToInputImageAsync(CameraImage image) async {
    try {
      // Optimize memory usage by processing in chunks
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final camera = _cameras[_currentCameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) return null;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return null;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      debugPrint('❌ Error converting camera image: $e');
      return null;
    }
  }

  @override
  CameraController? get controller => _controller;

  @override
  bool get isInitialized => _state == CameraState.initialized || _state == CameraState.streaming;

  @override
  bool get isStreaming => _state == CameraState.streaming;

  @override
  Stream<CameraImage> get imageStream => _imageStreamController.stream;

  @override
  Stream<InputImage> get inputImageStream => _inputImageStreamController.stream;

  @override
  CameraConfig get config => _config;

  @override
  void dispose() {
    _controller?.dispose();
    _imageStreamController.close();
    _inputImageStreamController.close();
    _state = CameraState.disposed;
    _isProcessingImage = false;
    _activeImageProcessingCount = 0;
    debugPrint('🗑️ Optimized Camera Service disposed');
  }
}