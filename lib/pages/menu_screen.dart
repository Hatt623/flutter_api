// import 'dart:ffi';

import 'package:flutter/material.dart';
// import 'package:flutter_api/pages/home_screen.dart';
// import 'package:flutter_api/pages/posts/list_post_screen.dart';
import 'package:flutter_api/pages/event/list_event_screen.dart';
import 'package:flutter_api/pages/order&event/list_order_screen.dart';
import 'package:flutter_api/pages/profile_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;
  // late AnimationController = _animationController;
  // late Animation<double> = _scaleAnimation;

  final List<Widget> _pages = [
    // const HomeScreen(),
    // const ListPostScreen(),
    const ListEventScreen(),
    const ListOrderScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Biar background transparan jalan
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.black.withOpacity(0.8),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            items: const [
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.home_rounded),
              //   label: 'Home',
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.article_outlined),
              //   label: 'Posts',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.airplane_ticket),
                label: 'Order & Tickets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
