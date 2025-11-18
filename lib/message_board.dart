import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBoard extends StatefulWidget {
  final String boardName;    
  final String title;

  const MessageBoard({
    super.key,
    required this.boardName,
    required this.title,
  });

  @override
  State<MessageBoard> createState() => _MessageBoardState();
}

class _MessageBoardState extends State<MessageBoard> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final boardRef = FirebaseFirestore.instance
        .collection("messageBoards")
        .doc(widget.boardName)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: boardRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final msg = docs[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg["text"]),
                    );
                  },
                );
              },
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    await FirebaseFirestore.instance
                        .collection("messageBoards")
                        .doc(widget.boardName)
                        .collection("messages")
                        .add({
                      "text": text,
                      "timestamp": DateTime.now(),
                    });

                    _controller.clear();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
