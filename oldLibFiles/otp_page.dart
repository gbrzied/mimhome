import 'package:flutter/material.dart';

import 'package:flutter_countdown_timer/countdown_timer_controller.dart';

import 'package:millime/Enrolement/authent.dart';
import 'package:millime/common/functions.dart';
import 'package:millime/conf/size_utils.dart';
import 'package:millime/core/utils/image_constant.dart';
import 'package:millime/localizationMillime/localization/app_localization.dart';
import 'package:millime/pages/custom_image_view.dart';
import 'package:millime/theme/custom_text_style.dart';
import 'package:millime/theme/theme_helper.dart';
import 'package:millime/fixed_packages/neon_circular_timer/neon_circular_timer.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';


import 'package:millime/pages/figma_integration/color.dart';
import 'package:millime/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:millime/stores/login_store.dart';
import 'package:millime/theme.dart';


// ignore: must_be_immutable
class OtpPage extends StatefulWidget {
  bool? reset;

  OtpPage({Key? key, bool? reset}) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String text = '';
  bool dDisableInput = false;

  final keyz2 = GlobalKey<FormState>();
  final CountDownController ctrTimerControler = new CountDownController();

  bool inkwellvisible = false;

  bool _passChanged = false;

  String msg = '';
  bool rtl= false;

  void _onKeyboardTap(String value) {
    setState(() {
      if (!dDisableInput && text.length < 6) text = text + value;
    });
  }

  @override
  void initState() {
    super.initState();
    rtl = AppLocalization.of().locale.languageCode=='ar';
    timerController = CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  Widget otpNumberWidget(int position) {
    final colors = context.watchAppColors;
    bool hasValue = text.length > position;
    bool isActive = text.length == position;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive
            ? colors.greenmillime
            : hasValue
              ? colors.greenmillime.withOpacity(0.7)
              : colors.borderColor,
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasValue
          ? colors.greenmillime.withOpacity(0.1)
          : colors.backgroundColor,
        boxShadow: isActive ? [
          BoxShadow(
            color: colors.greenmillime.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          hasValue ? text[position] : '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
  late CountdownTimerController timerController;

  @override
  Widget build(BuildContext context) {
    final colors = context.watchAppColors;
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        String source = (loginStore.bParsms ? 'TEL' : '') +
            ((loginStore.bParsms && loginStore.bParmail) ? '/' : '') +
            (loginStore.bParmail ? 'MAIL' : '');

        return Scaffold(
            appBar: buildAppBar(context,(context){ Navigator.pop(context);}),
            
         
            backgroundColor: colors.backgroundColor,
            key: loginStore.otpScaffoldKey,
            
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                                CustomImageView(
                      imagePath: ImageConstant.imgMillimelogo,
                      height: 70.adaptSize,
                      width: 70.adaptSize),
SizedBox(height: 16.v),
                      Container(
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("key_otp".tr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ),
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                    (loginStore.bMotPasseOublie
                                            ? "msg_enter_code_by_phone".tr + ' '
                                            : "msg_enter_code_by_sms".tr + ' '+
                                                loginStore.currentPhone.toString()) +'--'
                                         + loginStore.oneTimePass.toString(),
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                                
                             
                            Visibility(
                              visible: inkwellvisible,
                              child: Center(
                                  child: InkWell(
                                onTap: () {
                                  setState(() {
                                    //ctrTimerControler.restart();
                                    text = '';
                                    dDisableInput = false;
                                    inkwellvisible = false;
                                  });
                                  loginStore.sendOtp(loginStore.currentPhone);
                                },
                              
                                child: Column(
                                  
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                      SizedBox(height: 8.v),
                                    Text("msg_time_expired".tr,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      )),
                                    SizedBox(height: 4.v),
                                    Text("msg_req_new_code".tr,
                                      style: TextStyle(
                                        color: colors.linkColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      )),

                                    //    const Text('Le temps a expiré !\n '),  msg_time_expired
                                    //  'Cliquer pour envoyer un autre code\n '  msg_req_new_code
                                  ],
                                ),
                              )),
                            ),
                            Visibility(
                              visible: !inkwellvisible,
                              child: NeonCircularTimer(
                                onComplete: () {
                                  setState(() {
                                    dDisableInput = true;
                                    inkwellvisible = true;
                                    text = '';
                                  });
                                },
                                width: 60,
                                duration: 30,
                                controller: ctrTimerControler,
                                isTimerTextShown: true,
                                neumorphicEffect: false,
                                textStyle: TextStyle(fontSize: 12.0,fontWeight: FontWeight.w500, color: colors.textPrimary),
                                innerFillGradient: LinearGradient(colors: [colors.greenmillime, Colors.blueAccent.shade400]),
                                neonGradient: LinearGradient(colors: [colors.greenmillime, Colors.blueAccent.shade400]),
                              ),
                            ),
                               SizedBox(height: 24.v),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  otpNumberWidget(0),
                                  otpNumberWidget(1),
                                  otpNumberWidget(2),
                                  otpNumberWidget(3),
                                  otpNumberWidget(4),
                                  otpNumberWidget(5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 40, right: 20, left: 20),
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.greenmillime,
                            foregroundColor: colors.white,
                            elevation: 2,
                            shadowColor: colors.shadowColor,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                          onPressed: () async {
                            setState(() {
                              _inProcess = true;
                            });
                            bool res = await loginStore.validateOtpAndLogin(context, text);
                            setState(() {
                              _inProcess = false;
                            });

                            if (loginStore.bMotPasseOublie && res) {
                              loginStore.bMotPasseOublie = false;
                              setState(() {
                                _passChanged = true;
                              });
                              ctrTimerControler.pause();

                               source = (loginStore.bParsms ? 'TEL' : '') +
                                  ((loginStore.bParsms && loginStore.bParmail) ? '/' : '') +
                                  (loginStore.bParmail ? 'MAIL' : '');

                              //  final res = email.split("@");
                              //   final user = res[0];
                              //   final res1 = res[1].split(".");
                              //   final domaine = res1[0];
                              //   final suffixe = res1[1];

                              String destTelSecours =
                                  (loginStore.walletMotPasseOublie?.walletGesNoTelSecours ?? '').replaceRange(2, 6, '****');

                              final res = (loginStore.walletMotPasseOublie?.walletEmailSecours ?? '').split('@');
                              final user = res[0];
                              final domaine = res[1];
                              String destMailSecours = user.replaceRange(3, null, '*' * (user.length - 3)) + '@' + domaine;

                              String destination = (loginStore.bParsms ? destTelSecours : '') +
                                  ((loginStore.bParsms && loginStore.bParmail) ? ' / ' : '') +
                                  (loginStore.bParmail ? destMailSecours : '');

                           
                              setState(() {
                                msg = 'key_message_mdp1'.tr + source + 'key_message_mdp2'.tr + destination;
                              });
                              await buildSuccessMessage(context, "lbl_f_licitations".tr,
                  msg, "key_fermer".tr, true);


                            //  await Future.delayed(const Duration(seconds: 10));
                              Navigator.of(context).pushAndRemoveUntil(
                                  //MaterialPageRoute(builder: (_) => const ConfirmPassPage()),
                                  MaterialPageRoute(builder: (_) => Authent()),
                                  (Route<dynamic> route) => false);
                            }
                          },
                          // color: Color.fromARGB(255, 68, 175, 104),
                          // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                          child: Row(
                            textDirection: rtl? TextDirection.rtl : TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "verif_code".tr,
                                style: TextStyle(
                                  color: colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.h),
                              Transform.scale(
                                scaleX: (rtl) ? -1 : 1,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: colors.white,
                                  size: 18,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      NumericKeyboard(
                        onKeyboardTap: _onKeyboardTap,
                        textColor: colors.textPrimary,
                        rightIcon: Icon(
                          Icons.backspace,
                          color: colors.iconPrimary,
                        ),
                        rightButtonFn: () {
                          setState(() {
                            if (!dDisableInput && text.length > 0) text = text.substring(0, text.length - 1);
                          });
                        },
                      )
                    ],
                  ),
                  (_inProcess)
                      ? Container(
                          color: colors.backgroundColor.withOpacity(0.8),
                          height: MediaQuery.of(context).size.height * 0.95,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(colors.greenmillime),
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Center(),
               
               
                ],
              ),
            ),
          );
      },
    );
  }

  @override
  void dispose() {
    _inProcess = false;

    super.dispose();
  }



  bool _inProcess = false;
  void onEnd() {
    setState(() {
      dDisableInput = true;
    });
  }
}
