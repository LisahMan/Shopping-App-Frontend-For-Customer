import 'package:flutter/material.dart';

class Start extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 200.0),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[

                Text("Customer App"),

                SizedBox(
                  height: 50.0,
                ),

                Container(
                  height: 50.0,
                  width: 150.0,
                  child: RaisedButton(
                    child: Text("Login"),
                    onPressed: (){
                      Navigator.of(context).pushNamed('/login');
                    },
                  ),
                ),

                SizedBox(
                  height: 20.0,
                ),

                Container(
                  height: 50.0,
                  width: 150.0,
                  child: RaisedButton(
                    child: Text("Sign Up"),
                    onPressed: (){
                      Navigator.of(context).pushNamed('/signUp');
                    },
                  ),
                )

              ],
            ),
          ),
        ),
      )
    );
  }
}