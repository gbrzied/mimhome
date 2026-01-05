import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'camera_view.dart';
import 'barcode_detector_painter.dart';

class BarcodeScannerView extends StatefulWidget {
  String cinToFind = "";

  BarcodeScannerView({Key? key, required this.onAcceptedCode, required this.onAcceptedImage, required this.cinToFind}) : super(key: key);

  final Function(String inputImage) onAcceptedImage;

  final Function(String inputImage) onAcceptedCode;

  @override
  _BarcodeScannerViewState createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
        title: 'Barcode Scanner',
        customPaint: _customPaint,
        text: _text,
        onImage: (inputImage) {
          processImage(inputImage);
        },
        onAcceptedImage: (image) async {
          await widget.onAcceptedImage(image.path);
        },
        showSaveButton: _boolFoundBarCode);
  }

  // String _cinToFind ='' ;
  bool _boolFoundBarCode = false;
  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess || _boolFoundBarCode) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    try {
      List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
      setState(() {});
      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        // final painter = BarcodeDetectorPainter(
        //     barcodes,
        //     inputImage.metadata!.size,
        //     inputImage.metadata!.rotation);
        // _customPaint = CustomPaint(painter: painter);

        if (barcodes.length >= 1 && barcodes.elementAt(0).displayValue != null && !_boolFoundBarCode) {
          final cin = barcodes.elementAt(0).displayValue?.substring(0, 8);
          print(barcodes.elementAt(0).displayValue);

          if (cin == widget.cinToFind) {
            //widget.onAcceptedCode(barcodes[0].displayValue ?? '');
            //widget.onAcceptedCode(barcodes.elementAt(0).displayValue ?? '');

            setState(() {
              _boolFoundBarCode = true;
            });
          }
          //  Navigator.pop(context);

          //    context, MaterialPageRoute(builder: (context) => _viewPage));
        }
      } else {
        String text = 'Barcodes found: ${barcodes.length}\n\n';
        for (final barcode in barcodes) {
          text += 'Barcode: ${barcode.rawValue}\n\n';
        }
        _text = text;
        // TODO: set _customPaint to draw boundingRect on top of image
        _customPaint = null;
      }
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    } //end try
    catch (e) {
      _isBusy = false;
      print('barcode scanner view ex');
    }
  }
}
