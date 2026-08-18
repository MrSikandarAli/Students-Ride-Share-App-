import 'package:cloud_firestore/cloud_firestore.dart';

/// A minimal chat message shape used by [ChatService] and the chat screen.
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Handles ride-scoped chat threads: `chats/{chatId}/messages/{messageId}`.
/// A `chatId` is deterministic per ride+passenger pair so drivers and
/// passengers always land in the same thread.
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String chatIdFor(String rideId, String passengerId) => '${rideId}_$passengerId';

  Stream<List<ChatMessage>> messages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.collection('messages').add({
      'senderId': senderId,
      'text': text.trim(),
      'sentAt': FieldValue.serverTimestamp(),
    });
    await chatRef.set({
      'lastMessage': text.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
