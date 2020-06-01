import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:projectx_customer_app/models/product.dart';
import 'package:projectx_customer_app/models/shop.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchState();
  }
}

class _SearchState extends State<Search>{

  String _customerId;
  List<bool> _isSelected;
  String _selectedItem;
  List<Product> _productList;
  List<Product> _originalProductList;
  List<Shop> _shopList;
  List<Shop> _originalShopList;
  List<String> _sortProductList;
  List<String> _sortShopList;
  String _sortProductCondition;
  String _sortShopCondition;
  List<String> _filterProductList;
  List<String> _filterProductListCopy;
  List<String> _filterShopList;
  List<String> _filterShopListCopy;
  TextEditingController _searchController;
  int _filterCount;
  FocusNode _searchNode;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isSelected = [true,false];
    _selectedItem = "products";
    _sortProductList = ['new','old','popular','lowest to highest price','highest to lowest price'];
    _sortShopList = ['new','old','popular'];
    _sortProductCondition = 'new';
    _sortShopCondition = 'new';
    _filterProductList = ['','','',''];
    _filterShopList = ['',''];
    _searchController = new TextEditingController();
    _filterCount = 0;
    _searchNode = new FocusNode();
    _baseUrl = "http://10.0.2.2:3000/";
    
    _getCustomerId();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchNode.dispose();
    super.dispose();
  }
  
  void _getCustomerId() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
  }

  void _search() async{

    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);

     if(_selectedItem.contains("products")){
       String url = _baseUrl+"productsearch/";
       Map<String,dynamic> body = {
         'customerId' : _customerId,
         'searchItem': _searchController.text.trim(),
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

      if(data['message']=="No product found"){
        Toast.show("No product found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else if(data['error']!=null){
        Toast.show("Some error occured try again",context,duration : Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else{
        List<Product> productList = List();
        for(var d in data['products']){
          var s = d['shopId'];
          Product product = new Product(d['_id'], d['name'],s['_id'],s['name'],d['category'],d['typeOfProduct'],d['price'],d['negotiable'],d['color'],d['size'],d['description'],DateTime.parse(d['date']),d['productImages'],d['views']);
          productList.add(product);
        }
        _originalProductList=productList;
        _filterProduct(productList);
      }
     }
     else if(_selectedItem.contains('shops')){
       String url = _baseUrl+"shopsearch/";
       Map<String,dynamic> body = {
         'customerId' : _customerId,
         'searchItem': _searchController.text.trim(),
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
       debugPrint(data.toString());
       if(data['message'] == "No shop found"){
         Toast.show("No shop found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
       }
       else if(data['error']!=null){
         Toast.show("Some error occured try again",context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
       }
       else{
         List<Shop> shopList = new List();
         for(var d in data['shops']){
           Shop shop = new Shop(d['_id'], d['name'], d['district'], d['address'], d['phoneNumber'], d['shopPic'], d['description'], DateTime.parse(d['date']), d['views']);
           shopList.add(shop);
         }
         _originalShopList = shopList;
         _filterShop(shopList);
       }
     }
  }

  void _filterProduct(List<Product> unfilteredList,{int toggleButton=0}){
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
    }
    if(toggleButton==0) {
      if (unfilteredList.length < 1) {
        Toast.show("No product found", context, duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      }
      else {
        if (_sortProductCondition == "new") {
          setState(() {
            _productList = unfilteredList;
          });
        }
        else {
          _sortProduct(unfilteredList);
        }
      }
    }else{
      if(unfilteredList.length<1){
        for(int i=0;i<_filterProductList.length;i++){
          _filterProductList[i]="";
        }
        _filterCount=0;
        _sortProduct(_originalProductList);
      }
      else{
        _sortProduct(unfilteredList);
      }


    }
  }

  void _sortProduct(List<Product> unsortedList){
    if(_sortProductCondition=="new"){
      unsortedList.sort((b,a)=> a.date.compareTo(b.date));
    }
    else if (_sortProductCondition=="old"){
      unsortedList.sort((a,b)=> a.date.compareTo(b.date));
    }
    else if(_sortProductCondition=="popular"){
      unsortedList.sort((b,a)=>a.views.compareTo(b.views));
    }
    else if(_sortProductCondition=="lowest to highest price"){
      unsortedList.sort((a,b)=>a.price.compareTo(b.price));
    }
    else if(_sortProductCondition=="highest to lowest price"){
      unsortedList.sort((b,a)=>a.price.compareTo(b.price));
    }

    if(unsortedList.length<1){
      Toast.show("No product found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }else{
      setState(() {
        _productList=unsortedList;
      });
    }
  }

  void _filterShop(List<Shop> unfilteredList,{int toggleButton=0}){
    if(_filterCount!=0){
      if(_filterShopList[0]!=''){
        unfilteredList = unfilteredList.where((x)=>x.district.toLowerCase().contains(_filterShopList[0].toLowerCase().trim())).toList();
      }
      if(_filterShopList[1]!=''){
        unfilteredList = unfilteredList.where((x)=>x.address.toLowerCase().contains(_filterShopList[1].toLowerCase().trim())).toList();
      }
      }

    if(toggleButton==0) {
      if (unfilteredList.length < 1) {
        Toast.show("No shop found", context, duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      }
      else {
        if (_sortShopCondition == 'new') {
          setState(() {
            _shopList = unfilteredList;
          });
        }
        else {
          _sortShop(unfilteredList);
        }
      }
    }
    else{
      if(unfilteredList.length<1){
        for(int i=0;i<_filterShopList.length;i++){
          _filterShopList[i]="";
        }
        _filterCount=0;
        _sortShop(_originalShopList);
      }
      else{
        _sortShop(unfilteredList);
      }
    }

  }

   void _sortShop(List<Shop> unsortedList){
     if(_sortShopCondition=="new"){
       unsortedList.sort((b,a)=> a.date.compareTo(b.date));
     }
     else if (_sortShopCondition=="old"){
       unsortedList.sort((a,b)=> a.date.compareTo(b.date));
     }
     else if(_sortShopCondition=="popular"){
       unsortedList.sort((b,a)=>a.views.compareTo(b.views));
     }

     if(unsortedList.length<1){
       Toast.show("No shop found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
     }
     else{
       setState(() {
         _shopList = unsortedList;
       });
     }
   }

     void _sortAlertDialog(BuildContext context) async{

      AlertDialog alertDialog = AlertDialog(
        title: Text("Sort"),
        content: (_selectedItem.contains('products'))
            ? ListView.builder(
            itemCount: _sortProductList.length,
            itemBuilder: (context,position){
              return GestureDetector(
                child: ListTile(
                  title: (_sortProductCondition.contains(_sortProductList[position]))
                         ? Text(_sortProductList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
                         : Text(_sortProductList[position]),
                ),
                onTap: (){
                  setState(() {
                    _sortProductCondition= _sortProductList[position];
                  });
                  _sortProduct(_productList);
                  Navigator.of(context).pop();
                },
              );

            })

            : ListView.builder(
            itemCount: _sortShopList.length,
            itemBuilder: (context,position){
              return GestureDetector(
                child: ListTile(
                  title: (_sortShopCondition.contains(_sortShopList[position]))
                         ? Text(_sortShopList[position],style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),)
                         : Text(_sortShopList[position]),
                  onTap: (){
                    setState(() {
                      _sortShopCondition = _sortShopList[position];
                    });
                    _sortShop(_shopList);
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),

      );

      showDialog(
          context: context,
          builder: (context){
            return alertDialog;
          });
     }

     void _gotoProductFilter() async{
       _filterProductListCopy = List<String>.generate(_filterProductList.length,(i)=> _filterProductList[i]);
      var result = await Navigator.of(context).pushNamed('/productFilter',arguments: _filterProductListCopy);
      if(result!=null) {
        if(result=="remove"){

          _filterProductList=['','','',''];
          _sortProduct(_originalProductList);
          setState(() {
            _filterCount = 0;
          });

        }
        else {
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
          _sortShop(_originalShopList);
          setState(() {
            _filterCount = 0;
          });
        }else{
//          ShopArg shopArg = result;
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
      Visibility(
      visible: ((_productList==null||_productList.length==0)&&(_shopList==null||_shopList.length==0))
       ? true
           : false,
       child: Center(
       child: Padding(
       padding: EdgeInsets.all(10.0),
       child: Text("No search result"),
       ),
       )
       ),
       _buildProductGridView(),
       _buildShopGridView(),
       _buildSortFilterButtonRow()
       ],

       );
     }

     Widget _buildProductGridView(){
      return  (_productList!=null && _productList.length!=0) & _selectedItem.contains("products")
          ? Expanded(
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio:  MediaQuery.of(context).size.height / 1200,
                  crossAxisCount: 2,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0
              ),

              itemCount: _productList.length,
              itemBuilder: (context,position) {
                return _buildSingleProduct(position);
              })
      )
          : SizedBox(
        height: 0.0,
        width: 0.0,
      );
     }

     Widget _buildSingleProduct(int position){
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product: _productList[position],calledFrom: "search"));
        },
        child: Card(
            elevation: 5.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Text(_productList[position].name, style: TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),),

                SizedBox(height: 2.0,),

                Text(_productList[position].shopName),

                SizedBox(height: 3.0,),

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
            )
        ),
      );
     }

     Widget _buildShopGridView(){
      return (_shopList!=null && _shopList.length!=0) & _selectedItem.contains("shops")
          ? Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio:  MediaQuery.of(context).size.height / 1200,
                crossAxisCount: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0
            ),
            itemCount: _shopList.length,
            itemBuilder: (context,position){
              return _buildSingleShop(position);
            },

          )
      )
          : SizedBox(
        height: 0.0,
        width: 0.0,
      );
     }

     Widget _buildSingleShop(int position){
     return GestureDetector(
       onTap: (){
         Navigator.of(context).pushNamed('/shopInfo',arguments: ShopArg(shopId: _shopList[position].shopId));
       },
       child:  Card(
           elevation: 5.0,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: <Widget>[

               Text(_shopList[position].shopName,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),

               SizedBox(height: 2.0,),

               Text(_shopList[position].address),

               SizedBox(height: 3.0,),

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
           )
       ),
     );
     }

     Widget _buildSortFilterButtonRow(){
     return  Visibility(
         visible: ((_productList==null||_productList.length==0)&&(_shopList==null||_shopList.length==0))
             ? false
             : true,
         child: Align(
           alignment: Alignment.bottomCenter,
           child : Row(
             children: <Widget>[
               Expanded(
                   child:FlatButton(
                     color: Colors.blue,
                     child: Text("Sort"),
                     onPressed: (){
                       _sortAlertDialog(context);
                     },)
               ),

//                   Expanded(
//                       child:  FlatButton(
//                         color: Colors.blue,
//                         child: Text("Filter"),
//                         onPressed: (){
//                           if(_selectedItem.contains("products")) {
//                             _gotoProductFilter();
//                           }else if(_selectedItem.contains("shops")){
//                             _gotoShopFilter();
//                           }
//                         },
//                       )
//
//                   ),
               SizedBox(
                 width: 5.0,
               ),

               Visibility(
                 visible: (_selectedItem.contains("products"))
                     ?true :false,
                 child: Expanded(
                     child: Stack(
                       children: <Widget>[
                         Container(
                           width: 180,
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
                     )

                 ),
               ),

               Visibility(
                 visible: (_selectedItem.contains("shops"))
                     ?true :false,
                 child: Expanded(
                     child: Stack(
                       children: <Widget>[
                         Container(
                           width: 180,
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
                     )

                 ),
               )
             ],
           ),
         )
     );
     }

     Widget _buildAppBarTitle(){
     return Padding(
         padding: EdgeInsets.all(10.0),
         child: TextField(
           focusNode: _searchNode,
           autofocus: true,
           controller: _searchController,
           decoration: InputDecoration(
             labelText: "Search",
             hintText: "Search",
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(5.0),
             ),
             suffix: Icon(Icons.search),
           ),
           onSubmitted: (item){
             if(item.isNotEmpty) {
               _search();
             }
           },
         )
     );
     }

     Widget _buildAppBarAction(){
      return  Padding(
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
                _selectedItem="products";
                _searchController.text="";
                _searchNode.requestFocus();
                _shopList=null;
                _filterCount=0;
//                        _sortProductCondition="new";
//                        _filterProductList=['','','',''];
                for(int i =0;i<_filterProductList.length;i++){
                  if(_filterProductList[i]!=''){
                    _filterCount++;
                  }
                }

                if(_originalProductList!=null && _originalProductList.length>0){
                  if(_filterCount<1){
                    _sortProduct(_originalProductList);
                  }
                  else{
                    _filterProduct(_originalProductList,toggleButton: 1);
                  }
                }

              }
              else if(index==1){
                _isSelected[0]=false;
                _isSelected[1] = true;
                _selectedItem="shops";
                _searchController.text="";
                _searchNode.requestFocus();
                _productList=null;
                _filterCount=0;
//                        _sortShopCondition="new";
//                        _filterShopList=['',''];
                for(int i=0;i<_filterShopList.length;i++){
                  if(_filterShopList[i]!=''){
                    _filterCount++;
                  }
                }
                if(_originalShopList!=null && _originalShopList.length>0){
                  if(_filterCount<1){
                    _sortShop(_originalShopList);
                  }
                  else{
                    _filterShop(_originalShopList,toggleButton: 1);
                  }
                }

              }

              debugPrint(_selectedItem);
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
        title: _buildAppBarTitle(),
        actions: <Widget>[
            _buildAppBarAction()
            ],
      ),

      body: Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: _buildColumnAllElements(),
            ),
      ),
    );
  }
}