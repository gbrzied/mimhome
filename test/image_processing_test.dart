import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:millime/core/utils/image_processing_utils.dart';

void main() {
  group('ImageProcessingUtils', () {
    test('should validate face for cropping correctly', () {
      // Test with a reasonable face size
      const faceRect = Rect.fromLTWH(100, 100, 200, 250);
      const imageSize = Size(800, 600);
      
      final isValid = ImageProcessingUtils.isValidFaceForCropping(faceRect, imageSize);
      expect(isValid, true);
    });

    test('should reject face that is too small', () {
      const faceRect = Rect.fromLTWH(100, 100, 20, 25); // Too small
      const imageSize = Size(800, 600);
      
      final isValid = ImageProcessingUtils.isValidFaceForCropping(faceRect, imageSize);
      expect(isValid, false);
    });

    test('should reject face that is too close to edges', () {
      const faceRect = Rect.fromLTWH(5, 5, 200, 250); // Too close to edges
      const imageSize = Size(800, 600);
      
      final isValid = ImageProcessingUtils.isValidFaceForCropping(faceRect, imageSize);
      expect(isValid, false);
    });

    test('should create centered face crop correctly', () {
      const faceRect = Rect.fromLTWH(100, 100, 200, 250);
      const imageSize = Size(800, 600);
      
      final cropRect = ImageProcessingUtils.createCenteredFaceCrop(faceRect, imageSize);
      
      expect(cropRect.width, faceRect.width * 2.0);
      expect(cropRect.height, faceRect.width * 2.0); // Square crop
      expect(cropRect.left, greaterThanOrEqualTo(0.0));
      expect(cropRect.top, greaterThanOrEqualTo(0.0));
    });

    test('should scale face coordinates correctly', () {
      const detectionRect = Rect.fromLTWH(0.2, 0.3, 0.4, 0.5);
      const detectionSize = Size(1.0, 1.0);
      const imageSize = Size(800, 600);
      
      final scaledRect = ImageProcessingUtils.scaleFaceRectToImage(
        detectionRect,
        detectionSize,
        imageSize,
      );
      
      expect(scaledRect.left, closeTo(160.0, 0.1)); // 0.2 * 800
      expect(scaledRect.top, closeTo(180.0, 0.1));  // 0.3 * 600
      expect(scaledRect.width, closeTo(320.0, 0.1)); // 0.4 * 800
      expect(scaledRect.height, closeTo(300.0, 0.1)); // 0.5 * 600
    });
  });
}