import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/utils/translation_constants.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/backend_server_provider.dart';

// --- Le fichier principal, par exemple, settings_screen.dart ---

class MillimeSettings extends StatefulWidget {
   const MillimeSettings({super.key});

    static Widget builder(BuildContext context) {
      return const MillimeSettings();
    }

    @override
   State<MillimeSettings> createState() => _MillimeSettingsState();
}

class _MillimeSettingsState extends State<MillimeSettings> {
  bool _isLanguageMenuExpanded = false;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<AppLanguageProvider>(
          builder: (context, appLanguageProvider, child) {
            return Stack(
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

                              // 4. Langue (avec sous-menu collapsible)
                              _buildCollapsibleLanguageTile(context, appLanguageProvider),

                              // 5. Mode (avec Switch)
                               CustomSettingsTile(
                                icon: ImageConstant.imgLight,
                                title: 'Mode',
                                subtitle: 'Activer le mode de nuit',
                                isToggle: true,
                                
                                initialToggleValue: false, // L'état initial du switch
                              ),

                              // 6. Serveur Backend
                              _buildBackendServerTile(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
        ],
      ),
    );
  }

  /// Build backend server configuration tile
  Widget _buildBackendServerTile(BuildContext context) {
    return Consumer<BackendServerProvider>(
      builder: (context, backendServerProvider, child) {
        return ListTile(
          leading: Container(
            width: 42,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: appTheme.overlayDark,
            ),
            child: Center(
              child: Icon(
                Icons.dns,
                color: appTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          title: Text(
            'Serveur Backend',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            backendServerProvider.getEnvironmentDisplayName(),
            style: const TextStyle(
              color: Colors.black45,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black45),
          onTap: () {
            _showBackendServerDialog(context, backendServerProvider);
          },
        );
      },
    );
  }

  /// Show backend server configuration dialog
  void _showBackendServerDialog(BuildContext context, BackendServerProvider provider) {
    final TextEditingController urlController = TextEditingController(text: provider.backendUrl);
    final TextEditingController portController = TextEditingController(text: provider.backendPort.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configuration Serveur Backend'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Environment selection
                const Text(
                  'Environnement:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<BackendEnvironment>(
                  value: provider.currentEnvironment,
                  onChanged: (BackendEnvironment? newValue) {
                    if (newValue != null) {
                      provider.setEnvironment(newValue);
                      urlController.text = provider.backendUrl;
                      portController.text = provider.backendPort.toString();
                    }
                  },
                  items: BackendEnvironment.values.map((environment) {
                    return DropdownMenuItem<BackendEnvironment>(
                      value: environment,
                      child: Text(provider.getEnvironmentDisplayName()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Server URL
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL du serveur',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Update URL in real-time
                  },
                ),
                const SizedBox(height: 16),
                
                // Port
                TextFormField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Current full URL display
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: appTheme.primaryColor.withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Text(
                //     'URL complet: ${provider.fullBackendUrl}',
                //     style: TextStyle(
                //       fontSize: 12,
                //       color: appTheme.primaryColor,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                final port = int.tryParse(portController.text.trim()) ?? 8080;
                
                if (url.isNotEmpty) {
                  await provider.setBackendServer(url, port: port);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Serveur backend mis à jour: ${provider.backendUrl}'),
                      backgroundColor: appTheme.successColor,
                    ),
                  );
                }
                
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  /// Get current language display name
  String _getCurrentLanguageName() {
    // Use the appLanguageProvider to get the current language display name
    return context.read<AppLanguageProvider>().currentLanguageDisplayName;
  }

  /// Build collapsible language tile with submenu
  Widget _buildCollapsibleLanguageTile(BuildContext context, AppLanguageProvider appLanguageProvider) {
    return Column(
      children: [
        // Main Language Menu Item
        ListTile(
          leading: Container(
            width: 42,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: appTheme.overlayDark,
            ),
            child: Center(
              child: CustomImageView(
                imagePath: ImageConstant.imgLangue,
                height: 24,
                width: 24,
                color: appTheme.primaryColor,
              ),
            ),
          ),
          title: Text(
            'Langue',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            _getCurrentLanguageName(),
            style: const TextStyle(
              color: Colors.black45,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isLanguageMenuExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          ),
          onTap: () {
            setState(() {
              _isLanguageMenuExpanded = !_isLanguageMenuExpanded;
            });
          },
        ),
        
        // Animated Language Options Submenu
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isLanguageMenuExpanded ? null : 0,
          child: ClipRect(
            child: Offstage(
              offstage: !_isLanguageMenuExpanded,
              child: Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildLanguageOption(
                          context,
                          languageCode: 'fr',
                          languageName: 'Français',
                          languageNameAr: 'الفرنسية',
                          languageNameEn: 'French',
                          isSelected: appLanguageProvider.currentLanguage == 'fr',
                          flag: "🇫🇷",
                          onTap: () => _changeLanguage(context, 'fr'),
                        ),
                        const SizedBox(height: 4),
                        _buildLanguageOption(
                          context,
                          languageCode: 'en',
                          languageName: 'English',
                          languageNameAr: 'الإنجليزية',
                          languageNameEn: 'English',
                          isSelected: appLanguageProvider.currentLanguage == 'en',
                             flag: "🇬🇧",
                          onTap: () => _changeLanguage(context, 'en'),
                        ),
                        const SizedBox(height: 4),
                        _buildLanguageOption(
                          context,
                          languageCode: 'ar',
                          languageName: 'العربية',
                          languageNameAr: 'العربية',
                          languageNameEn: 'Arabic',
                          isSelected: appLanguageProvider.currentLanguage == 'ar',
                          flag: "🇹🇳",
                          onTap: () => _changeLanguage(context, 'ar'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build language option for submenu
  Widget _buildLanguageOption(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required String languageNameAr,
    required String languageNameEn,
    required bool isSelected,
    required String flag,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.primaryColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? appTheme.primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? appTheme.primaryColor : appTheme.onSurfaceVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                 flag,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getLanguageDisplayName(languageCode, languageNameAr, languageNameEn),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? appTheme.primaryColor : appTheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: appTheme.primaryColor,
                size: 20,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: appTheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Get language display name based on current app language
  String _getLanguageDisplayName(String languageCode, String languageNameAr, String languageNameEn) {
    switch (AppTranslations.currentLanguage) {
      case 'en':
        return languageNameEn;
      case 'ar':
        return languageNameAr;
      default: // French
        return languageCode == 'fr' ? 'Français' : languageNameEn;
    }
  }

  /// Change language and show confirmation
  void _changeLanguage(BuildContext context, String languageCode) {
    final appLanguageProvider = Provider.of<AppLanguageProvider>(context, listen: false);
    appLanguageProvider.setLanguage(languageCode);
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getLanguageChangeMessage(languageCode)),
        backgroundColor: appTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Collapse the menu
    setState(() {
      _isLanguageMenuExpanded = false;
    });
  }

  /// Get language change confirmation message
  String _getLanguageChangeMessage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Language changed to English successfully';
      case 'ar':
        return 'تم تغيير اللغة إلى العربية بنجاح';
      default: // French
        return 'Langue changée en français avec succès';
    }
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
        },
        activeColor: const Color(0xFF4DB6AC),
      ),
      onTap: () {
        setState(() {
          _isOn = !_isOn;
        });
      },
    );
  }
}
