import 'package:charcha/login_page.dart';
import 'package:charcha/registration_page.dart';
import 'package:charcha/splash_screen_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

var uuid = const Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      // Set the default font family
      fontFamily: 'Dosis',
      // Optionally, customize the text theme
      primaryTextTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Dosis', color: Colors.white),
        bodyMedium: TextStyle(fontFamily: 'Dosis', color: Colors.white),
        titleLarge: TextStyle(fontFamily: 'Dosis', color: Colors.white),
        // You can customize other text styles as needed
      ),
    ),
    home: const SplashScreen(),
  ));
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/charchaBgImg.jpeg"),
            // colorFilter: ColorFilter.mode(Colors.black, BlendMode.softLight),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: SizedBox(
                  height: screenHeight * 0.5,
                  width: screenWidth * 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    // child: Image.asset("assets/gifs/charchaGif2O.gif",
                    //         fit: BoxFit.cover)
                    //     .animate(),
                    child: Image.asset("assets/images/charchaGif2.gif",
                            fit: BoxFit.cover)
                        .animate(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome !',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 600),
                      child: const RegistrationPage(),
                    ),
                  );
                },
                child: Container(
                  height: 53,
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Center(
                    child: Text(
                      'Register Yourself',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 600),
                      child: const LoginPage(),
                      // childCurrent: this.widget
                    ),
                  );
                },
                child: Container(
                  height: 53,
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
