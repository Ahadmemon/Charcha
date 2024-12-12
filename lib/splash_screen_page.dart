import 'dart:async';

import 'package:charcha/ModelUsed/user_model.dart';
import 'package:charcha/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'ModelUsed/firebasehelper.dart';
import 'firebase_options.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Create a bounce effect with CurvedAnimation
    _bounceAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastEaseInToSlowEaseOut,
    );

    // Start the animation
    _animationController.forward();

    // Timer to navigate after 1 second
    Timer(const Duration(seconds: 1), () async {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          UserModel? thisUserModel =
              await FirebaseHelper.getUserModelById(currentUser.uid);

          if (thisUserModel != null) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                duration: const Duration(milliseconds: 500),
                child: HomePage(
                  user: currentUser,
                  userModel: thisUserModel,
                ),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 600),
              child: const WelcomePage(),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error navigating from splash screen: $e');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/charchaSplashScreen.png"),
                    fit: BoxFit.contain,
                  ),
                  color: Color(0xff7c7c74),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
