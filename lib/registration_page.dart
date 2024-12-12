// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:charcha/ModelUsed/user_model.dart';
import 'package:charcha/login_page.dart';
import 'package:charcha/profile_page.dart';
import 'package:charcha/round_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegistrationPage(),
  ));
}

class RegistrationPage extends StatefulWidget {
  final UserModel? userModel;
  final User? user;

  const RegistrationPage({super.key, this.userModel, this.user});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode fieldOne = FocusNode();
  FocusNode fieldTwo = FocusNode();

  bool _passwordVisibility = true;
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      _passwordVisibility = !_passwordVisibility;
    });
  }

  /*void register(String email, String password) async {
    setState(() {
      loading = true;
    });
    UserCredential? credentials;
    try {
      credentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint(e.code.toString());
    }
    if (credentials != null) {
      String uid = credentials.user!.uid;
      await _firestore.collection("users").doc(uid).set({
        "name": "",
        "email": email,
        "password": password,
        "profile_pic": ""
      }).then((value) {
        if (!mounted) return;
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 600),
              child: const ProfilePage(),
            ));
        return debugPrint("User added succesfully");
      });
    }
  }*/

  void register(String email, String password) async {
    setState(() {
      loading = true;
    });
    UserCredential? credentials;
    try {
      credentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(e.message ?? 'An error occurred'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        loading = false;
      });
      debugPrint(e.code.toString());
    }
    if (credentials != null) {
      String uid = credentials.user!.uid;
      UserModel newuser =
          UserModel(uid: uid, name: "", email: email, profilePic: "");
      await _firestore
          .collection("users")
          .doc(uid)
          .set(newuser.toJson())
          .then((value) {
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
            context,
            PageTransition(
                // child: const ProfilePage(),
                child: ProfilePage(
                  user: credentials!.user,
                  userModel: newuser,
                ),
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 600)));
        return debugPrint("User added succesfully");
      }); //collection refers to data folder means which data it stores, here it stores users login and registration info
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      register(
        _emailController.value.text.trim().toString(),
        _passwordController.value.text.trim().toString(),
      );
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          top: false,
          // bottom: false,
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/charchaBgImg.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 60.0, left: 22.0, bottom: 20),
                  child: Text(
                    'Register Yourself',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 200),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 550,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context)
                              .viewInsets
                              .bottom, // Adjusts padding to prevent overlap
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              /*TextFormField(
                                cursorColor: Colors.white,
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.person_2_outlined,
                                    color: Colors.white,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),*/
                              const SizedBox(height: 20),
                              TextFormField(
                                focusNode: fieldOne,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(fieldTwo);
                                },
                                cursorColor: Colors.white,
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.mail_outline_outlined,
                                    color: Colors.white,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailRegExp =
                                      RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegExp.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                focusNode: fieldTwo,
                                cursorColor: Colors.white,
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: _passwordVisibility,
                                decoration: InputDecoration(
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_passwordVisibility
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    color: Colors.white,
                                    onPressed: _togglePassword,
                                  ),
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 70),
                              RoundedBtn(
                                onPressed: () {
                                  _submitForm();
                                  FocusScope.of(context).unfocus();
                                },
                                child: loading
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.black,
                                      )
                                    : const Text('SIGN UP'),
                              ),
                              const SizedBox(
                                height: 100,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                            context,
                                            PageTransition(
                                                child: const LoginPage(),
                                                type: PageTransitionType.fade,
                                                duration: const Duration(
                                                    milliseconds: 600)));
                                      },
                                      child: const Text(
                                        "Sign in",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
