import 'package:charcha/ModelUsed/user_model.dart';
import 'package:charcha/forgot_password_page.dart';
import 'package:charcha/registration_page.dart';
import 'package:charcha/round_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  final UserModel? userModel;
  final User? user;

  const LoginPage({super.key, this.userModel, this.user});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // var usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  FocusNode fieldOne = FocusNode();
  FocusNode fieldTwo = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool passwordVisibility = true;
  bool loading = false;

  void togglePassword() {
    setState(() {
      passwordVisibility = !passwordVisibility;
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // void login(String email, String password) async {
  //   setState(() {
  //     loading = true;
  //   });
  //   UserCredential? credential;
  //   try {
  //     credential = await _auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //   } on FirebaseAuthException catch (e) {
  //     debugPrint(e.message.toString());
  //   }
  //   if (credential != null) {
  //     String uid = credential.user!.uid;
  //     DocumentSnapshot userData = await _db.collection("users").doc(uid).get();
  //     if (userData.exists && userData.data() != null) {
  //       //UserModel userdata =
  //          // UserModel.fromMap(userData.data() as Map<String, dynamic>);
  // (userData.data() as Map<String, dynamic>)
  //       setState(() {
  //         loading = false;
  //       });
  //       Navigator.pushReplacement(
  //         context,
  //         PageTransition(
  //             child: const HomePage(),
  //             type: PageTransitionType.fade,
  //             duration: const Duration(milliseconds: 600)),
  //       );
  //       debugPrint('Logged In');
  //     }
  //   }
  // }
  void login(String email, String password) async {
    setState(() {
      loading = true;
    });
    UserCredential? credentials;
    try {
      credentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
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
      debugPrint(e.message.toString());
      return;
    }
    if (credentials.user != null) {
      String uid = credentials.user!.uid;
      DocumentSnapshot docSnap =
          await firestore.collection("users").doc(uid).get();
      debugPrint("User ID: $uid");
      debugPrint("UserData: ${docSnap.data()}");
      if (docSnap.exists) {
        debugPrint("Document exists: ${docSnap.data()}");
      } else {
        debugPrint("Document does not exist for UID: $uid");
      }
      if (docSnap.data() != null) {
        UserModel userModel =
            UserModel.fromJson(docSnap.data() as Map<String, dynamic>);
        debugPrint("Mapped UserModel: $userModel");
        // (userData.data() as Map<String, dynamic>);
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
          context,
          PageTransition(
              child: HomePage(
                user: credentials.user,
                userModel: userModel,
              ),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 600)),
        );
        debugPrint('Logged In');
      } else {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('User Not Found'),
            content: const Text('No user data found for this account'),
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
      }
    }
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      login(emailController.text.trim().toString(),
          passwordController.text.trim().toString());
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
                    'Welcome to\nLogin Page',
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
                              const SizedBox(height: 25),
                              TextFormField(
                                focusNode: fieldOne,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(fieldTwo);
                                },
                                cursorColor: Colors.white,
                                controller: emailController,
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
                              const SizedBox(height: 30),
                              TextFormField(
                                focusNode: fieldTwo,
                                cursorColor: Colors.white,
                                controller: passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: passwordVisibility,
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
                                    icon: Icon(passwordVisibility
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    color: Colors.white,
                                    onPressed: togglePassword,
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
                                    return 'Please enter a password';
                                  } else if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: const ForgotPassword(),
                                          type: PageTransitionType.fade,
                                          duration: const Duration(
                                              milliseconds: 600)));
                                },
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 70),
                              RoundedBtn(
                                onPressed: () {
                                  _validateAndSubmit();
                                  FocusScope.of(context).unfocus();
                                },
                                child: loading
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.black,
                                      )
                                    : const Text('SIGN IN'),
                              ),
                              const SizedBox(height: 100),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account?",
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
                                                child: const RegistrationPage(),
                                                type: PageTransitionType.fade,
                                                duration: const Duration(
                                                    milliseconds: 600)));
                                      },
                                      child: const Text(
                                        "Sign up",
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
