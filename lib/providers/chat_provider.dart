import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easydrive/models/chat_model.dart';
import 'package:easydrive/models/message_model.dart' as message_lib;

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChatModel> _chats = [];
  List<message_lib.MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatModel> get chats => _chats;
  List<message_lib.MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _firestore
          .collection('chats')
          .where('userId', isEqualTo: user.uid)
          .where('isResolved', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        _chats = snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data()))
            .toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadChatMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        _messages = snapshot.docs
            .map((doc) => message_lib.MessageModel.fromMap(doc.data()))
            .toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final message = message_lib.MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: user.uid,
        text: text,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      await _firestore.collection('chats').doc(chatId).update({
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}