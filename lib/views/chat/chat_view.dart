import 'package:chateo/controllers/ChatController/chat_controller.dart';
import 'package:chateo/cubits/chat_cubit/chat_cubit.dart';
import 'package:chateo/cubits/chat_cubit/chat_states.dart';
import 'package:chateo/helper/helper.dart';
import 'package:chateo/services/user_database_services.dart';
import 'package:chateo/views/widgets/custom_back_icon.dart';
import 'package:chateo/views/widgets/custom_toastification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../../models/message_model.dart';
import 'chat_bubble.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_form.dart';

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
    required this.receiverName,
    required this.receiverID,
  });
  final String receiverName;
  final String receiverID;

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: Builder(builder: (context) {
        return Scaffold(
            backgroundColor: const Color(0xfff7f7fc),
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: CustomText(
                text: receiverName,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              leading: const CustomBackIcon(),
              actions: [
                IconButton(
                    onPressed: () async {
                      customShowDialog(context,
                          titleColor: Colors.amber.shade700,
                          title:
                              "All messages will be deleted from your friend's side too.Are you sure you want to do that?",
                          height: MediaQuery.of(context).size.height * 0.1,
                          widgets: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const CustomText(text: "Cancel")),
                                TextButton(
                                  onPressed: () {
                                    BlocProvider.of<ChatCubit>(context)
                                        .deleteMessages(receiverID: receiverID);
                                    Navigator.pop(context);
                                  },
                                  child: const CustomText(
                                    text: "Delete",
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ]);
                    },
                    icon: const Icon(
                      Icons.delete_outlined,
                      color: Colors.red,
                    ))
              ],
            ),
            body: BodyBuilder(
                receiverID: receiverID, messageController: messageController));
      }),
    );
  }
}

Widget _buildMessageList(
  context,
  String otherId,
) {
  final scrollController = ScrollController();
  final chatController = ChatController();
  return StreamBuilder<List<MessageModel>>(
    stream: chatController.getMessages(otherId),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: CustomText(text: 'Error fetching messages'));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (snapshot.hasData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.bounceIn);
          }
        });
        return ListView.builder(
          controller: scrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data![index]);
          },
        );
      }
      return Container();
    },
  );
}

Widget _buildMessageItem(MessageModel messageData) {
  return messageData.senderId == UserDatabaseServices().currentUser!.uid
      ? CustomChatBubble(
          messageModel: messageData,
        )
      : CustomChatBubbleForFriend(
          messageModel: messageData,
        );
}

class BodyBuilder extends StatelessWidget {
  const BodyBuilder(
      {super.key, required this.receiverID, required this.messageController});
  final String receiverID;
  final TextEditingController messageController;
  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<ChatCubit>(context);
    return BlocListener<ChatCubit, ChatStates>(
      listener: (context, state) {
        if (state is FailedSendMessageState) {
          showToastification(context,
              title: state.errorText!, message: state.errorText!);
        }
      },
      child: BlocBuilder<ChatCubit, ChatStates>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildMessageList(context, receiverID)),
              Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          onTapOutside: (p0) {},
                          contentPadding: const EdgeInsets.all(5),
                          controller: messageController,
                          hintText: 'Enter a message',
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (messageController.text.isNotEmpty) {
                            cubit.sendMessage(
                                receiverId: receiverID,
                                controller: messageController);
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: kMainColor,
                          size: 30,
                        ),
                      )
                    ],
                  ))
            ],
          );
        },
      ),
    );
  }
}
