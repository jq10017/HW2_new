import 'package:flutter/material.dart';
import 'message_board.dart';

class BoardGamesBoard extends StatelessWidget {
  const BoardGamesBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageBoard(
      boardName: "board_games",
      title: "Board Games",
    );
  }
}
