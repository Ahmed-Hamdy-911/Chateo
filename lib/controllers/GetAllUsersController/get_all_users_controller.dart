import 'package:chateo/services/user_database_services.dart';

import '../../models/user_model.dart';

class GetAllUsersController {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  Stream<List<UserModel?>> getAllUser() {
    return _userDatabaseServices.getAllUserStream();
  }
}
