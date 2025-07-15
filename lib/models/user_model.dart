import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final Timestamp createdAt;

  UserModel({
    required this.name,
    required this.id,
    required this.email,
    required this.createdAt,
    this.bio,
  });
  factory UserModel.fromJson(json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['create_at'],
      bio: json['bio'],
    );
  }
}
