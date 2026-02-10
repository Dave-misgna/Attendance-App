import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  const MyBottomNavigation({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/employees');
        break;
      case 2:
        context.go('/admin');
        break;
        
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      ],
    );
  }
}
