import 'dart:developer';

import 'package:chateo/services/user_database_services.dart';
import '../../models/user_model.dart';

class UserController {
  UserModel? userModel;
  final _userDatabaseServices = UserDatabaseServices();

  Future<UserModel?> getUserData() async {
    try {
      userModel = await _userDatabaseServices.getCurrentUserData();
      if (userModel == null) {
        log('User data is null');
      } else {
        // log('User ID: ${userModel!.id}');
      }
      return userModel;
    } catch (e) {
      log('Error getting user data: $e');
      return null;
    }
  }
}
