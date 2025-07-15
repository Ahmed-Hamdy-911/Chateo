import 'dart:developer';

import 'package:chateo/controllers/ChatController/chat_controller.dart';
import 'package:chateo/cubits/chat_cubit/chat_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(InitialChatState());
  String message = '';
  final ChatController _chatController = ChatController();
  void clearField(TextEditingController controller) {
    message = controller.text;
    controller.clear();
  }

  Future<void> sendMessage(
      {required String receiverId,
      required TextEditingController controller}) async {
    emit(LoadingState());
    try {
      clearField(controller);
      _chatController.sendMessage(receiverId, message);
      emit(SuccessfulSendMessageState());
    } on FirebaseException catch (e) {
      log(e.toString());
      emit(FailedSendMessageState(e.code));
    }
  }

  Future<void> deleteMessages({
    required String receiverID,
  }) async {
    emit(LoadingState());
    try {
      await _chatController.deleteChat(otherId: receiverID);
      emit(SuccessfulDeleteMessageState());
    } catch (e) {
      log(e.toString());
    }
  }
}
