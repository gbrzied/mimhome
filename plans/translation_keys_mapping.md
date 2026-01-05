# Translation Keys Mapping for Millime App

## Overview
This document maps specific translation keys needed for each screen, organized by functionality and screen. Use this as a reference when adding keys to language files.

## Screen 1: Account Type Selection (Partially Done)

### Existing Keys (Already in files)
- `key_account_opening_request`
- `key_account_opening_description` 
- `key_choose_account_type`
- `key_individual_person`
- `key_personal_account_description`
- `key_legal_entity`
- `key_business_account_description`

### Keys to Add
```dart
// Button text
"key_next": "Next" (EN) / "Suivant" (FR) / "التالي" (AR)
```

## Screen 2: Login Screen (Partially Done)

### Existing Keys (Already in files)
- `key_num_tel`
- `key_entrer_num_tel`
- `key_next`
- `key_no_account_question`
- `key_register`
- `key_discover_app_question`
- `key_discover_app`

### Keys to Add
```dart
// Phone number validation
"key_invalid_mobile_number": "Invalid mobile number" / "Numéro mobile invalide" / "رقم هاتف غير صحيح"
"key_phone_number_required": "Phone number required" / "Numéro de téléphone requis" / "رقم الهاتف مطلوب"

// Error messages
"key_login_failed": "Login failed" / "Échec de connexion" / "فشل تسجيل الدخول"
"key_network_error": "Network error" / "Erreur réseau" / "خطأ في الشبكة"
```

## Screen 3: Account Level Selection (Not Translated)

### Keys to Add
```dart
// Main titles
"key_choose_account_level": "Choose account level" / "Choisir le niveau du compte" / "اختر مستوى الحساب"
"key_account_level_description": "Select your preferred account level for more details, then click next to proceed" / "Sélectionner le niveau pour avoir plus du détails sur ton choix et puis cliquer suivant pour avancer" / "اختر المستوى المفضل للحصول على مزيد من التفاصيل، ثم انقر على التالي للمتابعة"

// Account types
"key_individual_account": "Individual Account" / "Compte Personnel" / "حساب فردي"
"key_business_account": "Business Account" / "Compte Professionnel" / "حساب تجاري"
"key_personal_account_description": "Personal account for individuals" / "Compte personnel pour particuliers" / "حساب شخصي للأفراد"
"key_business_account_description": "Professional account for companies" / "Compte professionnel pour entreprises" / "حساب مهني للشركات"

// Level details
"key_max_balance": "Maximum Balance" / "Solde maximal" / "الرصيد الأقصى"
"key_monthly_cumulative": "Monthly Cumulative" / "Cumul mensuel" / "المجموع الشهري"
"key_level": "Level" / "Niveau" / "المستوى"

// Form validation
"key_select_account_level_first": "Please select an account level first" / "Veuillez d'abord sélectionner un niveau de compte" / "يرجى اختيار مستوى الحساب أولاً"
```

## Screen 4: Personal Informations (Not Translated)

### Keys to Add
```dart
// Main titles
"key_personal_information": "Personal Information" / "Informations personnelles" / "المعلومات الشخصية"
"key_personal_information_description": "We need some information to verify your identity and create your account" / "Nous avons besoin de quelques informations pour vérifier votre identité et créer votre compte" / "نحتاج إلى بعض المعلومات للتحقق من هويتك وإنشاء حسابك"

// Form fields
"key_document_type": "Document Type" / "Type de pièce" / "نوع الوثيقة"
"key_select_document_type": "Select document type" / "Sélectionnez le type de pièce" / "اختر نوع الوثيقة"
"key_document_number": "Document Number" / "N° Pièce" / "رقم الوثيقة"
"key_enter_document_number": "Enter your document number" / "Entrez le numéro de votre pièce" / "أدخل رقم وثيقتك"
"key_last_name": "Last Name" / "Nom" / "الاسم الأخير"
"key_enter_last_name": "Enter your last name" / "Entrez votre nom" / "أدخل اسمك الأخير"
"key_first_name": "First Name" / "Prénom" / "الاسم الأول"
"key_enter_first_name": "Enter your first name" / "Entrez votre prénom" / "أدخل اسمك الأول"
"key_date_of_birth": "Date of Birth" / "Date de naissance" / "تاريخ الميلاد"
"key_select_birth_date": "Select your birth date" / "Sélectionnez votre date de naissance" / "اختر تاريخ ميلادك"
"key_address": "Address" / "Adresse" / "العنوان"
"key_enter_address": "Enter your address" / "Entrez votre adresse" / "أدخل عنوانك"
"key_phone_number": "Phone Number" / "Numéro de téléphone" / "رقم الهاتف"
"key_enter_phone_number": "Enter your phone number" / "Entrez votre numéro de téléphone" / "أدخل رقم هاتفك"
"key_email": "Email" / "Email" / "البريد الإلكتروني"
"key_enter_email": "Enter your email" / "Entrez votre email" / "أدخل بريدك الإلكتروني"

// Account type selection
"key_account_type": "Account Type" / "Type de compte" / "نوع الحساب"
"key_holder_only": "Holder Only" / "Titulaire uniquement" / "المالك فقط"
"key_holder_and_signatory": "Holder and Signatory" / "Titulaire et signataire" / "المالك والتوقيع"

// Validation messages
"key_field_required": "This field is required" / "Ce champ est requis" / "هذا الحقل مطلوب"
"key_minimum_characters": "Must contain at least 2 characters" / "Doit contenir au moins 2 caractères" / "يجب أن يحتوي على حرفين على الأقل"
"key_invalid_date": "Invalid date" / "Date invalide" / "تاريخ غير صحيح"
"key_must_be_18_years": "You must be at least 18 years old" / "Vous devez avoir au moins 18 ans" / "يجب أن يكون عمرك 18 سنة على الأقل"
"key_invalid_phone_length": "Incorrect length" / "Longueur incorrecte" / "الطول غير صحيح"
"key_invalid_phone_number": "Invalid phone number" / "Numéro de téléphone invalide" / "رقم هاتف غير صحيح"
"key_invalid_email_format": "Invalid email address" / "Adresse email invalide" / "عنوان بريد إلكتروني غير صحيح"

// Button text
"key_submit": "Submit" / "Soumettre" / "إرسال"
```

## Screen 5: Identity Verification (Not Translated)

### Keys to Add
```dart
// Main titles
"key_identity_verification": "Identity Verification" / "Vérification d'identité" / "التحقق من الهوية"
"key_identity_verification_description": "Please upload clear photos of your CIN, your signature and a selfie to verify your identity" / "Veuillez téléverser des photos claires de votre CIN, votre signature et un selfie pour vérifier votre identité" / "يرجى تحميل صور واضحة لبطاقة الهوية والتوقيع وصورة ذاتية للتحقق من هويتك"

// Document types
"key_cin_recto": "CIN Front" / "CIN Recto" / "وجه بطاقة الهوية"
"key_cin_verso": "CIN Back" / "CIN Verso" / "ظهر بطاقة الهوية"
"key_selfie": "Selfie" / "Selfie" / "صورة ذاتية"
"key_proof_of_life": "Proof of Life" / "Preuve de vie" / "إثبات الحياة"
"key_signature": "Signature" / "Signature" / "التوقيع"

// Actions
"key_take_photo": "Take Photo" / "Prendre une photo" / "التقاط صورة"
"key_select_from_gallery": "Select from Gallery" / "Sélectionner dans la galerie" / "اختيار من المعرض"
"key_retake_photo": "Retake Photo" / "Reprendre la photo" / "إعادة التقاط الصورة"
"key_confirm_photo": "Confirm Photo" / "Confirmer la photo" / "تأكيد الصورة"
"key_camera": "Camera" / "Appareil photo" / "الكاميرا"
"key_gallery": "Gallery" / "Galerie" / "المعرض"

// Status messages
"key_processing": "Processing..." / "Traitement en cours..." / "جاري المعالجة..."
"key_photo_captured_successfully": "Photo captured successfully!" / "Photo capturée avec succès!" / "تم التقاط الصورة بنجاح!"
"key_capture_cancelled": "Capture cancelled" / "Capture annulée" / "تم إلغاء الالتقاط"
"key_capture_error": "Capture error" / "Erreur de capture" / "خطأ في الالتقاط"
"key_please_sign": "Please sign" / "Veuillez signer" / "يرجى التوقيع"
"key_cancel": "Cancel" / "Annuler" / "إلغاء"
"key_confirm": "Confirm" / "Confirmer" / "تأكيد"

// Selfie specific
"key_preparing_selfie_capture": "Preparing selfie capture..." / "Préparation de la capture de selfie..." / "جاري إعداد التقاط الصورة الذاتية"
"key_take_selfie": "Take Selfie" / "Prendre un selfie" / "التقاط صورة ذاتية"

// Navigation
"key_previous": "Previous" / "Précédent" / "السابق"
"key_next": "Next" / "Suivant" / "التالي"
```

## Screen 6: Wallet Setup Confirmation (Not Translated)

### Keys to Add
```dart
// Main titles
"key_wallet_setup_confirmation": "Wallet Setup Confirmation" / "Confirmation de configuration du portefeuille" / "تأكيد إعداد المحفظة"
"key_congratulations": "Congratulations" / "Félicitations" / "تهانينا"

// Messages
"key_account_created_successfully": "Your account has been created successfully!" / "Votre compte a été créé avec succès!" / "تم إنشاء حسابك بنجاح!"
"key_wallet_setup_complete": "Wallet setup is complete" / "La configuration du portefeuille est terminée" / "إعداد المحفظة مكتمل"
"key_ready_to_use": "Your account is ready to use" / "Votre compte est prêt à utiliser" / "حسابك جاهز للاستخدام"

// Actions
"key_go_to_dashboard": "Go to Dashboard" / "Aller au tableau de bord" / "الذهاب إلى لوحة التحكم"
"key_explore_app": "Explore App" / "Explorer l'application" / "استكشاف التطبيق"
```

## Screen 7: Terms & Conditions (Not Translated)

### Keys to Add
```dart
// Main titles
"key_terms_and_conditions": "Terms and Conditions" / "Conditions d'utilisation" / "الشروط والأحكام"
"key_read_and_accept": "Please read and accept the following conditions" / "Veuillez lire et accepter les conditions suivantes" / "يرجى قراءة وقبول الشروط التالية"

// Contact coordinates
"key_contact_coordinates": "Contact Coordinates" / "Coordonnées de contact" / "بيانات الاتصال"
"key_for_account_recovery": "For account recovery" / "Pour la récupération de compte" / "لاسترداد الحساب"
"key_phone_number_hint": "Enter your phone number" / "Entrez votre numéro de téléphone" / "أدخل رقم هاتفك"
"key_email_address_hint": "Enter your email address" / "Entrez votre adresse email" / "أدخل عنوان بريدك الإلكتروني"

// Data protection
"key_data_protection": "Your data is protected" / "Vos données sont protégées" / "بياناتك محمية"
"key_data_protection_description": "We use bank-level encryption to protect your personal information." / "Nous utilisons un cryptage de niveau bancaire pour protéger vos informations personnelles." / "نستخدم تشفير المستوى المصرفي لحماية معلوماتك الشخصية.

// Actions
"key_read_and_approved": "Read and approved" / "Lu et approuvé" / "مقروء ومقبول"
"key_read_more": "Read more..." / "Lire la suite..." / "اقرأ المزيد..."
"key_validate": "Validate" / "Valider" / "التحقق"
"key_close": "Close" / "Fermer" / "إغلاق"
```

## Screen 8: Account Dashboard (Not Translated)

### Keys to Add
```dart
// Main interface
"key_welcome_back": "Welcome back" / "Bon retour" / "مرحباً بعودتك"
"key_your_balance": "Your Balance" / "Votre Solde" / "رصيدك"
"key_actions": "Actions" / "Actions" / "الإجراءات"
"key_transactions": "Transactions" / "Transactions" / "المعاملات"
"key_transfer": "Transfer" / "Transfert" / "تحويل"
"key_reload": "Reload" / "Recharger" / "إعادة تحميل"
"key_see_more": "See More" / "Voir Plus" / "عرض المزيد"

// Services
"key_payments": "Payments" / "Paiements" / "المدفوعات"
"key_internet": "Internet" / "Internet" / "الإنترنت"
"key_others": "Others" / "Autres" / "أخرى"

// Utility services
"key_steg": "STEG" / "STEG" / "الستاغ"
"key_sonede": "SONEDE" / "SONEDE" / "سونيد"
"key_bank_statement": "Bank Statement" / "Relevé bancaire" / "كشف حساب"

## Screen 9: Settings & Language Selection (Not Translated)

### Keys to Add
```dart
// Settings menu
"key_settings": "Settings" / "Paramètres" / "الإعدادات"
"key_language": "Language" / "Langue" / "اللغة"
"key_select_language": "Select Language" / "Choisir la langue" / "اختر اللغة"
"key_profile": "Profile" / "Profil" / "الملف الشخصي"
"key_logout": "Logout" / "Déconnexion" / "تسجيل الخروج"
"key_about": "About" / "À propos" / "حول"
"key_assistance": "Assistance" / "Assistance" / "المساعدة"
"key_faq": "FAQ" / "FAQ" / "الأسئلة الشائعة"

// Language options
"key_french": "French" / "Français" / "الفرنسية"
"key_english": "English" / "Anglais" / "الإنجليزية"
"key_arabic": "Arabic" / "Arabe" / "العربية"
```

## Common Validation & Error Messages

```dart
// Generic validation
"key_field_required": "This field is required" / "Ce champ est requis" / "هذا الحقل مطلوب"
"key_invalid_format": "Invalid format" / "Format invalide" / "تنسيق غير صحيح"
"key_minimum_length": "Minimum length is {0} characters" / "La longueur minimale est de {0} caractères" / "الحد الأدنى للطول {0} أحرف"
"key_maximum_length": "Maximum length is {0} characters" / "La longueur maximale est de {0} caractères" / "الحد الأقصى للطول {0} أحرف"

// Network errors
"key_network_connection_error": "Network connection error" / "Erreur de connexion réseau" / "خطأ في الاتصال بالشبكة"
"key_server_error": "Server error" / "Erreur serveur" / "خطأ في الخادم"
"key_try_again_later": "Please try again later" / "Veuillez réessayer plus tard" / "يرجى المحاولة لاحقاً"

// Success messages
"key_operation_successful": "Operation successful" / "Opération réussie" / "العملية ناجحة"
"key_data_saved": "Data saved successfully" / "Données sauvegardées avec succès" / "تم حفظ البيانات بنجاح"
```

## Notes for Implementation

1. **Parameter Support**: Some keys use `{0}` placeholders for dynamic values (dates, amounts, etc.)
2. **RTL Support**: Ensure Arabic translations work properly with RTL layout
3. **Consistency**: Use same keys for same concepts across all screens
4. **Context**: Consider cultural context when translating legal and financial terms
5. **Testing**: Test each screen in all three languages after implementation