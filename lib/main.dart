import 'package:flutter/material.dart';

import 'pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Douban",
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginPage(),
    );
    
  }
}
