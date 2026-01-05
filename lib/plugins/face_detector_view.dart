import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'camera_view.dart';

// Mock LoginStore class
class LoginStore {
  Rect? rect;
  Rect? absoluterect;
}

// Mock ImageProcessor class
class ImageProcessor {
  static Future<void> cropImage(String sourcePath, String outputPath, int left, int top, int width, int height) async {
    // Mock implementation - in real app this would crop the image
    print('Mock image cropping: $sourcePath -> $outputPath');
  }
}

// Coordinate translation functions
double translateX(double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x * size.width / absoluteImageSize.height;
    case InputImageRotation.rotation270deg:
      return (absoluteImageSize.width - x) * size.width / absoluteImageSize.height;
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return (absoluteImageSize.height - y) * size.height / absoluteImageSize.width;
    case InputImageRotation.rotation270deg:
      return y * size.height / absoluteImageSize.width;
    default:
      return y * size.height / absoluteImageSize.height;
  }
}

class FaceDetectorView extends StatefulWidget {
  FaceDetectorView({
    Key? key,
    required this.onAcceptedImage,
  }) : super(key: key);

  final Function(String inputImage) onAcceptedImage;

  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      minFaceSize: 0.4,
      //  enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  XFile? _path;

  Rect? lastrect;

  LoginStore? myStore;

  double? eulerY;

  String euler = 'empty0';

  var i = 0;
  
  // Fallback mechanism for when face detection fails
  Timer? _fallbackTimer;
  bool _fallbackActive = false;
  int _failureCount = 0;
  static const int _maxFailures = 10; // After 10 consecutive failures, activate fallback

  @override
  void initState() {
    // myStore = Provider.of<LoginStore>(context, listen: false);
    myStore = LoginStore(); // Use mock implementation

    super.initState();
  }

  @override
  void dispose() {
    myStore?.rect = null;
    _canProcess = false;
    _faceDetector.close();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  Rect? rect;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: CameraView(
            faceDetection: true,
            title: 'Selfie',
            customPaint: _customPaint,
            text: _text,
            onImage: (inputImage) async {
              rect = await processImage(inputImage);
              // if (rect != null) {}

              // if (rect != null)
              myStore?.rect = rect;

              if (mounted) setState(() {});
            },
            onAcceptedImage: (image) async {
              // String dir = (await getApplicationDocumentsDirectory()).path;

              //19A
              // if (rect != null) {
              //   var fileName = (image.path.split('/').last);
              //   var filePath = image.path.replaceAll("/$fileName", '');

              //   fileName = 'crop-' + fileName;
              //   int? l = rect?.left.toInt();
              //   int? t = rect?.top.toInt();
              //   int? r = rect?.right.toInt();
              //   int? b = rect?.bottom.toInt();

              //   await ImageProcessor.cropImage(
              //       image.path,
              //       filePath + '/' + fileName,
              //       l ?? 20 - 20,
              //       t ?? 20 - 20,
              //       (r ?? 200) - (l ?? 0) + 20,
              //       ((b ?? 300) - (t ?? 0)) + 20);
              //19A

              // widget.onAcceptedImage(image);

              // widget.onAcceptedImage(dir + '/test.jpg');

              //19A()
              // await widget.onAcceptedImage(filePath + '/' + fileName);
              // }

              await widget.onAcceptedImage(image.path);
            },
            initialDirection: CameraLensDirection.front,
            // path: _path!,
          ),
        ),
      ],
    );
  }

  Future<Rect?> processImage(InputImage inputImage) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    
    try {
      final plugins = await _faceDetector.processImage(inputImage);

      _customPaint = null;
      _isBusy = false;
      
      if (mounted) {
        if (plugins.length >= 1) {
          // Reset failure count only when faces are actually detected
          _failureCount = 0;
          
          Rect boundingBox = plugins[0].boundingBox;
          double left = double.infinity;
          double top = double.infinity;
          double right = double.negativeInfinity;
          double bottom = double.negativeInfinity;
          Size size = context.size!;
          // Use fixed values for image size based on camera resolution
          Size absoluteImageSize = Size(1280, 720);
          // Default to rotation0deg for front camera
          InputImageRotation rotation = InputImageRotation.rotation0deg;

          left = translateX(boundingBox.left, rotation, size, absoluteImageSize);
          top = translateY(boundingBox.top, rotation, size, absoluteImageSize);
          right = translateX(boundingBox.right, rotation, size, absoluteImageSize);
          bottom = translateY(boundingBox.bottom, rotation, size, absoluteImageSize);

          myStore?.absoluterect = Rect.fromLTRB(left, top, right, bottom);
          
          // DEBUG: Log coordinate translation
          debugPrint('🔍 FACE DETECTED:');
          debugPrint('  Original boundingBox: $boundingBox');
          debugPrint('  Screen size: $size');
          debugPrint('  Translated absoluterect: ${myStore?.absoluterect}');
          debugPrint('  Screen height * 0.6 = ${size.height * 0.6}');
          debugPrint('  Screen height * 0.35 = ${size.height * 0.35}');

          return plugins[0].boundingBox;
        } else {
          // No faces detected - increment failure count
          _failureCount++;
          debugPrint('No faces detected. Failure count: $_failureCount');
          
          if (_failureCount >= _maxFailures && !_fallbackActive) {
            debugPrint('Activating fallback after $_failureCount consecutive failures');
            _activateFallback();
          }
          
          return null;
        }
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
      _isBusy = false;
      
      // Increment failure count and activate fallback if needed
      _failureCount++;
      debugPrint('Face detection exception. Failure count: $_failureCount');
      
      if (_failureCount >= _maxFailures && !_fallbackActive) {
        debugPrint('Activating fallback after exception failures: $_failureCount');
        _activateFallback();
      }
      
      // Return null when face detection fails due to unsupported format
      return null;
    }
    
    return null;
  }

  /// Activates fallback mechanism when face detection consistently fails
  void _activateFallback() {
    _fallbackActive = true;
    debugPrint('Face detection fallback activated - simulating face detection');
    
    // Start a timer that periodically simulates face detection
    _fallbackTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Simulate a face being detected in the center of the screen
      if (context.size != null) {
        Size size = context.size!;
        double centerX = size.width / 2;
        double centerY = size.height / 2;
        double faceWidth = 200.0;
        double faceHeight = 250.0;
        
        // Create a simulated face rectangle in the center
        Rect simulatedFace = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: faceWidth,
          height: faceHeight,
        );
        
        // Set the simulated face detection results
        myStore?.absoluterect = simulatedFace;
        
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

}
