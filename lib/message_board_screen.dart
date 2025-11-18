import 'package:flutter/material.dart';

class MessageBoardsScreen extends StatelessWidget {
  const MessageBoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boards = [
  {
    "title": "Card Games",
    "image": "assets/card_games.png",
    "route": "/cardgames"
  },
  {
    "title": "Video Games",
    "image": "assets/video_games.png",
    "route": "/videogames"
  },
  {
    "title": "Board Games",
    "image": "assets/board_games.png",
    "route": "/boardgames"
  },
  {
    "title": "Trivia Games",
    "image": "assets/trivia_games.png",
    "route": "/triviagames"
  },
];

    return Scaffold(
      appBar: AppBar(title: const Text("Message Boards")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boards.length,
        itemBuilder: (context, i) {
          final b = boards[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, b["route"]!),
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
