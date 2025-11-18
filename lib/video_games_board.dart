import 'package:flutter/material.dart';
import 'message_board.dart';

class VideoGamesBoard extends StatelessWidget {
  const VideoGamesBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageBoard(
      boardName: "video_games",
      title: "Video Games",
    );
  }
}
