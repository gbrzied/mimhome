# Plan: Mirror Document Saving Functionality in IdentityVerificationMandProvider

## Objective
Replace the manual SharedPreferences storage in IdentityVerificationMandProvider with DocumentManager.storeDocumentsWithCodes to match the implementation in IdentityVerificationProvider.

## Current Implementation Analysis

### IdentityVerificationProvider (Reference Implementation)
```dart
void navigateToNextScreen(BuildContext context) async {
  if (allDocumentsCaptured) {
    // Use DocumentManager to store documents with their codes
    if (identityVerificationModel.docManquants != null && 
        identityVerificationModel.tituimages != null) {
      await DocumentManager.storeDocumentsWithCodes(
        identityVerificationModel.tituimages!,
        identityVerificationModel.docManquants!,
      );
    }

    // Save other identity verification data to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('identity_cinr', identityVerificationModel.cinr ?? '');
    await prefs.setBool('identity_piece_id_verifiee', identityVerificationModel.pieceIdVerifiee ?? false);
    await prefs.setString('identity_selected_piece_type', identityVerificationModel.selectedPieceType ?? '');
    
    // Navigation logic...
  }
}
```

### IdentityVerificationMandProvider (Current Implementation)
```dart
void navigateToNextScreen(BuildContext context) async {
  if (allDocumentsCaptured) {
    // Save document data and validation results to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('identity_document_images_mand', identityVerificationMandModel.mandimages?.where((path) => path != null).cast<String>().toList() ?? []);
    await prefs.setString('identity_cinr_mand', identityVerificationMandModel.cinr ?? '');
    await prefs.setBool('identity_piece_id_verifiee_mand', identityVerificationMandModel.pieceIdVerifiee ?? false);
    await prefs.setString('identity_selected_piece_type_mand', identityVerificationMandModel.selectedPieceType ?? '');
    
    // Navigation logic...
  }
}
```

## Implementation Steps

### Step 1: Replace Document Storage with DocumentManager
**File**: `lib/presentation/identity_verification_mand_screen/provider/identity_verification_mand_provider.dart`
**Method**: `navigateToNextScreen()`
**Change**: Replace lines 927-932 with DocumentManager.storeDocumentsWithCodes() call

**Before**:
```dart
// Save document data and validation results to SharedPreferences
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setStringList('identity_document_images_mand', identityVerificationMandModel.mandimages?.where((path) => path != null).cast<String>().toList() ?? []);
```

**After**:
```dart
// Use DocumentManager to store documents with their codes
if (identityVerificationMandModel.docManquants != null && 
    identityVerificationMandModel.mandimages != null) {
  await DocumentManager.storeDocumentsWithCodes(
    identityVerificationMandModel.mandimages!,
    identityVerificationMandModel.docManquants!,
  );
}
```

### Step 2: Keep Additional Data Storage
Maintain the existing SharedPreferences storage for:
- `identity_cinr_mand`
- `identity_piece_id_verifiee_mand` 
- `identity_selected_piece_type_mand`

These are specific to the mandate flow and should remain as-is.

### Step 3: Ensure DocumentManager Import
**Verify**: The file already imports DocumentManager (line 17):
```dart
import '../../../core/utils/document_manager.dart';
```

### Step 4: Remove Redundant Code
The DocumentManager.storeDocumentsWithCodes method already handles:
- Filtering null/empty images
- Validating file existence
- Storing paired image-code data

So we can remove any redundant manual storage of document images.

## DocumentManager.storeDocumentsWithCodes Behavior

The method will:
1. Filter out null/empty images from `mandimages`
2. Pair each valid image with its corresponding document code from `docManquants`
3. Store in SharedPreferences using keys:
   - `identity_document_images`
   - `identity_document_codes`

## Data Flow Comparison

### Before (Current):
```
mandimages -> identity_document_images_mand (manual storage)
docManquants -> (not stored separately)
```

### After (Mirrored):
```
mandimages + docManquants -> DocumentManager.storeDocumentsWithCodes() -> 
  identity_document_images + identity_document_codes (managed storage)
```

## Benefits of This Change

1. **Consistency**: Both providers use the same document storage mechanism
2. **Maintainability**: Document management logic is centralized in DocumentManager
3. **Validation**: DocumentManager includes file existence checks and data validation
4. **Code Reusability**: Future changes to document storage only need to be made in one place

## Testing Considerations

After implementation, verify:
1. Documents are stored correctly with their codes
2. Navigation works as expected
3. Document data can be retrieved using DocumentManager.loadDocumentsWithCodes()
4. No regressions in existing functionality

## Files to Modify

- `lib/presentation/identity_verification_mand_screen/provider/identity_verification_mand_provider.dart`
  - Method: `navigateToNextScreen()`
  - Lines: 927-932 (approximately)

## Estimated Impact

- **Low Risk**: Minimal changes to existing logic
- **High Value**: Improved consistency and maintainability
- **No Breaking Changes**: All existing SharedPreferences data remains accessible