import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CategoryTypeFilter extends StatefulWidget{

  final List<String> _filterListCopy;
  CategoryTypeFilter(this._filterListCopy);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _CategoryTypeFilterState(this._filterListCopy);
  }
}

class _CategoryTypeFilterState extends State<CategoryTypeFilter>{

  _CategoryTypeFilterState(this._filterListCopy);

  final List<String> _filterListCopy;

  String _selectedItem;

  List<String> _filterList;
  List<String> _colorList;
  List<String> _sizeList;
  List<Color> _selectedColorList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedItem="Color";
    _filterList = ["Color","Size"];
    _colorList = ["Red","Blue","Yellow","Green"];
    _sizeList = ["S","M","L","XL"];
    _selectedColorList = [Colors.white,Colors.black];
  }

 Widget _buildColumnAllElements(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
     _buildCategoryTypeOfProductRow(),
      _buildResetApplyButtonRow()
      ],
    );
  }

  Widget _buildCategoryTypeOfProductRow(){
    return  Expanded(
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
                                  _selectedColorList=[Colors.black,Colors.black];
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
            visible: _selectedItem.contains("Color")
                ? true
                : false,
            child: Expanded(
                child: ListView.builder(
                    itemCount: _colorList.length,
                    itemBuilder: (context,position){
                      return ListTile(
                        title: (_filterListCopy[0] ==_colorList[position])
                            ? Text(_colorList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
                            : Text(_colorList[position]),
                        onTap: (){
                          if(_filterListCopy[0] ==_colorList[position]){
                            setState(() {
                              _filterListCopy[0] = '';
                            });
                          }else{
                            setState(() {
                              _filterListCopy[0] = _colorList[position];
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
                        title: (_filterListCopy[1] ==_sizeList[position])
                            ? Text(_sizeList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
                            : Text(_sizeList[position]),
                        onTap: (){
                          if(_filterListCopy[1] ==_sizeList[position]){
                            setState(() {
                              _filterListCopy[1] = '';
                            });
                          }else{
                            setState(() {
                              _filterListCopy[1] = _sizeList[position];
                            });
                          }

                        },
                      );
                    })
            ),
          ),


        ],
      ),
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
                if(_filterListCopy[0]=="" && _filterListCopy[1]==""){
                  Toast.show("No Filter Selected", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
                }else {
//
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
          child: _buildColumnAllElements(),
        ),
      ),
    );;
  }
}