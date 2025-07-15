import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserDatabaseServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  String? get userEmail => _firebaseAuth.currentUser?.email;
  bool get isVerify => _firebaseAuth.currentUser?.emailVerified ?? false;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String _collectionUser = 'users';

  //  Store user data
  Future<void> storeUserData({
    required String name,
    required String email,
  }) async {
    final userUid = _firebaseAuth.currentUser!.uid;
    try {
      await _firebaseFirestore.collection(_collectionUser).doc(userUid).set(
        {
          'id': userUid,
          'name': name,
          'email': email,
          'bio': '',
          'create_at': Timestamp.now(),
        },
      );
    } on FirebaseException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // update  user data on firestore
  Future updateUserData({
    String? name,
    String? email,
    String? bio,
  }) async {
    try {
      final userUid = _firebaseAuth.currentUser!.uid;

      await _firebaseFirestore.collection(_collectionUser).doc(userUid).set(
        {
          'name': name,
          'email': email,
          'bio': bio,
          'update_at': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // // create a unique field on firestore
  Future<void> createUniqueFieldOnFirestoreOnSpecificCollection({
    required String keyOfField,
    required dynamic valueOfField,
  }) async {
    final userUid = _firebaseAuth.currentUser!.uid;

    try {
      await _firebaseFirestore.collection(_collectionUser).doc(userUid).set(
        {
          keyOfField: valueOfField,
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //  get current user data from firestore
  Future<UserModel> getCurrentUserData() async {
    final userUid = _firebaseAuth.currentUser!.uid;
    try {
      DocumentSnapshot documentSnapshot = await _firebaseFirestore
          .collection(_collectionUser)
          .doc(userUid)
          .get();
      return UserModel.fromJson(
          documentSnapshot.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

// Get users the current user has chatted with
  Stream<List<UserModel>> getChattedUsers() {
    final currentUserId = _firebaseAuth.currentUser!.uid;

    return _firebaseFirestore
        .collection('chat_room')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      final chattedUserIds = <String>{};
      for (final doc in snapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        participants.removeWhere((id) => id == currentUserId);
        chattedUserIds.addAll(participants);
      }

      if (chattedUserIds.isEmpty) return [];

      final usersSnapshot = await _firebaseFirestore
          .collection(_collectionUser)
          .where(FieldPath.documentId, whereIn: chattedUserIds.toList())
          .get();

      return usersSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    });
  }

  //  delete current user data from firestore
  Future<void> deleteCurrentUserData() async {
    final userUid = _firebaseAuth.currentUser!.uid;

    try {
      // Delete the user's document 
      await _firebaseFirestore
          .collection(_collectionUser)
          .doc(userUid)
          .delete();

      // Delete all chat rooms where the user is a participant
      final chatRoomsQuery = await _firebaseFirestore
          .collection("chat_room")
          .where('participants', arrayContains: userUid)
          .get();

      for (final chatRoomDoc in chatRoomsQuery.docs) {
        // Delete all messages in the chat room
        final messagesQuery = await chatRoomDoc.reference
            .collection("messages")
            .where('senderId', isEqualTo: userUid)
            .get();

        for (final messageDoc in messagesQuery.docs) {
          await messageDoc.reference.delete();
        }

        // Delete the chat room if it only contains the current user
        final participants = List<String>.from(chatRoomDoc['participants']);
        if (participants.length == 1 && participants.contains(userUid)) {
          await chatRoomDoc.reference.delete();
        } else {
          // Remove the user from the participants list
          await chatRoomDoc.reference.update({
            'participants': FieldValue.arrayRemove([userUid]),
          });
        }
      }

      log('User data deleted successfully');
    } on FirebaseException catch (e) {
      log('Firebase Error deleting user data: ${e.code}');
      throw Exception(e.code);
    } catch (e) {
      log('Error deleting user data: $e');
      throw Exception(e.toString());
    }
  }

// delete user account
  Future<void> deleteUserAccount() async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      try {
        // Delete the user's data from Firestore
        await deleteCurrentUserData();

        // Delete the user's authentication account
        await user.delete();
        log('User account deleted successfully');
      } on FirebaseAuthException catch (e) {
        log('Firebase Auth Error deleting account: ${e.code}');
        throw Exception(e.code);
      } catch (e) {
        log('Error deleting user account: $e');
        throw Exception(e.toString());
      }
    } else {
      throw Exception('No user is currently signed in');
    }
  }

  // Get user stream
  Stream<List<UserModel?>> getAllUserStream() {
    return _firebaseFirestore
        .collection(_collectionUser)
        .where('verified', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => UserModel.fromJson(doc.data()),
          )
          .toList();
    });
  }
}
