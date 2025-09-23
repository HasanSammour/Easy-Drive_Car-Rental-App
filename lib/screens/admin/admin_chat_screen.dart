import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easydrive/models/chat_model.dart';
import 'package:easydrive/models/message_model.dart' as message_lib;

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedChatId;
  ChatModel? _selectedChat;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Support')),
      body: Column(
        children: [
          // Customer selection dropdown
          _buildCustomerSelectionBar(),
          // Main content
          Expanded(
            child: _selectedChatId != null
                ? _buildChatInterface()
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Text(
            'Select Customer:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('isResolved', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Tooltip(
                    message: 'Error loading chats',
                    child: Icon(Icons.error, color: Colors.red),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final chats = snapshot.data!.docs.map((doc) {
                  return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                // Sort by last activity (use updatedAt or createdAt)
                chats.sort((a, b) {
                  final aTime = a.updatedAt ?? a.createdAt;
                  final bTime = b.updatedAt ?? b.createdAt;
                  return bTime.compareTo(aTime);
                });

                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: chats.any((chat) => chat.id == _selectedChatId)
                        ? _selectedChatId
                        : null, // <--- safe fallback
                    hint: const Text('Choose a customer...'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedChatId = newValue;
                        if (newValue != null) {
                          _selectedChat = chats.firstWhere(
                            (chat) => chat.id == newValue,
                          );
                        } else {
                          _selectedChat = null;
                        }
                      });
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Select a customer...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...chats.map<DropdownMenuItem<String>>((ChatModel chat) {
                        final lastUpdate = chat.updatedAt ?? chat.createdAt;
                        return DropdownMenuItem<String>(
                          value: chat.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Last activity: ${_getTimeAgo(lastUpdate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 64, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'Welcome to Customer Support',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Select a customer from the dropdown above to start chatting',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedChat?.userName ?? 'Customer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Chat started: ${_formatDate(_selectedChat?.createdAt ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {}),
                    tooltip: 'Refresh chat',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: _selectedChatId != null
                        ? () => _resolveChat(_selectedChatId!)
                        : null,
                    tooltip: 'Mark as resolved',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Messages area
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _selectedChatId != null
                ? _firestore
                      .collection('chats')
                      .doc(_selectedChatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots()
                : const Stream<QuerySnapshot>.empty(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No messages yet', style: TextStyle(fontSize: 16)),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final messages = snapshot.data!.docs.map((doc) {
                return message_lib.MessageModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: messages.map((message) {
                  final isMe = message.senderId == _auth.currentUser?.uid;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {}); // For send button enable/disable
              },
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: _messageController.text.trim().isEmpty
                ? Colors.grey
                : Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _messageController.text.trim().isEmpty
                  ? null
                  : () => _sendMessage(_selectedChatId!, _messageController),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(
    String chatId,
    TextEditingController controller,
  ) async {
    if (controller.text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final message = message_lib.MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: user.uid,
      text: controller.text.trim(),
      timestamp: DateTime.now(),
    );

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      await _firestore.collection('chats').doc(chatId).update({
        'adminId': user.uid,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      controller.clear();
      setState(() {}); // Update send button state
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _resolveChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isResolved': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chat marked as resolved')));

      // Reset selected chat before dropdown rebuild
      setState(() {
        _selectedChatId = null;
        _selectedChat = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to resolve chat: $e')));
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
