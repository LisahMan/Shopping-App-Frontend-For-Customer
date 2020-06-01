import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_customer_app/models/product.dart';
import 'package:projectx_customer_app/models/shop.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:toast/toast.dart';

class CategoryTypeProduct extends StatefulWidget{

  final String _category;
  final String _typeOfProduct;

  CategoryTypeProduct(this._category,this._typeOfProduct);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CategoryTypeProductState(this._category,this._typeOfProduct);
  }
}

class _CategoryTypeProductState extends State<CategoryTypeProduct>{

  _CategoryTypeProductState(this._category,this._typeOfProduct);

  final String _category;
  final String _typeOfProduct;
  List<Product> _productList;
  List<Product> _originalProductList;
  String _sortProductCondition;
  ScrollController _scrollController;
  List<String> _sortProductList;
  List<String> _filterList;
  List<String> _filterListCopy;
  int _filterCount;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sortProductCondition = 'new';
    _scrollController = new ScrollController();
    _sortProductList = ['new','old','popular','lowest to highest price','highest to lowest price'];
    _filterList = ['',''];
    _filterCount=0;
    _baseUrl = "http://10.0.2.2:3000/";
    _getProduct();
  }

  void _getProduct() async{

    String url = _baseUrl+"product/filtercategory/";
    Map<String,dynamic> body;
    if(_typeOfProduct=='All wear'){
      body = {'category' : _category,
              'typeOfProduct' : "all",
              };
    }else {

      body = {
        'category': _category,
        'typeOfProduct': _typeOfProduct
      };
    }

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: json.encode(body)
    );

    var data = json.decode(response.body);

    debugPrint('$data');

    if(data['message']=="No products found"){
      Toast.show("No Products found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      List<Product> productList = List();
      for(var d in data['products']){
        var s = d['shopId'];
        Product product = new Product(d['_id'],d['name'],s['_id'],s['name'], d['category'],d['typeOfProduct'],d['price'],d['negotiable'],d['color'],d['size'],d['description'],DateTime.parse(d['date']),d['productImages'],d['views']);
        productList.add(product);
      }
      setState(() {
        _productList=productList;
        _originalProductList = productList;
      });
    }
  }

  void _filterProduct(List<Product> unfilteredList){
    if(_filterCount!=0){
      if(_filterList[0]!=''){
        debugPrint("Filter color");
        unfilteredList = unfilteredList.where((x)=>x.color.toLowerCase().contains(_filterList[0].toLowerCase())).toList();
      }
      if(_filterList[1]!=''){
        debugPrint("Filter size");
        unfilteredList = unfilteredList.where((x)=>x.size.toLowerCase().contains(_filterList[1].toLowerCase())).toList();
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
    debugPrint(_originalProductList.length.toString());
    if(unsortedList.length<1){
      Toast.show("No product found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }else{
      _productList=unsortedList;
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
                if(_filterCount==0) {
                  _sortProduct(_productList);
                }
                else{
                  _filterProduct(_productList);
                }
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


  void _gotoFilter() async{
    _filterListCopy = List<String>.generate(_filterList.length,(i)=> _filterList[i]);
    var result = await Navigator.of(context).pushNamed('/categoryTypeFilter',arguments: _filterListCopy);
    if(result!=null) {
      if(result=="remove") {
//        _search(_searchController.text, _sortProductCondition);
        _filterList = ['', ''];
        if(_sortProductCondition!='new'){
          _sortProduct(_originalProductList);
        }else{
          _productList=_originalProductList;
        }
        setState(() {
          _filterCount = 0;
        });
      }
      else {
//        ProductArg productArg = result;
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
        _filterProduct(_originalProductList);
      }

    }
  }

  Widget _buildColumnAllElements(){
    return Column( crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      _buildProductGridView(),
      _buildSortFilterButtonRow()
      ],
    );
  }

  Widget _buildProductGridView(){
    return Expanded(
      child: GridView.builder(
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
        Navigator.of(context).pushNamed('/productInfo',arguments: ProductArg(product: _productList[position],calledFrom: "content"));
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
                        image: NetworkImage(_baseUrl+"uploads/" + _productList[position].productImages[0].toString().split('\\')[1]),
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
    return Align(
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


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Products"),
      ),
      body:  Center(
      child: Padding(
      padding: EdgeInsets.all(10.0),
      child: (_productList==null || _productList.length==0)
      ? Text("No Products")
      : _buildColumnAllElements(),
      )
    )
    );
  }
}