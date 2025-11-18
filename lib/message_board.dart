import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  final ScrollController _scrollController = ScrollController();

  // Cache user info: uid -> {avatar, name}
  final Map<String, Map<String, String>> _userCache = {};

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<Map<String, String>> _getUserData(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid]!;

    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final avatar = data['avatar'] ?? '🙂';
      final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
      _userCache[uid] = {'avatar': avatar, 'name': name};
      return _userCache[uid]!;
    }
    return {'avatar': '🙂', 'name': 'Unknown'};
  }

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('MM/dd HH:mm').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final boardRef = FirebaseFirestore.instance
        .collection("messageBoards")
        .doc(widget.boardName)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: boardRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                // Scroll to bottom after build
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final msg = docs[i];
                    final data = msg.data() as Map<String, dynamic>;
                    final isMe = data['uid'] == currentUser?.uid;
                    final uid = data['uid'];

                    return FutureBuilder<Map<String, String>>(
                      future: _getUserData(uid),
                      builder: (context, userSnapshot) {
                        String avatar = '🙂';
                        String name = 'Unknown';
                        if (userSnapshot.hasData) {
                          avatar = userSnapshot.data!['avatar']!;
                          name = userSnapshot.data!['name']!;
                        }

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar for others
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      avatar,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isMe ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            formatTimestamp(data['timestamp']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isMe ? Colors.white70 : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['text'] ?? '',
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Avatar for current user
                                if (isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      avatar,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Input Field + Send Button
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

                    final user = FirebaseAuth.instance.currentUser!;
                    final userDoc = await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.uid)
                        .get();

                    final username = "${userDoc['firstName']} ${userDoc['lastName']}";
                    final avatar = userDoc['avatar'] ?? '🙂';

                    await FirebaseFirestore.instance
                        .collection("messageBoards")
                        .doc(widget.boardName)
                        .collection("messages")
                        .add({
                      "uid": user.uid,
                      "username": username,
                      "avatar": avatar,
                      "text": text,
                      "timestamp": FieldValue.serverTimestamp(),
                    });

                    _controller.clear();
                    _scrollToBottom();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
