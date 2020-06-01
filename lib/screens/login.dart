import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<Login>{

  GlobalKey<FormState> _loginFormKey;
  GlobalKey<ScaffoldState> _loginScaffoldKey;
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  FocusNode _passwordNode;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loginFormKey = new GlobalKey<FormState>();
    _loginScaffoldKey = new GlobalKey<ScaffoldState>();
    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
    _passwordNode= new FocusNode();
    _baseUrl = "http://10.0.2.2:3000/";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _passwordNode.dispose();
    super.dispose();
  }

  void _setLoginData(String id,String username,String mobileNumber,String sex) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('customer_id', id);
    prefs.setString('username', username);
    prefs.setString('mobile_number', mobileNumber);
    prefs.setString('sex',sex);
    prefs.setBool('logged_in', true);
  }


  void _postLoginData() async{
    Map<String,dynamic> body = {'username' : _usernameController.text,'password' : _passwordController.text};
    String url = _baseUrl+'customer/login/';

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    var data = jsonDecode(response.body);

    debugPrint('$data');

    if(data['message']=="Auth failed"){
      SnackBar _snackBar = SnackBar(content: Text("Please enter your details correctly"),);
      _loginScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error']!=null){
      SnackBar _snackBar = SnackBar(content: Text("Some error occured try again"),);
      _loginScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else{
      _setLoginData(data['_id'], data['username'], data['mobileNumber'],data['sex']);
      Navigator.of(context).pushNamedAndRemoveUntil('/home',(Route<dynamic> route) => false );
    }
  }

  Widget _buildForm(){
    return Form(
        key: _loginFormKey,
        child: _buildFormElements(),
    );
  }

  Widget _buildFormElements(){
    return ListView(
      children: <Widget>[

        TextFormField(
          controller: _usernameController,
          validator: (value){
            if(value.isEmpty){
              return ("Please enter your username");
            }
          },

          decoration: InputDecoration(
              labelText: "Username",
              hintText: "Ram_Sharma",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_passwordNode),
        ),


        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _passwordNode,
          controller: _passwordController,
          obscureText: true,
          validator: (value){
            if(value.isEmpty){
              return "Please enter your password";
            }
          },

          decoration: InputDecoration(
              labelText: "Password",
              hintText: "********",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
        ),

        SizedBox(
          height: 30.0,
        ),

        Container(
          height: 50.0,
          width: 200.0,
          child: RaisedButton(
            child: Text("Login"),
            onPressed: (){
              if(_loginFormKey.currentState.validate()){
                debugPrint("Login");
                _postLoginData();
              }
            },
          ),
        )



      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _loginScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildForm(),
        ),
      )
    );
  }
}