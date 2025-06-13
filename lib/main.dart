import 'package:arriendapp/screens/CreatePropertyPage.dart';
import 'package:arriendapp/screens/FeedPage.dart';
import 'package:arriendapp/screens/LoginPage.dart';
import 'package:arriendapp/screens/MyPropertiesPage.dart';
import 'package:arriendapp/screens/PasswordForget.dart';
import 'package:arriendapp/screens/ProfilePage.dart';
import 'package:arriendapp/screens/PropertyDetailPage.dart';
import 'package:arriendapp/screens/RegisterPage.dart';
import 'package:arriendapp/screens/SolicityArrPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArriendApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue.shade600, 
        brightness: Brightness.light,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginPage(),
        "/Register":  (context) => const RegisterPage(),
        "/Feed": (context) => const FeedPage(),
        "/CreateProperty": (context) => const Createpropertypage(),
        "/SolicityArr": (context) => const Solicityarrpage(),
        "/myProperties": (context) => const Mypropertiespage(),
        "/MyProfile": (context) => const ProfilePage(),
        "/PasswordForget": (context) => const PasswordForgetPage()
      },
    );
  }
}
