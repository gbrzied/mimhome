import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:millime/common/functions.dart';
// import 'package:millime/conf/size_utils.dart';
// import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:millime/theme/theme_helper.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:millime/pages/figma_integration/color.dart';
// import 'package:millime/pages/plugins/dashedRect.dart';
// import 'package:millime/pages/plugins/imageProcessor.dart';
// import 'package:millime/pages/plugins/rectangle_clipping.dart';
// import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
// import 'package:safe_device/safe_device.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../main.dart';
// import '../../stores/login_store.dart';

// Mock cameras list for testing
List<CameraDescription> cameras = [];

// Mock greenmillime color
Color greenmillime = Colors.green;

// Mock selfie variable
Image? selfie;

// Mock theme
ThemeData theme = ThemeData();

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
//  XFile path;

  CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      required this.onAcceptedImage,
      this.onScreenModeChanged,
      this.initialDirection = CameraLensDirection.back,
      this.faceDetection = false,
      this.showSaveButton = false
      // required this.path
      })
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(File inputImage) onAcceptedImage;

  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;

  bool faceDetection = false;
  bool showSaveButton = false;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;

  // LoginStore? myStore;

  bool? faceExist;

  bool isTakingPicture = false;

  Rect? rect;
  bool _isCameraPermissionGranted = false;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
    // myStore = Provider.of<LoginStore>(context, listen: false);
    // SafeDevice.isRealDevice.then((value) => myStore?.isRealDevice = value);

    _start = 5; // Default countdown value
    getPermissionStatus();

    // WidgetsBinding.instance.addObserver(this);

    //_cameraIndex = 0;
    if (cameras.length > 1) if (cameras.any(
      (element) => element.lensDirection == widget.initialDirection && element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) => element.lensDirection == widget.initialDirection && element.sensorOrientation == 90),
      );
    } else {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere(
          (element) => element.lensDirection == widget.initialDirection,
        ),
      );
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    // mounted = false;
    //rect = null;
    try {
      if (_controller != null && _controller!.value.isStreamingImages) {
        _stopLiveFeed();
      }
    } catch (e) {
      print('error');
    }
    
    // Clean up timers
    if (_timerStarted) {
      _timer.cancel();
    }
    
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        initCam();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void initCam() {
    _controller?.dispose();

    _controller = CameraController(cameras[0], ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    _controller?.addListener(() {
      if (mounted) setState(() {});
      if (_controller!.value.hasError) {
        print('Camera error ${_controller!.value.errorDescription}');
      }
    });

    _controller!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenmillime,
        title: Text(widget.title),
        actions: [
          if (_allowPicker)
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: _switchLiveCamera, //_switchScreenMode,
                child: Icon(
                  _mode == ScreenMode.liveFeed
                      ? Icons.flip_camera_android_outlined
                      : (Platform.isIOS ? Icons.camera_alt_outlined : Icons.flip_camera_android_outlined),
                ),
              ),
            ),
        ],
      ),
      body: _body(),
      floatingActionButton: _takePicture(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  late Future<void>? _initializeControllerFuture;

  Widget _takePicture() {
    // if (_mode == ScreenMode.gallery) return null;
    //  if (cameras.length == 1) return null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_image != null)
          SizedBox(
            height: 70.0,
            width: 70.0,
            child: FloatingActionButton(
              heroTag: "btn1",
              backgroundColor: Color.fromARGB(255, 170, 39, 39),
              child: Icon(
                Platform.isIOS
                    ? Icons.flip_camera_ios_outlined
                    // : Icons.flip_camera_android_outlined,
                    : Icons.cancel_outlined,
                size: 40,
              ),
              onPressed: () async {
                try {
                  // _controller?.startImageStream(_processCameraImage);
                  //_startLiveFeed();
                  _startLiveFeed();

                  _start = 5; // Default countdown value
                  _image = null;
                  selfie = null;
                  // Reset timer state
                  if (_timerStarted) {
                    _timer.cancel();
                    _timerStarted = false;
                  }
                  // Fallback timer removed - handled in face_detector_view.dart
                  setState(() {});
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
            ),
          ),
        if (widget.showSaveButton)
          SizedBox(
            height: 70.0,
            width: 70.0,
            child: FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: Color.fromARGB(255, 39, 170, 46),
              child: Icon(
                Platform.isIOS
                    ? Icons.flip_camera_ios_outlined
                    // : Icons.flip_camera_android_outlined,
                    : (_image != null ? Icons.check_circle : null), // Icons.save),
                size: 40,
              ),
              onPressed: () {
                Navigator.of(context).pop();

                //getPictureFromCam();
              },
            ),
          ),
        //  if (widget.showSaveButton && _image == null)
        // SizedBox(
        //   height: 70.0,
        //   width: 70.0,
        //   child: FloatingActionButton(
        //     heroTag: "btn3",
        //     child: Icon(
        //       Platform.isIOS
        //           ? Icons.flip_camera_ios_outlined
        //           // : Icons.flip_camera_android_outlined,
        //           : (_image != null ? Icons.check_circle : Icons.save),
        //       size: 40,
        //     ),
        //     onPressed: () => getPictureFromCam,
        //   ),
        // ),
      ],
    );
  }

  Widget? _floatingActionButton() {
    // if (_mode == ScreenMode.gallery) return null;
    if (cameras.length <= 1) return null;
    return SizedBox(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined,
            size: 40,
          ),
          onPressed: () async {
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   behavior: SnackBarBehavior.floating,
            //   backgroundColor: Colors.red,
            //   content: Text(
            //     // 'Pas encore implémentée',
            //     _cameraIndex.toString(),
            //     // cameras.length.toString(),
            //     style: TextStyle(color: Colors.black),
            //   ),
            // ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Pas encore implémentée"),
        ));
            await _switchLiveCamera();
          },
        ));
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.liveFeed) {
      body = _liveFeedBody();
    } else {
      body = _galleryBody();
    }
    return body;
  }

  // int counter = 5;
  Image? selfie;

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale;
    if (_controller != null) {
      scale = size.aspectRatio * _controller!.value.aspectRatio;
    } else {
      if (selfie != null)
        return Container(
            color: Color.fromARGB(255, 19, 19, 20),
            child: Stack(
              fit: StackFit.expand,
              children: [selfie!],
            )); // ?? Container()
      // return selfie ?? Container();
      ;
    }

    // to 3prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    //  if (snapshot.connectionState == ConnectionState.done) {
    //         // If the Future is complete, display the preview.
    //         return CameraPreview(_controller);
    //       } else {
    //         // Otherwise, display a loading indicator.
    //         return const Center(child: CircularProgressIndicator());
    //       }

    if (rect != null) {
      setState(() {
        faceExist = true;
        // counter >= 0 ? counter-- : counter = 1;
      });

      if (!isTakingPicture) {
        // DEBUG: Log face detection success - no positioning requirements
        debugPrint('✅ FACE DETECTED - STARTING COUNTDOWN:');
        debugPrint('  Face position: ${rect}');
        debugPrint('  Timer started: $_timerStarted, Start: $_start');
        
        // Start timer immediately when any face is detected (no positioning requirements)
        if (!_timerStarted) {
          debugPrint('🚀 STARTING COUNTDOWN TIMER');
          startTimer();
        }
        if (_start == 0) getPictureFromCam();
      }
    } else {
      setState(() {
        faceExist = false;
        rect = null;
        // Reset timer when face is no longer detected
        if (_timerStarted) {
          _timer.cancel();
          _timerStarted = false;
          _start = 5; // Default countdown value
        }
      });
    }

    // Remove the separate fallback timer - let face_detector_view handle fallback
    // The face detection fallback is now handled in face_detector_view.dart

    return FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          //  if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: Color.fromARGB(255, 19, 19, 20),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (_image != null) selfie!,
                if (mounted && _controller != null && _controller!.value.isInitialized && _controller!.value.isStreamingImages)
                  CameraPreview(_controller!),
                // if (_image == null && widget.faceDetection) OverlayWithRectangleClipping(5),
 if (_image == null && widget.faceDetection)
   Align(
                               alignment: Alignment.center,
                               child: Container(
                                 padding: EdgeInsets.only(top: 20),
                                 child: Container(
                                   padding: EdgeInsets.only(bottom: 10),
                                   decoration: BoxDecoration(
                                     border: Border.all(
                                       color: (_start < 5) ? greenmillime : theme.colorScheme.error,
                                       width: 3,
                                       style: BorderStyle.solid,
                                     ),
                                     borderRadius: BorderRadius.circular(210),
                                   ),
                                   child: Padding(
                                     padding: EdgeInsets.all(10),
                                     child: Container(
                                       height: 400,
                                       width: 300,
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(100),
                                       ),
                                     ),
                                   ),
                                 ),
                               )),



                if (widget.faceDetection)
                  Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/img/nomask.png', scale: 5),
                          SizedBox(
                            width: 8,
                          ),
                          Image.asset('assets/img/noglasses.png', scale: 7.5),
                        ],
                      ),
                      if (_image == null)
                        SizedBox(
                          height: 8,
                        ),
                      if (_image == null)
                        Center(
                          child: Text.rich(
                              TextSpan(
                                  text: 'Veuillez placer votre visage au milieu du cercle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    //fontWeight: FontWeight.w800
                                  )),
                              textAlign: TextAlign.center),
                        ),
                      if (_image == null)
                        Text(_start.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            )),
                                SizedBox(
                          height: 8,
                        ),
                    ],
                  ),
              ],
            ),
          );
          //   } else {
          // Otherwise, display a loading indicator.
          //     return const Center(child: CircularProgressIndicator());
          //     }
        });
  }

  late Timer _timer;
  late int _start;

  void startTimer() {
    _timerStarted = true;
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (mounted) {
          if (_start == 0) {
            setState(() {
              timer.cancel();
              _timerStarted = false;
            });
          } else {
            setState(() {
              _start--;
            });
          }
        } else {
          timer.cancel();
          _timerStarted = false;
          return;
        }
      },
    );
  }

  // Fallback timer method removed - fallback is now handled in face_detector_view.dart

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(_image!),
                  if (widget.customPaint != null) widget.customPaint!,
                ],
              ),
            )
          : Icon(
              Icons.image,
              size: 200,
            ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  void _switchScreenMode() {
    _image = null;
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      _startLiveFeed();
    }
    if (widget.onScreenModeChanged != null) {
      widget.onScreenModeChanged!(_mode);
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low, // Use lower resolution for better ML Kit compatibility
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Try NV21 format which is more widely supported
    );

    _initializeControllerFuture = _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });

      _controller?.startImageStream(_processCameraImage);

      // rect = null;
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    var oldcontroller = _controller;
    if (_controller!.value.isStreamingImages) {
      await _controller?.stopImageStream();
    }

    await oldcontroller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    setState(() {});

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }

  Future _processCameraImage(CameraImage image) async {
    if (_controller == null) return;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final camera = cameras[_cameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) {
        debugPrint('Unsupported camera rotation: ${camera.sensorOrientation}');
        return;
      }

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) {
        debugPrint('Unsupported image format: ${image.format.raw}');
        return;
      }

      // Get the bytesPerRow from the first plane
      final bytesPerRow = image.planes.first.bytesPerRow;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      widget.onImage(inputImage);
    } catch (e) {
      debugPrint('Error processing camera image: $e');
      // Continue processing other frames even if one fails
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = _controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
      //} on CameraException catch (e) {
    } catch (e) {
      isTakingPicture = false;
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  void getPictureFromCam() async {
    if (_image != null) {
      // Navigator.of(context).pop((route) => route.isFirst);
      //Navigator.of(context).pop();
      return;
    }

    try {
      if (isTakingPicture) 
        return;
      setState(() {
        isTakingPicture = true;
      });
      await _initializeControllerFuture;
      if (_controller != null && _controller?.value.isStreamingImages != null) {
        var streeaming = _controller?.value.isStreamingImages;

        if (streeaming!) {
          await _controller?.stopImageStream();
          //closeCaptureSession

        }
      }

      if (_controller?.value.hasError ?? false) {
        final previousCameraController = _controller;
        await previousCameraController?.dispose();

        await _startLiveFeed();
      }

      // final ximage = await _controller?.takePicture();
      final ximage = await takePicture();
      setState(() {
        isTakingPicture = false;
      });
      //_stopLiveFeed();

      //_processPickedFile(ximage);

      final path = ximage?.path;
      // final bytes = await File(path!).readAsBytes();
      _image = File(path!);
      if (_image != null) {
        selfie = Image.file(_image!);
      } else {
        selfie = null;
      }

      if (rect != null && path != null) {
        var fileName = (path.split('/').last);
        var filePath = path.replaceAll("/$fileName", '');

        fileName = 'crop-' + fileName;
        int? l = rect?.left.toInt();
        int? t = rect?.top.toInt();
        int? r = rect?.right.toInt();
        int? b = rect?.bottom.toInt();

        // ImageProcessor.cropImage(
        //     path, filePath + '/' + fileName, l ?? 20 - 20, t ?? 20 - 20, (r ?? 200) - (l ?? 0) + 20, ((b ?? 300) - (t ?? 0)) + 20);

        _image = File(filePath + '/' + fileName);
        if (_image != null) {
          selfie = Image.file(_image!);
        } else {
          selfie = null;
        }

        widget.showSaveButton = true;
        await widget.onAcceptedImage(_image!);
        await _stopLiveFeed();
      }
      setState(() {});

      //await Future.delayed(Duration(seconds: 1)).then((value) => DateTime.now());

      // await Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (_) => const LoginPage()),
      //     (Route<dynamic> route) => true);

      //19A
      // Navigator.of(context).pop((route) => route.isFirst);

      //////////cropping////

      //_controller?.startImageStream(_processCameraImage);
      // setState(() {});
      // print(ximage?.path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      isTakingPicture = false;
      if (_controller != null) {
        _startLiveFeed();
        //_controller?.startImageStream(_processCameraImage);
      }
      //_startLiveFeed();
      print(e);
    }
  }

  
  
  
  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      // onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      print("permission not granted");
    }
  }
}
