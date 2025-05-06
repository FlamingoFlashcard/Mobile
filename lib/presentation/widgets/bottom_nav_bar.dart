import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/chatbot');
        break;
      case 2:
        context.go('/camera');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color unselectedColor = Colors.black;
    final Color selectedColor = CustomTheme.primaryColor;

    return Container(
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
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onItemTapped(context, index),
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
