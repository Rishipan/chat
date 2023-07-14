import 'package:flutter/material.dart';

class EmailBubble extends StatelessWidget {
  final String email;
  const EmailBubble({super.key, required this.email,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      child: Text(
        email,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}