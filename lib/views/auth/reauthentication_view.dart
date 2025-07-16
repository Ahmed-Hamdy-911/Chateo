import 'package:chateo/helper/helper.dart';
import 'package:chateo/views/home/home_view.dart';
import 'package:chateo/views/widgets/custom_back_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../../constants/constants.dart';
import '../../../cubits/auth_cubit/auth_cubit.dart';
import '../../../cubits/auth_cubit/auth_states.dart';

import '../widgets/custom_email_and_password_auth_widget.dart';
import '../widgets/custom_loading_widget.dart';
import '../widgets/custom_material_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_toastification.dart';

class ReauthenticationView extends StatefulWidget {
  const ReauthenticationView({super.key});

  @override
  State<ReauthenticationView> createState() => _ReauthenticationViewState();
}

class _ReauthenticationViewState extends State<ReauthenticationView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved email, password, and "Remember Me" state
  Future<void> _loadSavedCredentials() async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final credentials = await authCubit.getSavedLoginCredentials();

    setState(() {
      authCubit.rememberMe = credentials['rememberMe'] ?? false;
      emailController.text = credentials['email'] ?? '';
      passwordController.text = credentials['password'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: const CustomBackIcon(),
        title: CustomText(text: "Verify Your Identity"),
      ),
      body: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is FailureFirebaseAuthExceptionState) {
            showToastification(
              context,
              title: "Error",
              message: state.error,
              type: ToastificationType.error,
            );
          } else if (state is SuccessfulPasswordResetState) {
            showToastification(
              context,
              title: "Info",
              message: "Please, check your email to reset your password.",
              type: ToastificationType.info,
            );
          } else if (state is FailureLoginAuthState) {
            showToastification(
              context,
              title: "Error",
              message: "Oops there was an error, try later",
              type: ToastificationType.error,
            );
          } else if (state is FailureVerificationAuthState) {
            showToastification(
              context,
              title: "Warning",
              message: state.error,
              type: ToastificationType.warning,
            );
          } else if (state is DeleteAccountSuccessState) {
            showToastification(
              context,
              title: "Success",
              message:
                  "Your account has been deleted successfully. Hope to see you again!",
              type: ToastificationType.success,
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BlocBuilder<AuthCubit, AuthStates>(
                builder: (context, state) {
                  final authCubit = BlocProvider.of<AuthCubit>(context);
                  return Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CustomEmailAndPasswordAuthWidget(
                          emailController: emailController,
                          passwordController: passwordController,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                if (emailController.text.isNotEmpty) {
                                  await authCubit.passwordReset(
                                    email: emailController.text,
                                  );
                                } else {
                                  showToastification(
                                    context,
                                    title: "Error",
                                    message: "Please, enter your email.",
                                    type: ToastificationType.error,
                                  );
                                }
                              },
                              child: const CustomText(
                                text: "Password Reset?",
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        CustomMaterialButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              authCubit.deleteUserAccount(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          widget: state is LoadingAuthState
                              ? const CustomLoadingWidget()
                              : const CustomText(
                                  text: "Sign In Again to Delete Account",
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w300,
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
