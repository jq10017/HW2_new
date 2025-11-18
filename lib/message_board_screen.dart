import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'message_board.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class MessageBoardsScreen extends StatelessWidget {
  const MessageBoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boards = [
      {"title": "Card Games", "image": "assets/card_games.png", "boardName": "cardGames"},
      {"title": "Video Games", "image": "assets/video_games.png", "boardName": "videoGames"},
      {"title": "Board Games", "image": "assets/board_games.png", "boardName": "boardGames"},
      {"title": "Trivia Games", "image": "assets/trivia_games.png", "boardName": "triviaGames"},
    ];

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Boards"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'home') {
                // Go to home (message boards)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MessageBoardsScreen()),
                  (route) => false,
                );
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen(user: user!)),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen(user: user!)),
                );
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'home', child: Text('Message Boards')),
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Sign Out')),
            ],
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boards.length,
        itemBuilder: (context, i) {
          final b = boards[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MessageBoard(
                    boardName: b["boardName"]!,
                    title: b["title"]!,
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      b["image"]!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      b["title"]!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
