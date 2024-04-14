import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:taskmgmt/screens/signin_screen.dart';


import 'globalVar.dart';
import 'HiveStruct/TaskStruct.dart';
import 'myHomePage.dart';



void main() async{
  // Initializations
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskStructAdapter());

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(ProviderScope(child: MyApp(savedThemeMode: savedThemeMode),));
}

bool isDark = false;


class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    isDark = savedThemeMode?.isDark ?? AdaptiveThemeMode.system.isDark;

    return AdaptiveTheme(
        light: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        dark: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orangeAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.system,
        builder: (theme, darkTheme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tasky',
            theme: theme,
            darkTheme: darkTheme,
            home: AuthenticationWrapper(),//const MyHomePage(title: 'Tasky'),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        }
    );
  }

}



class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Check if a user is already signed in when the app starts
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      taskBox = await Hive.openBox<TaskStruct>('${user.email}');
      // User is signed in, navigate to home screen
      Future.microtask(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Tasky',)));

      });
    } else {
      // User is not signed in, navigate to login screen
      Future.microtask(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignInScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder widget until authentication check is completed
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}