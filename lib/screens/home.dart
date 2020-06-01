import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectx_customer_app/screens/content.dart';
import 'package:projectx_customer_app/screens/category.dart';
import 'package:projectx_customer_app/screens/search.dart';
import 'package:projectx_customer_app/screens/settings.dart';
import 'package:projectx_customer_app/screens/shopliked.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home>{

  int _selectedIndex = 0;

  var _pages = [
    Content(),
    Category(),
    Search(),
    ShopLiked(),
    Settings(),
  ];



  void _logOut() async{
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('customer_id');
  prefs.remove('username');
  prefs.remove('mobile_number');
  prefs.remove('sex');
  prefs.setBool('logged_in', false);
  Navigator.of(context).pushNamedAndRemoveUntil('/start', (Route<dynamic> route) => false);
  }

  void _onNavItemTapped(int index){
    setState(() {
      _selectedIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(

        items: <BottomNavigationBarItem>[

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home")
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            title: Text("Category")
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            title: Text("Liked"),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Setting")
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purpleAccent,
        onTap: _onNavItemTapped,
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,

      ),

      body: _pages[_selectedIndex]
    );
  }
}