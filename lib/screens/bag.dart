import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:projectx_customer_app/models/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:projectx_customer_app/models/product.dart';
import 'dart:convert';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:toast/toast.dart';

class Bag extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BagState();
  }
}

class _BagState extends State<Bag>{

  String _customerId;
  List<Product> _productList;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _baseUrl = "http://10.0.2.2:3000/";
    _getCustomerId();
  }

  void _getCustomerId() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
    _getBag();
}

  void _getBag() async{

    String url = _baseUrl+"bag/customer/"+_customerId;
    var response = await http.get(url);
    var data = jsonDecode(response.body);

    if(data['message']=="Customer doesnt exists"){
      Toast.show("Customer doesnt exists", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['message']=="No products on bag"){
      Toast.show("You have no products on the bag", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      List<Product> productList = new List();
      for(var d in data['bag']){
        var p = d['productId'];
        var s = p['shopId'];
        Product product = new Product(p['_id'], p['name'],s['_id'],s['name'], p['category'],p['typeOfProduct'],p['price'],p['negotiable'],p['color'],p['size'],p['description'],DateTime.parse(p['date']),p['productImages'],p['views']);
        product.bagId = d['_id'];
        productList.add(product);
      }

      setState(() {
        _productList=productList;
      });
    }
  }

  void _removeProduct(int position) async{
    String url = _baseUrl+"bag/" + _productList[position].bagId;
    var response = await http.delete(url);
    var data = jsonDecode(response.body);

    if(data['error']!=null){
      Toast.show("some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      setState(() {
        _productList.removeAt(position);
      });
    }
  }

  Widget _buildBaggedProductListView(){
    return  ListView.builder(
        itemCount: _productList.length,
        itemBuilder: (context,position){
          return _buildSingleBaggedProduct(position);
        });
  }


  Widget _buildSingleBaggedProduct(int position){
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product: _productList[position],calledFrom: "bag"));
      },
      child:  Card(
        elevation: 5.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Container(
              height: 150.0,
              width: 150.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(_baseUrl+"uploads/"+_productList[position].productImages[0].toString().split("\\")[1]),
                      fit: BoxFit.fill
                  )
              ),
            ),

            SizedBox(
              width: 5.0,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text(_productList[position].name,style: TextStyle(fontSize: 25.0),),

                  SizedBox(
                    height: 2.0,
                  ),

                  Text(_productList[position].shopName,style: TextStyle(fontSize: 20.0),),

                  SizedBox(
                    height: 2.0,
                  ),

                  Text("Rs." + _productList[position].price.toString(),style: TextStyle(fontSize: 20.0),),

                  SizedBox(
                    height: 40.0,
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 20.0,
                      width: 100.0,
                      child: RaisedButton(
                        child: Text("Delete",style: TextStyle(fontSize: 15.0),),
                        onPressed: (){
                          _removeProduct(position);
                        },
                      ),
                    ),
                  )

                ],
              ),
            )


          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Bag"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
            child: (_productList==null || _productList.length==0)
                ? Text("No product in bag")
                : _buildBaggedProductListView(),

        ),
      )
    );
  }
}