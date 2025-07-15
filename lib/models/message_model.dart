import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String? senderEmail;
  final String? senderName;
  final String receiverId;
  final String messageContent;
  final Timestamp publishAt;
  final String iv; 

  MessageModel({
    required this.senderId,
    this.senderEmail,
    this.senderName,
    required this.receiverId,
    required this.messageContent,
    required this.publishAt,
    required this.iv,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'receiverId': receiverId,
      'messageContent': messageContent,
      'publishAt': publishAt,
      'iv': iv, // Include IV in the map
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      senderEmail: json['senderEmail'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
      messageContent: json['messageContent'],
      publishAt: json['publishAt'],
      iv: json['iv'], // Extract IV
    );
  }
}
