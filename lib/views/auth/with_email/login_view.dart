import 'package:chateo/helper/helper.dart';
import 'package:chateo/views/home/home_view.dart';
import 'package:chateo/views/widgets/custom_back_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../../constants/constants.dart';
import '../../../cubits/auth_cubit/auth_cubit.dart';
import '../../../cubits/auth_cubit/auth_states.dart';
import '../../widgets/custom_email_and_password_auth_widget.dart';
import '../../widgets/custom_loading_widget.dart';
import '../../widgets/custom_material_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toastification.dart';
import '../verification/verification_email_auth_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
            naviPush(
              context,
              widgetName: VerificationEmailAuthView(
                email: emailController.text,
              ),
            );
          } else if (state is SuccessfulLoginAuthState) {
            naviPushAndRemoveUntil(context, widgetName: const HomeView());
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
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Log in to  ",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "chateo",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: kMainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Center(
                          child: CustomText(
                            text:
                                "Welcome back! Sign in using your email to continue us",
                            textAlign: TextAlign.center,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomEmailAndPasswordAuthWidget(
                          emailController: emailController,
                          passwordController: passwordController,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: authCubit.rememberMe,
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (value) {
                                    authCubit.toggleRememberMe();
                                  },
                                ),
                                const CustomText(
                                  fontSize: 14,
                                  text: "Remember me",
                                  color: kMainColor,
                                ),
                              ],
                            ),
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
                              await authCubit.saveLoginCredentials(
                                email: emailController.text,
                                password: passwordController.text,
                                rememberMe: authCubit.rememberMe,
                              );
                              authCubit.submitLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          widget: state is LoadingAuthState
                              ? const CustomLoadingWidget()
                              : const CustomText(
                                  text: "Log in",
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
