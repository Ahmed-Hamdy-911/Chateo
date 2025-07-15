import 'package:chateo/views/auth/with_email/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/auth_cubit/auth_states.dart';
import '../../helper/helper.dart';
import '../auth/with_email/sign_up_view.dart';
import '../home/home_view.dart';
import '../widgets/custom_loading_widget.dart';
import '../widgets/custom_material_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_toastification.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is FailureFirebaseAuthExceptionState) {
            showToastification(context, title: "Error", message: state.error);
          } else if (state is FailureLoginAuthState) {
            showToastification(context, title: "Error", message: state.error);
          } else if (state is SuccessfulLoginAuthState) {
            naviPushAndRemoveUntil(context, widgetName: const HomeView());
          }
        },
        child: BlocBuilder<AuthCubit, AuthStates>(
          builder: (context, state) {
            final authCubit = BlocProvider.of<AuthCubit>(context);

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Illustration.png',
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    const CustomText(
                      text:
                          'Connect easily with\n your family and friends\n over countries',
                      textAlign: TextAlign.center,
                      color: Colors.black,
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: OutlinedButton(
                        onPressed: () async {
                          await authCubit.signInWithGoogle();
                        }, // logic
                        style: const ButtonStyle(
                            shape: WidgetStatePropertyAll(CircleBorder()),
                            padding: WidgetStatePropertyAll(EdgeInsets.all(8))),
                        child: authCubit.state is LoadingGoogleAuthState
                            ? const CustomLoadingWidget(
                                color: kMainColor,
                              )
                            : Image.asset(
                                'assets/icons/google.png',
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey[400],
                            endIndent: 20,
                            indent: 25,
                          ),
                        ),
                        const Text("OR"),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[400],
                            endIndent: 25,
                            indent: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomMaterialButton(
                      onPressed: () {
                        naviPush(context, widgetName: const SignUpView());
                      },
                      widget: const CustomText(
                          text: "Sign up with email",
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w300),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                            text: "Existing account?",
                            color: Colors.black,
                            fontSize: 14.5),
                        TextButton(
                          onPressed: () {
                            naviPush(context, widgetName: const LoginView());
                          },
                          child: const CustomText(
                              text: "Log in",
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
