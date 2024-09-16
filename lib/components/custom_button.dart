import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  final Color color, textColor;

  const MyButton({
    Key? key,
    required this.text,
    required this.onPress,
    this.color = Colors.deepPurpleAccent,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      width: size.width * 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
          onPressed: onPress,
          child: Text(
            text,
            style: TextStyle( // Remove const here
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor, // Use dynamic textColor
            ),
          ),
        ),
      ),
    );
  }
}
