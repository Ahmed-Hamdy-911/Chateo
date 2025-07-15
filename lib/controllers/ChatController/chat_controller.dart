import 'dart:developer';

import 'package:chateo/models/message_model.dart';
import 'package:chateo/models/user_model.dart';
import 'package:chateo/services/chat_services.dart';
import 'package:chateo/services/user_database_services.dart';

import '../../services/encryption_services.dart';

class ChatController {
  final EncryptionServices _encryptionServices = EncryptionServices();
  final ChatServices _chatServices = ChatServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();

  // send message
  Future<void> sendMessage(
    String receiverId,
    String message,
  ) async {
    await _chatServices.sendMessage(receiverId, message);
  }

  // Get users the current user has chatted with
  Stream<List<UserModel>> getChattedUsers() {
    return _userDatabaseServices.getChattedUsers();
  }

// Decrypt the message
  String getOriginalMessage(MessageModel messageModel) {
    final decryptedMessage = _encryptionServices.decryptMessage(
        messageModel.messageContent, messageModel.iv);
    log("Original message after decrypt:$decryptedMessage");
    return decryptedMessage;
  }

// chat room id
  String _returnChatRoomId(String otherId) {
    List<String> ids = [_userDatabaseServices.currentUser!.uid, otherId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return chatRoomId;
  }

  // get last message of each chat room
  Stream<MessageModel?> lastMessageToEveryUser(String otherId) {
    String chatRoomId = _returnChatRoomId(otherId);

    return _chatServices.fetchLastMessage(chatRoomId);
  }

  // Get messages
  Stream<List<MessageModel>> getMessages(String otherId) {
    String chatRoomId = _returnChatRoomId(otherId);

    return _chatServices.loadMessages(chatRoomId);
  }

  // Delete all messages in a chat room
  Future<void> deleteChat({required String otherId}) async {
    String chatRoomId = _returnChatRoomId(otherId);
    await _chatServices.deleteMessagesBetweenTwoUsers(chatRoomId);
  }
}
