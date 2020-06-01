import 'package:flutter/material.dart';
import 'package:projectx_customer_app/screenarguments/shoparg.dart';
import 'package:toast/toast.dart';

class ShopFilter extends StatefulWidget{
  final List<String> _filterShopListCopy;

  ShopFilter(this._filterShopListCopy);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShopFilterState(_filterShopListCopy);
  }
}

class _ShopFilterState extends State<ShopFilter>{

  _ShopFilterState(this._filterShopListCopy);

  final List<String> _filterShopListCopy;
  TextEditingController _districtController;
  TextEditingController _locationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _districtController = new TextEditingController();
    _locationController = new TextEditingController();

    if(_filterShopListCopy[0]!=""){
      _districtController.text=_filterShopListCopy[0];
    }
     if(_filterShopListCopy[1]!=""){
      _locationController.text = _filterShopListCopy[1];
    }
  }

  Widget _buildListViewAllElements(){
    return ListView(
      children: <Widget>[
        TextField(
          controller: _districtController,
          decoration: InputDecoration(
              labelText: "District",
              hintText: "Kathmandu",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
              )
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextField(
          controller: _locationController,
          decoration: InputDecoration(
              labelText: "Location",
              hintText: "New Road",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
              )
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        _buildApplyResetButtonRow()

      ],
    );
  }

  Widget _buildApplyResetButtonRow(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              child: Text("Reset"),
              onPressed: (){
                _districtController.text="";
                _locationController.text="";
              },
            ),
          ),

          Expanded(
            child: FlatButton(
              color: Colors.red,
              child: Text("Filter"),
              onPressed: (){
                if(_districtController.text.isEmpty && _locationController.text.isEmpty){
                  Toast.show("Please enter district or location or both", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
                }
                else{
//                            ShopArg shopArg = ShopArg(district: _districtController.text,location: _locationController.text);
                  _filterShopListCopy[0] = _districtController.text;
                  _filterShopListCopy[1] = _locationController.text;
                  Navigator.of(context).pop(1);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBarAction(){
    return FlatButton(
      child: Text("Remove Filters",style: TextStyle(color: Colors.white),),
      onPressed: (){
        Navigator.of(context).pop("remove");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Filter"),
        actions: <Widget>[
         _buildAppBarAction()
        ],
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildListViewAllElements(),
        ),
      ),
    );
  }
}