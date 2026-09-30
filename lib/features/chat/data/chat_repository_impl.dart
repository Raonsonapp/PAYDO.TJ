import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../models/chat_model.dart';
import '../domain/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection(FirestorePaths.chats);

  DocumentReference<Map<String, dynamic>> _chat(String id) => _chats.doc(id);

  CollectionReference<Map<String, dynamic>> _messages(String id) =>
      _chat(id).collection(FirestorePaths.messages);

  String _chatId(String a, String b) =>
      ([a, b]..sort()).join('_');

  @override
  Stream<List<ChatModel>> watchMyChats(String uid) => _chats
      .where('participantIds', arrayContains: uid)
      .orderBy('lastMessageAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList());

  @override
  Stream<ChatModel?> watchChat(String chatId) =>
      _chat(chatId).snapshots().map((d) => d.exists && d.data() != null
          ? ChatModel.fromMap(d.id, d.data()!)
          : null);

  @override
  Future<String> getOrCreateChat({
    required String myUid,
    required String myName,
    String? myPhoto,
    required String otherUid,
    required String otherName,
    String? otherPhoto,
    String? contextType,
    String? contextId,
    String? contextTitle,
  }) async {
    final id = _chatId(myUid, otherUid);
    final ref = _chat(id);
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({
        'participantIds': [myUid, otherUid],
        'participantNames': {myUid: myName, otherUid: otherName},
        'participantPhotos': {myUid: myPhoto, otherUid: otherPhoto},
        'lastMessageText': null,
        'lastMessageSenderId': null,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCounts': {myUid: 0, otherUid: 0},
        'contextType': contextType,
        'contextId': contextId,
        'contextTitle': contextTitle,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if (contextType != null || contextId != null || contextTitle != null) {
      await ref.set({
        'contextType': contextType,
        'contextId': contextId,
        'contextTitle': contextTitle,
      }, SetOptions(merge: true));
    }
    return id;
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) => _messages(chatId)
      .orderBy('timestamp', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map((d) => MessageModel.fromMap(d.id, d.data())).toList());

  @override
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _messages(chatId).add({
      'senderId': senderId,
      'type': MessageType.text.value,
      'text': clean,
      'imageUrl': null,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    await _updateLastMessage(chatId, senderId, clean);
  }

  @override
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required File imageFile,
  }) async {
    final name = '${DateTime.now().microsecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
    final ref = _storage.ref('chat_images/$chatId/$name');
    final upload = await ref.putFile(imageFile);
    final url = await upload.ref.getDownloadURL();
    await _messages(chatId).add({
      'senderId': senderId,
      'type': MessageType.image.value,
      'text': null,
      'imageUrl': url,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    await _updateLastMessage(chatId, senderId, '📷 Акс');
  }

  Future<void> _updateLastMessage(String chatId, String senderId, String text) async {
    final ref = _chat(chatId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};
      final ids = List<String>.from(data['participantIds'] as List? ?? const []);
      final unread = Map<String, dynamic>.from(data['unreadCounts'] as Map? ?? {});
      for (final id in ids) {
        unread[id] = id == senderId ? 0 : ((unread[id] as num?)?.toInt() ?? 0) + 1;
      }
      tx.set(ref, {
        'lastMessageText': text,
        'lastMessageSenderId': senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCounts': unread,
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> markAsRead({required String chatId, required String uid}) async {
    final chatRef = _chat(chatId);
    final messages = await _messages(chatId)
        .where('senderId', isNotEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    batch.set(chatRef, {
      'unreadCounts': {uid: 0},
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
