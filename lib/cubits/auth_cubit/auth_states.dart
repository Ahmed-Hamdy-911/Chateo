abstract class AuthStates {}

class InitialAuthState extends AuthStates {}

class TogglePasswordVisibilityState extends AuthStates {}

class ToggleConfirmPasswordVisibilityState extends AuthStates {}

class LoadingAuthState extends AuthStates {}

class LoadingGoogleAuthState extends AuthStates {}

class FailureFirebaseAuthExceptionState extends AuthStates {
  final String error;

  FailureFirebaseAuthExceptionState({required this.error});
}

class FailureSignAuthState extends AuthStates {
  final String error;

  FailureSignAuthState({required this.error});
}

class SuccessfulLoginAuthState extends AuthStates {}

class FailureLoginAuthState extends AuthStates {
  final String error;

  FailureLoginAuthState({required this.error});
}

class CancelSocialSignInState extends AuthStates {}

class WaitingSocialSignInState extends AuthStates {}

class SendVerificationAuthState extends AuthStates {}

class SuccessfulSendVerificationAuthState extends AuthStates {}

class SuccessfulVerificationAuthState extends AuthStates {}

class FailureVerificationAuthState extends AuthStates {
  final String error;

  FailureVerificationAuthState({required this.error});
}

class SuccessfulLogOutAuthState extends AuthStates {}

class FailureLogOutAuthState extends AuthStates {
  final String error;
  FailureLogOutAuthState({required this.error});
}

class SuccessfulStoreUserDataAuthState extends AuthStates {}

class FailureStoreUserDataAuthState extends AuthStates {
  final String error;

  FailureStoreUserDataAuthState({required this.error});
}

class SuccessfulPasswordResetState extends AuthStates {}

class FailurePasswordResetState extends AuthStates {
  final String error;

  FailurePasswordResetState({required this.error});
}

class SuccessfulUpdateUserDataState extends AuthStates {}

class FailureUpdateUserDataState extends AuthStates {
  final String? error;

  FailureUpdateUserDataState(this.error);
}

class ToggleRememberMeState extends AuthStates {}

class DeleteAccountSuccessState extends AuthStates {}

class ReauthenticateSuccessState extends AuthStates {}

class ReauthenticateFailureState extends AuthStates {
  final String? error;

  ReauthenticateFailureState(this.error);
}

class DeleteUserDataSuccessState extends AuthStates {}

class DeleteAccountFailureState extends AuthStates {
  final String? error;

  DeleteAccountFailureState(this.error);
}
