import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectx_customer_app/models/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_customer_app/models/product.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:toast/toast.dart';

class ShopProduct extends StatefulWidget{
  final String _shopId;
  final String _category;
  final String _typeOfProduct;
  final String _calledFrom;

  ShopProduct(this._shopId,this._category,this._typeOfProduct,this._calledFrom);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShopProductState(this._shopId,this._category,this._typeOfProduct,this._calledFrom);
  }
}

class _ShopProductState extends State<ShopProduct>{

  _ShopProductState(this._shopId,this._category,this._typeOfProduct,this._calledFrom);

  final String _shopId;
  final String _category;
  final String _typeOfProduct;
  final String _calledFrom;
  String _customerId;
  ScrollController _scrollController;
  List<String> _filterList;
  List<String> _filterListCopy;
  int _filterCount;
  Widget _appBarTitle;
  Icon _actionIcon;
  TextEditingController _searchController;

  List<Product> _productList;
  List<Product> _originalProductList;
  List<Product> _searchResultList;
  List<String> _sortProductList;
  String _sortProductCondition;
  String _baseUrl;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController= new ScrollController();
    _filterList = ['','','',''];
    _filterCount=0;
    _appBarTitle = Text("Products");
    _actionIcon = Icon(Icons.search,color: Colors.white,);
    _searchController = new TextEditingController();
    _sortProductList = ['new','old','popular','lowest to highest price','highest to lowest price'];
    _sortProductCondition = 'new';
    _baseUrl = "http://10.0.2.2:3000/";

    if(_calledFrom=="productInfo") {
      if(_category!=null&&_typeOfProduct!=null){
        _filterList[0]=this._category;
        _filterList[1]=this._typeOfProduct;
        setState(() {
          _filterCount=2;
        });
      }
    }
    _getCustomerDetail();
  }

  void _getCustomerDetail() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
    if(_category==null) {
      _filterList[0] = prefs.getString('sex');
      setState(() {
        _filterCount++;
      });
    }
  _getProducts();
  }

  void _getProducts() async{
    String url;
    if(_calledFrom=="shopInfo" || _calledFrom=="productInfo") {
         url = _baseUrl+"shop/" + _shopId + "/product";
    }
    else{
      url = _baseUrl+"shopliked/customer/" + _customerId+"/product";
    }
    var response = await http.get(url);
    var data = json.decode(response.body);
    
    if(data['message']=="Shop doesnt exists"){
      Toast.show("Shop doesn't exists", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['message']=="Shop has no products"){
      Toast.show("Shop has no products",context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['message']=="No shop liked"){
      Toast.show("No shop liked", context,duration : Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured try again",context,duration:Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      List<Product> productList = new List();
      for(var d in data['products']){
        var s = d['shopId'];
        Product product = new Product(d['_id'],d['name'],s['_id'],s['name'],d['category'],d['typeOfProduct'],d['price'],d['negotiable'],d['color'],d['size'],d['description'],DateTime.parse(d['date']),d['productImages'],d['views']);
        productList.add(product);
      }
      _originalProductList=productList;
      debugPrint(_filterCount.toString());
      if(_filterCount<1){
        setState(() {
          _productList = productList;
        });
      }
      else{
        _filterProduct(productList);
      }

    }
    
  }

  void _searchProduct() async{
    String searchItem = _searchController.text.trim().toLowerCase();

    _searchResultList = _originalProductList.where((x)=>x.name.toLowerCase().contains(searchItem) || x.category.toLowerCase()==searchItem || x.typeOfProduct.toLowerCase().contains(searchItem)).toList();



    if(_searchResultList.length<1){
      _searchResultList = _productList;
      Toast.show("No Products found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      debugPrint("product list : " + _productList.length.toString());
    }else{
//      _productList = searchResultList;
      _filterProduct(_searchResultList);
    }


  }

  void _filterProduct(List<Product> unfilteredList){
    if(_filterCount!=0){
      if(_filterList[0]!=''){
        debugPrint("Filter category");
        unfilteredList = unfilteredList.where((x)=>x.category.toLowerCase()==_filterList[0].toLowerCase()).toList();
      }
      if(_filterList[1]!=''){
        debugPrint("Filter type of product");
        unfilteredList = unfilteredList.where((x)=>x.typeOfProduct.toLowerCase().contains(_filterList[1].toLowerCase())).toList();
      }
      if(_filterList[2]!=''){
        debugPrint("Filter color");
        unfilteredList = unfilteredList.where((x)=>x.color.toLowerCase().contains(_filterList[2].toLowerCase())).toList();
      }
      if(_filterList[3]!=''){
        debugPrint("Filter size");
        unfilteredList = unfilteredList.where((x)=>x.size.toLowerCase().contains(_filterList[3].toLowerCase())).toList();
      }
    }
    _sortProduct(unfilteredList);
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




  void _gotoFilter() async{
    _filterListCopy = List<String>.generate(_filterList.length,(i)=> _filterList[i]);
    var result = await Navigator.of(context).pushNamed('/productFilter',arguments: _filterListCopy);
    if(result!=null) {

      if(result=="remove"){
        _filterList=['','','',''];
        setState(() {
          _filterCount=0;
        });
        if(_searchController.text==""){
          _sortProduct(_originalProductList);
        }else{
          _sortProduct(_searchResultList);
        }
      }
      else {
        _filterList=_filterListCopy;
        int count=0;
        for(int i=0;i<_filterList.length;i++){
          if(_filterList[i]!=""){
            count++;
          }
        }
        setState(() {
          _filterCount=count;
        });
         if(_searchController.text==''){
          _filterProduct(_originalProductList);
        }
        else{
          _filterProduct(_searchResultList);
        }
      }
    }
  }



  void _sortAlertDialog(BuildContext context) async{

    AlertDialog alertDialog = AlertDialog(
      title: Text("Sort"),
      content: ListView.builder(
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

          }),

    );

    showDialog(
        context: context,
        builder: (context){
          return alertDialog;
        });
  }

  Widget _buildColumnAllElements(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      _buildProductGridView(),
      _buildSortFilterButtonRow()
      ],
    );
  }

  Widget _buildProductGridView(){
    return Expanded(
      child: (_productList==null || _productList.length==0)
          ? ((_filterList[0]=="")
          ?Text("No Products")
          :Text("No " + _filterList[0] + " Product")
      )
          : GridView.builder(
          controller: _scrollController,
          itemCount: _productList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 2.0,mainAxisSpacing: 2.0,childAspectRatio: MediaQuery.of(context).size.height / 1200),
          itemBuilder: (context,position){
            return _buildSingleProduct(position);
          }),
    );
  }

  Widget _buildSingleProduct(int position){

    return GestureDetector(
      onTap: (){
        String calledFrom;
        if(_calledFrom=="shopliked"){
          calledFrom="shopproductfromshopliked";
        }
        else{
          calledFrom="shopproduct";
        }
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product: _productList[position],calledFrom: calledFrom));
      },
      child:  Card(
          elevation: 5.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(_productList[position].name,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),

              SizedBox(height: 2.0,),

              Text(_productList[position].shopName),

              SizedBox(height: 3.0,),

              Container(
                height: 200.0,
                width: 200.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(_baseUrl+"uploads/"+_productList[position].productImages[0].toString().split("\\")[1]),
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
    return     Align(
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

              SizedBox(
                width: 2.0,
              ),

              Stack(
                children: <Widget>[
                  Container(
                    width: 180.0,
                    height: 36.0,
                    child:  RaisedButton(
                      child: Text("Filter"),
                      onPressed: (){
                        _gotoFilter();
                      },
                    ) ,
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
            ])
    );
  }

  Widget _buildAppBarAction(){
    return  IconButton(
      icon: _actionIcon,
      onPressed: (){
        setState(() {
          if(_actionIcon.icon==Icons.search){
            _actionIcon = Icon(Icons.close);
            _appBarTitle = TextField(
              autofocus: true,
              controller: _searchController,
              style: TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,color: Colors.white,),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.white)
              ),

              onSubmitted: (String item){
//                      _searchProduct(item);
                _searchProduct();
              },

            );
          }
          else{
            _actionIcon = Icon(Icons.search,color: Colors.white,);
            _appBarTitle = Text("Product",style: TextStyle(color: Colors.white),);
            _searchController.text="";
            _productList=_originalProductList;
            _filterProduct(_productList);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _appBarTitle,
        actions: <Widget>[
         _buildAppBarAction()
        ],
      ),
      body: Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: _buildColumnAllElements()
          )
      ),
    );
  }
}