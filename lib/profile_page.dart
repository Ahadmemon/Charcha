import 'dart:io';

import 'package:charcha/ModelUsed/user_model.dart';
import 'package:charcha/home_page.dart';
import 'package:charcha/round_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

import 'ModelUsed/firebasehelper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  final UserModel? userModel;
  final User? user;

  const ProfilePage({super.key, this.userModel, this.user});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel? userModel; // Allow userModel to be nullable
  File? imageFile;
  final ImagePicker pickImage = ImagePicker();
  final TextEditingController fullNameController = TextEditingController();
  final FirebaseStorage fb = FirebaseStorage.instance;
  bool loading = false;

  @override
  void initState() {
    userModel = widget.userModel;
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userModel =
                UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
            fullNameController.text = userModel?.name ?? '';
          });
        }
      } else {
        debugPrint("No user is logged in");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> imagePicker(ImageSource source) async {
    try {
      final image = await pickImage.pickImage(source: source);
      if (image != null) {
        setState(() {
          imageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> uploadData() async {
    if (userModel == null ||
        userModel!.uid == null ||
        userModel!.uid!.isEmpty) {
      debugPrint("User model is not initialized or UID is missing");
      return;
    }

    if (fullNameController.text.isEmpty && imageFile == null) {
      debugPrint("No data to update");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      String? imageURL;

      if (imageFile != null) {
        // Ensure the imageFile is not null
        UploadTask uploadTask =
            fb.ref("profilePic").child(userModel!.uid!).putFile(imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        imageURL = await snapshot.ref.getDownloadURL();
      }

      // Check if fullNameController.text is not empty
      String fullName = fullNameController.text.toString();
      if (fullName.isNotEmpty) {
        userModel!.name = fullName;
      }
      if (imageURL != null) {
        userModel!.profilePic = imageURL;
      }

      // Ensure userModel's UID is not null
      if (userModel!.uid != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userModel!.uid!)
            .set(userModel!.toJson())
            .then((value) async {
          setState(() {
            loading = false;
          });

          UserModel? updatedUserModel =
              await FirebaseHelper.getUserModelById(widget.user!.uid!);
          if (updatedUserModel != null) {
            debugPrint(
                'Navigating back to HomePage with userModel uid: ${updatedUserModel.uid}');
            Navigator.pushReplacement(
              context,
              PageTransition(
                child: HomePage(
                  user: widget.user,
                  userModel: updatedUserModel,
                ),
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 600),
              ),
            );
          } else {
            debugPrint('Error: Updated UserModel is null');
          }
        });
      } else {
        debugPrint("Error: User UID is null");
      }

      debugPrint("Profile updated");
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("Error uploading data: $e");
    }
  }

  Future showUploadOptions() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Upload Options"),
          content: SizedBox(
            height: 120,
            width: 800,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Select from gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    imagePicker(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Click image"),
                  onTap: () {
                    Navigator.pop(context);
                    imagePicker(ImageSource.camera);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userModel == null) {
      return const CircularProgressIndicator(); // or any placeholder
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]
            // image: DecorationImage(
            //   image: AssetImage("assets/images/charchaBgImage13.jpg"),
            //   colorFilter: ColorFilter.mode(Colors.black, BlendMode.softLight),
            //   fit: BoxFit.cover,
            // ),
            ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 70),
              GestureDetector(
                onTap: showUploadOptions,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[400],
                  backgroundImage: imageFile != null
                      ? FileImage(
                          imageFile!) // Show selected image from file picker
                      : ((userModel?.profilePic != null &&
                              userModel!.profilePic!.isNotEmpty)
                          ? NetworkImage(
                              userModel!.profilePic!) // Show image from URL
                          : null), // No image, so use the default child,
                  child: imageFile == null &&
                          (userModel?.profilePic == null ||
                              userModel!.profilePic!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey[700],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: fullNameController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              const SizedBox(height: 60),
              RoundedBtn(
                onPressed: uploadData,
                child: loading
                    ? const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      )
                    : const Text('Upload Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
