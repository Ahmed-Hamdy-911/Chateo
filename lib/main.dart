import 'package:chateo/constants/constants.dart';
import 'package:chateo/views/home/home_view.dart';
import 'package:chateo/views/walkthrough/walkthrough_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/auth_cubit/auth_cubit.dart';
import 'cubits/bloc_observer.dart';
import 'cubits/timer_cubit/timer_cubit.dart';
import 'firebase_options.dart';
import 'services/user_database_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => TimerCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Chateo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kMainColor),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: _returnPageForStart(),
      ),
    );
  }

  Widget _returnPageForStart() {
    Widget widget;
    if (UserDatabaseServices().currentUser != null &&
        UserDatabaseServices().isVerify) {
      widget = const HomeView();
    } else {
      widget = const WalkthroughScreen();
    }
    return widget;
  }
}
