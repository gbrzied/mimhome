# Millime App - Comprehensive Translation Plan

## Overview
This document outlines the complete translation strategy for the Millime banking app, utilizing existing translation files (`fr_tn_translations.dart`, `en_us_translations.dart`, `ar_tn_translations.dart`) to translate all screens in navigation order.

## Current Status Analysis

### ✅ Already Translated
- **OTP Screen** (`otp_screen.dart`) - Fully translated using `.tr()` extension
- **Account Type Selection Screen** (`account_type_pers_selection_screen.dart`) - Mostly translated, needs 1 fix

### 🔄 Partially Translated  
- **Login Screen** (`login_screen.dart`) - Mixed approach (some `.tr()`, some `AppLocalization.of().getString()`)

### ❌ Not Translated (Hardcoded French)
- **Account Level Selection Screen** (`account_level_selection_screen.dart`)
- **Personal Informations Screen** (`personal_informations_screen.dart`) 
- **Personal Informations Mandatory Screen** (`personal_informations_mand_screen.dart`)
- **PM Informations Screen** (`pm_informations_screen.dart`)
- **Identity Verification Screen** (`identity_verification_screen.dart`)
- **Identity Verification Mandatory Screen** (`identity_verification_mand_screen.dart`)
- **Identity Verification PM Screen** (`identity_verification_pm_screen.dart`)
- **Wallet Setup Confirmation Screen** (`wallet_setup_confirmation_screen.dart`)
- **Terms & Conditions Screen** (`terms_conditions_screen.dart`)
- **Terms & Conditions V2 Screen** (`terms_conditions_screen_v2.dart`)
- **Account Dashboard Screen** (`account_dashboard_screen.dart`)
- **Settings Screens** (multiple files)
- **Other Screens** (various utility screens)

## Navigation Flow & Priority Order

Based on `app_routes.dart`, the typical user journey is:

1. **Login Screen** → 2. **OTP Screen** → 3. **Account Type Selection** → 4. **Account Level Selection** → 5. **Personal Informations** → 6. **Identity Verification** → 7. **Wallet Setup Confirmation** → 8. **Account Dashboard**

## Translation Strategy

### 1. Translation Method Standardization
- **Use**: `.tr()` extension method (e.g., `'key_login'.tr()`)
- **Avoid**: `AppLocalization.of().getString()` method
- **Reason**: More concise and consistent with existing translated screens

### 2. Key Naming Convention
- Follow existing pattern: `key_[descriptive_name]`
- Use clear, descriptive keys that indicate purpose and location
- Examples: `key_phone_number`, `key_account_level_selection`, `key_identity_verification`

### 3. Language Coverage
- **French (fr_tn)**: Primary language - ensure all strings are properly translated
- **English (en_us)**: Secondary language - provide accurate translations  
- **Arabic (ar_tn)**: Tertiary language - ensure RTL support considerations

## Implementation Plan

### Phase 1: Critical Path Screens (High Priority)
**Screens in user registration flow - must be completed first**

#### 1.1 Fix Account Type Selection Screen
- **File**: `lib/presentation/account_type_selection_screen/account_type_pers_selection_screen.dart`
- **Issues**: Hardcoded "Suivant" button text
- **Action**: Replace with `'key_next'.tr()`

#### 1.2 Complete Login Screen Translation  
- **File**: `lib/presentation/login_screen/login_screen.dart`
- **Issues**: Inconsistent translation method usage
- **Actions**:
  - Standardize all strings to use `.tr()` extension
  - Add missing translation keys
  - Ensure all UI text is translatable

#### 1.3 Translate Account Level Selection Screen
- **File**: `lib/presentation/account_level_selection_screen/account_level_selection_screen.dart`
- **Status**: Completely hardcoded in French
- **Actions**:
  - Replace all hardcoded French strings with translation keys
  - Add required keys to all language files
  - Test account type display logic with translations

#### 1.4 Translate Personal Informations Screen
- **File**: `lib/presentation/personal_informations_screen/personal_informations_screen.dart`
- **Status**: Completely hardcoded in French
- **Actions**:
  - Translate all form labels, validation messages, and UI text
  - Handle dynamic content and validation error messages
  - Ensure date picker and dropdown translations work properly

#### 1.5 Translate Personal Informations Mandatory Screen
- **File**: `lib/presentation/personal_informations_mand_screen/personal_informations_mand_screen.dart`
- **Status**: Needs analysis and translation
- **Actions**: Full screen translation following same pattern

#### 1.6 Translate PM Informations Screen
- **File**: `lib/presentation/pm_informations_screen/pm_informations_screen.dart`
- **Status**: Needs analysis and translation  
- **Actions**: Full screen translation for business account information

### Phase 2: Identity Verification Screens (High Priority)
**Critical for account verification process**

#### 2.1 Identity Verification Screen (Individual)
- **File**: `lib/presentation/identity_verification_titu_pp_screen/identity_verification_screen.dart`
- **Status**: Completely hardcoded in French
- **Actions**:
  - Translate all document type labels, instructions, and button text
  - Handle dynamic document lists and validation messages
  - Ensure camera/gallery dialog translations work

#### 2.2 Identity Verification Mandatory Screen  
- **File**: `lib/presentation/identity_verification_mand_screen/identity_verification_mand_screen.dart`
- **Status**: Needs analysis and translation
- **Actions**: Full screen translation following verification pattern

#### 2.3 Identity Verification PM Screen
- **File**: `lib/presentation/identity_verification_pm_screen/identity_verification_pm_screen.dart`
- **Status**: Needs analysis and translation
- **Actions**: Full screen translation for business accounts

### Phase 3: Confirmation & Dashboard (Medium Priority)

#### 3.1 Wallet Setup Confirmation Screen
- **File**: `lib/presentation/wallet_setup_confirmation_screen/wallet_setup_confirmation_screen.dart`
- **Actions**: Translate success messages, confirmation text, and navigation

#### 3.2 Account Dashboard Screen
- **File**: `lib/presentation/account_dashboard_screen/account_dashboard_screen.dart`
- **Actions**: Translate main app interface, menu items, and transaction descriptions

### Phase 4: Secondary Screens (Lower Priority)

#### 4.1 Terms & Conditions Screens
- **Files**: 
  - `lib/presentation/accordion_document_screen/terms_conditions_screen.dart`
  - `lib/presentation/accordion_document_screen/terms_conditions_screen_v2.dart`
- **Actions**: Translate legal text, buttons, and navigation

#### 4.2 Settings & Language Selection
- **Files**: 
  - `lib/presentation/millime_settings/millime_settings.dart`
  - `lib/presentation/millime_settings/language_selection_screen.dart`
- **Actions**: Translate settings options and language selection interface

#### 4.3 Additional Screens
- Account Recovery Screen
- Bill Payment Selection Screen  
- App Navigation Screen
- Onboarding Screens
- Other utility screens

## Translation Keys to Add

Based on the analysis, we need to add approximately 100+ new translation keys covering:

### Authentication & Registration
- Account opening flow
- Form validation messages
- Error messages
- Success messages

### Personal Information
- Form field labels
- Validation rules
- Date and address formatting

### Identity Verification  
- Document types
- Camera instructions
- Validation feedback

### Main Application
- Dashboard elements
- Menu items
- Transaction descriptions
- Settings options

## Quality Assurance

### 1. Translation Consistency
- Ensure same key is used for same concept across all screens
- Maintain consistent tone and terminology
- Verify cultural appropriateness of translations

### 2. Testing Requirements
- Test all screens in all three languages (French, English, Arabic)
- Verify RTL layout support for Arabic
- Test language switching functionality
- Validate dynamic content translation

### 3. Code Quality
- Remove all hardcoded strings
- Ensure no missing translation keys cause app crashes
- Maintain existing code structure and patterns

## Estimated Timeline

- **Phase 1 (Critical Path)**: 2-3 screens per session, ~6-8 sessions
- **Phase 2 (Identity Verification)**: 3 screens, ~4-6 sessions  
- **Phase 3 (Dashboard)**: 2 screens, ~3-4 sessions
- **Phase 4 (Secondary)**: Remaining ~10 screens, ~8-10 sessions

**Total Estimated Time**: 21-28 coding sessions

## Next Steps

1. **Start with Phase 1.1**: Fix the Account Type Selection screen
2. **Proceed through Phase 1**: Complete critical path screens
3. **Move to Phase 2**: Identity verification screens
4. **Continue systematically**: Through remaining phases
5. **Final validation**: Test all languages and functionality

## Success Criteria

- ✅ Zero hardcoded strings in any screen
- ✅ All screens functional in French, English, and Arabic
- ✅ Consistent translation method (`.tr()` extension) across app
- ✅ Language switching works properly
- ✅ No app crashes due to missing translation keys
- ✅ Cultural and linguistic appropriateness of translations