import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../localizationMillime/localization/app_localization.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'models/personal_informations_mand_model.dart';
import 'provider/personal_informations_mand_provider.dart';

class PersonalInformationsMandScreen extends StatefulWidget {
  const PersonalInformationsMandScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<PersonalInformationsMandProvider>(
      create: (context) => PersonalInformationsMandProvider(),
      child: const PersonalInformationsMandScreen(),
    );
  }

  @override
  State<PersonalInformationsMandScreen> createState() => _PersonalInformationsMandScreenState();
}

class _PersonalInformationsMandScreenState extends State<PersonalInformationsMandScreen> {
  // Add focus node for phone field
  final FocusNode _phoneFocusNode = FocusNode();
  
  // Add focus node for email field
  final FocusNode _emailFocusNode = FocusNode();

  final FocusNode _numPieceFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();

        // Add listener for phone field focus changes
    _numPieceFocusNode.addListener(() {
      if (!_numPieceFocusNode.hasFocus) {
        // Phone field lost focus - validate phone number
        _validateNumPieceOnBlur();
      }
    });
    
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
      context.read<PersonalInformationsMandProvider>().initialize();
    });
  }

  // Method to validate phone number when field loses focus
  void _validatePhoneNumberOnBlur() {
    final provider = context.read<PersonalInformationsMandProvider>();
    final phoneNumber = provider.phoneController.text;
    
    // Only validate if phone number is not empty and has 8 digits
    if (phoneNumber.isNotEmpty && phoneNumber.length == 8) {
      provider.validatePhoneNumberMatch(phoneNumber);
    }
  }



  void _validateNumPieceOnBlur() {
    final provider = context.read<PersonalInformationsMandProvider>();
    final numPiece = provider.numeroPieceController.text;
     final codePiece = provider.typePieceController.text;
    
    // Only validate if phone number is not empty and has 8 digits
    if (numPiece.isNotEmpty && numPiece.length == 8) {
      provider.validateNumPieceMatch(codePiece,numPiece);
    }
  }
  
  
  // Method to validate email when field loses focus
  void _validateEmailOnBlur() {
    final provider = context.read<PersonalInformationsMandProvider>();
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
        currentStep: 5,
        totalSteps: 7,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
                child: Consumer<PersonalInformationsMandProvider>(
                  builder: (context, provider, child) {
                    return Form(
                      key: provider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'key_mandataire_identity'.tr,
                            style: TextStyleHelper.instance.title18SemiBoldSyne.copyWith(
                              color: appTheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'key_personal_information_description'.tr,
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
                            label: '${'key_document_number'.tr} *',
                            focusNode: _numPieceFocusNode,

                            controller: provider.numeroPieceController,
                            hintText: 'key_enter_document_number'.tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }

                              // Validate based on selected document type
                              final selectedType = provider.typePieceController.text;
                              if (selectedType.isNotEmpty) {
                                final validation = provider.validateDocumentNumber(selectedType, value);
                                if (!validation.isValid) {
                                  return validation.errorMessage ?? 'key_invalid_document_number_format'.tr;
                                }
                              }

                              return null;
                            },
                          ),
                          _buildTextField(
                            context: context,
                            label: 'key_last_name'.tr,
                            controller: provider.nomController,
                          //  provider: provider,
                            hintText: 'key_enter_last_name'.tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }
                              if (value.length == 1) {
                                return 'key_minimum_characters'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: 'key_first_name'.tr,
                            controller: provider.prenomController,
                           // provider: provider,
                            hintText: 'key_enter_first_name'.tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }
                              if (value.length == 1) {
                                return 'key_minimum_characters'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: 'key_date_of_birth'.tr,
                            controller: provider.dateController,
                            readOnly: true,
                            onTap: () => provider.selectDate(context),
                         //   provider: provider,
                            hintText: 'key_select_birth_date'.tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }
                              // Parse the date in DD-MM-YYYY format and check if person is at least 18 years old
                              try {
                                final parts = value.split('-');
                                if (parts.length != 3) throw FormatException('Invalid date format');
                                final day = int.parse(parts[0]);
                                final month = int.parse(parts[1]);
                                final year = int.parse(parts[2]);
                                final date = DateTime(year, month, day);
                                final now = DateTime.now();
                                final age = now.difference(date).inDays / 365;
                                if (age < 18) {
                                  return 'key_must_be_18_years'.tr;
                                }
                              } catch (e) {
                                return 'key_invalid_date'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            context: context,
                            label: 'key_address'.tr,
                            controller: provider.adresseController,
                          //  provider: provider,
                            hintText: 'key_enter_address'.tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }
                              if (value.length == 1) {
                                return 'key_minimum_characters'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildTextField(
                            maxLength: 8,
                            context: context,
                            label: 'key_phone_number'.tr,
                            controller: provider.phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                          //  provider: provider,
                            hintText: 'key_enter_phone_number'.tr,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              final provider = context.read<PersonalInformationsMandProvider>();
                              
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }
                              if (value.length != 8) {
                                return 'key_invalid_phone_length'.tr;
                              }
                              if (value == '00000000') {
                                return 'key_invalid_phone_number'.tr;
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
                            label: 'key_email'.tr,
                            controller: provider.emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                          //  provider: provider,
                            hintText: 'key_enter_email'.tr,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'key_field_required'.tr;
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'key_invalid_email_format'.tr;
                              }
                              
                              // Check for email mismatch error
                              if (provider.emailMismatchError != null) {
                                return provider.emailMismatchError;
                              }
                              
                              return null;
                            },
                          ),
                         
                          SizedBox(height: 12.h),
                          // Handicap/signature checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: provider.isHandicapChecked,
                                onChanged: (value) {
                                  provider.isHandicapChecked = value ?? false;
                                  if (!provider.isHandicapChecked) {
                                    provider.handicapMotifController.clear();
                                  }
                                  provider.notifyListeners();
                                },
                                activeColor: appTheme.primaryColor,
                              ),
                              Expanded(
                                child: Text(
                                  'key_handicap_signature'.tr,
                                  style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                                    color: appTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Motif handicap text field (appears when checkbox is checked)
                          if (provider.isHandicapChecked) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                SizedBox(width: 44.h), // Align with text field content padding
                                Expanded(
                                  child: _buildTextField(
                                    context: context,
                                    label: 'key_motif_handicap'.tr,
                                    controller: provider.handicapMotifController,
                                    hintText: 'key_specify_handicap_reason'.tr,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (provider.isHandicapChecked && (value == null || value.isEmpty)) {
                                        return 'key_field_required_when_handicap_selected'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // SizedBox(height: 12.h),
                          // Text(
                          //   'Type de compte',
                          //   style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                          //     color: appTheme.onSurfaceVariant,
                          //   ),
                          // ),
                          // SizedBox(height: 10.h),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: _buildRadioOption(
                          //         context: context,
                          //         value: AccountType.titulaire,
                          //         label: 'Titulaire',
                          //         provider: provider,
                          //       ),
                          //     ),
                          //     SizedBox(width: 16.h),
                          //     Expanded(
                          //       child: _buildRadioOption(
                          //         context: context,
                          //         value: AccountType.titulaireEtSignataire,
                          //         label: 'Titulaire et signataire',
                          //         provider: provider,
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
              child: Consumer<PersonalInformationsMandProvider>(
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
                              'key_next'.tr,
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
              return 'key_field_required'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDocumentTypeDropdown(
    BuildContext context,
    PersonalInformationsMandProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'key_document_type'.tr} *',
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
                      'key_select_document_type'.tr,
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
                      return 'key_field_required'.tr;
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
    required PersonalInformationsMandProvider provider,
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