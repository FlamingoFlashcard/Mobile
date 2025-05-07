import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class AboutScreen extends StatelessWidget {
  final String imagePath;

  const AboutScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Large Label',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Placeholder description text goes here. This is where you can add more details about the image or the subject.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for learn more button
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
