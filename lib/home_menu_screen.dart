import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'message_boards_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({Key? key}) : super(key: key);

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  int _selectedIndex = 0; 
  late User _currentUser;

  final List<String> _titles = ['Message Boards', 'Profile', 'Settings'];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in!');
    }
    _currentUser = user;
  }

  @override
  Widget build(BuildContext context) {
    Widget _getPage(int index) {
      switch (index) {
        case 0:
          return const MessageBoardsScreen();
        case 1:
          return EditProfileScreen(user: _currentUser);
        case 2:
          return SettingsScreen(user: _currentUser);
        default:
          return const MessageBoardsScreen();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser.displayName ?? 'User'),
              accountEmail: Text(_currentUser.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _currentUser.displayName != null && _currentUser.displayName!.isNotEmpty
                      ? _currentUser.displayName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 32, color: Colors.black),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Message Boards'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context); // close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: _getPage(_selectedIndex),
    );
  }
}
