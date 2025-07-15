import 'package:chateo/cubits/auth_cubit/auth_cubit.dart';
import 'package:chateo/cubits/auth_cubit/auth_states.dart';
import 'package:chateo/cubits/timer_cubit/timer_cubit.dart';
import 'package:chateo/cubits/timer_cubit/timer_states.dart';
import 'package:chateo/views/home/home_view.dart';
import 'package:chateo/views/widgets/custom_loading_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../../constants/constants.dart';
import '../../../helper/helper.dart';
import '../../widgets/custom_back_icon.dart';
import '../../widgets/custom_material_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toastification.dart';

class VerificationEmailAuthView extends StatefulWidget {
  const VerificationEmailAuthView({
    super.key,
    required this.email,
  });
  final String email;

  @override
  State<VerificationEmailAuthView> createState() =>
      _VerificationEmailAuthViewState();
}

class _VerificationEmailAuthViewState extends State<VerificationEmailAuthView> {
  late TimerCubit _timerCubit;

  @override
  void initState() {
    super.initState();
    const timeout = 120;
    _timerCubit = context.read<TimerCubit>();
    _timerCubit.resetTimer(timeout);
  }

  @override
  void dispose() {
    _timerCubit.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final timerCubit = BlocProvider.of<TimerCubit>(context);

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackIcon(
          onPressed: () {
            Navigator.pop(context);
            timerCubit.cancelTimer();
          },
        ),
      ),
      body: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is FailureVerificationAuthState) {
            showToastification(
              context,
              title: "Warning",
              message: "Please check your email to verify",
              type: ToastificationType.warning,
            );
          }
          if (state is SuccessfulVerificationAuthState) {
            naviPushAndRemoveUntil(context, widgetName: const HomeView());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                      'assets/animation/Animation - 1718041914581.json'),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    child: RichText(
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          const TextSpan(
                              text:
                                  'We have sent you a link to verify your email address.\n to ',
                              style: TextStyle(
                                color: Colors.black54,
                              )),
                          TextSpan(
                              text: ' ${widget.email}',
                              style: const TextStyle(
                                  color: Colors.blue, height: 1.7)),
                        ])),
                  ),
                  BlocBuilder<AuthCubit, AuthStates>(
                    builder: (context, state) {
                      final authCubit = BlocProvider.of<AuthCubit>(context);

                      return CustomMaterialButton(
                        onPressed: () async {
                          await authCubit.afterVerifySuccessful();
                        },
                        widget: state is SuccessfulVerificationAuthState
                            ? const CustomLoadingWidget()
                            : const CustomText(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w300,
                                text: 'Continue',
                              ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  BlocBuilder<TimerCubit, TimerStates>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          if (state is TimerTickingState)
                            RichText(
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Resend verify in ',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' ${BlocProvider.of<TimerCubit>(context).start}',
                                    style: const TextStyle(
                                      color: kMainColor,
                                      height: 1.7,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' seconds',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () async {
                                await authCubit.sendVerification();
                                _timerCubit.resetTimer(120);
                                showToastification(
                                  context,
                                  title: "Warning",
                                  message: "Please check your email to verify",
                                  type: ToastificationType.warning,
                                );
                              },
                              child: const Text(
                                'Send verify again?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff002DE3),
                                ),
                              ),
                            )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
