import 'dart:async';

import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../interfaces/camera_service.dart';

/// Flutter Camera implementation of camera service
class FlutterCameraService implements CameraService {
  CameraController? _controller;
  final CameraConfig _config;
  CameraState _state = CameraState.uninitialized;
  
  final StreamController<CameraImage> _imageStreamController = StreamController<CameraImage>.broadcast();
  final StreamController<InputImage> _inputImageStreamController = StreamController<InputImage>.broadcast();
  
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  FlutterCameraService({CameraConfig? config}) 
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
        resolution,
        enableAudio: _config.enableAudio,
        imageFormatGroup: ImageFormatGroup.nv21, // Use NV21 for better compatibility
      );
      
      await _controller!.initialize();
      
      _state = CameraState.initialized;
      debugPrint('✅ Camera Service initialized with ${camera.lensDirection} camera');
      
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
      debugPrint('✅ Camera preview started');
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
      debugPrint('✅ Camera preview stopped');
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
      // Stop image stream before taking picture
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
        _config.resolution,
        enableAudio: _config.enableAudio,
        imageFormatGroup: _config.imageFormatGroup,
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
    _imageStreamController.add(image);
    
    // Convert to InputImage for ML Kit
    _convertToInputImage(image).then((inputImage) {
      if (inputImage != null) {
        _inputImageStreamController.add(inputImage);
      }
    }).catchError((e) {
      debugPrint('❌ Failed to convert camera image: $e');
    });
  }

  Future<InputImage?> _convertToInputImage(CameraImage image) async {
    try {
      // For NV21 format, we need to handle YUV420 properly
      if (image.format.group == ImageFormatGroup.nv21) {
        return await _convertNv21ToInputImage(image);
      } else if (image.format.group == ImageFormatGroup.yuv420) {
        return await _convertYuv420ToNv21(image);
      } else {
        // Fallback for other formats
        debugPrint('⚠️ Unsupported format: ${image.format.group}, trying direct conversion');
        return await _convertGenericToInputImage(image);
      }
    } catch (e) {
      debugPrint('❌ Error converting camera image: $e');
      return null;
    }
  }

  Future<InputImage?> _convertNv21ToInputImage(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = _cameras[_currentCameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      
      if (imageRotation == null) return null;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      debugPrint('❌ Error converting NV21: $e');
      return null;
    }
  }

  Future<InputImage?> _convertYuv420ToNv21(CameraImage image) async {
    try {
      if (image.planes.length != 3) {
        debugPrint('⚠️ YUV420 format with ${image.planes.length} planes, expected 3');
        return null;
      }

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final yBytes = yPlane.bytes;
      final uBytes = uPlane.bytes;
      final vBytes = vPlane.bytes;

      final int yLength = yBytes.length;
      final int uvLength = uBytes.length;

      final List<int> nv21Bytes = List<int>.filled(yLength + (uvLength * 2), 0);

      // Copy Y plane
      nv21Bytes.setRange(0, yLength, yBytes);

      // Interleave U and V into NV21 format
      for (int i = 0; i < uvLength; i++) {
        if (i < vBytes.length) {
          nv21Bytes[yLength + (i * 2)] = uBytes[i];
          nv21Bytes[yLength + (i * 2) + 1] = vBytes[i];
        }
      }

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = _cameras[_currentCameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      
      if (imageRotation == null) return null;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: yPlane.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: Uint8List.fromList(nv21Bytes), metadata: inputImageData);
    } catch (e) {
      debugPrint('❌ Error converting YUV420 to NV21: $e');
      return null;
    }
  }

  Future<InputImage?> _convertGenericToInputImage(CameraImage image) async {
    try {
      // For other formats, try to combine planes directly
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = _cameras[_currentCameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      
      if (imageRotation == null) return null;

      // Try to detect supported format
      InputImageFormat format;
      if (image.format.group == ImageFormatGroup.bgra8888) {
        format = InputImageFormat.bgra8888;
      } else {
        // Default fallback to NV21
        format = InputImageFormat.nv21;
      }

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      debugPrint('❌ Error in generic conversion: $e');
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
    debugPrint('🗑️ Camera Service disposed');
  }
}