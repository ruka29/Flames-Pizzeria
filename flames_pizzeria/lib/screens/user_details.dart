import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/firestore_users.dart';
import '../services/styles_&_fn_handle.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  bool textFieldsReadOnly = true;

  PlatformFile? pickedFile;
  final _fireStoreService = FireStoreService();

  Future<void> pickImage() async {
    if(kIsWeb) {
      getFile();
    } else {
      final storageStatus = await Permission.photos.request();
      if(storageStatus.isGranted) {
        getFile();
      }
    }
  }

  Future<void> getFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<String> uploadImage() async {
    if (pickedFile == null) {
      return "";
    }
    try {
      final file = File(pickedFile?.path as String);
      final fileName = pickedFile?.name;
      final imageRef = FirebaseStorage.instance.ref('images/$fileName');
      await imageRef.putFile(file);
      final downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print(e.message);
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "User Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(globalUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userDetails = snapshot.data!.data();
            final firstName = userDetails!['firstName'];
            final lastName = userDetails['lastName'];
            final email = userDetails['email'];
            final address = userDetails['address'];
            final mobileNumber = userDetails['mobileNumber'];
            final imageURL = userDetails['imageURL'];

            late final firstNameController = TextEditingController()..text = firstName;
            late final lastNameController = TextEditingController()..text = lastName;
            late final emailController = TextEditingController()..text = email;
            late final addressController = TextEditingController()..text = address;
            late final mobileNumberController = TextEditingController()..text = mobileNumber;

            Future<void> updateUser() async {
              final updatedImageURL = await uploadImage();

              _fireStoreService.updateUser(
                firstNameController.text,
                lastNameController.text,
                emailController.text,
                addressController.text,
                mobileNumberController.text,
                updatedImageURL.isNotEmpty ? updatedImageURL : imageURL
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('User Updated successfully!'),
                ),
              );

              Navigator.pop(context);
            }

            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Center(
                  child: Form(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //profile picture
                          CircleAvatar(
                            radius: 70.0,
                            backgroundImage: imageURL.isEmpty && pickedFile == null
                                ?
                            const ResizeImage(
                              AssetImage("images/profile.jpg"),
                              width: 350,
                              height: 350
                            )
                                : pickedFile != null ?
                            ResizeImage(
                                FileImage(File(pickedFile?.path as String)),
                                width: 350,
                                height: 350
                            )
                                :
                            ResizeImage(
                                NetworkImage(imageURL),
                                width: 350,
                                height: 350
                            ),
                          ),

                          IconButton(
                              onPressed: pickImage,
                              icon: const Icon(
                                Icons.add_a_photo_outlined
                              )
                          ),

                          const SizedBox(height: 10.0),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                textFieldsReadOnly = !textFieldsReadOnly;
                              });
                            },
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Color.fromRGBO(197, 110, 51, 1.0),
                              ),
                            )
                          ),

                          const SizedBox(height: 25.0),

                          // first name
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                            child: TextFormField(
                              controller: firstNameController,
                              readOnly: textFieldsReadOnly,
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
                            ),
                          ),

                          const SizedBox(height: 10),

                          // lastname
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                            child: TextFormField(
                              controller: lastNameController,
                              readOnly: textFieldsReadOnly,
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
                            ),
                          ),

                          const SizedBox(height: 10),

                          // email
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                            child: TextFormField(
                              controller: emailController,
                              readOnly: textFieldsReadOnly,
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
                                    ),
                                  ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // address
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                            child: TextFormField(
                              controller: addressController,
                              readOnly: textFieldsReadOnly,
                              decoration: const InputDecoration(
                                  labelText: "Address",
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
                            ),
                          ),

                          const SizedBox(height: 10),

                          // mobile number
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                            child: TextFormField(
                              controller: mobileNumberController,
                              readOnly: textFieldsReadOnly,
                              decoration: const InputDecoration(
                                  labelText: "Mobile Number",
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
                            ),
                          ),

                          const SizedBox(height: 10),

                          //save button
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
                              onPressed: updateUser,
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: Colors.black,));
        },
      ),
    );
  }
}
