import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:millime/plugins/progress_modal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as imglib;


// Import local files
import 'cicular_painter.dart';
import 'right_left_camera_view.dart';

// Constants for file paths
const String cteAvatar = '/avatar_path.txt';
const String cteLocalDirStorage = '/storage/emulated/0/Download';

// Mock store class for rect property
class MyStore {
  Rect? rect;
}

// Mock dialog factory class
class RefreshablePlayerDialogFactory {
  void dialogShow(String message) {}
  void dialogUpdate(String message) {}
  void dialogHide() {}
  void refresh() {}
}



class RightLeftFaceDetectorView extends StatefulWidget {
  RightLeftFaceDetectorView({
    Key? key,
    required this.onAcceptedImage,
  }) : super(key: key);

  final Function(String inputImage) onAcceptedImage;

  @override
  _RightLeftFaceDetectorViewState createState() => _RightLeftFaceDetectorViewState();
}

enum LifeNessAction { selfie, turnRight, turnLeft, turnUp, turnDown, fin }

GlobalKey _globalKey = GlobalKey();

class _RightLeftFaceDetectorViewState extends State<RightLeftFaceDetectorView>
    with TickerProviderStateMixin  implements RefreshablePlayerDialogFactory{
  static const step = 0.05;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,
      enableLandmarks: true,

      minFaceSize: 0.2,
      enableClassification: true
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text = '';
  LifeNessAction _currentAction = LifeNessAction.selfie;
  String distanceString = 'distance';

  XFile? _path;

  Rect? lastrect;

  double? eulerY;
  double? eulerX;

  double previouseulerY = 0.0;

  String euler = 'empty0';

  var i = 0;

  var _image;

  AnimationController? controller;

  // bool isPlaying = false;

  String get timerString {
    Duration duration = (controller?.duration)! * (controller!.value);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool isEndOfTimer = false;
  int compteur = 100;
  String randomStr = '';

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(DateTime.now().millisecondsSinceEpoch % _chars.length)));

  @override
  void initState() {
    super.initState();

    //var bStoragePerm=await isStoragegGranted();

    init(this);
    randomStr = getRandomString(5);

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: compteur),
    )..reverse();

    controller!.addStatusListener((status) {
      if (timerStarted && controller?.status == AnimationStatus.dismissed && !isEndOfTimer) {
        setState(() => isEndOfTimer = true);
        // if (_right < 1 || _left <1 || _up<1 || _down< 1 ){
        //     Navigator.of(context).pop();
        // return;
        // }
        //stopLiveFeed();
      }
    });
  }



  stopLiveFeed() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    controller!.dispose();
    super.dispose();
  }

  Rect? rect;
  bool conversionNotRunedOnce = true;
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Stack(
      key: _globalKey,
      alignment: Alignment.center,
      children: [
        //    Expanded(flex:1,
        //   child:Material( child: Text(euler))),
        // Expanded(flex:1,
        //   child:Material( child: Text(euler))),

        // Expanded(
        //   flex: 8,
        // child:
        Container(
            child: RightLeftCameraView(
                faceDetection: true,
                title: "Preuve de vie", // Replaced translation with simple string
                customPaint: _customPaint,
                text: _text,
                onImage: (inputImage, camImage) async {
                  if (mounted) {
                    rect = await processImage(inputImage, camImage);
                  }
                },
                onAcceptedImage: (image) async {
                  await widget.onAcceptedImage(image.path);
                },
                initialDirection: CameraLensDirection.front,
                action: _currentAction
                // path: _path!,
                )),
        // ),
        Positioned(
            bottom: 0,
            child: AnimatedBuilder(
                animation: controller!,
                builder: (BuildContext context, Widget? child) {
                  return DefaultTextStyle(
                      style: TextStyle(),
                      child: Text(timerString, // + ' ' + distanceString,
                          style: TextStyle(color: Colors.green.shade900, fontSize: 18, fontWeight: FontWeight.bold)));
                })),

        //   if(_image!=null)
        //  Image.memory (_image!),
        //   Expanded(flex: 1, child: Material(child: Slider(max: 70, min: -70, value: ((eulerY ?? 0)), onChanged: (val) {}))),
      ],
    );
  }

  // bool _up = false;
  // bool _right = false;
  // bool _down = false;
  // bool _left = false;

  double _right = 0;
  double _left = 0;
  double _up = 0;
  double _down = 0;
  double _y = 0.0;
  double _x = 0.0;
  List<double> ylist = [0];
  List<double> xlist = [0];

  final double seuil = 23;
  bool timerStarted = false;
  int imageIndex = 0;
  ZipFileEncoder encoder = ZipFileEncoder();
  List<int> indexesOfFaceRLUP = [-1, -1, -1, -1, -1];
  //bool bSelfieNonPrise = true;

  String dir = '';

  Future<Rect?> processImage(InputImage inputImage, CameraImage? camImage) async {
    if (!_canProcess) return null;
   if (_isBusy) return null;

    setState(() {
          _isBusy = true;
    });

    final plugins = await _faceDetector.processImage(inputImage);
   setState(() {
          _isBusy = false;
    });
    if (_currentAction == LifeNessAction.fin && conversionNotRunedOnce) {
      conversionNotRunedOnce = false;
      
      try {
        // Show progress dialog
        dialogShow("Création de l'archive en cours...");
        
        // Validate directory exists and is writable
        final zipFilePath = dir + '/outproof_' + randomStr + '.zip';
        print('Creating zip file at: $zipFilePath');
        
        // Create zip encoder
        encoder.create(zipFilePath);
        
        // Validate and add files to zip
        int validFilesCount = 0;
        for (int i = 0; i < listOfFiles.length; i++) {
          final file = listOfFiles[i];
          if (await file.exists()) {
            print('Adding file to zip: ${file.path}');
            await encoder.addFile(file);
            validFilesCount++;
          } else {
            print('Warning: File does not exist: ${file.path}');
          }
        }
        
        print('Total files added to zip: $validFilesCount');
        
        // Close the encoder to flush and complete the zip
        await encoder.close();
        
        // Verify the zip file was created
        final zipFile = File(zipFilePath);
        if (await zipFile.exists()) {
          final fileSize = await zipFile.length();
          print('Zip file created successfully. Size: $fileSize bytes');
          
          // Hide progress dialog
          dialogHide();
          
          // Call the callback with the zip file path
          await widget.onAcceptedImage(zipFilePath);
          Navigator.of(context).pop();
        } else {
          throw Exception('Zip file was not created successfully');
        }
        
      } catch (e, stackTrace) {
        print('Error creating zip file: $e');
        print('Stack trace: $stackTrace');
        dialogHide();
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Erreur lors de la création de l\'archive: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close error dialog
                    Navigator.of(context).pop(); // Close current screen
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    if (plugins.isNotEmpty) {
      if (!timerStarted) {
        controller?.reverse(from: 100);
        setState(() {
          timerStarted = true;
        });
      }

      if (_currentAction == LifeNessAction.turnRight || _currentAction == LifeNessAction.turnLeft)
        eulerY = (plugins[0].headEulerAngleY ?? 0.0);
      else
        eulerX = (plugins[0].headEulerAngleX ?? 0.0);

      _y = (eulerY ?? 00) / seuil;
      _x = (eulerX ?? 0) / seuil;
      if (_y < 0) _y = -_y;
      if (_y > 1) _y = 1;

      if (_x < 0) _x = -_x;
      if (_x > 1) _x = 1;

      double previous = 0;
      if (_currentAction == LifeNessAction.turnRight && (_right < 1)) {
        if ((plugins[0].headEulerAngleY ?? 0) < -seuil && _right > 0.8) {
          setState(() {
            _currentAction = LifeNessAction.turnLeft;
            ylist = [0];
            _right = 1;
          });
        } 
        // else if ((plugins[0].headEulerAngleY ?? 0) > 0) {
        //   setState(() {
        //     _right = 0;
        //     ylist = [0];
        //   });
        // }         
        else if( (plugins[0].headEulerAngleY ?? 0) < -seuil ){          
          if (indexesOfFaceRLUP[1] == -1 && (plugins[0].headEulerAngleY ?? 0) < -10) {
            indexesOfFaceRLUP[1] = imageIndex ;
          }          
          ylist.add(_y);
          /////23 dec 2023
          if (ylist.length>=10){setState((){_currentAction = LifeNessAction.turnLeft; ylist = [0];_right = 1; }); }
          ///fin 23 dec 2023
          previous = _right;
          setState(() {
           // _right = ylist.reduce((value, element) => element + value) / (ylist.length);           
            _right = (_right + _y) / 2;
            if ((plugins[0].headEulerAngleY ?? 0) < -seuil ){ _right+=step;}            
            _right = (previous > _right )  ? previous : _right;
          });
        }
      } else
//////////////LEFT
      if (_currentAction == LifeNessAction.turnLeft && (_left < 1)) {
        // String? dir = (await getExternalStorageDirectory())?.path; //(await getApplicationDocumentsDirectory()).path;
        // dir = "/storage/emulated/0/Download/";
        //  Sound.initPlatformState();
        //  Sound.setupAudio();
        //  Sound.loadFile();
        //  bool playing = await AudioManager.instance.playOrPause();
        if ((plugins[0].headEulerAngleY ?? 0) > seuil && _left > 0.8) {
          setState(() {
            _currentAction = LifeNessAction.turnUp;
            ylist = [0];
            _left = 1;
          });
        } 
        // else if ((plugins[0].headEulerAngleY ?? 0) < 0) {
        //   setState(() {
        //     _left = 0;
        //     ylist = [0];
        //   });
        // } 
        else  if( (plugins[0].headEulerAngleY ?? 0) > seuil )   {
          if (indexesOfFaceRLUP[2] == -1 && (plugins[0].headEulerAngleY ?? 0) > 10) {
            indexesOfFaceRLUP[2] = imageIndex ;
          }
          ylist.add(_y);
          /////23 dec 2023
          if (ylist.length>=10){setState((){_currentAction = LifeNessAction.turnUp; ylist = [0];_left = 1; }); }
          ///fin 23 dec 2023
          
          previous = _left;

          setState(() {
           // _left = ylist.reduce((value, element) => element + value) / ylist.length;
            _left = (_left + _y) / 2;
           if ((plugins[0].headEulerAngleY ?? 0) > seuil ){ _left+=step;}

            _left = previous > _left ? previous : _left;
          });
        }
      } else
//////////////////////UP
      if (_currentAction == LifeNessAction.turnUp && (_up < 1)) {
        if ((plugins[0].headEulerAngleX ?? 0) > seuil && _up > 0.8) {
          setState(() {
            _currentAction = LifeNessAction.turnDown;
            xlist = [0];
            _up = 1;
          });
        } 
        // else if ((plugins[0].headEulerAngleX ?? 0) < 0) {
        //   setState(() {
        //     _up = 0;
        //     xlist = [0];
        //   });
        // }        
        else  if( (plugins[0].headEulerAngleX ?? 0) > seuil )  {
          if (indexesOfFaceRLUP[3] == -1 && (plugins[0].headEulerAngleX ?? 0) > 10) {
            indexesOfFaceRLUP[3] = imageIndex ;
          }
          xlist.add(_x);
           /////23 dec 2023
          ///fin 23 dec 2023
          double _upPrevious = _up;
          setState(() {
          //  _up = xlist.reduce((value, element) => element + value) / (xlist.length);
            _up = (_up + _x) / 2;
           if ((plugins[0].headEulerAngleX ?? 0) > seuil ){ _left+=step;}

            if (_upPrevious > _up) _up = _upPrevious;
          });
          if (xlist.length>=10){setState((){_currentAction = LifeNessAction.turnDown; xlist = [0];_up = 1; }); }

        }
      } else
////////////////////////DOWN
      if (_currentAction == LifeNessAction.turnDown && (_down < 1)) {
        if ((plugins[0].headEulerAngleX ?? 0) < (-seuil + 12) && _down > 0.8) {
          setState(() {
            _currentAction = LifeNessAction.fin;
            xlist = [0];
            _down = 1;
          });
        } 
        // else if ((plugins[0].headEulerAngleX ?? 0) > 0) {
        //   setState(() {
        //     _down = 0;
        //     xlist = [0];
        //   });
        // } 
        
        else  if ((plugins[0].headEulerAngleX ?? 0) < (-seuil + 12)){
          if (indexesOfFaceRLUP[4] == -1 && (plugins[0].headEulerAngleX ?? 0) < -10) {
            indexesOfFaceRLUP[4] = imageIndex;
          }
          xlist.add(_x);
          /////23 dec 2023
          if (xlist.length>=10){setState((){_currentAction = LifeNessAction.fin; xlist = [0];_down = 1; }); }
          ///fin 23 dec 2023
          double _downPrevious = _down;

          setState(() {
           // _down = xlist.reduce((value, element) => element + value) / (xlist.length);
            _down = (_down + _x) / 2;
          if ((plugins[0].headEulerAngleY ?? 0) < -seuil+12){ _down+=step;}

            if (_downPrevious > _down  ) _down = _downPrevious;

          });
        }
      }

      if (dir != null && conversionNotRunedOnce) {
        if (indexesOfFaceRLUP[0] == -1 &&
            (plugins[0].headEulerAngleX ?? 0) < 10 &&
            (plugins[0].headEulerAngleX ?? 0) > -10 &&
            (plugins[0].headEulerAngleY ?? 0) < 10 &&
            (plugins[0].headEulerAngleY ?? 0) > -10) {
          indexesOfFaceRLUP[0] = imageIndex ;
          
          // Notify camera view that selfie has been captured
          setState(() {
            _currentAction = LifeNessAction.turnRight;
          });

          String selfieFileName = dir + '/' + 'proof_' + randomStr + '_' + (imageIndex).toString().padLeft(3, '0') + '.jpg';

          // File file = File(dir + '/' + "selfieFilePath.txt");
          File file = File(dir + cteAvatar);

          file.writeAsStringSync(selfieFileName);
        }

        File file = File(dir + '/' + 'proof_' + randomStr + '_' + (imageIndex ).toString().padLeft(3, '0') + '.jpg');

        listOfFiles.add(file);

        imglib.Image? imageTosave = await convertYUV420ToImage2(camImage!);

        ///1
        if (imageTosave != null) {
          //final imglib.Image orientedImage=bakeOrientation(imageTosave);flipHorizontal
          //     final imglib.Image orientedImage=flipHorizontal(imageTosave);
          // Uint8List? bytes =  imageTosave.getBytes()  ;   //inputImage.bytes!.buffer.asUint8List();//     base64.decode((doc?.docInYImageScan).toString());

          // await file.writeAsBytes(imglib.encodeJpg(imageTosave), flush: true);  //1

          //imageTosave);
          await file.writeAsBytes(imglib.encodeJpg(imageTosave, quality: 50));

          //  await FlutterExifRotation.rotateAndSaveImage   (path: dir + '/' + 'proof' + (imageIndex ~/ 2).toString() + '.jpg');

          // final File newImage = await imageTosave.  ('$path/image1.png');

        }
      }


      // if (_currentAction == LifeNessAction.fin && conversionNotRunedOnce) {
      //   conversionNotRunedOnce = false;
      //   this.hideProgressDialog();
      //   this.showProgressDialog();
      //   // String ffmpegCommand=" -framerate 1 -i '"+dir+"/proof%d.jpg' -c:v  mpeg4 -r 15 '"+ dir+ "/output.mp4'";
      //   String ffmpegCommand = " -framerate 1 -i '" +
      //       dir +
      //       "/proof%d.jpg' -c:v  mpeg4 -vf fps=10 -pix_fmt yuv420p -r 15 '" +
      //       dir +
      //       "/output.mp4'";
      //   //-framerate 1/3  -i proof%d.jpg -c:v libx264 -vf fps=10 -pix_fmt yuv420p out.mp4

      //   FFmpegKit.executeAsync(
      //       ffmpegCommand,
      //       (session) async {
      //         final state = FFmpegKitConfig.sessionStateToString(
      //             await session.getState());
      //         final returnCode = await session.getReturnCode();
      //         final failStackTrace = await session.getFailStackTrace();
      //         final duration = await session.getDuration();
      //         this.hideProgressDialog();
      //         if (ReturnCode.isSuccess(returnCode)) {
      //           print(
      //               "Encode completed successfully in ${duration} milliseconds; playing video.");
      //           //this.playVideo();
      //         } else {
      //           // showPopup(
      //           //     "Encode failed. Please check log for the details.");
      //           print(
      //               "Encode failed with state ${state} and rc ${returnCode})");
      //         }
      //         controller!.stop();
      //       },
      //       (log) => {print("log here ffmpeg")}, //ffprint(log.getMessage()),
      //       (statistics) {
      //         this._statistics = statistics;
      //         this.updateProgressDialog();
      //       }).then((session) => {print("session trt")}); //  ffprint(
      //   //  "Async FFmpeg process started with sessionId ${session.getSessionId()}."));
      // }

setState(() {
  
     imageIndex = imageIndex + 1;

      _customPaint = CustomPaint(
        size: const Size(250, 250), // no effect while adding child
        painter: CircularPaint(
          progressValue: (eulerY ?? 0.0) / 120, //[0-1]
          up: _up,
          right: _right,
          down: _down,
          left: _left,
          y: _y,
        ),
        // child:   SizedBox(
        //   height: 150,
        //   width:150,
        //   // child: Text("_start.toString()",
        //   //             style: TextStyle(
        //   //               color: Colors.white,
        //   //               fontSize: 22,
        //   //             ))
        //               ),
      );
         // _isBusy = false;

    
});

    
    }
  }

  List<File> listOfFiles = [];

  // late Statistics? _statistics;

  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;

  Future<void> init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) async {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;

    // _statistics = null;
    var bperm = await isStoragegGranted();

    ///use one of these
    // getExternalCacheDirectories()
    // getTemporaryDirectory()
    // getApplicationCacheDirectory()
    dir = (await getExternalStorageDirectory())?.path ?? "/storage/emulated/0/Download"; //(await getApplicationDocumentsDirectory()).path;
    dir = cteLocalDirStorage;

    final dirtoempty = Directory(dir);
    bool exists = await dirtoempty.exists();
    if (!exists) await dirtoempty.create();

    // List contents = await dirtoempty.listSync();

    // for (var fileOrDir in contents) {
    //   if (fileOrDir is File) {
    //       fileOrDir.delete();
    //   }

    // }

    //dirtoempty.deleteSync(recursive: true);
  }

  // void showProgressDialog() {
  //   // CLEAN STATISTICS
  //   _statistics = null;
  //   _refreshablePlayerDialogFactory.dialogShow("Traitement en cours");
  // }

  // void updateProgressDialog() {
  //   var statistics = this._statistics;
  //   if (statistics == null || statistics.getTime() < 0) {
  //     return;
  //   }

  //   int timeInMilliseconds = statistics.getTime();
  //   int totalVideoDuration = 9000;

  //   int completePercentage = (timeInMilliseconds * 100) ~/ totalVideoDuration;
  //   if (completePercentage > 80) {
  //     completePercentage =
  //         80 + (((completePercentage - 80) / completePercentage) * 20).ceil();
  //   }

  //   _refreshablePlayerDialogFactory
  //       .dialogUpdate("En cours de traitement % $completePercentage");
  //   _refreshablePlayerDialogFactory.refresh();
  // }

  // void hideProgressDialog() {
  //   _refreshablePlayerDialogFactory.dialogHide();
  // }

  void refresh() {
    setState(() {});
  }

  Future<bool> isStoragegGranted() async {
    var status = await Permission.manageExternalStorage.status;
    //var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (status.isGranted)
        return true;
      else
        return false;
    } else
      return true;
  }

  /// Converts a CameraImage to an Image
  Future<imglib.Image?> convertYUV420ToImage2(CameraImage cameraImage) async {
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;

      // Create a new image with the correct dimensions
      final imglib.Image image = imglib.Image(width: width, height: height);

      // Convert YUV420 to RGB
      const int hexFF = 0xFF000000;
      final int uvyButtonStride = cameraImage.planes[1].bytesPerRow;
      final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final int uvIndex =
              uvyButtonStride * (y ~/ 2) + uvPixelStride * (x ~/ 2);
          final int index = y * width + x;

          final yp = cameraImage.planes[0].bytes[index];
          final up = cameraImage.planes[1].bytes[uvIndex];
          final vp = cameraImage.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 443546 / 131072 - vp * 93604 / 131072)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
      return image;
    } catch (e) {
      print("Error converting image: $e");
      return null;
    }
  }
   ProgressModal? progressModal;
 @override
  void dialogHide() {
    if (progressModal != null) {
      progressModal?.hide();
    }
  }

  @override
  void dialogShowCancellable(String message, Function cancelFunction) {
    progressModal = new ProgressModal(_globalKey.currentContext!);
    progressModal?.show(message, cancelFunction: cancelFunction);
  }

  @override
  void dialogShow(String message) {
    progressModal = new ProgressModal(_globalKey.currentContext!);
    progressModal?.show(message);
  }

  @override
  void dialogUpdate(String message) {
    progressModal?.update(message: message);
  }
}
