import 'dart:async';
import 'dart:io';
// import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:millime/core/app_export.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:millime/plugins/rightleft/right_left_face_view.dart';
// import 'package:millime/core/utils/image_processing_utils.dart';
// import 'package:millime/core/utils/functions.dart';
// import 'package:millime/core/utils/navigator_service.dart';
// import 'package:millime/core/utils/document_manager.dart';
// import 'package:millime/core/utils/image_constant.dart';
// import 'package:millime/core/utils/size_utils.dart';
// import 'package:millime/core/app_export.dart';

enum ScreenMode { liveFeed, gallery }

class RightLeftCameraView extends StatefulWidget {
//  XFile path;

  RightLeftCameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      required this.onAcceptedImage,
      this.onScreenModeChanged,
      this.initialDirection = CameraLensDirection.back,
      this.faceDetection = false,
      this.showSaveButton = false,
      required this.action})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final LifeNessAction action;
  final Function(InputImage inputImage, CameraImage? image) onImage;
  final Function(File inputImage) onAcceptedImage;

  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;

  bool faceDetection = false;
  bool showSaveButton = false;

  @override
  _RightLeftCameraViewState createState() => _RightLeftCameraViewState();
}

class _RightLeftCameraViewState extends State<RightLeftCameraView> with WidgetsBindingObserver {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;

  bool? faceExist;
  bool isTakingPicture = false;
  Rect? rect;
  bool _isCameraPermissionGranted = false;
  bool _isStoragePermissionGranted = false;
  bool bTournerAdroite = true;

  String? strLifenessActionToDo;
  String? strFace;
  String? strDroite;
  String? strGauche;
  String? strHaut;
  String? strBas;
  String? strMerci;

  // Selfie countdown variables
  int selfiecountdown = 5;
  bool _isCountdownActive = false;
  bool _hasTakenSelfie = false;

  // Missing variables
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();

    strFace = "key_face".tr;

    strDroite ="key_droite".tr;

    strGauche = "key_gauche".tr;
    strHaut = "key_haut".tr;

    strBas = "key_bas".tr;
//'';

    strMerci = "key_merci".tr;
//'merci, ';

  _imagePicker = ImagePicker();

  _start = selfiecountdown;

  getPermissionStatus();

  // Initialize cameras list
  availableCameras().then((value) {
    cameras = value;
    if (mounted) {
      setState(() {
        // Set camera index based on initial direction
        if (cameras.length > 1) {
          if (cameras.any(
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
        }
        
        _startLiveFeed();
      });
    }
  }).catchError((e) {
    print('Error getting cameras: $e');
  });

  // WidgetsBinding.instance.addObserver(this);
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

   // if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
   // }

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
    switch (widget.action) {
      case LifeNessAction.selfie:
        strLifenessActionToDo = strFace;
        break;
      case LifeNessAction.turnRight:
        // Reset selfie state when transitioning to turn right
        if (_hasTakenSelfie) {
          _isCountdownActive = false;
          _hasTakenSelfie = false;
          _start = selfiecountdown;
        }
        strLifenessActionToDo = strDroite;
        break;

      case LifeNessAction.turnLeft:
        strLifenessActionToDo = strGauche;
        break;

      case LifeNessAction.turnUp:
        strLifenessActionToDo = strHaut;
        break;

      case LifeNessAction.turnDown:
        strLifenessActionToDo = strBas;
        break;

      case LifeNessAction.fin:
        strLifenessActionToDo = strMerci;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appTheme.primaryColor,
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

                resetSelfieState();
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
              backgroundColor: appTheme.primaryColor,
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
                    content: Text('Error: ${_cameraIndex.toString()}'),
                    duration: Duration(seconds: 2),
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

  int counter = 5;
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

    // Face detection logic - rect should be set by face detection
    if (rect != null) {
      setState(() {
        faceExist = true;
        // Check if face is properly positioned for selfie
        bool isFaceProperlyPositioned =
            (rect!.top <= size.height * 0.4) &&
            (rect!.bottom >= size.height * 0.50);
        
        // Start countdown if face is properly positioned and we haven't taken selfie yet
        if (isFaceProperlyPositioned && !_hasTakenSelfie && !_isCountdownActive) {
          _isCountdownActive = true;
          _start = selfiecountdown;
          startTimer();
        }
      });

      // Auto-capture selfie when countdown reaches zero
      if (_isCountdownActive && _start <= 0 && !_hasTakenSelfie) {
        setState(() {
          _isCountdownActive = false;
          _hasTakenSelfie = true;
        });
        getPictureFromCam();
      }
    } else {
      setState(() {
        faceExist = false;
        rect = null;
        // Reset countdown if face is lost
        if (_isCountdownActive) {
          _isCountdownActive = false;
          _start = selfiecountdown;
        }
      });
    }

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
                // if (_image == null && widget.faceDetection)
                //   OverlayWithRectangleClipping(5),
                if (widget.faceDetection)
                  Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                                CustomImageView(
                        imagePath: ImageConstant.imgmask,
                        height: 24.h,
                        width: 24.h,
                      ),
                         // Image.asset(ImageConstant.imgmask, scale: 5),
                          SizedBox(
                            width: 8,
                          ),
                       //   Image.asset(ImageConstant.imgnoglass, scale: 7.5),
                                      CustomImageView(
                        imagePath: ImageConstant.imgnoglass,
                        height: 24.h,
                        width: 24.h,
                      ),
                        ],
                      ),
                      if (_image == null)
                        SizedBox(
                          height: 20,
                        ),
                      if (_image == null && bTournerAdroite)
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 50),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text.rich(
                                TextSpan(
                                    text: strLifenessActionToDo,
                                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      // Stack(
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(bottom: 100),
                      //       child: Lottie.asset("assets/loading.json",
                      //           width: MediaQuery.of(context).size.width * 0.7),
                      //     ),
                      if (widget.customPaint != null) widget.customPaint!,
                      //   ],
                      // )

                      // if (_image == null)
                      // Text(_start.toString(),
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 22,
                      //     )),
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
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (mounted) {
          if (_start == 0) {
            setState(() {
              timer.cancel();
            });
          } else {
            setState(() {
              _start--;
            });
          }
        } else
          return;
      },
    );
  }

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
   // if (cameras.isEmpty) return;
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
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
  //  if (cameras.isNotEmpty) {
      _cameraIndex = (_cameraIndex + 1) % cameras.length;
   // }
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
    widget.onImage(inputImage, null);
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

     // if (cameras.isEmpty) return;
      final camera = cameras[_cameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) return;

      // Use NV21 format which is supported by ML Kit
      final inputImageFormat = InputImageFormat.nv21;
      
      // Get the bytesPerRow from the first plane
      final bytesPerRow = image.planes.first.bytesPerRow;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      widget.onImage(inputImage, image);
    } catch (e) {
      print('Error processing camera image: $e');
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
      if (isTakingPicture) return;
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
        // For now, just use the original image without cropping
        // TODO: Implement proper image cropping using ImageProcessingUtils.cropImageToFace

        // widget.showSaveButton = true; // Cannot modify final field
        await widget.onAcceptedImage(_image!);
        await _stopLiveFeed();
      }
      setState(() {});
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

  void resetSelfieState() {
    _start = selfiecountdown;
    _image = null;
    selfie = null;
    _isCountdownActive = false;
    _hasTakenSelfie = false;
    rect = null;
    faceExist = null;
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
      print("cam permission not granted");
    }
    status = await Permission.storage.request();

    if (status.isGranted) {
      setState(() {
        _isStoragePermissionGranted = true;
      });
      // Set and initialize the new camera
      // onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      print("storage permission not granted");
    }
  }
}
