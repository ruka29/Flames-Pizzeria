import 'package:flutter/material.dart';

import '../screens/sign_in.dart';
import '../screens/sign_up.dart';

class ToggleScreens extends StatefulWidget {
  const ToggleScreens({super.key});

  @override
  State<ToggleScreens> createState() => _ToggleScreensState();
}

class _ToggleScreensState extends State<ToggleScreens> {
  bool showSignInPage = true;

  void toggleScreen() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showSignInPage) {
      return SignIn(showSignUpPage: toggleScreen,);
    } else {
      return SignUp(showSignInPage: toggleScreen,);
    }
  }
}