import 'package:flutter/material.dart';
import 'package:projectx_customer_app/models/product.dart';
import 'package:projectx_customer_app/models/shop.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Trending extends StatefulWidget{

  final String _trendingItem;
   Trending(this._trendingItem);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TrendingState(this._trendingItem);
  }
}

class _TrendingState extends State<Trending>{

  _TrendingState(this._trendingItem);

   String _trendingItem;
   String _sex;

  List<Product> _productList;
  List<Product> _originalProductList;
  List<Shop> _shopList;
  List<Shop> _originalShopList;

  List<bool> _isSelected;
   List<String> _filterProductList;
   List<String> _filterProductListCopy;
   List<String> _filterShopList;
   List<String> _filterShopListCopy;

   int _filterCount;

   String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isSelected = [true,false];
    _filterProductList = ['','','',''];
    _filterShopList = ['',''];
    _filterCount = 0;
    _baseUrl = "http://10.0.2.2:3000/";

    if(_trendingItem.contains("product")){
      _getSex();

    }
    else if(_trendingItem.contains("shop")){

       _getTrendingShops();
      _isSelected[0] = false;
      _isSelected[1] = true;
    }
  }

  void _getSex() async{
    final prefs = await SharedPreferences.getInstance();
     _sex = prefs.getString('sex');
      _filterProductList[0]= _sex;
      setState(() {
        _filterCount=1;
      });
    _getTrendingProducts();
  }

  void _getTrendingProducts() async{
    String url = _baseUrl+"productview/trending";

    var response = await http.get(url);

    var data = jsonDecode(response.body);

    if(data['message']=="No trending products"){
      Toast.show("No trending products", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      List<Product> productList = new List();
      for(var d in data['trendingProducts']){
        var p = d['product'];
        var s = p['shop'];
        Product product = new Product(p['_id'],p['name'],s['_id'],s['name'],p['category'],p['typeOfProduct'],p['price'],p['negotiable'],p['color'],p['size'],p['description'],DateTime.parse(p['date']),p['productImages'],p['views']);
        productList.add(product);
      }
      _originalProductList=productList;
      if(_filterCount<1){
        setState(() {
          _productList=productList;
        });
      }
      else{
        _filterProduct(productList);
      }

    }
  }

  void _getTrendingShops() async{
     String url = _baseUrl+"shopview/trending";
     var response = await http.get(url);

     var data = jsonDecode(response.body);

     if(data['message']=="No trending shops"){
       Toast.show("No trending shops", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
     }
     else if(data['error']!=null){
       Toast.show("Some error occured try again",context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
     }
     else{
       List<Shop> shopList = new List();
       for(var d in data['trendingShops']){
         var s = d['shop'];
         Shop shop = new Shop( s['_id'], s['name'], s['district'], s['address'], s['phoneNumber'], s['shopPic'], s['description'], DateTime.parse(s['date']), s['views']);
         shopList.add(shop);
       }
       _originalShopList=shopList;
       if(_filterCount<1){
         setState(() {
           _shopList=shopList;
         });
       }else{
         _filterShop(shopList);
       }
     }
  }

  void _filterProduct(List<Product> unfilteredList){
    if(_filterCount!=0){
      if(_filterProductList[0]!=''){
        debugPrint("Filter category");
        unfilteredList = unfilteredList.where((x)=>x.category.toLowerCase()==_filterProductList[0].toLowerCase()).toList();
      }
      if(_filterProductList[1]!=''){
        debugPrint("Filter type of product");
        unfilteredList = unfilteredList.where((x)=>x.typeOfProduct.toLowerCase().contains(_filterProductList[1].toLowerCase())).toList();
      }
      if(_filterProductList[2]!=''){
        debugPrint("Filter color");
        unfilteredList = unfilteredList.where((x)=>x.color.toLowerCase().contains(_filterProductList[2].toLowerCase())).toList();
      }
      if(_filterProductList[3]!=''){
        debugPrint("Filter size");

        unfilteredList = unfilteredList.where((x)=>x.size.toLowerCase().contains(_filterProductList[3].toLowerCase())).toList();
      }

      if(unfilteredList.length<1){
        Toast.show("No product found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else{
        setState(() {
          _productList=unfilteredList;
        });
      }
    }


    }


  void _filterShop(List<Shop> unfilteredList){
    if(_filterCount!=0){
      if(_filterShopList[0]!=''){
        unfilteredList = unfilteredList.where((x)=>x.district.toLowerCase().contains(_filterShopList[0].toLowerCase().trim())).toList();
      }
      if(_filterShopList[1]!=''){
        unfilteredList = unfilteredList.where((x)=>x.address.toLowerCase().contains(_filterShopList[1].toLowerCase().trim())).toList();
      }
      if(unfilteredList.length<1){
        Toast.show("No shop found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else{
        setState(() {
          _shopList=unfilteredList;
        });

      }
    }
  }


   void _gotoProductFilter() async{
     _filterProductListCopy = List<String>.generate(_filterProductList.length,(i)=> _filterProductList[i]);
     var result = await Navigator.of(context).pushNamed('/productFilter',arguments: _filterProductListCopy);
     if(result!=null) {
       if(result=="remove"){
         _filterProductList=['','','',''];
         setState(() {
           _filterCount = 0;
           _productList=_originalProductList;
         });
         debugPrint("originalProductinfilter : " +_originalProductList.length.toString());

       }
       else {
//         ProductArg productArg = result;
         _filterProductList=_filterProductListCopy;
         int count = 0;
         for(int i=0;i<_filterProductList.length;i++){
           if(_filterProductList[i]!=""){
             count++;
           }
         }
         setState(() {
           _filterCount=count;
         });
         _filterProduct(_originalProductList);
       }

     }
   }

   void _gotoShopFilter() async{
     _filterShopListCopy = List<String>.generate(_filterShopList.length,(i)=> _filterShopList[i]);
     var result = await Navigator.of(context).pushNamed('/shopFilter',arguments: _filterShopListCopy);
     if(result!=null){
       if(result=="remove"){
         _filterShopList=['',''];
         setState(() {
           _filterCount = 0;
           _shopList = _originalShopList;
         });
       }else{
//         ShopArg shopArg = result;
         _filterShopList=_filterShopListCopy;
         int count = 0;
         for(int i=0;i<_filterShopList.length;i++) {
           if (_filterShopList[i] != "") {
             count++;
           }
         }
         setState(() {
           _filterCount = count;
         });

         _filterShop(_originalShopList);
       }
     }
  }

  Widget _buildColumnAllElements(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
           _buildProductGridView(),
           _buildShopGridView(),
           _buildProductSortFilterButtonRow(),
           _buildShopSortFilterButtonRow()
        ]);
  }

  Widget _buildProductGridView(){
    return ((_productList!=null && _productList.length!=0) & _trendingItem.contains("product"))
        ? Expanded(
      child: GridView.builder(
          itemCount: _productList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio:  MediaQuery.of(context).size.height / 1000,crossAxisCount: 2,mainAxisSpacing: 5.0,crossAxisSpacing: 5.0),
          itemBuilder: (context,position){
            return _buildSingleProduct(position);
          }),
    )
        :SizedBox(height: 0.0,width: 0.0,);
  }

  Widget _buildSingleProduct(int position){
    return  GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_productList[position].name,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),

            SizedBox(height: 2.0,),

            Text(_productList[position].shopName,style: TextStyle(fontSize: 12.0),),

            Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(_baseUrl+"uploads/" +
                          _productList[position].productImages[0].toString().split("\\")[1]),
                      fit: BoxFit.fill

                  )
              ),
            )
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product: _productList[position],calledFrom: "content"));
      },
    );
  }

  Widget _buildShopGridView(){
    return ((_shopList!=null && _shopList.length!=0) & _trendingItem.contains("shop"))
        ? Expanded(
      child: GridView.builder(
          itemCount: _shopList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio:  MediaQuery.of(context).size.height / 1000,crossAxisCount: 2,mainAxisSpacing: 5.0,crossAxisSpacing: 5.0),
          itemBuilder: (context,position){
            return _buildSingleShop(position);
          }),
    )
        :SizedBox(height: 0.0,width: 0.0,);

    Visibility(
    visible: ((_productList==null || _productList.length==0) && (_shopList==null||_shopList.length==0))
    ?true
        :false,
    child: Text("No trending result"),
    );
  }

  Widget _buildSingleShop(int position){
    return GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_shopList[position].shopName,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),

            SizedBox(height: 2.0,),

            (_shopList[position].shopPic==null)
                ? Container(
              height: 200.0,
              width: 200.0,
              child: Text("No Image"),
            )
                : Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(_baseUrl+"uploads/"+_shopList[position].shopPic.toString().split("\\")[1]),
                      fit: BoxFit.fill

                  )
              ),
            )
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).pushNamed('/shopInfo',arguments: ShopArg(shopId: _shopList[position].shopId,calledFrom: "content"));
      },
    );
  }

  Widget _buildProductSortFilterButtonRow(){
   return Visibility(
       visible: (_trendingItem.contains("product"))
           ?true :false,

       child: Align(
         alignment: Alignment.bottomCenter,
         child: Stack(
           children: <Widget>[
             Container(
               width: 300,
               height: 36,
               child: FlatButton(
                 color: Colors.blue,
                 child: Text("Filter"),
                 onPressed: (){
                   _gotoProductFilter();

                 },
               ),
             )
             ,

             (_filterCount!=0)
                 ? Positioned(
                 top: 2.0,
                 right: 2.0,
                 child:  Container(
                   decoration:  BoxDecoration(
                       borderRadius:  BorderRadius.circular(10.0),
                       color: Colors.red),
                   width: 25.0,
                   child: Center(
                     child: Text(
                       _filterCount.toString(),
                       style:  TextStyle(color: Colors.white,fontSize: 18.0),
                     ),
                   ) ,
                 ))
                 : SizedBox(

             )


           ],
         ),
       )
   );
  }

  Widget _buildShopSortFilterButtonRow(){
    return     Visibility(
        visible: (_trendingItem.contains("shop"))
            ?true :false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: <Widget>[
              Container(
                width: 300,
                height: 36,
                child: FlatButton(
                  color: Colors.blue,
                  child: Text("Filter"),
                  onPressed: (){
                    _gotoShopFilter();

                  },
                ),
              ),

              (_filterCount!=0)
                  ? Positioned(
                  top: 2.0,
                  right: 2.0,
                  child:  Container(
                    decoration:  BoxDecoration(
                        borderRadius:  BorderRadius.circular(10.0),
                        color: Colors.red),
                    width: 25.0,
                    child: Center(
                      child: Text(
                        _filterCount.toString(),
                        style:  TextStyle(color: Colors.white,fontSize: 18.0),
                      ),
                    ) ,
                  ))
                  : SizedBox(

              )

            ],
          ),
        )
    );
  }

  Widget _buildAppBarAction(){
    return    Padding(
      padding: EdgeInsets.only(left: 20.0,top: 10.0,right: 0.0,bottom: 10.0),
      child: ToggleButtons(
        borderColor: Colors.black,
        fillColor: Colors.grey,
        borderWidth: 0,
        selectedBorderColor: Colors.black,
        selectedColor: Colors.white,
        isSelected: _isSelected,
        children: <Widget>[
          Text("Products"),

          Text("Shops")
        ],

        onPressed: (index){
          setState(() {
            if(index==0){
              _isSelected[0]=true;
              _isSelected[1]=false;
              _trendingItem="products";
              _shopList=null;
              for(int i=0;i<_filterShopList.length;i++){
                _filterShopList[i]="";
              }
              if(this._sex==null){
                _getSex();
              }else{
                _filterProductList[0]=this._sex;
                _filterCount=1;
                _filterProduct(_originalProductList);
              }
            }
            else if(index==1){
              _isSelected[0]=false;
              _isSelected[1] = true;
              _trendingItem="shops";
              _productList=null;
              for(int i=0;i<_filterProductList.length;i++){
                _filterProductList[i]="";
              }
              _filterCount=0;
              if(_originalShopList==null){
                _getTrendingShops();
              }else{
                _shopList = _originalShopList;
              }

            }

            debugPrint(_trendingItem);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Trending"),
        actions: <Widget>[
         _buildAppBarAction()
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildColumnAllElements()
    )
    )
    );
  }
}