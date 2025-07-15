import 'package:chateo/views/auth/profile/edit_profile_view.dart';
import 'package:chateo/views/widgets/custom_back_icon.dart';
import 'package:chateo/views/widgets/custom_email_and_password_auth_widget.dart';
import 'package:chateo/views/widgets/custom_material_button.dart';
import 'package:chateo/views/widgets/custom_profile_item.dart';
import 'package:chateo/views/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../constants/constants.dart';
import '../../../controllers/UserController/user_controller.dart';
import '../../../cubits/auth_cubit/auth_cubit.dart';
import '../../../cubits/auth_cubit/auth_states.dart';
import '../../../helper/helper.dart';
import '../../../models/user_model.dart';
import '../../../services/format_services.dart';
import '../../walkthrough/walkthrough_screen.dart';
import '../../widgets/custom_toastification.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserController _userController = UserController();
  UserModel? userData;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is DeleteAccountSuccessState) {
          naviPushAndRemoveUntil(context,
              widgetName: const WalkthroughScreen());
        } else if (state is DeleteAccountFailureState) {
          showToastification(
            title: state.error!,
            message: state.error!,
            type: ToastificationType.error,
            context,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackIcon(),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                naviPush(context,
                    widgetName: EditProfileView(userData: userData!));
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: _userController.getUserData(),
          builder: (context, snapshot) {
            userData = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: kMainColor,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: size.width * 0.2,
                  child: Center(
                    child: CustomText(
                      text: FormatServices()
                          .returnFirstAndLastInitials(name: userData!.name)
                          .toString()
                          .toUpperCase(),
                      fontSize: size.width * 0.1,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                CustomProfileItem(
                  subtitle: userData!.name,
                  title: "Name",
                  icon: Icons.person_2_outlined,
                ),
                CustomProfileItem(
                  subtitle: userData!.email,
                  title: "Email",
                  icon: Icons.email_outlined,
                ),
                CustomProfileItem(
                  subtitle: userData!.bio ?? "No bio yet.",
                  title: "Bio",
                  icon: Icons.text_fields,
                ),
                CustomProfileItem(
                  subtitle:
                      FormatServices().formatDateTime(userData!.createdAt),
                  title: "Member since",
                  icon: Icons.date_range,
                ),
                const Spacer(),
                CustomMaterialButton(
                  color: Colors.red,
                  widget: const CustomText(
                    text: "Delete Account",
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    customShowDialog(
                      context,
                      title:
                          "Warning \nYou are about to permanently delete your account",
                      titleColor: Colors.amber,
                      widgets: [
                        const CustomText(
                          text:
                              "If you choose to delete, we will remove your account from our server.\nYour app data will also be deleted and you will not be able to recover it.\nBecause this is a security-sensitive process, you will be asked to log in again before deleting your account.",
                          color: Colors.black,
                          maxLines: 8,
                          textAlign: TextAlign.start,
                          fontSize: 13,
                        ),
                      ],
                      actionsAlignment: MainAxisAlignment.spaceAround,
                      actionsPadding: const EdgeInsets.all(0),
                      insetPadding: const EdgeInsets.all(8),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const CustomText(
                            text: "Cancel",
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close the first dialog
                            _handleReauthentication(context);
                          },
                          child: const CustomText(
                            text: "Delete",
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: size.height * 0.02),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleReauthentication(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        // Google Sign-In user
        await BlocProvider.of<AuthCubit>(context).deleteUserAccount();
      } else {
        // Email/password user
        _showReauthenticationDialog(context);
      }
    }
  }

  void _showReauthenticationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const CustomText(text: "Re-authenticate"),
          insetPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomEmailAndPasswordAuthWidget(
                  emailController: _emailController,
                  passwordController: _passwordController)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const CustomText(
                text: "Cancel",
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (email.isNotEmpty && password.isNotEmpty) {
                  await BlocProvider.of<AuthCubit>(context).deleteUserAccount(
                    email: email,
                    password: password,
                  );
                  Navigator.pop(context); // Close the re-authentication dialog
                } else {
                  showToastification(
                    title: "Error",
                    message: "Please enter your email and password.",
                    type: ToastificationType.error,
                    context,
                  );
                }
              },
              child: const CustomText(
                text: "Confirm",
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}
