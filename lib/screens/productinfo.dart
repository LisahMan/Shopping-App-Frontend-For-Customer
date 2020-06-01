import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_customer_app/models/product.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:toast/toast.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:intl/intl.dart';

class ProductInfo extends StatefulWidget{

  final Product _product;
  final String _calledFrom;

  ProductInfo(this._product,this._calledFrom);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductInfoState(this._product,this._calledFrom);
  }
}

class _ProductInfoState extends State<ProductInfo>{

  _ProductInfoState(this._product,this._calledFrom);

  final Product _product;
  final String _calledFrom;
  String _customerId;


  GlobalKey<ScaffoldState> _productInfoScaffoldKey;
  String _baseUrl;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   _productInfoScaffoldKey = new GlobalKey<ScaffoldState>();
   _baseUrl = "http://10.0.2.2:3000/";
   _getCustomerId();
  }


  void _getCustomerId() async{
    final prefs = await SharedPreferences.getInstance();
      _customerId = prefs.getString('customer_id');
      _postProductView();
  }

  void _postProductView() async{

    String url = _baseUrl+"productview";
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    debugPrint("date :"+date);
    Map<String,dynamic> body = {'customerId' : _customerId,'productId' : _product.productId,'date' : date};

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );
  }

  void _addToBag() async{

    Map<String,dynamic> body = {'customerId' : _customerId,'productId' : _product.productId,'date' : DateTime.now().toIso8601String()};
    String url = _baseUrl+'bag/';

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    var data = jsonDecode(response.body);
    debugPrint(response.statusCode.toString());
    debugPrint(data.toString());

      if(data['message']=="Product is already in bag"){
        Toast.show("Product already added in bag", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else if(data['error']!=null){
        Toast.show("Some error occured try again",context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else{
        Toast.show("Product added to bag", context,duration : Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
  }

  Widget _buildColumnAllElements(){
    return  Column(
      children: <Widget>[
       _buildProductInfoWindow(),
       _buildAddToBagButton()
      ],
    );
  }

  Widget _buildProductInfoWindow(){
    return   Expanded(
      child: ListView(
        children: <Widget>[

          SizedBox(
            width: 500.0,
            height: 300.0,
            child: Carousel(
              images: _product.productImages.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      height: 300.0,
                      width: 500.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(_baseUrl+"uploads/" + i.toString().split('\\')[1]),
                              fit: BoxFit.fill

                          )
                      ),
                    );
                  },
                );
              }).toList(),
              dotBgColor: Colors.white.withOpacity(0.2),
              autoplay: false,

            ),
          ),

          SizedBox(
            height: 10.0,
          ),

          Card(
              elevation: 5.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text(_product.name,style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold),),

                  SizedBox(
                    height: 2.0,
                  ),

                  FlatButton(
                    child: Text(_product.shopName,style: TextStyle(fontSize: 20.0),),
                    onPressed: (){
                      if(_calledFrom!="shopproduct"){
                        Navigator.of(context).pushNamed('/shopInfo',arguments: ShopArg(shopId: _product.shopId));
                      }
                    },
                  ),


                  SizedBox(
                    height: 5.0,
                  ),

                  Row(
                    children: <Widget>[
                      Text("Rs. " + _product.price.toString(),style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold)),

                      SizedBox(
                        width: 20.0,
                      ),

                      SizedBox(
                        width: 100.0,
                        child: (_product.negotiable==true)
                            ? Text("Fixed Price",style: TextStyle(fontSize: 20.0),)
                            : Text("Negotiable",style: TextStyle(fontSize: 20.0),),
                      ),
                    ],
                  )

                ],
              )
          ),

          SizedBox(
            height: 10.0,
          ),

          Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Category",style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold),),

                SizedBox(
                  height: 10.0,
                ),

                Text(_product.category,style: TextStyle(fontSize: 25.0),),

                SizedBox(
                  height: 5.0,
                ),

                Text(_product.typeOfProduct,style: TextStyle(fontSize: 20.0),)
              ],
            ) ,
          ),

          SizedBox(
            height: 10.0,
          ),

          Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[

                    Text("Colors :",style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold)),

                    SizedBox(
                      width: 2.0,
                    ),

                    Expanded(
                      child: Text(_product.color,style: TextStyle(fontSize: 30.0),),
                    )
                  ],
                ),

                SizedBox(
                  height: 5.0,
                ),

                Row(
                  children: <Widget>[
                    Text("Sizes :",style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold)),


                    SizedBox(
                      width: 2.0,
                    ),

                    Expanded(
                      child: Text(_product.size,style: TextStyle(fontSize: 30.0),),
                    )
                  ],
                )
              ],
            ),
          ),

          SizedBox(
            height: 10.0,
          ),

          Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Description",style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold),),

                SizedBox(
                  height: 5.0,
                ),

                Text(_product.description,style: TextStyle(fontSize: 25.0),)
              ],
            ),
          ),

          _buildViewMoreWindow()

        ],
      ),
    );
  }

  Widget _buildViewMoreWindow(){
    return Visibility(
      visible: _calledFrom!="shopproduct",
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Visibility(
              visible: _calledFrom!="shopinfo",
              child: Container(
                height: 30.0,
                width: 300.0,
                child: FlatButton(
                  child: Text("View " + _product.shopName,
                    style: TextStyle(color: Colors.blue,fontSize: 15.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  onPressed: (){
                    Navigator.of(context).pushNamed('/shopInfo',arguments: ShopArg(shopId : _product.shopId));
                  },
                ),
              ),
            ),

            SizedBox(
              height: 5.0,
            ),

            Container(
              height: 30.0,
              width: 300.0,
              child: FlatButton(
                child: Text("View more "+_product.category + " " +_product.typeOfProduct +" from "+_product.shopName,
                  style: TextStyle(color: Colors.blue,fontSize: 15.0),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                onPressed: (){
                  Navigator.of(context).pushNamed('/shopProduct',arguments: ShopArg(shopId: _product.shopId,searchItem: _product.typeOfProduct,category: _product.category,typeOfProduct: _product.typeOfProduct,calledFrom: "productInfo"));
                },
              ),
            ),

            SizedBox(
              height: 5.0,
            ),



            Container(
              height: 30.0,
              width: 300.0,
              child: FlatButton(
                child: Text("View more products from "+_product.shopName,
                  style: TextStyle(color: Colors.blue,fontSize: 15.0),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                onPressed: (){
                  Navigator.of(context).pushNamed('/shopProduct',arguments: ShopArg(shopId : _product.shopId));
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildAddToBagButton(){
    return Visibility(
      visible: (_calledFrom.contains('bag'))
          ? false
          : true,
      child: Align(
          alignment: Alignment.bottomCenter,
          child:  Container(
            height: 50.0,
            width: 300.0,
            child:  RaisedButton.icon(
              icon: Icon(Icons.add_circle),
              label: Text("Add to Bag"),
              onPressed: (){
                _addToBag();
              },),
          )
      ),
    );
  }


  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return Scaffold(
      key: _productInfoScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Product"),
      ),
      body: Center(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: (_product==null)
                ? Text("Loading")
                : _buildColumnAllElements()
        ),
      )
    );
  }
}