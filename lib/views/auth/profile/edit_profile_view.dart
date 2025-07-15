import 'package:chateo/views/widgets/custom_back_icon.dart';
import 'package:chateo/views/widgets/custom_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../cubits/auth_cubit/auth_cubit.dart';
import '../../../cubits/auth_cubit/auth_states.dart';
import '../../../helper/helper.dart';
import '../../../models/user_model.dart';
import '../../home/home_view.dart';
import '../../widgets/custom_material_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_form.dart';
import '../../widgets/custom_toastification.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({
    super.key,
    required this.userData,
  });
  final UserModel userData;
  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    emailController.text = widget.userData.email;
    nameController.text = widget.userData.name;
    bioController.text = widget.userData.bio ?? '';
    // log(widget.userData.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Edit Profile',
        ),
        leading: const CustomBackIcon(),
      ),
      body: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is FailureFirebaseAuthExceptionState) {
            showToastification(context,
                title: "Error",
                message: state.error,
                type: ToastificationType.success);
          } else if (state is FailureUpdateUserDataState) {
            showToastification(context,
                title: "Error",
                message: "Oops there was an error, try later",
                type: ToastificationType.success);
          } else if (state is SuccessfulUpdateUserDataState) {
            showToastification(context,
                title: "Successful",
                message: "Your data has been updated successfully",
                type: ToastificationType.success);
            naviPushAndRemoveUntil(context, widgetName: const HomeView());
          }
        },
        child: BlocBuilder<AuthCubit, AuthStates>(
          builder: (context, state) {
            var authCubit = BlocProvider.of<AuthCubit>(context);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          } else if (value.length < 3) {
                            return 'Too short';
                          } else if (value.startsWith(RegExp(r'^[0-9]'))) {
                            return 'Name should not start with number';
                          } else if (value.contains(RegExp(r'^.*[@/$!%*?&]'))) {
                            return 'Name should not contain special characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const CustomText(
                        text: "Your Email",
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
                        hintText: "Enter your email",
                        controller: emailController,
                        enabled: false,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const CustomText(
                        text: "Your Bio",
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
                        hintText: "Enter your bio",
                        controller: bioController,
                        keyboardType: TextInputType.text,
                        minLines: 6,
                        // maxLines: 8,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(300),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: CustomMaterialButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await authCubit.updateUserData(
                                name: nameController.text,
                                email: emailController.text,
                                bio: bioController.text,
                              );
                            }
                          },
                          widget: context.watch<AuthCubit>().state
                                  is LoadingAuthState
                              ? const CustomLoadingWidget()
                              : const CustomText(
                                  text: "Save Changes",
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
