import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import 'package:millime/theme/theme_helper.dart';

// --- Le fichier principal, par exemple, settings_screen.dart ---

class MillimeSettings extends StatelessWidget {
   const MillimeSettings({super.key});

   static Widget builder(BuildContext context) {
     return const MillimeSettings();
   }

   @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background overlay with gradient
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6BA8B8).withAlpha(204),
                    Color(0xFF9BC4CC).withAlpha(153),
                    appTheme.whiteCustom.withAlpha(77),
                  ],
                ),
              ),
            ),
          ),
          // Settings panel
          Positioned(
            top: 30,
            left: 0,
            child: Container(
              width: 289,
              height: 768,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  // La AppBar customisée
                  Container(
                    height: 150.0,
                    color: appTheme.primaryColor, // La couleur de fond de l'en-tête
                    padding: const EdgeInsets.only(top: 40.0, left: 16.0, bottom: 20.0),
                    alignment: Alignment.center,
                    child: _buildLogoSection(),
                  ),

                  // Le corps de la page (la liste des options)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      children: [
                        // 1. FAQ
                        CustomSettingsTile(
                          icon: ImageConstant.imgFaq,
                          title: 'FAQ',
                          subtitle: 'Questions fréquentes',
                          showChevron: false,
                        ),

                        // 2. Assistance
                         CustomSettingsTile(
                          icon: ImageConstant.imgAssistance,
                          title: 'Assistance',
                          subtitle: 'Support Client',
                          showChevron: false,
                        ),

                        // 3. À propos
                         CustomSettingsTile(
                          icon: ImageConstant.imgApropos,
                          title: 'A propos',
                          subtitle: 'à propos de l\'application',
                          showChevron: false,
                        ),

                        // 4. Langue
                         CustomSettingsTile(
                          icon: ImageConstant.imgLangue,
                          title: 'Langue',
                          subtitle: 'Français',
                          showChevron: true,
                        ),

                        // 5. Mode (avec Switch)
                         CustomSettingsTile(
                          icon: ImageConstant.imgLight,
                          title: 'Mode',
                          subtitle: 'Activer le mode de nuit',
                          isToggle: true,
                          
                          initialToggleValue: false, // L'état initial du switch
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget: Logo Section
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgMillimeLogo,
            height: 67.h,
            width: 137.h,
          ),
          SizedBox(height: 8.h),
          // Text(
          //   "MILLIME",
          //   style: TextStyleHelper.instance.title18SemiBoldQuicksand.copyWith(
          //     color: appTheme.black_900,
          //   ),
          // ),
        ],
      ),
    );
  }
}

// --- Widget pour un élément de la liste (ListTile customisé) ---
class CustomSettingsTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final bool showChevron;
  final bool isToggle;
  final bool initialToggleValue;
  final VoidCallback? onTap;
  final Color? color;

  const CustomSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showChevron = true,
    this.isToggle = false,
    this.initialToggleValue = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Si c'est un toggle, on utilise un StatefulWidget pour gérer l'état du switch
    if (isToggle) {
      return _ToggleSettingsTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        initialValue: initialToggleValue,
        color: color,
      );
    }

    // Sinon, on retourne un ListTile normal
    return ListTile(
      leading: Container(
        width: 42,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: appTheme.overlayDark
        ),
        child: Center(
          child: icon is IconData ? Icon(icon as IconData, color: color ?? appTheme.primaryColor) : CustomImageView(imagePath: icon as String, height: 24, width: 24, color: color ?? appTheme.primaryColor),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.black45
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: Colors.black45)
          : null,
      onTap: onTap, // Déclenche une action au clic
    );
  }
}

// --- Widget spécial pour le switch (pour gérer son propre état) ---
class _ToggleSettingsTile extends StatefulWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final bool initialValue;
  final Color? color;

  const _ToggleSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    this.color,
  });

  @override
  State<_ToggleSettingsTile> createState() => _ToggleSettingsTileState();
}

class _ToggleSettingsTileState extends State<_ToggleSettingsTile> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
                    color: appTheme.overlayDark

        ),
        child: Center(
          child: widget.icon is IconData ? Icon(widget.icon as IconData, color: widget.color ?? appTheme.primaryColor) : CustomImageView(imagePath: widget.icon as String, height: 24, width: 24, color: widget.color ?? appTheme.primaryColor),
        ),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0
        ),
      ),
      subtitle: Text(
        widget.subtitle,
        style: const TextStyle(
          color: Colors.black45
        ),
      ),
      trailing: Switch(
        value: _isOn,
        onChanged: (bool newValue) {
          setState(() {
            _isOn = newValue;
          });
          // Ici, vous ajouteriez la logique réelle pour changer de mode (ex: ThemeProvider)
          print('Mode de nuit activé : $newValue');
        },
        activeColor: const Color(0xFF4DB6AC), // Couleur du switch quand actif
      ),
      onTap: () {
        // Permet de cliquer sur tout l'élément pour changer l'état
        setState(() {
          _isOn = !_isOn;
        });
      },
    );
  }
}

// --- Widget pour lancer l'application (pour test) ---
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Millime App UI',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MillimeSettingsScreen(),
//     );
//   }
// }