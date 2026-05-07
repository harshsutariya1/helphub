import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_center, size: 80, color: Colors.blue),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
