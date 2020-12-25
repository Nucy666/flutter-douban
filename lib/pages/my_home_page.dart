import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'person_center_page.dart';

class MyHomePage extends StatefulWidget {
  State createState() {
    return _myHomePageState();
  }
}

class _myHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<BottomNavigationBarItem> bottomNavigationBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('主页')),
    BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我的'))
  ];

  final pages = [HomePage(), PersonalCenter()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavigationBarItems,
        currentIndex: _selectedIndex,
        fixedColor: Colors.green,
        onTap: (int index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  
}
