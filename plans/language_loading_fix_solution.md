# TermsConditionsScreenV2 Language Loading Fix - Solution Documentation

## Problem Summary

In `TermsConditionsScreenV2`, the document loading system was always defaulting to French documents regardless of the selected language. The root cause was that the `loadAllDocuments()` method was called from `initState` without providing the `AppLanguageProvider`, causing it to fall back to the default 'fr' language.

## Root Cause Analysis

### Issue Details
1. **Method Call**: `loadAllDocuments()` was called from `initState` without any parameters
2. **Parameter Handling**: The method had an optional `AppLanguageProvider?` parameter that was null by default
3. **Fallback Logic**: When provider was null, the method defaulted to 'fr' language
4. **Language Provider Availability**: The `AppLanguageProvider` was available in the context through `Consumer2<TermsConditionsProvider, AppLanguageProvider>` but wasn't being accessed

### Original Code Flow
```dart
// In initState (line 62)
loadAllDocuments(); // No provider passed

// In loadAllDocuments method (line 439)
final currentLanguage = languageProvider?.currentLanguage ?? 'fr'; // Always 'fr'
```

## Solution Implementation

### 1. Enhanced `loadAllDocuments` Method

**Changes Made**:
- Modified the method to automatically get the `AppLanguageProvider` from context when not provided
- Added proper error handling for provider availability
- Maintained backward compatibility with explicit provider passing

**Implementation**:
```dart
Future<void> loadAllDocuments([AppLanguageProvider? languageProvider]) async {
  try {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Get language provider from context if not provided
    AppLanguageProvider? provider = languageProvider;
    if (provider == null) {
      try {
        provider = context.read<AppLanguageProvider>();
      } catch (e) {
        // Provider not available in context, use fallback
        provider = null;
      }
    }

    final currentLanguage = provider?.currentLanguage ?? 'fr';
    // ... rest of method unchanged
```

### 2. Automatic Language Change Detection

**Changes Made**:
- Added a listener to automatically reload documents when language changes
- Created a stored listener reference for proper cleanup
- Removed redundant manual `loadAllDocuments()` calls from language selector

**Implementation**:
```dart
class _TermsConditionsScreenV2State extends State<TermsConditionsScreenV2> {
  // ... existing fields ...
  VoidCallback? _languageChangeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TermsConditionsProvider>().initialize();
      loadAllDocuments();
      
      // Create and store listener for language changes
      _languageChangeListener = () {
        loadAllDocuments();
      };
      
      // Add listener to reload documents when language changes
      context.read<AppLanguageProvider>().addListener(_languageChangeListener!);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    
    // Remove language change listener
    if (_languageChangeListener != null) {
      try {
        context.read<AppLanguageProvider>().removeListener(_languageChangeListener!);
      } catch (e) {
        // Provider might not be available during dispose
      }
      _languageChangeListener = null;
    }
    
    super.dispose();
  }
```

### 3. Streamlined Language Selector

**Changes Made**:
- Removed explicit `loadAllDocuments()` call from language selector
- Let the automatic listener handle document reload

**Before**:
```dart
onSelected: (String language) {
  languageProvider.setLanguage(language);
  loadAllDocuments(); // Reload documents with new language
},
```

**After**:
```dart
onSelected: (String language) {
  languageProvider.setLanguage(language);
  // Documents will be automatically reloaded by the language change listener
},
```

## Architecture Compliance

### Follows App Patterns
✅ **Provider Pattern**: Uses the existing `AppLanguageProvider` for state management
✅ **Context Access**: Properly accesses providers through Flutter's context system
✅ **Lifecycle Management**: Correctly manages listeners in `initState` and `dispose`
✅ **Error Handling**: Graceful fallback when provider is unavailable
✅ **Memory Management**: Properly cleans up listeners to prevent memory leaks

### Code Quality
✅ **Backward Compatibility**: Maintains existing API for explicit provider passing
✅ **Defensive Programming**: Handles provider unavailability gracefully
✅ **Separation of Concerns**: Language management separate from document loading logic
✅ **Clean Architecture**: Follows the app's established patterns

## Testing Recommendations

### Manual Testing Scenarios
1. **Initial Load Test**: 
   - Start app with different saved languages (fr, en, ar)
   - Verify correct documents load on screen entry

2. **Language Switching Test**:
   - Change language using the selector
   - Verify documents reload in new language
   - Check UI text updates correctly

3. **Provider Availability Test**:
   - Test during widget lifecycle changes
   - Verify no errors when provider is temporarily unavailable

4. **Memory Leak Test**:
   - Navigate in/out of screen multiple times
   - Monitor for memory usage growth
   - Verify proper listener cleanup

### Automated Testing Considerations
- Mock `AppLanguageProvider` for unit tests
- Test document loading with different language codes
- Verify listener registration and cleanup
- Test error handling scenarios

## Benefits of Solution

1. **Reliable Language Detection**: Documents now load in the correct language from startup
2. **Automatic Updates**: Language changes automatically trigger document reload
3. **Better UX**: No manual intervention needed for language switching
4. **Robust Error Handling**: Graceful fallbacks for edge cases
5. **Memory Safe**: Proper cleanup prevents memory leaks

## Files Modified

- `lib/presentation/accordion_document_screen/terms_conditions_screen_v2.dart`
  - Enhanced `loadAllDocuments()` method
  - Added language change listener
  - Updated lifecycle methods
  - Streamlined language selector

## Conclusion

The solution addresses the root cause of the language loading issue while maintaining code quality and following the app's architectural patterns. The implementation is robust, handles edge cases gracefully, and provides a better user experience through automatic language detection and updates.