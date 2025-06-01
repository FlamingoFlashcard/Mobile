import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/utils/home_item_list.dart';
import 'package:lacquer/presentation/pages/home/widgets/home_item.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onGoToProfile;
  const HomePage({super.key, this.onGoToProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CustomTheme.loginGradientStart,
            CustomTheme.loginGradientEnd,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildWelcomeSection(context),
                  const SizedBox(height: 24),
                  _buildRecentlyLearnSection(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      backgroundColor: CustomTheme.mainColor2,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CustomTheme.mainColor2,
                CustomTheme.mainColor2.withAlpha((0.9 * 255).toInt()),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoo.png',
                  width: 360,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Learn • Practice • Master',
                  style: GoogleFonts.poppins(
                    color: const Color.fromRGBO(255, 255, 255, 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue your learning journey',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF718096),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (onGoToProfile != null) {
                  onGoToProfile!();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.mainColor2.withAlpha((0.2 * 255).toInt()),
                      CustomTheme.mainColor2.withAlpha((0.1 * 255).toInt()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CustomTheme.mainColor2.withAlpha(
                      (0.1 * 255).toInt(),
                    ),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomTheme.mainColor2.withAlpha(
                          (0.2 * 255).toInt(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.penToSquare,
                        color: CustomTheme.mainColor2,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set up your profile',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tell us more about you!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: CustomTheme.mainColor2,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyLearnSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildGridView(),
        ),
      ],
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
