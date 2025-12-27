import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../core/app_export.dart';
import '../../services/interfaces/camera_service.dart';
import '../../services/interfaces/face_detection_service.dart';
import '../../services/interfaces/selfie_capture_service.dart';
import '../../services/implementations/flutter_camera_service.dart';
import '../../services/implementations/optimized_face_detection_service.dart';
import '../../services/implementations/selfie_capture_service_impl.dart';

/// Clean Selfie Page using proper service architecture for reliable face detection
class CleanSelfiePage extends StatefulWidget {
  final String title;
  final Function(File)? onImageCaptured;

  const CleanSelfiePage({
    super.key,
    this.title = 'Prendre un selfie',
    this.onImageCaptured,
  });

  @override
  State<CleanSelfiePage> createState() => _CleanSelfiePageState();
}

class _CleanSelfiePageState extends State<CleanSelfiePage> with WidgetsBindingObserver {
  
  // Service instances
  late final CameraService _cameraService;
  late final FaceDetectionService _faceDetectionService;
  late final SelfieCaptureService _selfieCaptureService;
  
  // State management
  SelfieCaptureState _captureState = SelfieCaptureState.idle;
  int _countdownValue = 0;
  File? _capturedImage;
  bool _showImagePreview = false;
  bool _isInitialized = false;
  
  // Stream subscriptions
  StreamSubscription<SelfieCaptureState>? _stateSubscription;
  StreamSubscription<int>? _countdownSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize services with optimized configuration
      _cameraService = FlutterCameraService();
      _faceDetectionService = OptimizedFaceDetectionService(
        config: const FaceDetectionConfig(
          minFaceSize: 0.1, // Reasonable minimum face size
          enableTracking: true,
          enableClassification: false,
          enableLandmarks: false,
          maxFailureCount: 15, // More tolerance for detection failures
          fallbackTimeout: Duration(seconds: 8),
        ),
      );
      
      _selfieCaptureService = SelfieCaptureServiceImpl(
        cameraService: _cameraService,
        faceDetectionService: _faceDetectionService,
      );

      // Configure selfie capture
      final config = const SelfieCaptureConfig(
        countdownDuration: 5,
        requireFaceDetection: true,
        requireFacePositioning: false,
        minFaceSize: 0.1,
        enableFallback: true,
        fallbackTimeout: Duration(seconds: 8),
        cropToFace: true,
        saveOriginal: false,
      );

      await _selfieCaptureService.initialize(config);

      // Listen to state changes
      _stateSubscription = _selfieCaptureService.captureStateStream.listen(_onStateChanged);
      _countdownSubscription = _selfieCaptureService.countdownStream.listen(_onCountdownChanged);

      setState(() {
        _isInitialized = true;
      });

      debugPrint('✅ CleanSelfiePage services initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'initialisation: $e'),
            backgroundColor: appTheme.colorF98600,
          ),
        );
      }
    }
  }

  void _onStateChanged(SelfieCaptureState newState) {
    setState(() {
      _captureState = newState;
    });

    // Handle specific state changes
    switch (newState) {
      case SelfieCaptureState.completed:
        _handleCaptureCompleted();
        break;
      case SelfieCaptureState.error:
        _handleCaptureError();
        break;
      case SelfieCaptureState.cancelled:
        _handleCaptureCancelled();
        break;
      default:
        break;
    }

    debugPrint('📊 Selfie state changed to: $newState');
  }

  void _onCountdownChanged(int value) {
    setState(() {
      _countdownValue = value;
    });
  }

  void _handleCaptureCompleted() async {
    final result = await _selfieCaptureService.getLastCaptureResult();
    if (result != null && result.isSuccess) {
      setState(() {
        _capturedImage = result.croppedImage ?? result.originalImage;
        _showImagePreview = true;
      });
      debugPrint('✅ Selfie captured successfully: ${_capturedImage?.path}');
    }
  }

  void _handleCaptureError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Erreur lors de la capture du selfie'),
        backgroundColor: appTheme.colorF98600,
      ),
    );
  }

  void _handleCaptureCancelled() {
    setState(() {
      _showImagePreview = false;
      _capturedImage = null;
    });
  }

  Future<void> _startCapture() async {
    if (!_isInitialized) return;
    
    try {
      await _selfieCaptureService.startCapture();
    } catch (e) {
      debugPrint('❌ Failed to start capture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: appTheme.colorF98600,
        ),
      );
    }
  }

  Future<void> _stopCapture() async {
    if (!_isInitialized) return;
    
    try {
      await _selfieCaptureService.stopCapture();
    } catch (e) {
      debugPrint('❌ Failed to stop capture: $e');
    }
  }

  void _acceptImage() {
    if (_capturedImage != null) {
      widget.onImageCaptured?.call(_capturedImage!);
      Navigator.of(context).pop(_capturedImage);
    }
  }

  void _rejectImage() {
    setState(() {
      _capturedImage = null;
      _showImagePreview = false;
    });
    
    // Restart the capture process
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startCapture();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    if (state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      _stopCapture();
    } else if (state == AppLifecycleState.resumed) {
      // Restart capture when returning to the app
      if (_captureState == SelfieCaptureState.idle && !_showImagePreview) {
        _startCapture();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _capturedImage == null,
      onPopInvoked: (didPop) async {
        if (!didPop && _capturedImage != null) {
          Navigator.of(context).pop(_capturedImage);
        } else if (didPop) {
          await _stopCapture();
        }
      },
      child: Scaffold(
        backgroundColor: appTheme.black_900,
        appBar: AppBar(
          backgroundColor: appTheme.primaryColor,
          title: Text(
            widget.title,
            style: TextStyleHelper.instance.title18SemiBoldSyne
                .copyWith(color: appTheme.onPrimary),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: appTheme.onPrimary,
            ),
            onPressed: () async {
              await _stopCapture();
              if (_capturedImage != null) {
                Navigator.of(context).pop(_capturedImage);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: _buildBody(),
        floatingActionButton: _showImagePreview ? null : _buildCaptureButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildBody() {
    if (_captureState == SelfieCaptureState.completed && _showImagePreview && _capturedImage != null) {
      return _buildImagePreview();
    }

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Initialisation de la caméra...',
              style: TextStyleHelper.instance.body14SemiBoldManrope
                  .copyWith(color: appTheme.white_A700),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        if (_cameraService.controller != null)
          CameraPreview(_cameraService.controller!),

        // Selfie Overlay
        _buildSelfieOverlay(),

        // Status Information
        _buildStatusInfo(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      color: appTheme.black_900,
      child: Column(
        children: [
          // Image display
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: appTheme.gray_300,
                  width: 2.h,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.h),
                child: Image.file(
                  _capturedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: appTheme.gray_200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              color: appTheme.gray_600,
                              size: 50.h,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Erreur de chargement',
                              style: TextStyleHelper.instance.body12RegularManrope
                                  .copyWith(color: appTheme.gray_600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Accept/Reject buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.h, vertical: 24.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                SizedBox(
                  width: 64.h,
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: _rejectImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.colorF98600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.h),
                      ),
                      elevation: 4.h,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 32.h,
                      color: appTheme.white_A700,
                    ),
                  ),
                ),

                // Accept button
                SizedBox(
                  width: 64.h,
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: _acceptImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.h),
                      ),
                      elevation: 4.h,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 32.h,
                      color: appTheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfieOverlay() {
    final hasFace = _captureState == SelfieCaptureState.faceDetected ||
                   _captureState == SelfieCaptureState.countdownStarted ||
                   _captureState == SelfieCaptureState.capturing;

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.only(top: 20.h),
        child: Container(
          height: 300.h,
          width: 240.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasFace ? appTheme.primaryColor : appTheme.colorF98600,
              width: 4.h,
            ),
            borderRadius: BorderRadius.circular(150.h),
          ),
          child: Stack(
            children: [
              // Corner indicators
              Positioned(
                top: -2.h,
                left: -2.h,
                child: Container(
                  width: 24.h,
                  height: 24.h,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                      left: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -2.h,
                right: -2.h,
                child: Container(
                  width: 24.h,
                  height: 24.h,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                      right: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2.h,
                left: -2.h,
                child: Container(
                  width: 24.h,
                  height: 24.h,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                      left: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2.h,
                right: -2.h,
                child: Container(
                  width: 24.h,
                  height: 24.h,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                      right: BorderSide(color: hasFace ? appTheme.primaryColor : appTheme.colorF98600, width: 4.h),
                    ),
                  ),
                ),
              ),

              // Center instruction text
              if (_captureState == SelfieCaptureState.waitingForFace)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.h),
                    child: Text(
                      'Positionnez votre visage ici',
                      style: TextStyleHelper.instance.body14SemiBoldManrope
                          .copyWith(color: appTheme.white_A700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Positioned(
      bottom: 120.h,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Instructions icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.face,
                color: appTheme.white_A700,
                size: 28.h,
              ),
              SizedBox(width: 16.h),
              Icon(
                Icons.no_encryption_gmailerrorred,
                color: appTheme.white_A700,
                size: 28.h,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Status text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.h),
            child: Text(
              _getStatusText(),
              style: TextStyleHelper.instance.body14SemiBoldManrope
                  .copyWith(color: appTheme.white_A700),
              textAlign: TextAlign.center,
            ),
          ),

          // Countdown display
          if (_captureState == SelfieCaptureState.countdownStarted)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Container(
                width: 80.h,
                height: 80.h,
                decoration: BoxDecoration(
                  color: appTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _countdownValue.toString(),
                    style: TextStyleHelper.instance.title38BoldQuicksand
                        .copyWith(
                          color: appTheme.onPrimary,
                          fontSize: 36.h,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    final canStart = _captureState == SelfieCaptureState.idle || 
                    _captureState == SelfieCaptureState.waitingForFace;

    return Container(
      margin: EdgeInsets.only(bottom: 32.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Manual capture button
          SizedBox(
            width: 80.h,
            height: 80.h,
            child: ElevatedButton(
              onPressed: canStart ? _manualCapture : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? appTheme.colorF98600 : appTheme.gray_600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.h),
                ),
                elevation: 8.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: appTheme.white_A700,
                    size: 32.h,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'MANUAL',
                    style: TextStyle(
                      fontSize: 10.h,
                      fontWeight: FontWeight.w600,
                      color: appTheme.white_A700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20.h),
          // Auto capture button
          SizedBox(
            width: 80.h,
            height: 80.h,
            child: ElevatedButton(
              onPressed: canStart ? _startCapture : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? appTheme.primaryColor : appTheme.gray_600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.h),
                ),
                elevation: 8.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.face,
                    color: appTheme.white_A700,
                    size: 32.h,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'AUTO',
                    style: TextStyle(
                      fontSize: 10.h,
                      fontWeight: FontWeight.w600,
                      color: appTheme.white_A700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _manualCapture() {
    debugPrint('📷 Manual capture initiated');
    // For manual capture, we stop face detection requirement
    _stopCapture().then((_) async {
      // Take picture directly without face detection
      try {
        final photo = await _cameraService.takePicture();
        if (photo != null) {
          setState(() {
            _capturedImage = File(photo.path);
            _showImagePreview = true;
            _captureState = SelfieCaptureState.completed;
          });
        }
      } catch (e) {
        debugPrint('❌ Manual capture failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de capture: $e'),
            backgroundColor: appTheme.colorF98600,
          ),
        );
      }
    });
  }

  String _getStatusText() {
    switch (_captureState) {
      case SelfieCaptureState.idle:
        return 'Positionnez votre visage dans le cercle et appuyez sur le bouton pour commencer';
      case SelfieCaptureState.waitingForFace:
        return 'Veuillez positionner votre visage dans le cercle';
      case SelfieCaptureState.faceDetected:
        return 'Visage détecté ! Préparez-vous...';
      case SelfieCaptureState.countdownStarted:
        return 'Restez immobile, la photo sera prise automatiquement';
      case SelfieCaptureState.capturing:
        return 'Prise de photo en cours...';
      case SelfieCaptureState.processing:
        return 'Traitement de l\'image...';
      case SelfieCaptureState.completed:
        return 'Photo capturée avec succès !';
      case SelfieCaptureState.error:
        return 'Une erreur s\'est produite. Réessayez.';
      case SelfieCaptureState.cancelled:
        return 'Capture annulée. Appuyez pour recommencer.';
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _countdownSubscription?.cancel();
    if (_isInitialized) {
      _selfieCaptureService.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}