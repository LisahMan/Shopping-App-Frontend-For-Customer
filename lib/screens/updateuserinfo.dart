import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectx_customer_app/models/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class UpdateUserInfo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UpdateUserInfoState();
  }
}

class _UpdateUserInfoState extends State<UpdateUserInfo>{

  String _customerId;
  Customer _customer;
  GlobalKey<FormState> _updateUserInfoFormKey;
  TextEditingController _usernameController;
  TextEditingController _mobileController;
  TextEditingController _districtController;
  TextEditingController _addressController;
  TextEditingController _dateOfBirthController;
  List<String> _categories;
  String _categorySelected;
  bool _mobileNumberChanged;
  bool _sexChanged;
  DateFormat _format;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateUserInfoFormKey = new GlobalKey<FormState>();

    _usernameController = new TextEditingController();
    _mobileController = new TextEditingController();
    _districtController = new TextEditingController();
    _addressController = new TextEditingController();
    _dateOfBirthController = new TextEditingController();

    _categories = ['Female','Male','Other'];
    _categorySelected = "Female";

    _mobileNumberChanged = false;
    _sexChanged = false;

    _format = new DateFormat("yyyy-MM-dd");

    _baseUrl = "http://10.0.2.2:3000/";
    _getCustomerId();
  }

  void _getCustomerId() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
    _getCustomer();
  }

  void _getCustomer() async{
    String url = _baseUrl+"customer/"+_customerId;
    var result = await http.get(url);

    var data = jsonDecode(result.body);

    if(data['message'] == "Customer doesnt exists"){
       Toast.show("User doesnt exists", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else {
      var cust = data['customer'];
      Customer customer = new Customer(cust['_id'],cust['username'],cust['mobileNumber'],DateTime.parse(cust['dob']),cust['district'],cust['address'],cust['sex']);
      setState(() {
        _customer = customer;
        _usernameController.text=customer.username;
        _categorySelected = customer.sex;
        _mobileController.text = customer.mobileNumber;
        _dateOfBirthController.text = customer.dob.toIso8601String().substring(0,10);
        _districtController.text = customer.district;
        _addressController.text = customer.address;
      });
    }
  }

  void _updateCustomer() async{
    String url = _baseUrl+'customer/'+_customerId;
    List<Map<String,dynamic>> body = new List();

    if (_categorySelected != _customer.sex) {
      _sexChanged = true;
      body.add({"propName": "sex",
        "value": _categorySelected
      });
    }

      if (_mobileController.text.trim() != _customer.mobileNumber) {
        _mobileNumberChanged=true;
        body.add({"propName": "mobileNumber",
          "value": _mobileController.text.trim()
        });
      }

        if (_addressController.text.trim() != _customer.address) {
          body.add({"propName": "address",
            "value": _addressController.text.trim()
          });
        }

    if (_districtController.text.trim() != _customer.district) {
      body.add({"propName": "district",
        "value": _districtController.text.trim()
      });
    }

    if (_dateOfBirthController.text.trim() != _customer.dob.toIso8601String().substring(0,10)) {
      body.add({"propName": "dob",
        "value": _dateOfBirthController.text.trim()
      });
    }

    var response = await http.patch(url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(body)
    );

    var data = await jsonDecode(response.body);

    if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      Toast.show("User updated", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      if(_sexChanged||_mobileNumberChanged){
        _updateSharedPref();
      }
      else{
        Navigator.of(context).pop();
      }
    }
  }

  void _updateSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    if(_sexChanged){
      prefs.setString('sex', _categorySelected);
    }
    if(_mobileNumberChanged){
      prefs.setString('mobile_number', _mobileController.text.trim());
    }
    Navigator.of(context).pop();
  }

  Widget _buildForm(){
    return Form(
      key: _updateUserInfoFormKey,
      child: _buildFormElements(),
    );
  }

  Widget _buildFormElements(){
    return ListView(
      children: <Widget>[

        TextFormField(

          controller: _usernameController,
          enabled: false,
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
        ),



        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          controller: _mobileController,
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
        ),

        SizedBox(
          height: 10.0,
        ),

        DateTimeField(
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
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
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
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
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
                  });
                },
              ),
            ],
          ),
        ),

        SizedBox(
          height: 30.0,
        ),

        Container(
          height: 50.0,
          width: 200.0,

          child: RaisedButton(

            child: Text("Update"),
            onPressed: (){
             if(_updateUserInfoFormKey.currentState.validate()){
               _updateCustomer();
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
      appBar: AppBar(
        centerTitle: true,
        title: Text("update user info"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildForm(),
        ),
      ),
    );
  }
}