import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  static String id = 'splash_screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: 'images/logo.png',
        splashIconSize: double.infinity,
        nextScreen: LoginScreen(),
        backgroundColor: kAppBarBackgroundColor,
        // duration: 1000,
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.leftToRightWithFade,
        // animationDuration: Duration(seconds: 1),
    );
  }
}
