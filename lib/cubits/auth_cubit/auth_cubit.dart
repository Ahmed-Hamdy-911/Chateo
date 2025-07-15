import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../cache/secure_storage.dart';
import '../../constants/constants.dart';
import '../../helper/helper.dart';
import '../../services/auth_services.dart';
import '../../services/user_database_services.dart';
import 'auth_states.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(InitialAuthState());
  get authServices => _authServices;
  final AuthServices _authServices = AuthServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  bool showPassword = true;
  bool showConfirmPassword = true;
  bool rememberMe = false;

// change visibility to password
  void togglePasswordVisibility() {
    showPassword = !showPassword;
    emit(TogglePasswordVisibilityState());
  }

// change visibility to confirm password
  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
    emit(ToggleConfirmPasswordVisibilityState());
  }

// reset visibility
  void resetVisibility() {
    showPassword = true;
    showConfirmPassword = true;
    emit(InitialAuthState());
  }

  // change remember me state
  void toggleRememberMe() {
    rememberMe = !rememberMe;
    rememberMeSave = rememberMe;
    emit(ToggleRememberMeState());
  }

// Save email, password, and "Remember Me" state
  Future<void> saveLoginCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await SecureStorage.saveSecureStorage(key: 'email', value: email);
      await SecureStorage.saveSecureStorage(key: 'password', value: password);
    } else {
      await SecureStorage.deleteSecureStorage(key: 'email');
      await SecureStorage.deleteSecureStorage(key: 'password');
    }
    await SecureStorage.saveSecureStorage(
        key: 'rememberMe', value: rememberMe.toString());
  }

  // Retrieve saved email and password
  Future<Map<String, dynamic>> getSavedLoginCredentials() async {
    final rememberMe = await SecureStorage.readSecureStorage(key: 'rememberMe');
    final email = await SecureStorage.readSecureStorage(key: 'email');
    final password = await SecureStorage.readSecureStorage(key: 'password');

    return {
      'rememberMe': rememberMe == 'true',
      'email': email,
      'password': password,
    };
  }

  // Clear saved login credentials
  Future<void> clearLoginCredentials() async {
    await SecureStorage.deleteSecureStorage(key: 'email');
    await SecureStorage.deleteSecureStorage(key: 'password');
    await SecureStorage.deleteSecureStorage(key: 'rememberMe');
  }

// sign in
  Future<void> signUpSubmit(
    context, {
    required String name,
    required String email,
    required String password,
  }) async {
    emit(LoadingAuthState());
    try {
      // create user
      await _authServices.signUpSubmit(email: email, password: password);
      // store user data
      await _userDatabaseServices.storeUserData(
        name: name,
        email: email,
      );
      emit(SendVerificationAuthState());
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      if (kDebugMode) {
        print(e);
      }
      emit(FailureFirebaseAuthExceptionState(error: messageError));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(FailureSignAuthState(error: e.toString()));
    }
  }

// Login
  Future<void> submitLogin({
    required String email,
    required String password,
  }) async {
    emit(LoadingAuthState());
    try {
      await _authServices.submitLogin(email: email, password: password);

      bool isVerified = await _authServices.verifyEmailSuccessful();

      if (!isVerified) {
        emit(FailureVerificationAuthState(
            error: "Please check your email to verify"));
        await sendVerification();
      } else {
        emit(SuccessfulLoginAuthState());
      }
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      emit(FailureFirebaseAuthExceptionState(error: messageError));
    } catch (e) {
      emit(FailureLoginAuthState(error: e.toString()));
    }
  }

// send verify
  Future<void> sendVerification() async {
    try {
      await _authServices.sendVerification();
      emit(SuccessfulSendVerificationAuthState());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(FailureVerificationAuthState(error: e.toString()));
    }
  }

// after verify successful
  Future<void> afterVerifySuccessful() async {
    try {
      final isUserVerified = await _authServices.verifyEmailSuccessful();
      print("User verification status: $isUserVerified"); // Debugging

      if (isUserVerified) {
        await _userDatabaseServices
            .createUniqueFieldOnFirestoreOnSpecificCollection(
          keyOfField: 'verified',
          valueOfField: true,
        );
        emit(SuccessfulVerificationAuthState());
        print("SuccessfulVerificationAuthState emitted"); // Debugging
      } else {
        emit(FailureVerificationAuthState(
            error: "Please check your email to verify"));
      }
    } catch (e) {
      emit(FailureVerificationAuthState(error: e.toString()));
    }
  }

// update user data
  Future updateUserData({
    String? name,
    String? email,
    String? bio,
  }) async {
    emit(LoadingAuthState());
    try {
      await _userDatabaseServices.updateUserData(
        email: email,
        name: name,
        bio: bio,
      );
      emit(SuccessfulUpdateUserDataState());
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      emit(FailureFirebaseAuthExceptionState(error: messageError));
    } catch (e) {
      emit(FailureUpdateUserDataState(e.toString()));
    }
  }

// sign in with google
  Future<void> signInWithGoogle() async {
    emit(LoadingGoogleAuthState());
    try {
      bool success = await _authServices.signInWithGoogle();
      if (success) {
        emit(WaitingSocialSignInState());
        await FirebaseAuth.instance.currentUser?.reload();
        await _userDatabaseServices
            .createUniqueFieldOnFirestoreOnSpecificCollection(
                keyOfField: 'verified', valueOfField: true);
        log('verified field updated successfully in Firestore');
        emit(SuccessfulLoginAuthState());
      } else {
        emit(CancelSocialSignInState());
      }
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      emit(FailureFirebaseAuthExceptionState(error: messageError));
      log(e.message!);
    } catch (e) {
      emit(FailureLoginAuthState(error: e.toString()));
      log(e.toString());
    }
  }

// password reset
  Future<void> passwordReset({required String email}) async {
    try {
      await _authServices.passwordReset(email: email);
      emit(SuccessfulPasswordResetState());
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      emit(FailureFirebaseAuthExceptionState(error: messageError));
    } catch (e) {
      emit(FailurePasswordResetState(error: e.toString()));
    }
  }

// log out
  Future<void> logOut() async {
    try {
      _authServices.logOut();
      emit(SuccessfulLogOutAuthState());
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.code);
      }
      String messageError = handleFirebaseException(e);
      emit(FailureFirebaseAuthExceptionState(error: messageError));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(FailureLogOutAuthState(error: e.toString()));
    }
  }

  // Re-authenticate email/password users
  Future<void> reauthenticateEmailUser(String email, String password) async {
    try {
      final user = _authServices.firebaseAuth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        emit(ReauthenticateSuccessState());
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      emit(ReauthenticateFailureState(e.code));
      throw Exception(e.code);
    } catch (e) {
      emit(ReauthenticateFailureState(e.toString()));
      throw Exception(e.toString());
    }
  }

  // Re-authenticate Google Sign-In users
  Future<void> reauthenticateGoogleUser() async {
    try {
      final user = _authServices.firebaseAuth.currentUser;
      if (user != null) {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          emit(ReauthenticateSuccessState());
        } else {
          throw Exception('Google Sign-In was canceled');
        }
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      emit(ReauthenticateFailureState(messageError));
      throw Exception(e.code);
    } catch (e) {
      emit(ReauthenticateFailureState(e.toString()));
      throw Exception(e.toString());
    }
  }

  // Delete the user's account
  Future<void> deleteUserAccount({String? email, String? password}) async {
    try {
      final user = _authServices.firebaseAuth.currentUser;
      if (user != null) {
        // Re-authenticate based on the provider
        if (user.providerData.any((info) => info.providerId == 'google.com')) {
          await reauthenticateGoogleUser();
        } else if (email != null && password != null) {
          await reauthenticateEmailUser(email, password);
        } else {}

        // Delete the user's data from Firestore
        await _userDatabaseServices.deleteCurrentUserData();

        // Delete the user's authentication account
        await user.delete();
        emit(DeleteAccountSuccessState());
      } else {}
    } on FirebaseAuthException catch (e) {
      String messageError = handleFirebaseException(e);
      emit(DeleteAccountFailureState(messageError));
    } catch (e) {
      emit(DeleteAccountFailureState(e.toString()));
    }
  }

}
