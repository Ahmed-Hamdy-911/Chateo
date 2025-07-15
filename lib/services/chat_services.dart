import 'dart:developer';
import 'package:chateo/controllers/UserController/user_controller.dart';
import 'package:chateo/models/user_model.dart';
import 'package:chateo/services/encryption_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserController _userController = UserController();
  final EncryptionServices _encryptionServices = EncryptionServices();

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      // load user model
      UserModel? userModel = await loadCurrentUserData();
      final String currentUserID = userModel!.id;
      final String currentUserName = userModel.name;
      final String currentUserEmail = userModel.email;
      final Timestamp timestamp = Timestamp.now();
      log("message before encrypt : $message");
      // Encrypt the message
      String encryptedMessage = _encryptionServices.encryptMessage(message);
      log("message after encrypt : $encryptedMessage");
      log("IV for the message : ${_encryptionServices.iv.base64}");
      // Create message model
      MessageModel newMessage = MessageModel(
        senderId: currentUserID,
        senderEmail: currentUserEmail,
        senderName: currentUserName,
        receiverId: receiverId,
        messageContent: encryptedMessage,
        publishAt: timestamp,
        iv: _encryptionServices.iv.base64,
      );

      // Generate chat room ID based on user IDs
      List<String> ids = [currentUserID, receiverId];
      ids.sort();
      String chatRoomId = ids.join('_');

      // Store the message in Firestore
      await storeMessages(chatRoomId, newMessage, currentUserID, receiverId);

      // log('Message sent successfully');
    } catch (e) {
      log('Error sending message: $e');
    }
  }

// load current user data
  Future<UserModel?> loadCurrentUserData() async {
    var userModel = _userController.userModel;
    userModel = await _userController.getUserData();
    return userModel;
  }

// Store messages in Firestore
  Future<void> storeMessages(String chatRoomId, MessageModel newMessage,
      String currentUserID, String receiverId) async {
    log("The message that was pushed to the firestore : ${newMessage.messageContent}");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());

    // Update the participants list in the chat room document
    await _firestore.collection("chat_room").doc(chatRoomId).set({
      'participants': [currentUserID, receiverId],
    }, SetOptions(merge: true));
  }

  // Load messages
  Stream<List<MessageModel>> loadMessages(String chatRoomId) {
    try {
      return _firestore
          .collection("chat_room")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy('publishAt', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              MessageModel message = MessageModel.fromJson(doc.data());
              return message;
            }).toList(),
          );
    } on FirebaseException catch (e) {
      log('Firebase Error getting messages: ${e.code}');
      return Stream.error(
        'Firebase Error getting messages: ${e.code}',
      );
    } catch (e) {
      log('Error getting messages: $e');
      return Stream.error(
        'Error getting messages: $e',
      );
    }
  }

  // Delete all messages in a chat room
  Future<void> deleteMessagesBetweenTwoUsers(String chatRoomId) async {
    try {
      var querySnapshot = await _firestore
          .collection("chat_room")
          .doc(chatRoomId)
          .collection("messages")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await Future.forEach(querySnapshot.docs, (doc) async {
          await doc.reference.delete();
        });
        log('Messages deleted successfully');
      } else {
        log('No messages found to delete');
      }
    } on FirebaseException catch (e) {
      log('Firebase Error deleting messages: ${e.code}');
    } catch (e) {
      log('Error deleting messages: $e');
    }
  }

// fetch last message of each chat room
  Stream<MessageModel?> fetchLastMessage(String chatRoomId) {
    return _firestore
        .collection("chat_room")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("publishAt", descending: true) // Get the most recent message
        .limit(1) // Only fetch the latest message
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return MessageModel.fromJson(snapshot.docs.first.data());
      } else {
        return null;
      }
    });
  }
}
