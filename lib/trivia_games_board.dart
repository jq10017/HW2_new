import 'package:flutter/material.dart';
import 'message_board.dart';

class TriviaGamesBoard extends StatelessWidget {
  const TriviaGamesBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageBoard(
      boardName: "trivia_games",
      title: "Trivia Games",
    );
  }
}
