import 'package:charcha/round_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'firebase_options.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ForgotPassword(),
  ));
}

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      _auth
          .sendPasswordResetEmail(email: _emailController.text.toString())
          .then((value) {
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
          context,
          PageTransition(
              child: const LoginPage(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 600)),
        );
        return debugPrint("Email is sent to you");
      }).onError((e, stackTrace) {
        setState(() {
          loading = false;
        });
        debugPrint(e.toString());
      });
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
                  padding: EdgeInsets.only(top: 60.0, left: 22.0),
                  child: Text(
                    'Create new password with mail',
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              TextFormField(
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
                              const SizedBox(height: 70),
                              RoundedBtn(
                                onPressed: () {
                                  _validateAndSubmit();
                                },
                                child: loading
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.black,
                                      )
                                    : const Text(
                                        'SEND MAIL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black,
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
            ],
          ),
        ),
      ),
    );
  }
}
