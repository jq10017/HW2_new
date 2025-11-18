import 'package:flutter/material.dart';
import 'message_board.dart';

class CardGamesBoard extends StatelessWidget {
  const CardGamesBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageBoard(
      boardName: "card_games",
      title: "Card Games",
    );
  }
}
