# Translation Implementation Checklist

## Phase 1: Critical Path Screens ✅

### 1.1 Account Type Selection Screen
- [ ] Fix hardcoded "Suivant" button → `'key_next'.tr()`
- [ ] Verify all other strings are using `.tr()` extension
- [ ] Test in all three languages (FR, EN, AR)

### 1.2 Login Screen
- [ ] Standardize all strings to use `.tr()` extension method
- [ ] Add missing translation keys (see mapping document)
- [ ] Remove any remaining `AppLocalization.of().getString()` calls
- [ ] Test phone number validation and error messages
- [ ] Test registration link translations

### 1.3 Account Level Selection Screen
- [ ] Replace "Choisir le niveau du compte" → `'key_choose_account_level'.tr()`
- [ ] Replace "Personne Physique/Morale" → `'key_individual_account'.tr()` / `'key_business_account'.tr()`
- [ ] Replace "Compte personnel/professionnel" → `'key_personal_account_description'.tr()` / `'key_business_account_description'.tr()`
- [ ] Replace "Solde maximal" → `'key_max_balance'.tr()`
- [ ] Replace "Cumul mensuel" → `'key_monthly_cumulative'.tr()`
- [ ] Replace "Suivant" button → `'key_next'.tr()`
- [ ] Add all required translation keys to language files
- [ ] Test account type display logic with translations

### 1.4 Personal Informations Screen
- [ ] Replace "Informations personnelles" → `'key_personal_information'.tr()`
- [ ] Replace description text → `'key_personal_information_description'.tr()`
- [ ] Replace all form field labels with translation keys
- [ ] Replace all validation messages with translation keys
- [ ] Replace "Type de pièce" → `'key_document_type'.tr()`
- [ ] Replace dropdown placeholder → `'key_select_document_type'.tr()`
- [ ] Replace "N° Pièce" → `'key_document_number'.tr()`
- [ ] Replace "Nom" → `'key_last_name'.tr()`
- [ ] Replace "Prénom" → `'key_first_name'.tr()`
- [ ] Replace "Date de naissance" → `'key_date_of_birth'.tr()`
- [ ] Replace "Adresse" → `'key_address'.tr()`
- [ ] Replace "Numéro de téléphone" → `'key_phone_number'.tr()`
- [ ] Replace "Email" → `'key_email'.tr()`
- [ ] Replace "Type de compte" → `'key_account_type'.tr()`
- [ ] Replace "Titulaire" → `'key_holder_only'.tr()`
- [ ] Replace "Titulaire et signataire" → `'key_holder_and_signatory'.tr()`
- [ ] Replace "Suivant" button → `'key_next'.tr()`
- [ ] Add all validation message keys
- [ ] Test date picker in all languages
- [ ] Test form validation with translated messages

### 1.5 Personal Informations Mandatory Screen
- [ ] Analyze current screen structure
- [ ] Apply same translation pattern as Personal Informations Screen
- [ ] Add mandatory-specific translation keys
- [ ] Test screen functionality

### 1.6 PM Informations Screen
- [ ] Analyze current screen structure  
- [ ] Translate business/company-specific fields
- [ ] Add business account translation keys
- [ ] Test screen functionality

## Phase 2: Identity Verification Screens ✅

### 2.1 Identity Verification Screen (Individual)
- [ ] Replace "Vérification d'identité" → `'key_identity_verification'.tr()`
- [ ] Replace description text → `'key_identity_verification_description'.tr()`
- [ ] Replace all document type labels:
  - "CIN Recto" → `'key_cin_recto'.tr()`
  - "CIN Verso" → `'key_cin_verso'.tr()`
  - "Selfie" → `'key_selfie'.tr()`
  - "Preuve de vie" → `'key_proof_of_life'.tr()`
  - "Signature" → `'key_signature'.tr()`
- [ ] Replace action buttons:
  - "Prendre une photo" → `'key_take_photo'.tr()`
  - "Reprendre la photo" → `'key_retake_photo'.tr()`
  - "Confirmer la photo" → `'key_confirm_photo'.tr()`
- [ ] Replace dialog options:
  - "Appareil photo" → `'key_camera'.tr()`
  - "Galerie" → `'key_gallery'.tr()`
- [ ] Replace status messages:
  - "Traitement en cours..." → `'key_processing'.tr()`
  - "Photo capturée avec succès!" → `'key_photo_captured_successfully'.tr()`
- [ ] Replace navigation buttons:
  - "Précédent" → `'key_previous'.tr()`
  - "Suivant" → `'key_next'.tr()`
- [ ] Add selfie-specific translation keys
- [ ] Test camera/gallery functionality in all languages

### 2.2 Identity Verification Mandatory Screen
- [ ] Analyze current screen structure
- [ ] Apply same translation pattern
- [ ] Add mandatory-specific translation keys
- [ ] Test screen functionality

### 2.3 Identity Verification PM Screen  
- [ ] Analyze current screen structure
- [ ] Apply same translation pattern for business accounts
- [ ] Add business-specific translation keys
- [ ] Test screen functionality

## Phase 3: Confirmation & Dashboard ✅

### 3.1 Wallet Setup Confirmation Screen
- [ ] Translate success messages
- [ ] Translate confirmation text
- [ ] Translate navigation buttons
- [ ] Test confirmation flow

### 3.2 Account Dashboard Screen
- [ ] Translate main interface elements
- [ ] Translate menu items
- [ ] Translate transaction descriptions
- [ ] Translate service labels
- [ ] Test dashboard functionality

## Phase 4: Secondary Screens ✅

### 4.1 Terms & Conditions Screens
- [ ] Translate legal text
- [ ] Translate buttons and navigation
- [ ] Test document loading in all languages

### 4.2 Settings & Language Selection
- [ ] Translate settings menu
- [ ] Translate language selection interface
- [ ] Test language switching functionality
- [ ] Verify RTL support for Arabic

### 4.3 Additional Screens
- [ ] Account Recovery Screen
- [ ] Bill Payment Selection Screen
- [ ] App Navigation Screen
- [ ] Onboarding Screens
- [ ] Other utility screens

## Translation Files Management ✅

### Add New Keys to Language Files
- [ ] Add new keys to `fr_tn_translations.dart`
- [ ] Add new keys to `en_us_translations.dart` 
- [ ] Add new keys to `ar_tn_translations.dart`
- [ ] Ensure all three files have matching keys
- [ ] Verify no missing keys cause app crashes

### Quality Assurance ✅

### Testing Checklist
- [ ] Test each screen in French (primary language)
- [ ] Test each screen in English (secondary language)
- [ ] Test each screen in Arabic (tertiary language)
- [ ] Verify RTL layout support for Arabic
- [ ] Test language switching functionality
- [ ] Test form validation messages in all languages
- [ ] Test dynamic content translation
- [ ] Test error messages in all languages
- [ ] Test success messages in all languages

### Code Quality ✅
- [ ] Ensure all screens use `.tr()` extension method
- [ ] Remove any remaining hardcoded strings
- [ ] Remove any remaining `AppLocalization.of().getString()` calls
- [ ] Verify no translation key typos
- [ ] Ensure consistent key naming convention
- [ ] Test app functionality after each translation

### Performance ✅
- [ ] Verify app loads properly with new translations
- [ ] Check for any translation-related crashes
- [ ] Test navigation between translated screens
- [ ] Verify memory usage is acceptable

## Progress Tracking

### Completion Status
- **Phase 1 (Critical Path)**: __ / 6 screens completed
- **Phase 2 (Identity Verification)**: __ / 3 screens completed  
- **Phase 3 (Dashboard)**: __ / 2 screens completed
- **Phase 4 (Secondary)**: __ / remaining screens completed

### Translation Files Updated
- **French (fr_tn)**: __% complete
- **English (en_us)**: __% complete  
- **Arabic (ar_tn)**: __% complete

### Issues & Notes
```
[Use this space to track issues encountered during translation]

Date: ________
Screen: _________________
Issue: _________________________________________________
Solution: _____________________________________________
Status: [ ] Resolved [ ] In Progress [ ] Blocked
```

## Success Criteria ✅

### Final Checklist
- [ ] Zero hardcoded strings in any screen
- [ ] All screens functional in French, English, and Arabic
- [ ] Consistent translation method (`.tr()` extension) across app
- [ ] Language switching works properly without crashes
- [ ] No app crashes due to missing translation keys
- [ ] Cultural and linguistic appropriateness of translations
- [ ] RTL layout works properly for Arabic
- [ ] All form validations work in all languages
- [ ] All dynamic content translates properly
- [ ] All error and success messages translate properly

**Translation Project Status: [ ] Not Started [ ] In Progress [ ] Complete**