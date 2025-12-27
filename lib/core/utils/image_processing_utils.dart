import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Utility class for image processing operations
class ImageProcessingUtils {
  /// Crop an image based on face coordinates
  /// 
  /// [imageFile] - The original image file
  /// [faceRect] - The bounding rectangle of the face in image coordinates
  /// [padding] - Additional padding around the face (default 50 pixels)
  /// [outputSize] - Optional output size for the cropped image
  static Future<File> cropImageToFace(
    File imageFile,
    Rect faceRect, {
    int padding = 50,
    Size? outputSize,
  }) async {
    try {
      // Read the image
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate crop area with padding
      final cropLeft = (faceRect.left - padding).clamp(0, originalImage.width.toDouble()).toInt();
      final cropTop = (faceRect.top - padding).clamp(0, originalImage.height.toDouble()).toInt();
      final cropRight = (faceRect.right + padding).clamp(0, originalImage.width.toDouble()).toInt();
      final cropBottom = (faceRect.bottom + padding).clamp(0, originalImage.height.toDouble()).toInt();
      
      // Ensure valid crop dimensions
      final cropWidth = cropRight - cropLeft;
      final cropHeight = cropBottom - cropTop;
      
      if (cropWidth <= 0 || cropHeight <= 0) {
        debugPrint('❌ Invalid crop dimensions: ${cropWidth}x$cropHeight');
        return imageFile; // Return original if crop dimensions are invalid
      }

      // Crop the image
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropLeft,
        y: cropTop,
        width: cropWidth,
        height: cropHeight,
      );

      // Resize if output size is specified
      final finalImage = outputSize != null 
        ? img.copyResize(
            croppedImage,
            width: outputSize.width.toInt(),
            height: outputSize.height.toInt(),
            interpolation: img.Interpolation.linear,
          )
        : croppedImage;

      // Create temporary file for cropped image
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cropped_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Encode and save the cropped image
      final croppedBytes = img.encodeJpg(finalImage, quality: 90);
      await tempFile.writeAsBytes(croppedBytes);
      
      debugPrint('✅ Image cropped successfully: ${cropWidth}x$cropHeight -> ${tempFile.path}');
      return tempFile;
      
    } catch (e) {
      debugPrint('❌ Failed to crop image: $e');
      return imageFile; // Return original on error
    }
  }

  /// Get the image dimensions
  static Future<Size> getImageSize(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint('❌ Failed to get image size: $e');
      return const Size(0, 0);
    }
  }

  /// Scale face coordinates from detection coordinates to image coordinates
  /// 
  /// This handles the transformation from ML Kit face detection coordinates
  /// to actual image pixel coordinates
  static Rect scaleFaceRectToImage(
    Rect detectionRect,
    Size detectionSize,
    Size imageSize,
  ) {
    final scaleX = imageSize.width / detectionSize.width;
    final scaleY = imageSize.height / detectionSize.height;
    
    return Rect.fromLTRB(
      detectionRect.left * scaleX,
      detectionRect.top * scaleY,
      detectionRect.right * scaleX,
      detectionRect.bottom * scaleY,
    );
  }

  /// Create a centered crop rectangle for a face
  /// 
  /// This creates a square crop area centered on the face, useful for profile pictures
  static Rect createCenteredFaceCrop(Rect faceRect, Size imageSize, {double faceScaleFactor = 2.0}) {
    final faceCenterX = faceRect.left + faceRect.width / 2;
    final faceCenterY = faceRect.top + faceRect.height / 2;
    
    // Make crop area larger than face
    final cropSize = faceRect.width * faceScaleFactor;
    
    // Ensure crop size doesn't exceed image dimensions
    final maxCropSize = imageSize.width < imageSize.height ? imageSize.width : imageSize.height;
    final finalCropSize = cropSize.clamp(50.0, maxCropSize);
    
    // Calculate crop rectangle, ensuring it stays within image bounds
    final halfCropSize = finalCropSize / 2;
    
    // Calculate potential crop position
    double cropLeft = faceCenterX - halfCropSize;
    double cropTop = faceCenterY - halfCropSize;
    
    // Ensure crop rectangle stays within image bounds
    if (cropLeft < 0) cropLeft = 0;
    if (cropTop < 0) cropTop = 0;
    if (cropLeft + finalCropSize > imageSize.width) {
      cropLeft = imageSize.width - finalCropSize;
    }
    if (cropTop + finalCropSize > imageSize.height) {
      cropTop = imageSize.height - finalCropSize;
    }
    
    return Rect.fromLTWH(cropLeft, cropTop, finalCropSize, finalCropSize);
  }

  /// Validate if face rectangle is reasonable for cropping
  static bool isValidFaceForCropping(Rect faceRect, Size imageSize) {
    final faceArea = faceRect.width * faceRect.height;
    final imageArea = imageSize.width * imageSize.height;
    final faceRatio = faceArea / imageArea;
    
    // Face should be between 5% and 80% of image area
    final isReasonableSize = faceRatio > 0.05 && faceRatio < 0.8;
    
    // Face should not be too close to edges (at least 10% margin)
    final minMargin = 0.1;
    final hasAdequateMargin = 
        faceRect.left > imageSize.width * minMargin &&
        faceRect.top > imageSize.height * minMargin &&
        faceRect.right < imageSize.width * (1 - minMargin) &&
        faceRect.bottom < imageSize.height * (1 - minMargin);
    
    return isReasonableSize && hasAdequateMargin;
  }
}