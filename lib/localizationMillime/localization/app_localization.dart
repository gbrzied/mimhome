

import 'package:millime/core/utils/navigator_service.dart';

import 'en_us/en_us_translations.dart';
import 'fr_tn/fr_tn_translations.dart';
import 'ar_tn/ar_tn_translations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';


class AppLocalization {
  AppLocalization(this.locale);

  Locale locale;

  static final Map<String, Map<String, String>> _localizedValues = {'fr': frTn,'en': enUs,'ar':arTn};

  static AppLocalization of() {
    if ( NavigatorService.navigatorKey.currentContext ==null)
      return AppLocalization(Locale('fr') );
    return Localizations.of<AppLocalization>(
          NavigatorService.navigatorKey.currentContext!, AppLocalization)!;
  }

  static List<String> languages() => _localizedValues.keys.toList();
  String getString(String text) =>
      _localizedValues[locale.languageCode]![text] ?? text;
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalization.languages().contains(locale.languageCode);

  //Returning a SynchronousFuture here because an async "load" operation
  //cause an async "load" operation
  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture<AppLocalization>(AppLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

extension LocalizationExtension on String {

  String get tr => AppLocalization.of().getString(this).replaceAll(RegExp(r'\{\{\d+\}\}'), "");
}

extension TranslationExtension on String {
  String translate([List<String> params = const []]) {
    String result = AppLocalization.of().getString(this);
    for (var i = 0; i < params.length; i++) {
      result = result.replaceAll('{{$i}}', params[i]);
    }
    return result;
  }
}

