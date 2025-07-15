abstract class ChatStates {}

class InitialChatState extends ChatStates {}

class LoadingState extends ChatStates {}

class SuccessfulSendMessageState extends ChatStates {}

class FailedSendMessageState extends ChatStates {
  final String? errorText;

  FailedSendMessageState(this.errorText);
}

class SendMessageWithNoInternetState extends ChatStates {
  final String? errorText;
  SendMessageWithNoInternetState(this.errorText);
}

class SuccessfulDeleteMessageState extends ChatStates {}
