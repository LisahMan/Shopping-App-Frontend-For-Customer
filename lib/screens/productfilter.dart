import 'package:flutter/material.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';
import 'package:toast/toast.dart';

class ProductFilter extends StatefulWidget{
  final List<String> _filterListCopy;
  ProductFilter(this._filterListCopy);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductFilterState(_filterListCopy);
  }
}

class _ProductFilterState extends State<ProductFilter>{

  final List<String> _filterListCopy;

  _ProductFilterState(this._filterListCopy);

  String _selectedItem;
//  String _category = "";
//  String _typeOfProduct = "";
//  String _color = "";
//  String _size = "";

  List<String> _filterList;
  List<String> _categoryList;
  List<String> _typeOfProductList;
  List<String> _colorList;
  List<String> _sizeList;
  List<Color> _selectedColorList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedItem="Category";
    _filterList = ["Category","Type of product","Color","Size"];
    _categoryList = ["Female","Male","Unisex","Kids"];
    _typeOfProductList = ["jeans","shirt","tshirt","kurtha"];
    _colorList = ["Red","Blue","Yellow","Green"];
    _sizeList = ["S","M","L","XL"];
    _selectedColorList = [Colors.white,Colors.black,Colors.black,Colors.black];
  }

  Widget _buildColumnAllElements(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      _buildFilterRow(),
      _buildResetApplyButtonRow()
      ],
    );
  }

  Widget _buildFilterRow(){
   return Expanded(
        child: Row(
        children: <Widget>[
        Expanded(
        child: ListView.builder(
        itemCount: _filterList.length,
        itemBuilder: (context,position){
      return Container(
          color: Colors.blueGrey,
          child: Stack(
            children: <Widget>[
              ListTile(
                title: Text(_filterList[position],style: TextStyle(color: _selectedColorList[position]),),
                onTap: (){
                  setState(() {
                    _selectedColorList=[Colors.black,Colors.black,Colors.black,Colors.black];
                    _selectedItem = _filterList[position];
                    _selectedColorList[position] = Colors.white;
                  });
                },
              ),
              (_filterListCopy[position]!="")
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
                        "1",
                        style:  TextStyle(color: Colors.white,fontSize: 18.0),
                      ),
                    ) ,
                  ))
                  : SizedBox(

              )
            ],
          )


      );
    })
    ),


    Visibility(
    visible: _selectedItem.contains("Category")
    ? true
        : false,
    child: Expanded(
    child: ListView.builder(
    itemCount: _categoryList.length,
    itemBuilder: (context,position){
    return ListTile(
    title: (_filterListCopy[0] == _categoryList[position])
    ? Text(_categoryList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
        : Text(_categoryList[position]),
    onTap: (){
    if(_filterListCopy[0] == _categoryList[position]){
    setState(() {
    _filterListCopy[0] = '';
    });
    }else{
    setState(() {
    _filterListCopy[0] = _categoryList[position];
    });
    }

    },
    );
    })
    ),
    ),

    Visibility(
    visible: _selectedItem.contains("Type of product")
    ? true
        : false,
    child: Expanded(
    child: ListView.builder(
    itemCount: _typeOfProductList.length,
    itemBuilder: (context,position){
    return ListTile(
    title: (_filterListCopy[1] == _typeOfProductList[position])
    ? Text(_typeOfProductList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
        : Text(_typeOfProductList[position]),
    onTap: (){
    if(_filterListCopy[1] == _typeOfProductList[position]){
    setState(() {
    _filterListCopy[1] = '';
    });
    }else {
    setState(() {
    _filterListCopy[1] = _typeOfProductList[position];
    });
    }
    },
    );
    })
    ),
    ),

    Visibility(
    visible: _selectedItem.contains("Color")
    ? true
        : false,
    child: Expanded(
    child: ListView.builder(
    itemCount: _colorList.length,
    itemBuilder: (context,position){
    return ListTile(
    title: (_filterListCopy[2] ==_colorList[position])
    ? Text(_colorList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
        : Text(_colorList[position]),
    onTap: (){
    if(_filterListCopy[2] ==_colorList[position]){
    setState(() {
    _filterListCopy[2] = '';
    });
    }else{
    setState(() {
    _filterListCopy[2] = _colorList[position];
    });
    }

    },
    );
    })
    ),
    ),

    Visibility(
    visible: _selectedItem.contains("Size")
    ? true
        : false,
    child: Expanded(
    child: ListView.builder(
    itemCount: _sizeList.length,
    itemBuilder: (context,position){
    return ListTile(
    title: (_filterListCopy[3] ==_sizeList[position])
    ? Text(_sizeList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
        : Text(_sizeList[position]),
    onTap: (){
    if(_filterListCopy[3] ==_sizeList[position]){
    setState(() {
    _filterListCopy[3] = '';
    });
    }else{
    setState(() {
    _filterListCopy[3] = _sizeList[position];
    });
    }

    },
    );
    })
    ),
    ),


    ],
    )
   );
  }

  Widget _buildResetApplyButtonRow(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              child: Text("Reset"),
              onPressed: (){
                setState(() {
                  _filterListCopy[0]="";
                  _filterListCopy[1]="";
                  _filterListCopy[2]="";
                  _filterListCopy[3]="";
                });

                Toast.show("Filter Reset", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
              },
            ),
          ),

          Expanded(
            child: FlatButton(
              child: Text("Apply"),
              color: Colors.red,
              onPressed: (){
                if(_filterListCopy[0]=="" && _filterListCopy[1]=="" && _filterListCopy[2]=="" && _filterListCopy[3]==""){
                  Toast.show("No Filter Selected", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
                }else {
//                         ProductArg productArg = ProductArg(category: _filterListCopy[0],typeOfProduct: _filterListCopy[1],color: _filterListCopy[2],size: _filterListCopy[3]);
                  Navigator.of(context).pop(1);
                }
              },
            ) ,
          )

        ],
      ),
    );
  }

  Widget _buildAppBarAction(){
    return  FlatButton(
      child: Text("Remove Filters",style: TextStyle(color: Colors.white)),
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
      child:  Padding(
        padding: EdgeInsets.all(10.0),
        child: _buildColumnAllElements()
      ),
    ),
    );
  }
}