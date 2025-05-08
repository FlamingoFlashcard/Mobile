import 'package:flutter/material.dart';
import 'package:lacquer/presentation/pages/camera/camera_page.dart';
import 'package:lacquer/presentation/pages/chatBot/chat_bot_page.dart';
import 'package:lacquer/presentation/pages/home/home_page.dart';
import 'package:lacquer/presentation/pages/profile/profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/config/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final Color unselectedColor = Colors.black;
  final Color selectedColor = CustomTheme.primaryColor;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomePage(),
          ChatBotPage(),
          CameraPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: selectedColor,
                    fontWeight: FontWeight.bold,
                  );
                }
                return TextStyle(
                  color: unselectedColor,
                  fontWeight: FontWeight.normal,
                );
              }),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: CustomTheme.lightbeige.withAlpha(
                (0.2 * 255).toInt(),
              ),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index),
              destinations: [
                _buildNavItem(
                  iconPath: 'assets/icons/house.svg',
                  selectedIcon: FontAwesomeIcons.house,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                  label: 'Home',
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.message,
                  selectedIcon: FontAwesomeIcons.solidMessage,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                  label: 'Chatbot',
                ),
                _buildNavItem(
                  iconPath: 'assets/icons/camera.svg',
                  selectedIcon: FontAwesomeIcons.camera,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                  label: 'Camera',
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.user,
                  selectedIcon: FontAwesomeIcons.solidUser,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavItem({
    String? iconPath,
    IconData? icon,
    required IconData selectedIcon,
    required Color unselectedColor,
    required Color selectedColor,
    required String label,
  }) {
    return NavigationDestination(
      icon:
          iconPath != null
              ? SvgPicture.asset(
                iconPath,
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              )
              : FaIcon(icon, color: unselectedColor),
      selectedIcon: FaIcon(selectedIcon, color: selectedColor),
      label: label,
    );
  }
}
