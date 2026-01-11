import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart' as sizer;

import 'localizationMillime/localization/app_localization.dart';
import 'theme/theme_helper.dart';
import 'routes/app_routes.dart';
import 'providers/app_language_provider.dart';
import 'providers/backend_server_provider.dart';
import 'core/app_export.dart';

// 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (context) => BackendServerProvider()),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, appLanguageProvider, child) {
          // Ensure provider is not null before accessing methods
          if (appLanguageProvider == null) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          
          // Get current locale from provider
          final currentLocale = appLanguageProvider.getCurrentLocale();
          return MaterialApp(
            navigatorKey: NavigatorService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Millime',
            theme: ThemeHelper().themeData(),
            initialRoute: AppRoutes.initialRoute,
            routes: AppRoutes.routes,
            locale: currentLocale,
            supportedLocales: [
              const Locale('fr'), // French (Tunisia)
              const Locale('en'), // English (US)
              const Locale('ar'), // Arabic (Tunisia)
            ],
            localizationsDelegates: const [
              AppLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Sizer(
                  builder: (context, orientation, deviceType) {
                    return child ?? const SizedBox.shrink();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
