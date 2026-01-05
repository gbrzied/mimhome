import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_text_form_field.dart';

import 'provider/pm_informations_provider.dart';
import '../../../localizationMillime/localization/app_localization.dart';

class PmInformationsScreen extends StatefulWidget {
  const PmInformationsScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<PmInformationsProvider>(
      create: (context) => PmInformationsProvider(),
      child: const PmInformationsScreen(),
    );
  }

  @override
  State<PmInformationsScreen> createState() => _PmInformationsScreenState();
}

class _PmInformationsScreenState extends State<PmInformationsScreen> {
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
      context.read<PmInformationsProvider>().initialize();
    });
  }

  // Method to validate phone number when field loses focus
  void _validatePhoneNumberOnBlur() {
    final provider = context.read<PmInformationsProvider>();
    final phoneNumber = provider.phoneController.text;
    
    // Only validate if phone number is not empty and has 8 digits
    if (phoneNumber.isNotEmpty && phoneNumber.length == 8) {
      provider.validatePhoneNumberMatch(phoneNumber);
    }
  }
  
  // Method to validate email when field loses focus
  void _validateEmailOnBlur() {
    final provider = context.read<PmInformationsProvider>();
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
        totalSteps: 7,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
                child: Consumer<PmInformationsProvider>(
                  builder: (context, provider, child) {
                    return Form(
                      key: provider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "key_pm_informations".tr,
                            style: TextStyleHelper.instance.title18SemiBoldSyne.copyWith(
                              color: appTheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "key_pm_informations_description".tr,
                            style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                              color: appTheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildDocumentTypeDropdown(context, provider),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            context: context,
                            label: "${"key_document_number".tr} *",
                            controller: provider.numeroPieceController,
                            hintText: "key_enter_document_number".tr,
                            maxLength: 8,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              provider.numeroPieceController.value = provider.numeroPieceController.value.copyWith(text: value.toUpperCase());
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }

                              // Validate based on selected document type
                              final selectedType = provider.typePieceController.text;
                              if (selectedType.isNotEmpty) {
                                final validation = provider.validateDocumentNumber(selectedType, value);
                                if (!validation.isValid) {
                                  return validation.errorMessage ?? "key_invalid_format".tr;
                                }
                              }

                              return null;
                            },
                          ),
                          _buildTextField(
                            context: context,
                            label: "key_corporate_name".tr,
                            controller: provider.raisonSocialeController,
                            hintText: "key_enter_corporate_name".tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "key_field_required".tr;
                              }
                              if (value.length == 1) {
                                return "key_corporate_name_minimum_characters".tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: "key_creation_date".tr,
                            controller: provider.dateController,
                            readOnly: true,
                            onTap: () => provider.selectDate(context),
                            hintText: "key_select_creation_date".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est requis';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: "key_address".tr,
                            controller: provider.adresseController,
                            hintText: "key_enter_address".tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "key_field_required".tr;
                              }
                              if (value.length == 1) {
                                return "key_address_minimum_characters".tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            maxLength: 8,
                            context: context,
                            label: "key_phone_number".tr,
                            controller: provider.phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            hintText: "key_enter_phone_number".tr,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "key_field_required".tr;
                              }
                              if (value.length != 8) {
                                return "key_invalid_phone_length".tr;
                              }
                              if (value == '00000000') {
                                return "key_invalid_phone_number".tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            context: context,
                            label: "key_email".tr,
                            controller: provider.emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            hintText: "key_enter_email".tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "key_field_required".tr;
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return "key_invalid_email_format".tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24.h),
              child: Consumer<PmInformationsProvider>(
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
    int maxLength = 35,
    ValueChanged<String>? onChanged,
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
          onChanged: onChanged,
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
    PmInformationsProvider provider,
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
          height: 48.h,
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
}