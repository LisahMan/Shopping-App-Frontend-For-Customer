import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp>{

  GlobalKey<FormState> _signUpFormKey;
  GlobalKey<ScaffoldState> _signUpScaffoldKey;
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;
  TextEditingController _mobileController;
  TextEditingController _districtController;
  TextEditingController _addressController;
  TextEditingController _dateOfBirthController;

  FocusNode _passwordNode;
  FocusNode _confirmPasswordNode ;
  FocusNode _mobileNode;
  FocusNode _districtNode ;
  FocusNode _addressNode ;
  FocusNode _dateOfBirthNode;

  List<String> _categories;
  String _categorySelected;

  DateFormat _format;

  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _signUpFormKey = new GlobalKey<FormState>();
    _signUpScaffoldKey = new GlobalKey<ScaffoldState>();

    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
    _confirmPasswordController = new TextEditingController();
    _mobileController = new TextEditingController();
    _districtController = new TextEditingController();
    _addressController = new TextEditingController();
    _dateOfBirthController = new TextEditingController();

    _categories = ['Female','Male','Other'];
    _categorySelected = "Female";

    _format = new DateFormat("yyyy-MM-dd");


    _passwordNode = new FocusNode();
    _confirmPasswordNode = new FocusNode();
    _mobileNode = new FocusNode();
    _districtNode = new FocusNode();
    _addressNode = new FocusNode();
    _dateOfBirthNode = new FocusNode();

    _baseUrl = "http://10.0.2.2:3000/";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mobileNode.dispose();
    _addressNode.dispose();
    _dateOfBirthNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    _districtNode.dispose();
    super.dispose();
  }

  void _setSignUpData(String id,String username,String mobileNumber,String sex) async{
   final prefs = await SharedPreferences.getInstance();
   prefs.setString('customer_id', id);
   prefs.setString('username', username);
   prefs.setString('mobile_number', mobileNumber);
   prefs.setString('sex',sex);
   prefs.setBool('logged_in', true);
  }

  void _postSignUpData() async{

    String date = _dateOfBirthController.text;
    debugPrint('date : $date');
    Map<String,dynamic> body = {'username' : _usernameController.text , 'password' : _passwordController.text,'mobileNumber' : _mobileController.text,'dob' : _dateOfBirthController.text,'district' : _districtController.text,'address' : _addressController.text,'sex' : _categorySelected};
    String url = _baseUrl+"customer/signup";

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    var data = jsonDecode(response.body);
    var res = data.toString();
    debugPrint('$res');


    if(data['message']=="Username already exists"){
      final _snackBar = SnackBar(content: Text("That username is already taken,Please try another username",));
      _signUpScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error']!=null){
      final _snackBar = SnackBar(content: Text("Some error occured please try again",));
      _signUpScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else{
      _setSignUpData(data['_id'], data['username'], data['mobileNumber'],data['sex']);
      Navigator.of(context).pushNamedAndRemoveUntil('/home',(Route<dynamic> route) => false );
    }
  }

  Widget _buildForm(){
    return Form(
        key: _signUpFormKey,
        child: _buildFormElements()
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

          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_mobileNode),


        ),



        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          controller: _mobileController,
          focusNode: _mobileNode,
          keyboardType: TextInputType.phone,
          validator: (value){
            if(value.isEmpty){
              return "Please enter your mobile number";
            }
            else if(value.length<10){
              return "Mobile number should be of length 10 ";
            }
          },

          decoration: InputDecoration(
              labelText: "Mobile Number",
              hintText: "9873894736",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )

          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_dateOfBirthNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        DateTimeField(
          focusNode: _dateOfBirthNode,
          format: _format,
          controller: _dateOfBirthController,
          validator: (value){
            if(value==null){
              return "Please enter your date of birth";
            }
          },
          decoration: InputDecoration(
              labelText: "Date of Birth",
              hintText: "1990-09-18",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )

          ),
          onShowPicker: (context,currentValue){
            return showDatePicker(
              context: context,
              initialDate: currentValue ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),);
          },
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_districtNode),

        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _districtNode,
          controller: _districtController,
          validator: (value){
            if(value.isEmpty){
              return ("Please enter your district");
            }
          },

          decoration: InputDecoration(
              labelText: "Current District",
              hintText: "Kathmandu",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),

          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_addressNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _addressNode,
          controller: _addressController,
          validator: (value){
            if(value.isEmpty){
              return ("Please enter your address");
            }
          },

          decoration: InputDecoration(
              labelText: "Current Address",
              hintText: "New Road",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Row(
            children: <Widget>[

              Text("Sex",style: TextStyle(fontSize: 20.0),),

              SizedBox(width: 20.0,),

              DropdownButton(
                items: _categories.map((String categoriesString){
                  return DropdownMenuItem<String>(
                    value: categoriesString,
                    child: Text(categoriesString),
                  );
                }).toList(),

                value: _categorySelected,
                onChanged: (newCategorySelected){
                  setState(() {
                    _categorySelected=newCategorySelected;
                    debugPrint("$_categorySelected");

                  });
                },


              ),


            ],
          ),
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
              return "Please enter your Password";
            }
            else if(value.length<8){
              return "Password should be of 8 characters";
            }
          },

          decoration: InputDecoration(
              labelText: "Password",
              hintText: "********",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_confirmPasswordNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _confirmPasswordNode,
          controller: _confirmPasswordController,
          obscureText: true,
          validator: (value){
            if(value.isEmpty){
              return "Please confirm your password ";
            }
            else if(_passwordController.text.isNotEmpty){
              if(_passwordController.text != value){
                return "Password doesn't match";
              }
            }
          },

          decoration: InputDecoration(
              labelText: "Confirm Password",
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

            child: Text("Sign Up"),
            onPressed: (){

              if(_signUpFormKey.currentState.validate()){
                debugPrint("SignUp");
                _postSignUpData();
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
      key: _signUpScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sign Up"),
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