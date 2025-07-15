import 'package:chateo/helper/helper.dart';
import 'package:chateo/views/auth/verification/verification_email_auth_view.dart';
import 'package:chateo/views/widgets/custom_back_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../../constants/constants.dart';
import 'package:flutter/material.dart';
import '../../../cubits/auth_cubit/auth_cubit.dart';
import '../../../cubits/auth_cubit/auth_states.dart';
import '../../widgets/custom_email_and_password_auth_widget.dart';
import '../../widgets/custom_loading_widget.dart';
import '../../widgets/custom_material_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_toastification.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conformPasswordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    final authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.resetVisibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: CustomBackIcon(onPressed: () {
          Navigator.pop(context);
        }),
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
          } else if (state is FailureSignAuthState) {
            showToastification(
              context,
              title: "Error",
              message: state.error,
              type: ToastificationType.error,
            );
          } else if (state is SendVerificationAuthState) {
            showToastification(
              context,
              title: "Warning",
              message: "Please check your email to verify",
              type: ToastificationType.warning,
            );
            naviPush(
              context,
              widgetName: VerificationEmailAuthView(
                email: emailController.text,
              ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "Sign Up With ",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "Email",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kMainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Center(
                          child: CustomText(
                            text:
                                "Get chatting with friends and family today by\n signing up for our chat app!",
                            textAlign: TextAlign.center,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const CustomText(
                          text: "Your Name",
                          customStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          hintText: "Enter your name",
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required';
                            } else if (value.length < 3) {
                              return 'Too short';
                            } else if (value.startsWith(RegExp(r'^[0-9]'))) {
                              return 'Name should not start with number';
                            } else if (value
                                .contains(RegExp(r'^.*[@/$!%*?&]'))) {
                              return 'Name should not contain special characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomEmailAndPasswordAuthWidget(
                          emailController: emailController,
                          passwordController: passwordController,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Confirm Password",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          hintText: "Enter confirm password",
                          controller: conformPasswordController,
                          keyboardType: TextInputType.text,
                          obscureText: authCubit.showConfirmPassword,
                          suffixIcon: IconButton(
                              onPressed: () {
                                authCubit.toggleConfirmPasswordVisibility();
                              },
                              icon: Icon(
                                  authCubit.showConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xffADB5BD))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required';
                            } else if (value != passwordController.text) {
                              return "Not Matching";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Center(
                          child: CustomMaterialButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                authCubit.signUpSubmit(context,
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: conformPasswordController.text);
                              }
                            },
                            widget: authCubit.state is LoadingAuthState
                                ? const CustomLoadingWidget()
                                : const CustomText(
                                    text: "Sign Up",
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300),
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
