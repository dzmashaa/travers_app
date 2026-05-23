import 'package:flutter/material.dart';
import 'package:travers_app/features/competitions/screens/competitions.dart';
import 'package:travers_app/features/judging/screens/judging.dart';
import 'package:travers_app/features/profile/screens/profile.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    CompetitionsScreen(),
    JudgingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,

        elevation: 8,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events_outlined),
            label: 'Змагання',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.balance_outlined),
            activeIcon: Icon(Icons.balance),
            label: 'Суддівство',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_outline),
            label: 'Профіль',
          ),
        ],
      ),
    );
  }
}
