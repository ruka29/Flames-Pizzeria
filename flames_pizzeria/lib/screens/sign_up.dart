import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/firestore_users.dart';
import '../services/toggle_screens.dart';

class SignUp extends StatefulWidget {
  final VoidCallback showSignInPage;
  const SignUp({super.key, required this.showSignInPage});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final _fireStoreService = FireStoreService();

  final  _firstNameController = TextEditingController();
  final  _lastNameController = TextEditingController();
  final  _emailController = TextEditingController();
  final  _passwordController = TextEditingController();
  final  _confirmPasswordController = TextEditingController();
  final String _displayText = "";
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  String _hashPassword(String password) {
    // Create a SHA-256 hasher
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void clearFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if the email already exists in the database
        final existingUser = await FirebaseFirestore.instance.collection(
            'users').doc(_emailController.text).get();
        if (existingUser.exists) {
          // Email is already registered, show error message to the user
          showDialog(
            context: context,
            builder: (context) =>
              AlertDialog(
                backgroundColor: const Color.fromRGBO(217, 188, 169, 1.0),
                title: const Text('Error'),
                content: const Text(
                    'Email is already registered. Please use a different email.'),
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
          return;
        }

        final hashedPassword = _hashPassword(_passwordController.text);

        _fireStoreService.addUser(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          hashedPassword,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Registration Successful!'),
          ),
        );

        clearFields();
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) {
                  return ToggleScreens();
                }
            )
        );
      } catch (e) {
        // Handle registration errors
        print('Error registering user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(217, 188, 169, 1.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 15.0, right: 15.0, top: 30.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        child: Text(
                          "Glad to have you onboard!",
                          style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      // first name
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: "First Name",
                            labelStyle: TextStyle(
                                color: Colors.black
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your first name";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // last name
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                            labelStyle: TextStyle(
                                color: Colors.black
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your last name";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      //email
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                                color: Colors.black
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                )
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black
                                )
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a email";
                            }
                            if (!RegExp(
                                r'^[\w-]+(\.w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                .hasMatch(value)) {
                              return "Please enter a valid email address.";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      //password
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                        child: TextFormField(
                          obscureText: _hidePassword,
                          controller: _passwordController,
                          decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: const TextStyle(
                                  color: Colors.black
                              ),
                              enabledBorder: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black
                                  )
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _hidePassword ? Icons.visibility_off : Icons
                                        .visibility),
                                onPressed: () =>
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    }),
                              )
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password";
                            }
                            if (value.length < 8) {
                              return "Minimum password length is 8 characters";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      //confirm password
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                        child: TextFormField(
                          obscureText: _hideConfirmPassword,
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                              labelText: "Confirm Password",
                              labelStyle: const TextStyle(
                                  color: Colors.black
                              ),
                              enabledBorder: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black
                                  )
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_hideConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() {
                                      _hideConfirmPassword =
                                      !_hideConfirmPassword;
                                    }),
                              )
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the password again";
                            }
                            if (_passwordController.text != value) {
                              return "Please check your password again";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      //signup button
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
                          onPressed: _registerUser,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5.0,),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: RichText(
                          text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(color: Colors.black),
                                ),

                                TextSpan(
                                  text: "Sign In",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = widget.showSignInPage,
                                )
                              ]
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
      ),
    );
  }
}
