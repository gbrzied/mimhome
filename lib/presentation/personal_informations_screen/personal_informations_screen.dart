import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'models/personal_informations_model.dart';
import 'provider/personal_informations_provider.dart';

class PersonalInformationsScreen extends StatefulWidget {
  const PersonalInformationsScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<PersonalInformationsProvider>(
      create: (context) => PersonalInformationsProvider(),
      child: const PersonalInformationsScreen(),
    );
  }

  @override
  State<PersonalInformationsScreen> createState() => _PersonalInformationsScreenState();
}

class _PersonalInformationsScreenState extends State<PersonalInformationsScreen> {
  // Add focus node for phone field
  final FocusNode _phoneFocusNode = FocusNode();
  
  // Add focus node for email field
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Add listener for phone field focus changes
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        // Phone field lost focus - validate phone number
        _validatePhoneNumberOnBlur();
      }
    });
    
    // Add listener for email field focus changes
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        // Email field lost focus - validate email
        _validateEmailOnBlur();
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalInformationsProvider>().initialize();
    });
  }

  // Method to validate phone number when field loses focus
  void _validatePhoneNumberOnBlur() {
    final provider = context.read<PersonalInformationsProvider>();
    final phoneNumber = provider.phoneController.text;
    
    // Only validate if phone number is not empty and has 8 digits
    if (phoneNumber.isNotEmpty && phoneNumber.length == 8) {
      provider.validatePhoneNumberMatch(phoneNumber);
    }
  }
  
  // Method to validate email when field loses focus
  void _validateEmailOnBlur() {
    final provider = context.read<PersonalInformationsProvider>();
    final email = provider.emailController.text;
    
    // Only validate if email is not empty and is valid format
    if (email.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      provider.validateEmailMatch(email);
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: CustomProgressAppBar(
        currentStep: 3,
        totalSteps: 5,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
                child: Consumer<PersonalInformationsProvider>(
                  builder: (context, provider, child) {
                    return Form(
                      key: provider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations personnelles',
                            style: TextStyleHelper.instance.title18SemiBoldSyne.copyWith(
                              color: appTheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Nous avons besoin de quelques informations pour vérifier votre identité et créer votre compte',
                            style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                              color: appTheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 8.h),
                         //  SizedBox(height: 6.h),
                          _buildDocumentTypeDropdown(context, provider),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            context: context,
                            label: 'N° Pièce *',
                            controller: provider.numeroPieceController,
                            hintText: 'Entrez le numéro de votre pièce',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }

                              // Validate based on selected document type
                              final selectedType = provider.typePieceController.text;
                              if (selectedType.isNotEmpty) {
                                final validation = provider.validateDocumentNumber(selectedType, value);
                                if (!validation.isValid) {
                                  return validation.errorMessage ?? 'Format invalide';
                                }
                              }

                              return null;
                            },
                          ),
                          _buildTextField(
                            context: context,
                            label: 'Nom',
                            controller: provider.nomController,
                          //  provider: provider,
                            hintText: 'Entrez votre nom',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              if (value.length == 1) {
                                return 'Le nom doit contenir au moins 2 caractères';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: 'Prénom',
                            controller: provider.prenomController,
                           // provider: provider,
                            hintText: 'Entrez votre prénom',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              if (value.length == 1) {
                                return 'Le prénom doit contenir au moins 2 caractères';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: 'Date de naissance',
                            controller: provider.dateController,
                            readOnly: true,
                            onTap: () => provider.selectDate(context),
                         //   provider: provider,
                            hintText: 'Sélectionnez votre date de naissance',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              // Parse the date in DD-MM-YYYY format and check if person is at least 18 years old
                              try {
                                final parts = value.split('-');
                                if (parts.length != 3) throw FormatException('Invalid format');
                                final day = int.parse(parts[0]);
                                final month = int.parse(parts[1]);
                                final year = int.parse(parts[2]);
                                final date = DateTime(year, month, day);
                                final now = DateTime.now();
                                final age = now.difference(date).inDays / 365;
                                if (age < 18) {
                                  return 'Vous devez avoir au moins 18 ans';
                                }
                              } catch (e) {
                                return 'Date invalide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: 'Adresse',
                            controller: provider.adresseController,
                          //  provider: provider,
                            hintText: 'Entrez votre adresse',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              if (value.length == 1) {
                                return 'L\'adresse doit contenir au moins 2 caractères';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            maxLength: 8,
                            context: context,
                            label: 'Numéro de téléphone',
                            controller: provider.phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                          //  provider: provider,
                            hintText: 'Entrez votre numéro de téléphone',
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              final provider = context.read<PersonalInformationsProvider>();
                              
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              if (value.length != 8) {
                                return 'Longeur incorrecte';
                              }
                              if (value == '00000000') {
                                return 'Numéro de téléphone invalide';
                              }
                              
                              // Check for phone number mismatch error
                              if (provider.phoneNumberMismatchError != null) {
                                return provider.phoneNumberMismatchError;
                              }
                              
                              return null;
                            },
                          ),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            context: context,
                            label: 'Email',
                            controller: provider.emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                          //  provider: provider,
                            hintText: 'Entrez votre email',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Adresse email invalide';
                              }
                              
                              // Check for email mismatch error
                              if (provider.emailMismatchError != null) {
                                return provider.emailMismatchError;
                              }
                              
                              return null;
                            },
                          ),
                         
                          SizedBox(height: 12.h),
                          Text(
                            'Type de compte',
                            style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                              color: appTheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRadioOption(
                                  context: context,
                                  value: AccountType.titulaire,
                                  label: 'Titulaire',
                                  provider: provider,
                                ),
                              ),
                              SizedBox(width: 16.h),
                              Expanded(
                                child: _buildRadioOption(
                                  context: context,
                                  value: AccountType.titulaireEtSignataire,
                                  label: 'Titulaire et signataire',
                                  provider: provider,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24.h),
              child: Consumer<PersonalInformationsProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : () => provider.onSubmit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(appTheme.onPrimary),
                              ),
                            )
                          : Text(
                              'Suivant',
                              style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                                color: appTheme.onPrimary,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    AutovalidateMode? autovalidateMode,
    int maxLength=35
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4.h),
        CustomTextFormField(
          maxLength: maxLength,
          controller: controller,
          focusNode: focusNode,
          textInputType: keyboardType,
          readOnly: readOnly,
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode,
          onTap: onTap,
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDocumentTypeDropdown(
    BuildContext context,
    PersonalInformationsProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de pièce *',
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 48.h, // Same height as CustomTextFormField
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          decoration: BoxDecoration(
            color: appTheme.whiteCustom,
            border: Border.all(
              color: appTheme.gray_400,
              width: 1.h,
            ),
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: provider.isLoadingDocumentTypes
              ? Center(
                  child: SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                    ),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: provider.typePieceController.text.isNotEmpty
                      ? provider.typePieceController.text
                      : null,
                  hint: Center(
                    child: Text(
                      'Sélectionnez le type de pièce',
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.gray_600,
                      ),
                    ),
                  ),
                  items: provider.documentTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['code'],
                      child: Center(
                        child: Text(
                          type['label']!,
                          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                            color: appTheme.black_900,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.typePieceController.text = value;
                      provider.updateTypePiece(value);
                    }
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required AccountType value,
    required String label,
    required PersonalInformationsProvider provider,
  }) {
    final isSelected = provider.selectedAccountType == value;
    return InkWell(
      onTap: () => provider.selectAccountType(value),
      child: Row(
        children: [
          Container(
            width: 24.h,
            height: 24.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? appTheme.primaryColor : appTheme.onSurface,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12.h,
                      height: 12.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appTheme.primaryColor,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8.h),
          Flexible(
            child: Text(
              label,
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}