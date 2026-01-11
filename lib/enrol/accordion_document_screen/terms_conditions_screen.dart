import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custum_button.dart';
import 'provider/terms_conditions_provider.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<TermsConditionsProvider>(
      create: (context) => TermsConditionsProvider(),
      child: TermsConditionsScreen(),
    );
  }

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TermsConditionsProvider>().initialize();
    });
  }

  Widget _buildTermsCard(
    BuildContext context,
    TermsConditionsProvider provider, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<String> sections,
    required bool isAccepted,
    required ValueChanged<bool?> onAcceptedChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: appTheme.whiteCustom,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900.withOpacity(0.05),
            blurRadius: 10.h,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24.h,
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                        color: appTheme.black_900,
                        fontSize: 16.fSize,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyleHelper.instance.label11MediumManrope.copyWith(
                        color: appTheme.gray_600,
                        fontSize: 13.fSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Expandable Sections
          ...sections.map((key) => _buildExpandableItem(context, provider, key)),

          SizedBox(height: 16.h),

          // Checkbox and Actions
          Row(
            children: [
              Checkbox(
                value: isAccepted,
                onChanged: onAcceptedChanged,
                activeColor: appTheme.teal_400,
              ),
              Text(
                'Lu et approuvé',
                style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                  color: appTheme.black_900,
                  fontSize: 14.fSize,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.download_outlined, size: 20.h),
                color: appTheme.gray_600,
                onPressed: () {
                  // Download logic
                },
              ),
              IconButton(
                icon: Icon(Icons.share_outlined, size: 20.h),
                color: appTheme.gray_600,
                onPressed: () {
                  // Share logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableItem(BuildContext context, TermsConditionsProvider provider, String key) {
    final isExpanded = provider.termsConditionsModel.expandedSections![key] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: appTheme.gray_50_01,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              provider.toggleSection(key);
            },
            borderRadius: BorderRadius.circular(8.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Article 1 - Définitions',
                      style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                        color: appTheme.black_900,
                        fontSize: 14.fSize,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: appTheme.gray_600,
                    size: 20.h,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(16.h, 0, 16.h, 16.h),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                  color: appTheme.gray_700,
                  fontSize: 13.fSize,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TermsConditionsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
      backgroundColor: appTheme.gray_50_01,
      appBar: CustomAppBar(
        leadingIcon: ImageConstant.imgArrowLeft,
        onLeadingPressed: () => NavigatorService.goBack(),
        backgroundColor: appTheme.whiteCustom,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Conditions d'utilisation",
              style: TextStyleHelper.instance.headline30MediumDMSans.copyWith(
                color: appTheme.black_900,
                fontSize: 28.fSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Subtitle
            Text(
              "Veuillez lire et accepter les conditions suivantes",
              style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                color: appTheme.gray_600,
                fontSize: 14.fSize,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Terms Card
            _buildTermsCard(
              context,
              provider,
              icon: Icons.description_outlined,
              iconColor: appTheme.blue_gray_700,
              title: "Conditions générales d'utilisation",
              subtitle: "Consultez nos conditions d'utilisation",
              sections: ['terms_0', 'terms_1', 'terms_2'],
              isAccepted: provider.termsConditionsModel.termsAccepted ?? false,
              onAcceptedChanged: (value) {
                provider.setTermsAccepted(value ?? false);
              },
            ),
            SizedBox(height: 20.h),

            // Privacy Card
            _buildTermsCard(
              context,
              provider,
              icon: Icons.shield_outlined,
              iconColor: appTheme.teal_400,
              title: "Politique de confidentialité",
              subtitle: "Protection de vos données personnelles",
              sections: ['privacy_0', 'privacy_1', 'privacy_2'],
              isAccepted: provider.termsConditionsModel.privacyAccepted ?? false,
              onAcceptedChanged: (value) {
                provider.setPrivacyAccepted(value ?? false);
              },
            ),
            SizedBox(height: 20.h),

            // Contact Coordinates Card
            Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                color: appTheme.whiteCustom,
                borderRadius: BorderRadius.circular(16.h),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.black_900.withOpacity(0.05),
                    blurRadius: 10.h,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: appTheme.gray_50_01,
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: appTheme.teal_400,
                          size: 24.h,
                        ),
                      ),
                      SizedBox(width: 12.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Coordonnées de contact",
                              style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                                color: appTheme.black_900,
                                fontSize: 16.fSize,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Pour la récupération de compte",
                              style: TextStyleHelper.instance.label11MediumManrope.copyWith(
                                color: appTheme.gray_600,
                                fontSize: 13.fSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Phone Number
                  CustomTextFormField(
                    controller: TextEditingController(text: '98989898'),
                    textInputType: TextInputType.phone,
                    textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                      color: appTheme.black_900,
                      fontSize: 15.fSize,
                    ),
                    fillColor: appTheme.gray_50_01,
                    contentPadding: EdgeInsets.all(16.h),
                  ),
                  SizedBox(height: 12.h),

                  // Email
                  CustomTextFormField(
                    controller: TextEditingController(text: 'gbrzied@gmail.com'),
                    textInputType: TextInputType.emailAddress,
                    textStyle: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                      color: appTheme.black_900,
                      fontSize: 15.fSize,
                    ),
                    fillColor: appTheme.gray_50_01,
                    contentPadding: EdgeInsets.all(16.h),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Security Info Banner
            Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                color: appTheme.cyan_50_19,
                borderRadius: BorderRadius.circular(16.h),
                border: Border.all(
                  color: appTheme.cyan_200_16,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.h),
                    decoration: BoxDecoration(
                      color: appTheme.whiteCustom,
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: Icon(
                      Icons.security,
                      color: appTheme.cyan_900,
                      size: 28.h,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vos données sont protégées",
                          style: TextStyleHelper.instance.body14BoldManrope.copyWith(
                            color: appTheme.blue_gray_900,
                            fontSize: 15.fSize,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Nous utilisons un cryptage de niveau bancaire pour protéger vos informations personnelles.",
                          style: TextStyleHelper.instance.body12RegularManrope.copyWith(
                            color: appTheme.blue_gray_700,
                            fontSize: 12.fSize,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: appTheme.whiteCustom,
          boxShadow: [
            BoxShadow(
              color: appTheme.black_900.withOpacity(0.05),
              blurRadius: 10.h,
              offset: Offset(0, -5.h),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Valider',
          width: double.maxFinite,
          onPressed: ((provider.termsConditionsModel.termsAccepted ?? false) && (provider.termsConditionsModel.privacyAccepted ?? false))
              ? () {
                  // Validation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Conditions acceptées!'),
                      backgroundColor: appTheme.teal_400,
                    ),
                  );
                }
              : null,
        ),
      ),
    );
      },
    );
  }

}
