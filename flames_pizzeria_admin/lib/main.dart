import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCASEsnKuSSsGhI_pjJuaWDJynJEGlD2Vc",
          appId: "1:32047911548:web:fd453b5c19dcfc4e86eff9",
          messagingSenderId: "32047911548",
          projectId: "flames-pizzeria",
          storageBucket: "gs://flames-pizzeria.appspot.com"
      )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flames Pizzeria Admin",
      home: SignIn(),
      // home: Orders(),
    );
  }
}