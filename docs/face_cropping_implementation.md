# Face Cropping Implementation for Selfie Capture

## Overview

This implementation adds automatic face cropping functionality to the selfie capture system. When a face is detected during selfie capture, the system automatically crops the image to focus on the face region only.

## Key Components

### 1. ImageProcessingUtils (`lib/core/utils/image_processing_utils.dart`)

A utility class that provides image processing functions:

- **`cropImageToFace()`**: Main function that crops an image based on face coordinates
- **`getImageSize()`**: Gets the dimensions of an image file
- **`scaleFaceRectToImage()`**: Converts face detection coordinates to image coordinates
- **`createCenteredFaceCrop()`**: Creates a centered square crop around the face
- **`isValidFaceForCropping()`**: Validates if a face is suitable for cropping

### 2. Updated SelfieCaptureService (`lib/services/implementations/selfie_capture_service_impl.dart`)

Enhanced to use the new image processing utilities:

- **`_processImage()`**: Now implements actual face cropping instead of just using the original image
- Integrates face detection coordinates with image processing
- Provides fallback to original image if cropping fails

### 3. Dependencies

Added to `pubspec.yaml`:
- `image: ^4.2.0` - For image manipulation operations

## How It Works

1. **Face Detection**: The system detects faces using Google ML Kit Face Detection API
2. **Coordinate Mapping**: Face detection coordinates are scaled to match the actual image dimensions
3. **Face Validation**: The detected face is validated for cropping suitability (size, position, etc.)
4. **Image Cropping**: If valid, the image is cropped to show only the face region with appropriate padding
5. **Output**: The cropped image is saved as a new file and returned as the result

## Configuration

The cropping behavior can be configured in the `SelfieCaptureConfig`:

```dart
final config = const SelfieCaptureConfig(
  cropToFace: true,        // Enable face cropping
  saveOriginal: false,     // Don't save original image
  // ... other settings
);
```

## Cropping Parameters

- **Padding**: 80 pixels of padding around the face for better framing
- **Output Size**: 400x400 pixels (square format ideal for selfies)
- **Face Validation**: 
  - Face should be between 5% and 80% of image area
  - Face should have adequate margin from image edges (10%)

## Error Handling

- If face detection fails: Uses original image
- If image processing fails: Falls back to original image
- If face coordinates are invalid: Uses original image
- All errors are logged for debugging

## Benefits

1. **Privacy**: Automatically focuses on face, reducing background content
2. **Consistency**: Standardized output size and format
3. **User Experience**: No manual cropping required
4. **Storage Efficiency**: Smaller file sizes with focused content

## Usage

The face cropping is automatically enabled when:
1. Face detection is enabled (`requireFaceDetection: true`)
2. Face cropping is enabled (`cropToFace: true`)
3. A valid face is detected with appropriate coordinates

Users will see the cropped result in the image preview and can accept or retake the selfie as needed.

## Testing

Unit tests are provided in `test/image_processing_test.dart` covering:
- Face validation logic
- Coordinate scaling
- Crop rectangle generation
- Edge case handling