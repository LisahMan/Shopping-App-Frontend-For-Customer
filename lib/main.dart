import 'package:flutter/material.dart';
import 'package:projectx_customer_app/screens/shopproduct.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectx_customer_app/screens/start.dart';
import 'package:projectx_customer_app/screens/home.dart';
import 'package:projectx_customer_app/screens/loading.dart';
import 'package:projectx_customer_app/screens/signup.dart';
import 'package:projectx_customer_app/screens/login.dart';
import 'package:projectx_customer_app/screens/productinfo.dart';
import 'package:projectx_customer_app/screens/bag.dart';
import 'package:projectx_customer_app/screens/shopinfo.dart';
import 'package:projectx_customer_app/screens/shopproduct.dart';
import 'package:projectx_customer_app/screens/productfilter.dart';
import 'package:projectx_customer_app/screens/categorytypeproduct.dart';
import 'package:projectx_customer_app/screens/shopfilter.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:projectx_customer_app/screens/trending.dart';
import 'screens/categorytypefilter.dart';
import 'package:projectx_customer_app/screens/resetpassword.dart';
import 'package:projectx_customer_app/screens/updateuserinfo.dart';


void main()=>runApp(MainScreen());

class MainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen>{

  Widget screen = Loading() ;

  void _setScreen() async{
    final prefs = await SharedPreferences.getInstance();

    if(prefs.getBool('logged_in')!=null){
      if(prefs.getBool('logged_in')){
        setState(() {
          screen = Home();
        });
      }
      else{
        setState(() {
          screen = Start();
        });

      }
    }
    else{
      setState(() {
        screen = Start();
      });

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setScreen();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Customer App",

      routes: <String,WidgetBuilder>{
        '/start' : (context) => Start(),
        '/login' : (context) => Login(),
        '/signUp' : (context) => SignUp(),
        '/home' : (context) => Home(),
        '/bag' : (context) => Bag(),
        '/resetPassword' : (context) => ResetPassword(),
        '/updateUserInfo' : (context) => UpdateUserInfo()
      },

      onGenerateRoute: (settings){
        if(settings.name == '/categoryTypeProduct'){
          final ProductArg args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return CategoryTypeProduct(args.category,args.typeOfProduct);
            }
          );
        }
        else if(settings.name == '/productInfo'){
          final ProductArg args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return ProductInfo(args.product,args.calledFrom);
            }
          );
        }
        else if(settings.name == '/shopInfo'){
          final ShopArg args = settings.arguments;
          return MaterialPageRoute(
            builder : (context){
              return ShopInfo(args.shopId,args.shopInfoList);
            }
          );
        }
        else if(settings.name == '/shopProduct'){
          final ShopArg args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return ShopProduct(args.shopId,args.category,args.typeOfProduct,args.calledFrom);
            }
          );
        }
        else if(settings.name == '/productFilter'){
          final List<String> args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return ProductFilter(args);
            }
          );
        }

        else if(settings.name == '/categoryTypeFilter'){
          final List<String> args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return CategoryTypeFilter(args);
            }
          );
        }
        else if(settings.name == '/shopFilter'){
          final List<String> args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return ShopFilter(args);
            }
          );
        }
        else if(settings.name == '/trending'){
          final String args = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return Trending(args);
            }
          );
        }
      },


      home: screen,

    );
  }
}