import 'package:chateo/controllers/ChatController/chat_controller.dart';
import 'package:chateo/models/message_model.dart';
import 'package:chateo/services/format_services.dart';
import 'package:chateo/views/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class CustomChatBubble extends StatelessWidget {
  const CustomChatBubble({
    super.key,
    this.messageModel,
  });

  final MessageModel? messageModel;

  @override
  Widget build(BuildContext context) {
    ChatController chatController = ChatController();
    String message = chatController.getOriginalMessage(messageModel!);
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.2),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: const EdgeInsets.all(8).copyWith(bottom: 4),
          padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15)
                .copyWith(bottomLeft: const Radius.circular(0)),
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                    minWidth: MediaQuery.of(context).size.width * 0.15),
                margin: const EdgeInsets.all(12).copyWith(bottom: 15),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xff0F1828),
                    fontSize: 13,
                  ),
                ),
              ),
              CustomText(
                text: FormatServices().formatTime(messageModel!.publishAt),
                fontSize: 9,
                color: const Color(0xffADB5BD),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomChatBubbleForFriend extends StatelessWidget {
  const CustomChatBubbleForFriend({
    super.key,
    this.messageModel,
  });

  final MessageModel? messageModel;

  @override
  Widget build(BuildContext context) {
    ChatController chatController = ChatController();
    String message = chatController.getOriginalMessage(messageModel!);
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.2),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          margin: const EdgeInsets.all(8).copyWith(bottom: 4),
          padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          decoration: BoxDecoration(
            color: kMainColor,
            borderRadius: BorderRadius.circular(15)
                .copyWith(bottomRight: const Radius.circular(0)),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                    minWidth: MediaQuery.of(context).size.width * 0.15),
                margin: const EdgeInsets.all(12).copyWith(bottom: 15),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
              CustomText(
                text: FormatServices().formatTime(messageModel!.publishAt),
                fontSize: 10,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
