import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingState();
  }
}

class _SettingState extends State<Settings>{

  void _logOut() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('customer_id');
    prefs.remove('username');
    prefs.remove('mobile_number');
    prefs.remove('sex');
    prefs.setBool('logged_in', false);
    Navigator.of(context).pushNamedAndRemoveUntil('/start', (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Settings"),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[

            RaisedButton.icon(
              icon : Icon(Icons.account_circle),
              label : Text("Update user Info"),
              onPressed: (){
                Navigator.of(context).pushNamed('/updateUserInfo');
              },
            ),

            RaisedButton.icon(
                icon: Icon(Icons.keyboard),
                label: Text("Reset password"),
                onPressed: (){
                  Navigator.of(context).pushNamed('/resetPassword');
                },
            ),

            RaisedButton.icon(
              icon: Icon(Icons.power_settings_new),
              label: Text("Log out"),
               onPressed: (){
              _logOut();
            }
           )
          ]
        )



      ),
    );
  }
}