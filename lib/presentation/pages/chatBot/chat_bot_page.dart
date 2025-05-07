import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat bot Screen')),
      backgroundColor: CustomTheme.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Discover culture, cuisine and more with',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30, 
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.lora().fontFamily,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mr. Calligraphy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35, 
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.moonDance().fontFamily,
                  ),
                ),
                const SizedBox(width: 5),
                Image(
                  image: AssetImage('assets/images/inkwell.png'),
                  width: 35,
                  height: 35,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SearchBar(
              hintText: 'Ask anything',
              onChanged: (value) {
                // Handle search input
              },
            )
          ],
        ),
      ),
    );
  }

  
}
