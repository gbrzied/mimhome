import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class to manage document codes and file operations
class DocumentManager {
  /// Map document codes to their display names
  static const Map<String, String> documentCodeNames = {
    'CINR': 'CIN Recto',
    'CINV': 'CIN Verso',
    'SELFIE': 'Selfie',
    'PREUVEIE': 'Preuve de vie',
    'SIGN': 'Signature',
    'PASSPORT': 'Passeport',
  };

  /// Store document images with their codes in SharedPreferences
  /// 
  /// [documentImages] - List of image file paths
  /// [documentCodes] - List of corresponding document codes
  /// [prefix] - Prefix for storing documents (e.g., 'titu', 'mand')
  static Future<void> storeDocumentsWithCodes(
    List<String?> documentImages,
    List<String> documentCodes, {
    String prefix = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Filter out null images and create paired list
    final List<String> validImagePaths = [];
    final List<String> validDocumentCodes = [];
    
    for (int i = 0; i < documentImages.length; i++) {
      if (documentImages[i] != null && 
          documentImages[i]!.isNotEmpty && 
          File(documentImages[i]!).existsSync()) {
        validImagePaths.add(documentImages[i]!);
        if (i < documentCodes.length) {
          validDocumentCodes.add(documentCodes[i]);
        } else {
          // Fallback to generic code if not enough codes provided
          validDocumentCodes.add('DOC_${i + 1}');
        }
      }
    }
    
    // Store the paired data with prefix
    final String imagesKey = prefix.isEmpty ? 'identity_document_images' : '${prefix}_identity_document_images';
    final String codesKey = prefix.isEmpty ? 'identity_document_codes' : '${prefix}_identity_document_codes';
    
    await prefs.setStringList(imagesKey, validImagePaths);
    await prefs.setStringList(codesKey, validDocumentCodes);
    
    debugPrint('✅ Stored ${validImagePaths.length} documents with prefix "$prefix" and codes: $validDocumentCodes');
  }

  /// Load document images with their codes from SharedPreferences
  /// 
  /// Returns a map with image paths as keys and document codes as values
  static Future<Map<String, String>> loadDocumentsWithCodes(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    
    final List<String>? imagePaths = prefs.getStringList('${prefix}_identity_document_images');
    final List<String>? documentCodes = prefs.getStringList('${prefix}_identity_document_codes');
    
    final Map<String, String> documentsWithCodes = {};
    
    if (imagePaths != null && documentCodes != null) {
      for (int i = 0; i < imagePaths.length && i < documentCodes.length; i++) {
        if (File(imagePaths[i]).existsSync()) {
          documentsWithCodes[imagePaths[i]] = documentCodes[i];
        }
      }
    }
    
    debugPrint('✅ Loaded ${documentsWithCodes.length} documents with codes');
    return documentsWithCodes;
  }

  /// Get filename for document based on document code
  /// 
  /// [documentCode] - The document code (e.g., 'CINR', 'CINV')
  /// [fileExtension] - File extension (default: empty string)
  static String getDocumentFilename(String documentCode, {String fileExtension = ''}) {
    // Remove any existing extension and normalize the code
    final normalizedCode = documentCode.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (fileExtension.isEmpty) {
      return normalizedCode;
    } else {
      // Add dot before extension if provided
      final cleanExtension = fileExtension.startsWith('.') ? fileExtension : '.$fileExtension';
      return '$normalizedCode$cleanExtension';
    }
  }

  /// Rename and copy document to standardized location with document code as filename
  /// 
  /// [sourcePath] - Source image file path
  /// [documentCode] - Document code (e.g., 'CINR', 'CINV')
  /// [fileExtension] - File extension (default: empty string)
  /// [prefix] - Prefix for subdirectory (e.g., 'titu', ' mand'). If empty, uses main documents directory
  static Future<String?> renameAndStoreDocument(
    String sourcePath,
    String documentCode, {
    String fileExtension = '',
    String prefix = '',
  }) async {
    try {
      if (!File(sourcePath).existsSync()) {
        debugPrint('❌ Source file does not exist: $sourcePath');
        return null;
      }

      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Build path based on prefix
      final documentsPath = prefix.isEmpty 
          ? '${directory.path}/documents'
          : '${directory.path}/documents/$prefix';
          
      final documentsDir = Directory(documentsPath);
      
      // Create documents directory (and prefix subdirectory if needed) if it doesn't exist
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      // Generate new filename with document code
      final newFilename = getDocumentFilename(documentCode, fileExtension: fileExtension);
      final newPath = '${documentsDir.path}/$newFilename';

      // Copy file to new location with new name
      await File(sourcePath).copy(newPath);
      
      debugPrint('✅ Document renamed and stored: $sourcePath -> $newPath (prefix: "$prefix")');
      return newPath;
    } catch (e) {
      debugPrint('❌ Error renaming document: $e');
      return null;
    }
  }

  /// Clear stored document data from SharedPreferences
  /// 
  /// [prefix] - Prefix for the keys to clear. If empty, clears default keys
  static Future<void> clearStoredDocuments({String prefix = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefix.isEmpty) {
      // Clear default keys (backward compatibility)
      await prefs.remove('identity_document_images');
      await prefs.remove('identity_document_codes');
      debugPrint('🧹 Cleared default stored document data');
    } else {
      // Clear prefixed keys
      final imagesKey = '${prefix}_identity_document_images';
      final codesKey = '${prefix}_identity_document_codes';
      await prefs.remove(imagesKey);
      await prefs.remove(codesKey);
      debugPrint('🧹 Cleared stored document data for prefix "$prefix"');
    }
  }

  /// Get display name for document code
  static String getDocumentDisplayName(String documentCode) {
    return documentCodeNames[documentCode] ?? documentCode;
  }

  /// Validate if document code is supported
  static bool isValidDocumentCode(String documentCode) {
    return documentCodeNames.containsKey(documentCode.toUpperCase());
  }
}