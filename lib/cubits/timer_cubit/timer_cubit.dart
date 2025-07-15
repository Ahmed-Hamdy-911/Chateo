import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'timer_states.dart';

class TimerCubit extends Cubit<TimerStates> {
  TimerCubit() : super(TimerInitialState());

  Timer? _timer;
  late int start;
  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    emit(TimerTickingState());
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          emit(TimerFinishedState());
          _timer!.cancel();
        } else {
          start--;
          emit(TimerTickingState());
        }
      },
    );
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      emit(TimerCanceledState());
    }
  }

  void resetTimer(int seconds) {
    cancelTimer(); // Cancel any ongoing timer
    start = seconds;
    startTimer(); // Start the timer again with the new time
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
