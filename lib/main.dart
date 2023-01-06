import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:face_check/screen/home/home_screen.dart';

import 'package:face_check/firebase_options.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  /// Init FirebaseApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ApplicationBasicSetting());
}

class ApplicationBasicSetting extends StatelessWidget {
  const ApplicationBasicSetting({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen()
    );
  }
}

