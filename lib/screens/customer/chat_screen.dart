import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easydrive/models/chat_model.dart';
import 'package:easydrive/models/message_model.dart' as message_lib; // Add alias

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if user already has a chat
    final chatQuery = await _firestore
        .collection('chats')
        .where('userId', isEqualTo: user.uid)
        .where('isResolved', isEqualTo: false)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      setState(() {
        _chatId = chatQuery.docs.first.id;
      });
    } else {
      // Create new chat
      final newChat = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: user.displayName ?? user.email!.split('@')[0],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(newChat.id)
          .set(newChat.toMap());

      setState(() {
        _chatId = newChat.id;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _chatId == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final message = message_lib.MessageModel( // Use the alias
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _chatId!,
      senderId: user.uid,
      text: _messageController.text,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    // Update chat timestamp
    await _firestore.collection('chats').doc(_chatId).update({
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return message_lib.MessageModel.fromMap( // Use the alias
                      doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _auth.currentUser!.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}