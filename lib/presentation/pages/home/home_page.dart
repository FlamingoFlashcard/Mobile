import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/utils/card_list.dart';
import 'package:lacquer/presentation/utils/home_item_list.dart';
import 'package:lacquer/presentation/widgets/flashcard_category.dart';
import 'package:lacquer/presentation/widgets/home_item.dart';
import 'package:lacquer/presentation/widgets/todayprogress_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [_buildAppBar(), TodayprogressCard()],
            ),
            const SizedBox(height: 150),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Recently learn',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            FlashcardCategory(title: "Cuisine", cards: cuisine),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: _buildGridView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        height: 150,
        color: CustomTheme.mainColor2,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.jpg'),
                radius: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Welcome, Vu Phan !',
              style: GoogleFonts.montserratAlternates(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(FontAwesomeIcons.bell, color: Colors.black),
              onPressed: () {},
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: homeItems.length,
      itemBuilder: (context, index) {
        return HomeItem(
          imagePath: homeItems[index].imagePath,
          title: homeItems[index].title,
          backgroundColor: homeItems[index].backgroundColor,
          onTap: () {
            final route = homeItems[index].route;
            if (route != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(route);
              });
            }
          },
        );
      },
    );
  }
}
