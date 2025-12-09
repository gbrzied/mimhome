import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalInformationsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        backgroundColor: appTheme.white_A700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: appTheme.black_900, size: 20),
          onPressed: () => NavigatorService.pushNamed(AppRoutes.appNavigationScreen),
        ),
        title: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: appTheme.cyan_900,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(width: 8.h),
            Expanded(
              flex: 7,
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: appTheme.gray_200,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Text(
              '3/5',
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.gray_600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.h),
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
                              color: appTheme.black_900,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Nous avons besoin de quelques informations pour vérifier votre identité et créer votre compte',
                            style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                              color: appTheme.gray_700,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          _buildTextField(
                            context: context,
                            label: 'Nom',
                            controller: provider.nomController,
                            provider: provider,
                          ),
                          SizedBox(height: 20.h),
                          _buildTextField(
                            context: context,
                            label: 'Prénom',
                            controller: provider.prenomController,
                            provider: provider,
                          ),
                          SizedBox(height: 20.h),
                          _buildTextField(
                            context: context,
                            label: 'Date de naissance',
                            controller: provider.dateController,
                            readOnly: true,
                            onTap: () => provider.selectDate(context),
                            provider: provider,
                          ),
                          SizedBox(height: 20.h),
                          _buildTextField(
                            context: context,
                            label: 'Adresse',
                            controller: provider.adresseController,
                            provider: provider,
                          ),
                          SizedBox(height: 20.h),
                          _buildTextField(
                            context: context,
                            label: 'Numéro de téléphone',
                            controller: provider.phoneController,
                            keyboardType: TextInputType.phone,
                            provider: provider,
                          ),
                          SizedBox(height: 20.h),
                          _buildTextField(
                            context: context,
                            label: 'Email',
                            controller: provider.emailController,
                            keyboardType: TextInputType.emailAddress,
                            provider: provider,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Type de compte',
                            style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                              color: appTheme.gray_700,
                            ),
                          ),
                          SizedBox(height: 12.h),
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
                          SizedBox(height: 32.h),
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
                        backgroundColor: appTheme.cyan_900,
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
                                valueColor: AlwaysStoppedAnimation<Color>(appTheme.white_A700),
                              ),
                            )
                          : Text(
                              'Suivant',
                              style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                                color: appTheme.white_A700,
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
    required PersonalInformationsProvider provider,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
            color: appTheme.gray_700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.black_900,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: appTheme.gray_300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: appTheme.cyan_900,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: appTheme.white_A700,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
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
                color: isSelected ? appTheme.cyan_900 : appTheme.gray_400,
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
                        color: appTheme.cyan_900,
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
                color: appTheme.gray_700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}