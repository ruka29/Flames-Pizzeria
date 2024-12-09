import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/firestore_items.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();

  final _itemNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _priceController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _mediumPriceController = TextEditingController();
  final _largePriceController = TextEditingController();

  String selectedCategory = "";
  PlatformFile? pickedFile;
  final _fireStoreService = ItemFireStoreService();

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

  void clearFields() {
    _itemNameController.clear();
    _ingredientsController.clear();
    _priceController.clear();
    _regularPriceController.clear();
    _mediumPriceController.clear();
    _largePriceController.clear();
  }

  Future<void> _addItem() async {
    if(_formKey.currentState!.validate()) {
      final imageURL = await uploadImage();

      if(imageURL.isNotEmpty) {
        _fireStoreService.addItems(
            imageURL,
            _itemNameController.text,
            _ingredientsController.text,
            selectedCategory,
            _priceController.text,
            _regularPriceController.text,
            _mediumPriceController.text,
            _largePriceController.text
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Item added successfully!'),
        ),
      );

      clearFields();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Add new item",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child:
                    pickedFile != null
                        ?
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.file(
                        File(pickedFile!.path as String),
                        width: screenWidth,
                        height: 350,
                        fit: BoxFit.cover,
                      ),
                    )
                        :
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 150.0),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: 50.0,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: DropdownMenu(
                    width: screenWidth - 20,
                    label: const Text(
                      "Select item category",
                      style: TextStyle(
                        color: Colors.black
                      ),
                    ),
                    onSelected: (category) {
                      if(category != null) {
                        setState(() {
                          selectedCategory = category;
                        });
                      }
                    },
                    dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: "pizza", label: "Pizza"),
                      DropdownMenuEntry(value: "burger", label: "Burger"),
                      DropdownMenuEntry(value: "submarine", label: "Submarine"),
                      DropdownMenuEntry(value: "quesadilla", label: "Quesadilla"),
                      DropdownMenuEntry(value: "combo", label: "Combo"),
                      DropdownMenuEntry(value: "beverages", label: "Beverages"),
                    ],
                  ),
                ),

                if(selectedCategory.isNotEmpty && selectedCategory != "pizza")
                  otherFormat(),

                if(selectedCategory == "pizza")
                  pizzaFormat(),

                //add items button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(197, 110, 51, 1.0),
                      minimumSize: const Size.fromHeight(65),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onPressed: _addItem,
                    child: const Text(
                      "Add Item",
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container pizzaFormat() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //item name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),

            //ingredients
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: "Ingredients",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Prices",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
                ),
              ),
            ),

            //regular price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _regularPriceController,
                decoration: const InputDecoration(
                  labelText: "Regular price",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),

            //medium price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _mediumPriceController,
                decoration: const InputDecoration(
                  labelText: "Medium price",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),

            //large price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _largePriceController,
                decoration: const InputDecoration(
                  labelText: "Large price",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container otherFormat() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //item name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),

            //ingredients or description
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: "Ingredients or Description",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),

            //price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill this field";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
