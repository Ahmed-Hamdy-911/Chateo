import 'package:chateo/cubits/auth_cubit/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit/auth_cubit.dart';
import 'custom_text_form.dart';

class CustomEmailAndPasswordAuthWidget extends StatelessWidget {
  const CustomEmailAndPasswordAuthWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        final authCubit = BlocProvider.of<AuthCubit>(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Email",
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
              hintText: "Enter your email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              inputFormatters: [
                FilteringTextInputFormatter.deny(" "),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                } else if (!RegExp(
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                    .hasMatch(value)) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Password",
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
              hintText: "Enter your password",
              controller: passwordController,
              keyboardType: TextInputType.text,
              obscureText: authCubit.showPassword,
              suffixIcon: IconButton(
                  onPressed: authCubit.togglePasswordVisibility,
                  icon: Icon(
                      authCubit.showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xffADB5BD))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                  return 'Password must include at least one lowercase letter';
                }
                if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                  return 'Password must include at least one uppercase letter';
                }
                if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                  return 'Password must include at least one number';
                }
                if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
                  return 'Password must include at least one special character (@, \$, !, %, *, ?, &)';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }
}
