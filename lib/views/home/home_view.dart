import 'package:chateo/constants/constants.dart';
import 'package:chateo/controllers/ChatController/chat_controller.dart';
import 'package:chateo/helper/helper.dart';
import 'package:chateo/views/auth/profile/profile_view.dart';
import 'package:chateo/views/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/GetAllUsersController/get_all_users_controller.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/auth_cubit/auth_states.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../services/user_database_services.dart';
import '../chat/chat_view.dart';
import '../walkthrough/walkthrough_screen.dart';
import '../widgets/custom_build_contact_item.dart';
import '../widgets/custom_error_message.dart';
import '../widgets/custom_loading_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is SuccessfulLogOutAuthState) {
            naviPushAndRemoveUntil(
              context,
              widgetName: const WalkthroughScreen(),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const CustomText(text: 'Home'),
            actions: [
              IconButton(
                  onPressed: () {
                    naviPush(context, widgetName: const ProfileView());
                  },
                  icon: const Icon(
                    Icons.person_2_outlined,
                  )),
              IconButton(
                  onPressed: () {
                    BlocProvider.of<AuthCubit>(context).logOut();
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                  )),
            ],
            bottom: const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                tabs: [
                  Tab(
                    text: 'Chats',
                  ),
                  Tab(
                    text: 'Users',
                  ),
                ]),
          ),
          body: const TabBarView(children: [
            ChatsTab(),
            UsersTab(),
          ]),
        ),
      ),
    );
  }
}

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = UserDatabaseServices().currentUser?.uid;
    GetAllUsersController getAllUserController = GetAllUsersController();
    return StreamBuilder(
      stream: getAllUserController.getAllUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorMessage(
            messageError: 'Error occurred while fetching data',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingWidget(
            color: kMainColor,
          );
        }
        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: CustomText(text: 'No Users yet!'),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                children: snapshot.data!
                    .where((userData) => userData?.id != currentUserId)
                    .map<Widget>((userData) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomContactItem(
                              onTap: () {
                                naviPush(context,
                                    widgetName: ChatView(
                                      receiverName: userData.name,
                                      receiverID: userData.id,
                                    ));
                              },
                              name: userData!.name,
                              message: userData.bio ?? '',
                            ),
                            const Divider(height: 0, color: Color(0xffEDEDED))
                          ],
                        ))
                    .toList(),
              ),
              // snapshot.data != null ? const HelperTextWidget() : Container(),
            ],
          ),
        );
      },
    );
  }
}

class HelperTextWidget extends StatelessWidget {
  const HelperTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: const TextSpan(children: [
          TextSpan(
            text: 'Your personal messages are',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          TextSpan(
            text: " end-to-end encrypted.",
            style: TextStyle(fontSize: 13, color: kMainColor),
          )
        ]),
      ),
    );
  }
}

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = ChatController();

    return StreamBuilder<List<UserModel>>(
      stream: chatController.getChattedUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorMessage(
            messageError: 'Error occurred while fetching data',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingWidget(
            color: kMainColor,
          );
        }

        final chattedUsers = snapshot.data ?? [];

        if (chattedUsers.isEmpty) {
          return const Center(
            child: CustomText(text: 'No Chats yet!'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                children: chattedUsers.map<Widget>((userData) {
                  return StreamBuilder<MessageModel?>(
                    stream: chatController.lastMessageToEveryUser(
                      userData.id,
                    ),
                    builder: (context, messageSnapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomContactItem(
                            onTap: () {
                              naviPush(context,
                                  widgetName: ChatView(
                                    receiverName: userData.name,
                                    receiverID: userData.id,
                                  ));
                            },
                            name: userData.name,
                            message: messageSnapshot.data != null
                                ? chatController
                                    .getOriginalMessage(messageSnapshot.data!)
                                : '',
                          ),
                          const Divider(height: 0, color: Color(0xffEDEDED)),
                        ],
                      );
                    },
                  );
                }).toList(),
              ),
              const HelperTextWidget(),
            ],
          ),
        );
      },
    );
  }
}
