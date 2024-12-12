import 'package:flutter/material.dart';

class RoundedBtn extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child; // Child widget passed from the constructor

  const RoundedBtn({required this.onPressed, required this.child, super.key});

  @override
  State<RoundedBtn> createState() => _RoundedBtnState();
}

class _RoundedBtnState extends State<RoundedBtn> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Colors.black,
        ),
        fixedSize: const Size(300, 55),
        foregroundColor: Colors.black,
      ),
      child: widget.child, // Use the child passed from the widget
    );
  }
}
