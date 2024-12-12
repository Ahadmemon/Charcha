import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

import 'home_page.dart';

class Settings extends StatefulWidget {
  String? text;

  Settings({super.key, required this.text});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController nameController = TextEditingController();
  XFile? _image;
  final ImagePicker _pickImage = ImagePicker();

  Future imagePicker() async {
    final pickedImage = await _pickImage.pickImage(source: ImageSource.gallery);
    _image = pickedImage;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/charchaBgImage1.jpg"),
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(Colors.black, BlendMode.softLight)),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 60, left: 30),
                  child: Text(
                    "You can set your profile picture here..",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),
                InkWell(
                  onTap: imagePicker,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[700],
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(File(_image!.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? const Icon(
                            Icons.person,
                            size: 150,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: nameController,
                    cursorColor: Colors.white,
                    // textAlign: TextAlign.center,
                    // textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Enter you name',
                      labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "You can set it later",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      // backgroundColor: Colors.greenAccent,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fixedSize: const Size(300, 55)),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: const HomePage(),
                            type: PageTransitionType.fade,
                            duration: const Duration(milliseconds: 600)));
                  },
                  child: const Text(
                    "Click to continue",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
