import 'package:txa/components/bottombar.dart';
import 'package:txa/components/login.dart';
import 'package:txa/components/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String isLogin = prefs.getString('login');
  String token = prefs.getString('token');
  print(isLogin);

  runApp(
    isLogin == 'true'
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DIKA E-Regist',
            routes: {"/submit-page": (_) => Home()},
            home: FancyBottomBarPage(),
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DIKA E-Regist',
            routes: {"/submitPage": (_) => Home()},
            home: Login(),
          ),
  );
}

// class MyApp extends StatefulWidget {
//   // This widget is the root of your application.

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String name, nip;

//   SharedPreferences prefs;
//   Widget _toChoose;

//   @override
//   void initState() {
//     super.initState();
//     //_test();
//   }

//   Future _test() async {
//     prefs = await SharedPreferences.getInstance();
//     name = prefs.getString('inputName');
//     nip = prefs.getString("inputNip");

//     if (name != null && nip != null) {
//       setState(() {
//         print("Has value");
//         _toChoose = SubmitPage();
//       });
//     } else {
//       print("No value");
//       setState(() {
//         _toChoose = Login();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//           primarySwatch: Colors.red, textTheme: GoogleFonts.ralewayTextTheme()),
//       home: Login(),
//     );
//   }
// }
