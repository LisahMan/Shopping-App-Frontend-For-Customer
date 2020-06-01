import 'package:flutter/material.dart';
import 'package:projectx_customer_app/models/product.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_customer_app/models/shop.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ShopInfo extends StatefulWidget{

  final String _shopId;
  final List<int> _shopInfoList;
  ShopInfo(this._shopId,this._shopInfoList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShopInfoState(this._shopId,this._shopInfoList);
  }
}

class _ShopInfoState extends State<ShopInfo>{

  _ShopInfoState(this._shopId,this._shopInfoList);

  final String _shopId;
  Shop _shop;
  List<int> _shopInfoList;
  GlobalKey<ScaffoldState> _shopInfoScaffoldState;
  String _customerId;
  bool liked;
  String _baseUrl;
  String _sex;
  List<Product> _trendingProductsList;
  List<String> _days;
  List<String> _openingTime;
  List<String> _closingTime;
  bool _showTiming;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _shopInfoScaffoldState = new GlobalKey<ScaffoldState>();
    liked = false;
    _baseUrl = "http://10.0.2.2:3000/";
    _sex = "";
    _days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    _openingTime = new List();
    _closingTime = new List();
    _showTiming=false;
    _getCustomerDetails();
  }

  void _getCustomerDetails() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
    _sex = prefs.getString('sex');
    _getShop();
  }

  void _getShop() async{

    String url = _baseUrl+"shopview";
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    debugPrint("customer" + _customerId);
    debugPrint("date :"+date);
    Map<String,dynamic> body = {
      'customerId' : _customerId,
      'shopId' : _shopId,
      'sex' : _sex,
      'date' : date
    };

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    var data = jsonDecode(response.body);

     if(data['error']!=null){
       debugPrint(data['error'].toString());
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      if(data['shopliked']=="yes"){
        setState(() {
          liked = true;
        });
      }
      else if(data['shopliked']=="no"){
        setState(() {
          liked = false;

        });
      }


      var sh = data['shop'];

      for(var t in sh['timings']){
          _openingTime.add(t['opening']);
          _closingTime.add(t['closing']);
      }

      Shop shop = new Shop(sh['_id'],sh['name'],sh['district'],sh['address'],sh['phoneNumber'],sh['shopPic'],sh['description'],DateTime.parse(sh['date']),sh['views']);
      setState(() {
        _showTiming=true;
        _shop = shop;
      });

      if(data['trendingProducts']!="No trending products"){
        List<Product> trendingProductsList = new List();
        for(var d in data['trendingProducts']){
          var p = d['product'];
          var s = p['shop'];
          Product product = new Product(p['_id'],p['name'],s['_id'],s['name'], p['category'],p['typeOfProduct'],p['price'],p['negotiable'],p['color'],p['size'],p['description'],DateTime.parse(p['date']),p['productImages'],p['views']);
          trendingProductsList.add(product);
        }
        setState(() {
          _trendingProductsList=trendingProductsList;
        });
      }
    }
  }

  void _shopLike() async{
    if(!liked){
      String url = _baseUrl+"shopliked/";
      Map<String,dynamic> body = {'customerId' : _customerId,'shopId' : _shopId,'date' : DateTime.now().toIso8601String()};
      var response = await http.post(url,
          headers: {
            "Accept" : "application/json",
            "Content-Type" : "application/json"
          },
          body: json.encode(body)
      );
      var data = json.decode(response.body);

      if(data['message']=="Shop already liked"){
        Toast.show("Shop is already liked", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else if(data['error']!=null){
        Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else{
        setState(() {
          liked=true;
        });
      }
    }else if(liked){
      String url = _baseUrl+"shopliked/"+_customerId+"/"+_shopId;
      var response = await http.delete(url);
      var data = jsonDecode(response.body);
      if(data['error']!=null){
        Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }else{
        setState(() {
          liked=false;
        });
      }
    }

  }


  Future<bool> _onWillScope() async{
    if(_shopInfoList!=null){
      if(liked){
        _shopInfoList[1] = 1;
      }
      else{
        _shopInfoList[1] = 0;
      }
    }
//    Navigator.of(context).pop(_shopInfoList);
    Navigator.of(context).pop();
    return false;
  }

  Widget _buildListViewAllElements(){
    return ListView(
        children: <Widget>[

        SizedBox(
        height: 200.0,
        width: 400.0,
        child: (_shop.shopPic==null)
        ? Text("No Image",style: TextStyle(fontSize: 20.0,color: Colors.black),)
        : Container(
      height: 200.0,
      width: 400.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(_baseUrl+"uploads/" + _shop.shopPic.toString().split('\\')[1]),
              fit: BoxFit.fill

          )
      ),
    ),
    ),


    SizedBox(
    height: 5.0,
    ),

    Card(
    elevation: 5.0,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[

    Row(
    children: <Widget>[
    Expanded(
    child:  Text(_shop.shopName,style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),),
    ),

    GestureDetector(
    child: (!liked)
    ?Icon(Icons.save,color: Colors.grey,size: 35.0,)
        :Icon(Icons.save,color: Colors.red,size: 35.0,),
    onTap: (){
    _shopLike();
    },
    )

    ],
    ),


    SizedBox(
    height: 2.0,
    ),

    Text("District :"+_shop.district,style: TextStyle(fontSize: 20.0),),

    SizedBox(
    height: 2.0,
    ),

    Text("Location : "+_shop.address,style: TextStyle(fontSize: 20.0),),

    SizedBox(
    height: 2.0,
    ),

    Text("Phone Number : "+_shop.phoneNumber,style: TextStyle(fontSize: 20.0),),

    SizedBox(
    height: 2.0,
    ),

    Text("Description : "+_shop.description,style: TextStyle(fontSize: 20.0),),

      SizedBox(
        height: 2.0,
      ),

      (_showTiming==true)? _buildTimingExpansionTile()
          : Text("Loading"),
    ],
    ),
    ),



    SizedBox(
      height: 10.0,
    ),

    Container(
    width: 300.0,
    height: 40.0,
    child: RaisedButton(
    child: Text("View Products",style: TextStyle(fontSize: 20.0),),
    onPressed: (){
    Navigator.of(context).pushNamed('/shopProduct',arguments: ShopArg(shopId: this._shop.shopId,calledFrom: "shopInfo"));
    },
    )
    ),

    SizedBox(
      height: 20.0,
    ),

    Text(
      "Trending " + _sex + " products",
      style: TextStyle(fontSize: 20.0),
    ),

    SizedBox(
      height: 10.0,
    ),

    _buildTrendingProductGridView()

    ]);
  }

  Widget _buildTimingExpansionTile(){
    return ExpansionTile(
        title: Text("Timings"),
        children: _buildTileElements()
    );
  }

  List<Widget> _buildTileElements(){
    List<Widget> widgets = new List();
    for(int i=0;i<7;i++){
      widgets.add(Row(
        children: <Widget>[

          Text(_days[i],style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),

          SizedBox(
            width: 10.0,
          ),

          Text("Opening:",style: TextStyle(fontSize: 15.0),),

          SizedBox(
            width: 10.0,
          ),

          Text(_openingTime[i],style: TextStyle(fontSize: 15.0)),


          SizedBox(
            width: 10.0,
          ),

          Text("Closing:",style: TextStyle(fontSize: 15.0)),

          SizedBox(
            width: 10.0,
          ),

          Text(_closingTime[i],style: TextStyle(fontSize: 15.0)),
        ],
      ));
    }
    return widgets;
  }

  Widget _buildTrendingProductGridView(){
   return (_trendingProductsList==null || _trendingProductsList.length==0)
          ? Text("No trending products")
          : GridView.builder(
//         controller: _scrollController,
         shrinkWrap: true,
         physics: NeverScrollableScrollPhysics(),
         itemCount: _trendingProductsList.length,
         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 2.0,mainAxisSpacing: 2.0,childAspectRatio: MediaQuery.of(context).size.height / 1200),
         itemBuilder: (context,position){
           return _buildSingleProduct(position);
         });
  }

  Widget _buildSingleProduct(int position){
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product: _trendingProductsList[position],calledFrom: "shopinfo"));
      },
      child:  Card(
          elevation: 5.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(_trendingProductsList[position].name,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),

              SizedBox(height: 2.0,),

              Text(_trendingProductsList[position].shopName),

              SizedBox(height: 3.0,),

              Container(
                height: 200.0,
                width: 200.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(_baseUrl+"uploads/" + _trendingProductsList[position].productImages[0].toString().split('\\')[1]),
                        fit: BoxFit.fill

                    )
                ),
              )
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onWillScope,
      child:   Scaffold(
        key: _shopInfoScaffoldState,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Shop"),
        ),

        body: Center(
        child:  Padding(
    padding: EdgeInsets.all(10.0),
    child: (_shop==null)
    ? Text("Loading")
        : _buildListViewAllElements(),
    ),
        )
      )
    );
  }
}