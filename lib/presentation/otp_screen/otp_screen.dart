import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:neon_circular_timer/neon_circular_timer.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../accordion_document_screen/provider/terms_conditions_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  static Widget builder(BuildContext context) {
    final phoneNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return OtpVerificationPage(phoneNumber: phoneNumber);
  }

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  CountDownController ctrTimerControler = CountDownController();
  bool inkwellvisible = false;
  bool dDisableInput = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  String _getValidOtpCode() {
          final provider = context.read<TermsConditionsProvider>();

    return provider.oneTimePass.toString();
  }
  void _validateOtp() async {
    String otp = _getOtpCode();
    if (otp.length == 6) {
      // Use the provider to validate OTP with backend
      final provider = context.read<TermsConditionsProvider>();
      bool isValid = await provider.validateOtpAndLogin(context, otp);

      if (!isValid) {
        provider.buildSuccessMessage(context, 'Code OTP invalide', isError: true);
      }
      // Navigation is handled in the provider's validateOtpAndLogin method
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code complet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: appTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: appTheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'OTP',
                      style: TextStyleHelper.instance.title20RegularRoboto.copyWith(
                        color: appTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Entrer le code reçu par sms sur le numéro',
                      style: TextStyleHelper.instance.body14RegularSyne.copyWith(
                        color: appTheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.phoneNumber+' '+_getValidOtpCode(),
                      style: TextStyleHelper.instance.body14SemiBoldManrope.copyWith(
                        color: appTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                      6,
                        (index) => SizedBox(
                          width: 45,
                          height: 54,
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (event) => _onKeyEvent(event, index),
                            child: TextField(
                               controller: _controllers[index],
                               focusNode: _focusNodes[index],
                               textAlign: TextAlign.center,
                               textAlignVertical: TextAlignVertical.center,
                               keyboardType: TextInputType.number,
                               maxLength: 1,
                               enabled: !dDisableInput,
                               style: TextStyleHelper.instance.title16SemiBoldPoppins.copyWith(
                                 color: appTheme.onSurface,
                               ),
                               decoration: InputDecoration(
                                 counterText: '',
                                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                 enabledBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(12),
                                   borderSide: BorderSide(
                                     color: appTheme.borderColor,
                                     width: 1.5,
                                   ),
                                 ),
                                 focusedBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(12),
                                   borderSide: BorderSide(
                                     color: appTheme.primaryColor,
                                     width: 2,
                                   ),
                                 ),
                                 filled: true,
                                 fillColor: appTheme.surfaceColor,
                               ),
                               inputFormatters: [
                                 FilteringTextInputFormatter.digitsOnly,
                               ],
                               onChanged: (value) => _onChanged(value, index),
                             ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !inkwellvisible,
                      child: NeonCircularTimer(
                        onComplete: () {
                          setState(() {
                            dDisableInput = true;
                            inkwellvisible = true;
                            for (var controller in _controllers) {
                              controller.clear();
                            }
                          });
                        },
                        width: 60,
                        duration: 30,
                        controller: ctrTimerControler,
                        isTimerTextShown: true,
                        neumorphicEffect: false,
                        textStyle: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: appTheme.onBackground),
                        innerFillGradient: LinearGradient(colors: [appTheme.primaryColor, Colors.blueAccent.shade400]),
                        neonGradient: LinearGradient(colors: [appTheme.primaryColor, Colors.blueAccent.shade400]),
                      ),
                    ),
                    Visibility(
                      visible: inkwellvisible,
                      child: Center(
                        child: InkWell(
                            onTap: () async {
                              final provider = context.read<TermsConditionsProvider>();
                              await provider.sendOtp(widget.phoneNumber);
                              setState(() {
                                ctrTimerControler = CountDownController();
                                for (var controller in _controllers) {
                                  controller.clear();
                                }
                                dDisableInput = false;
                                inkwellvisible = false;
                              });
                              _focusNodes[0].requestFocus();
                            },
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                "Le temps a expiré !",
                                style: TextStyle(
                                  color: appTheme.onBackground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Cliquer pour envoyer un autre code",
                                style: TextStyle(
                                  color: appTheme.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _validateOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Valider',
                    style: TextStyleHelper.instance.title16MediumSyne.copyWith(
                      color: appTheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}