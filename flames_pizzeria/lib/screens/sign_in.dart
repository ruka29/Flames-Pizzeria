import 'dart:convert';
// import 'package:barista_application_demo/services/firestore_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/styles_&_fn_handle.dart';
import 'main_page.dart';
// import 'main_page.dart';

class SignIn extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const SignIn({super.key, required this.showSignUpPage});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool hidePassword = true;
  String passwordIcon = 'Icons.remove_red_eye';

  void clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }

  String _hashPassword(String password) {
    // Create a SHA-256 hasher
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> validateUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
          title: const Text('Error'),
          content: const Text('Please enter your user credentials!'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final user = await FirebaseFirestore.instance.collection('users').doc(_emailController.text).get();

      final userDetails = user.data();

      final hashedPassword = _hashPassword(_passwordController.text);

      if (user.exists && userDetails?['password'] == hashedPassword) {
        Navigator.of(context).pushAndRemoveUntil(
          SlidePageRoute(page: const MainPage()),
              (Route<dynamic> route) => false,
        );
        globalUserId = userDetails?['email'];
        clearFields();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
            title: const Text('Error'),
            content: const Text('Invalid email or password!'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color.fromRGBO(217, 188, 169, 1.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 15.0, right: 15.0, top: 50.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0,),

                    Image.asset(
                      "images/logo.png",
                      height: 250.0,
                      width: 250.0,
                      fit: BoxFit.cover,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Welcome Back!",
                        style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 20.0,),

                    // username
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              )),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //password
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: TextFormField(
                        obscureText: hidePassword,
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.black),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                )),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(() {
                                hidePassword = !hidePassword;
                              }),
                            )
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //sign in button
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                          minimumSize: const Size.fromHeight(65),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        onPressed: () {
                          validateUser();
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ),

                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: "Sign Up",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.showSignUpPage,
                          )
                        ]
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(65),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            side: BorderSide(color: Color.fromRGBO(197, 110, 51, 1.0)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            SlidePageRoute(page: const MainPage()),
                                (Route<dynamic> route) => false,
                          );
                          globalUserId = "";
                        },
                        child: const Text(
                          "Continue as Guest",
                          style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(197, 110, 51, 1.0),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
