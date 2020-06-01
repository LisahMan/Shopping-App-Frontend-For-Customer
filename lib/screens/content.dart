import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_customer_app/models/product.dart';
import 'package:projectx_customer_app/models/shop.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:toast/toast.dart';

class Content extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ContentState();
  }
}

class _ContentState extends State<Content>{

  List<Product> _trendingProductList;
  List<Product> _shopLikedProductList;
  List<Shop> _trendingShopList;
  String _sex;
  String _customerId;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sex = "";
    _customerId = "";
    _baseUrl = "http://10.0.2.2:3000/";
    _getSex();
  }

  void _getSex() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
    _sex = prefs.getString('sex');
    _getHomePage();
  }


  void _getHomePage() async{
    String url = _baseUrl+"customer/"+this._customerId+"/homepage/"+this._sex;
    var response = await http.get(url);
    var data = jsonDecode(response.body);

    if(data['error']!=null){
        Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      if(data['trendingProducts']!="No trending products"){
        List<Product> productList = new List();
        for(var d in data['trendingProducts']){
          var p = d['product'];
          var s = p['shop'];
          Product product = new Product(p['_id'],p['name'],s['_id'],s['name'],p['category'],p['typeOfProduct'],p['price'],p['negotiable'],p['color'],p['size'],p['description'],DateTime.parse(p['date']),p['productImages'],p['views']);
          productList.add(product);
        }
        setState(() {
          _trendingProductList=productList;
        });
      }

      if(data['trendingShops']!="No trending shops"){
        List<Shop> shopList = new List();
        for(var d in data['trendingShops']){
          var s = d['shop'];
          Shop shop = new Shop(s['_id'], s['name'],s['district'], s['address'] ,s['phoneNumber'], s['shopPic'],s['description'],DateTime.parse(s['date']),s['views']);
          shopList.add(shop);
        }
        setState(() {
          _trendingShopList=shopList;
        });
      }

      if(data['shopLikedProducts']!="No shop liked" && data['shopLikedProducts']!="Shop has no products"){
           List<Product> productList = new List();
           for(var d in data['shopLikedProducts']){
             var s = d['shopId'];
             Product product = new Product(d['_id'],d['name'],d['_id'],d['name'],d['category'],d['typeOfProduct'],d['price'],d['negotiable'],d['color'],d['size'],d['description'],DateTime.parse(d['date']),d['productImages'],d['views']);
             productList.add(product);
           }
           setState(() {
             _shopLikedProductList=productList;
           });
      }
    }

  }

  Widget _buildListViewAllElements(){
    return ListView(
      children: <Widget>[
        Text("Trending "+_sex+ " Products",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),


        SizedBox(
          height: 10.0,
        ),

        SizedBox(
          height: 150.0,
          child:  (_trendingProductList==null || _trendingProductList.length==0)
              ? Text("No trending products",style: TextStyle(fontSize: 15.0),)
              : _buildTrendingProductListView(),
        ),

        SizedBox(
          height: 15.0,
        ),


        Text("Trending Shop",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),


        SizedBox(
          height: 10.0,
        ),

        SizedBox(
          height: 150.0,
          child: (_trendingShopList==null || _trendingShopList.length==0)
              ? Text("No Trending shops",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),)
              : _buildTrendingShopListView(),
        ),

        SizedBox(
          height: 15.0,
        ),


        Text("New products from Shop Liked",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),

        SizedBox(
          height: 10.0,
        ),

        SizedBox(
          height: 150.0,
          child:  (_shopLikedProductList==null || _shopLikedProductList.length==0)
              ? Text("No products from liked shop",style: TextStyle(fontSize: 15.0),)
              : _buildShopLikedProductListView(),
        ),


      ],
    );
  }

  Widget _buildTrendingProductListView(){
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingProductList.length+1,
        itemBuilder: (context,position){

          if(position==_trendingProductList.length){
            return Card(
              child: Container(
                height: 100.0,
                width: 100.0,
                child: RaisedButton.icon(
                  icon: Icon(Icons.add),
                  label: Expanded(child: Text("View more")),
                  onPressed: (){
                    Navigator.of(context).pushNamed('/trending',arguments: "product");
                  },
                ),
              ),
            );
          }
          else {
            return _buildSingleTrendingProduct(position);
          }
        });
  }

  Widget _buildSingleTrendingProduct(int position){
    return  GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_trendingProductList[position].name,
                style: TextStyle(fontSize: 13.0)),

            Text(_trendingProductList[position].shopName,
                style: TextStyle(fontSize: 13.0)),

            Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          _baseUrl+"uploads/" +
                              _trendingProductList[position]
                                  .productImages[0].toString().split("\\")[1]),
                      fit: BoxFit.fill

                  )
              ),
            )

          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product : _trendingProductList[position],calledFrom: "content"));
      },
    );
  }

  Widget _buildTrendingShopListView(){
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingShopList.length+1,
        itemBuilder: (context,position){
          if(position==_trendingShopList.length){
            return  Card(
              elevation: 5.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                child: RaisedButton.icon(
                  icon: Icon(Icons.add),
                  label: Expanded(child: Text("View more")),
                  onPressed: (){
                    Navigator.of(context).pushNamed('/trending',arguments: "shop");
                  },
                ),
              ) ,
            );

          }
          else {
            return _buildSingleTrendingShop(position);
          }
        });
  }

  Widget _buildSingleTrendingShop(int position){
    return GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_trendingShopList[position].shopName,
              style: TextStyle(fontSize: 13.0),),

            (_trendingShopList[position].shopPic==null)
                ? Container(
              height: 100.0,
              width: 100.0,
              child: Text("No Image"),
            )
                : Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(_baseUrl+"uploads/"+_trendingShopList[position].shopPic.toString().split("\\")[1]),
                      fit: BoxFit.fill

                  )
              ),
            )

          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/shopInfo',arguments: ShopArg(shopId: _trendingShopList[position].shopId,calledFrom: "content"));
      },
    );
  }

  Widget _buildShopLikedProductListView(){
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _shopLikedProductList.length+1,
        itemBuilder: (context,position){

          if(position==_shopLikedProductList.length){
            return Card(
              child: Container(
                height: 100.0,
                width: 100.0,
                child: RaisedButton.icon(
                  icon: Icon(Icons.add),
                  label: Expanded(child: Text("View more")),
                  onPressed: (){
                    Navigator.of(context).pushNamed('/shopProduct',arguments: ShopArg(calledFrom: "content"));
                  },
                ),
              ),
            );
          }
          else {
            return _buildSingleShopLikedProduct(position);
          }
        });
  }

  Widget _buildSingleShopLikedProduct(int position){
    return GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_shopLikedProductList[position].name,
                style: TextStyle(fontSize: 13.0)),

            Text(_shopLikedProductList[position].shopName,
                style: TextStyle(fontSize: 13.0)),

            Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          _baseUrl+"uploads/" +
                              _shopLikedProductList[position]
                                  .productImages[0].toString().split("\\")[1]),
                      fit: BoxFit.fill

                  )
              ),
            )

          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product : _shopLikedProductList[position],calledFrom: "content"));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
        actions: <Widget>[
          GestureDetector(
            child: Icon(Icons.shopping_cart,color: Colors.white,),
            onTap: (){
              Navigator.of(context).pushNamed('/bag');
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
        padding: EdgeInsets.all(10.0),
          child: _buildListViewAllElements(),
        )
    )
    );
  }
}