// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mobile_millime_16nov/presentation/personal_informations_screen/provider/personal_informations_provider.dart';

// class MockSharedPreferences extends Mock implements SharedPreferences {}

// void main() {
//   group('Phone Number Validation Tests', () {
//     late PersonalInformationsProvider provider;
//     late MockSharedPreferences mockPrefs;

//     setUp(() {
//       provider = PersonalInformationsProvider();
//       mockPrefs = MockSharedPreferences();
//     });

//     test('Phone number validation - matching numbers', () async {
//       // Mock SharedPreferences to return a stored phone number
//       when(mockPrefs.getString('terms_phone_number')).thenReturn('98765432');
      
//       // Test with matching phone number
//       final result = await provider.validatePhoneNumberMatch('98765432');
      
//       expect(result, true);
//       expect(provider.phoneNumberMismatchError, isNull);
//     });

//     test('Phone number validation - non-matching numbers', () async {
//       // Mock SharedPreferences to return a stored phone number
//       when(mockPrefs.getString('terms_phone_number')).thenReturn('98765432');
      
//       // Test with different phone number
//       final result = await provider.validatePhoneNumberMatch('12345678');
      
//       expect(result, false);
//       expect(provider.phoneNumberMismatchError, isNotNull);
//       expect(provider.phoneNumberMismatchError, 
//           'Le numéro de téléphone ne correspond pas à celui enregistré précédemment');
//     });

//     test('Phone number validation - no stored number', () async {
//       // Mock SharedPreferences to return null (no stored phone number)
//       when(mockPrefs.getString('terms_phone_number')).thenReturn(null);
      
//       // Test with any phone number
//       final result = await provider.validatePhoneNumberMatch('12345678');
      
//       expect(result, true);
//       expect(provider.phoneNumberMismatchError, isNull);
//     });
//   });
// }