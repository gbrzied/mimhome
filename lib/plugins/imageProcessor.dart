import 'dart:io';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart';

class ImageProcessor {
  static Future cropImage(String srcFilePath, String destFilePath, offsetX, offsetY, cropWidth, cropHeight, {bool flip = false}) async {
    var bytes = await File(srcFilePath).readAsBytes();
    IMG.Image? src = IMG.decodeImage(bytes);

    // var cropSize = min<int>(src!.width, src.height);
    // int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    // int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    IMG.Image destImage = IMG.copyCrop(src!, x:offsetX,y: offsetY, width:cropWidth, height:cropHeight);
    //IMG.copyCrop(src!, 50, 50, 100, 100);

    if (flip) {
      destImage = IMG.flipVertical(destImage);
    }

    // String dir = (await getApplicationDocumentsDirectory()).path;
    var jpg = IMG.encodeJpg(destImage);
    // await File(dir + '/test.jpg').writeAsBytes(jpg);
    await File(destFilePath).writeAsBytes(jpg);
  }
}
