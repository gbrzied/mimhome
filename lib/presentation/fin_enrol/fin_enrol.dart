import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/text_style_helper.dart';
import '../../core/app_export.dart';
import './provider/enrollment_success_provider.dart';

// Définition de la classe de l'écran de fin d'inscription
class EnrollmentSuccessScreen extends StatefulWidget {
  const EnrollmentSuccessScreen({super.key});

  @override
  State<EnrollmentSuccessScreen> createState() => _EnrollmentSuccessScreenState();
}

class _EnrollmentSuccessScreenState extends State<EnrollmentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // The provider will auto-submit on initialization
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EnrollmentSuccessProvider>(
      create: (context) => EnrollmentSuccessProvider()..initialize(),
      child: Consumer<EnrollmentSuccessProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: appTheme.white_A700,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: const Color(0xFFF0F0F0),
                      valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('5/5', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (provider.isLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Soumission de votre demande en cours...',
                            style: TextStyleHelper.instance.title16MediumSyne,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else if (provider.submissionSuccess)
                      Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              size: 80,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Félicitations',
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title38BoldQuicksand,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            provider.submissionMessage ?? 'Votre demande d\'ouverture de compte a été déposée avec succès.',
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title20RegularQuicksand,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () => provider.navigateToDashboard(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Continuer',
                              style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                                color: appTheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error,
                              size: 80,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Erreur',
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title38BoldQuicksand,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            provider.submissionMessage ?? 'Une erreur s\'est produite lors de la soumission.',
                            textAlign: TextAlign.center,
                            style: TextStyleHelper.instance.title20RegularQuicksand,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () => provider.submitAccountOpeningRequest(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Réessayer',
                              style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                                color: appTheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


