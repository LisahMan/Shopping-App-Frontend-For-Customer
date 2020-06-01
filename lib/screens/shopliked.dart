import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectx_customer_app/models/shop.dart';
import 'dart:convert';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:toast/toast.dart';

class ShopLiked extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShopLikedState();
  }
}

class _ShopLikedState extends State<ShopLiked>{

  String _customerId;
  var _shopLikedScaffoldState;
  List<Shop> _shopList;
  List<Shop> _originalShopList;
  Widget _appBarTitle;
  Icon _actionIcon;
  TextEditingController _searchController;
  List<int> _shopInfoList;
  String _baseUrl;
//  List<int> _shopInfoListCopy;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appBarTitle = Text("Shop Liked");
    _actionIcon = Icon(Icons.search,color: Colors.white,);
    _searchController = new TextEditingController();
    _shopInfoList = [0,0];
    _baseUrl = "http://10.0.2.2:3000/";
    _getCustomerId();
  }

  void _getCustomerId() async{
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customer_id');
    _getShopLiked();
  }

  void _getShopLiked() async{
    String url = _baseUrl+"shopliked/customer/" + _customerId;
    var response = await http.get(url);

    var data = json.decode(response.body);

    debugPrint(data.toString());

    if(data['message']=="Customer not found"){
      Toast.show("Customer not found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['message']=="No shop liked"){
      Toast.show("No shop liked", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      List<Shop> shopList = List();
      for(var d in data['shopliked']){
        var s = d['shopId'];

        Shop shop = new Shop( s['_id'], s['name'], s['district'], s['address'], s['phoneNumber'], s['shopPic'], s['description'], DateTime.parse(s['date']), s['views']);
        shop.liked = true;
        shopList.add(shop);
      }
      _originalShopList=shopList;
      setState(() {
        _shopList=shopList;
      });
    }
  }

  void _searchShopLiked() async{
   List<Shop> searchResultList;
   searchResultList = _shopList.where((x)=>x.shopName.toLowerCase().contains(_searchController.text.trim().toLowerCase())).toList();
   if(searchResultList.length<1){
     Toast.show("No shop found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
   }
   else{
     setState(() {
       _shopList = searchResultList;
     });
   }
  }

  void _shopLiked(Shop shop) async {
    if (shop.liked) {
      String url = _baseUrl+"shopliked/" +
          _customerId + "/" + shop.shopId ;
      var response = await http.delete(url);
      var data = jsonDecode(response.body);
      if(data['error']!=null){
        Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }else{
        setState(() {
          shop.liked = false;
        });
      }
    }
    else if (!shop.liked) {
      String url = _baseUrl+"shopliked/";
      Map<String, dynamic> body = {'customerId': _customerId, 'shopId': shop.shopId,'date' : DateTime.now().toIso8601String()};
      var response = await http.post(url,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(body)
      );
      var data = jsonDecode(response.body);

      if(data['message']=="Shop already liked"){
        Toast.show("You have already liked the shop", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else if(data['error']!=null){
        Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }
      else{
        setState(() {
          shop.liked=true;
        });
      }
    }
  }

  void _getShopInfo(Shop shop,int position,bool shopLiked) async{
    _shopInfoList[0] = position;
    if(shopLiked){
      _shopInfoList[1]=1;
    }else{
      _shopInfoList[1]=0;
    }

    debugPrint("start value: "+_shopInfoList[1].toString());

//    _shopInfoListCopy = List<int>.generate(_shopInfoList.length,(i)=> _shopInfoList[i]);
    var data= await Navigator.of(context).pushNamed('/shopInfo',arguments: ShopArg(shopId: _shopList[position].shopId,shopInfoList: _shopInfoList));
//   List<int> data1=List<int>.from(data) ;

    debugPrint("return value: "+ _shopInfoList[1].toString());

    if(_shopList[position].liked&&_shopInfoList[1]==0){
      setState(() {
        _shopList[position].liked=false;
      });
    }
    else if(!_shopList[position].liked && _shopInfoList[1]==1){
      setState(() {
        _shopList[position].liked=true;
      });
    }
  }

  Widget _buildColumnAllElements(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildShopListView(),
        _buildViewShopLikedProductsButton()
      ],
    );
  }

  Widget _buildShopListView(){
    return Expanded(
      child:   ListView.builder(
          itemCount: _shopList.length,
          itemBuilder: (context,position){
            return _buildSingleShop(position);
          }
      ),
    );
  }

  Widget _buildSingleShop(int position){
    return GestureDetector(
        onTap: (){
          _getShopInfo(_shopList[position],position,_shopList[position].liked);
        },

        child: Card(
          elevation: 5.0,
          child:  Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: (_shopList[position].shopPic==null)
                      ? Text("No Image",)
                      : Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(_baseUrl+"uploads/"+ _shopList[position].shopPic.toString().split("\\")[1]),
                            fit: BoxFit.fill
                        )
                    ),
                  ),

                ),
              ),

              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(_shopList[position].shopName,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),

                    SizedBox(
                      height: 2.0,
                    ),

                    Text(_shopList[position].address,style: TextStyle(fontSize: 15.0),),

                    SizedBox(
                      height: 2.0,
                    ),

                    Text(_shopList[position].district,style: TextStyle(fontSize: 15.0),)
                  ],
                ),
              ),

              GestureDetector(
                child: (_shopList[position].liked)
                    ? Icon(Icons.save,color: Colors.red,)
                    : Icon(Icons.save,color: Colors.grey,),
                onTap: (){
                  _shopLiked(_shopList[position]);
                },
              ),

            ],
          ),
        )
    );
  }

  Widget _buildViewShopLikedProductsButton(){
    return  Visibility(
      visible: (_shopList==null || _shopList.length==0)
          ?false
          :true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 30.0,
          width: 300.0,
          child: RaisedButton(
            child: Text("View products from shop liked"),
            onPressed: (){
              Navigator.of(context).pushNamed('/shopProduct',arguments: ShopArg(calledFrom: "shopliked",));
            },
          ),

        ),
      ),
    );
  }

  Widget _buildAppBarAction(){
    return           IconButton(
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
                _searchShopLiked();
              },

            );

          }
          else{
            _actionIcon = Icon(Icons.search,color: Colors.white,);
            _appBarTitle = Text("Shop Liked",style: TextStyle(color: Colors.white),);
            if(_searchController.text!="") {
              _searchController.text = "";
              _shopList = _originalShopList;
            }
          }
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _shopLikedScaffoldState,
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
          child: (_shopList==null || _shopList.length==0 )
                 ? Text("No shop found")
                 : _buildColumnAllElements(),
        ),
      ),
    );
  }
}