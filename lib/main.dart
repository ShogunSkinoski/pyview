import 'package:flutter/material.dart';

import 'package:pyview/ui/home_page.dart';

Future<void> main() async {
  String apiKey = "AIzaSyBcuMK_su_aMuoCP8jjI-lAaNiykyappNU";

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PyView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
