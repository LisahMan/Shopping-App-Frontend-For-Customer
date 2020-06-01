import 'package:flutter/material.dart';
import 'package:projectx_customer_app/screenarguments/productarg.dart';


class Category extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CategoryState();
  }
}

class _CategoryState extends State<Category>{

  List<String> _categoryList;
  List<String> _femaleList;
  List<String> _maleList;
  List<String> _unisexList;
  List<String> _kidsList;
  String _selectedCategory;
  List<Color> _selectedColorList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _categoryList = ["Female","Male","Unisex","Kids"];
    _femaleList = ["All wear","Jeans","Tshirt","Shirt","Kurtha","Sari"];
    _maleList = ["All wear","Jeans","Tshirt","Shirt","Hoodie","Suit"];
    _unisexList = ["All wear","Jeans","Tshirt","Shirt"];
    _kidsList = ["All wear","Jeans","Dress","Tshirt"];
    _selectedCategory = "";
    _selectedColorList = [Colors.black,Colors.black,Colors.black,Colors.black];
  }

  Widget _buildColumnAllElements(){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
       _buildCategoryTypeOfProductRow()
      ],
    );
  }

  Widget _buildCategoryTypeOfProductRow(){
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _categoryList.length,
                itemBuilder: (context,position){
                  return Container(
                    color: Colors.blueGrey,
                    child: ListTile(
                      title: Text(_categoryList[position],style: TextStyle(color: _selectedColorList[position] ),),
                      onTap: (){
                        setState(() {
                          _selectedColorList=[Colors.black,Colors.black,Colors.black,Colors.black];
                          _selectedCategory = _categoryList[position];
                          _selectedColorList[position] = Colors.white;
                        });
                      },
                    ),
                  );
                }),
          ),

          Visibility(
            visible: (_selectedCategory=="Female")
                ? true
                : false,
            child: Expanded(
              child: ListView.builder(
                  itemCount: _femaleList.length,
                  itemBuilder: (context,position){
                    return ListTile(
                      title: Text(_femaleList[position]),
                      onTap: (){
                        Navigator.of(context).pushNamed('/categoryTypeProduct',arguments: ProductArg(category: _selectedCategory,typeOfProduct: _femaleList[position]));
                      },
                    );
                  }),
            ),
          ),

          Visibility(
            visible: (_selectedCategory=="Male")
                ? true
                : false,
            child: Expanded(
              child: ListView.builder(
                  itemCount: _maleList.length,
                  itemBuilder: (context,position){
                    return ListTile(
                      title: Text(_maleList[position]),
                      onTap: (){
                        Navigator.of(context).pushNamed('/categoryTypeProduct',arguments: ProductArg(category: _selectedCategory,typeOfProduct: _maleList[position]));
                      },
                    );
                  }),
            ),
          ),

          Visibility(
            visible: (_selectedCategory=="Unisex")
                ? true
                : false,
            child: Expanded(
              child: ListView.builder(
                  itemCount: _unisexList.length,
                  itemBuilder: (context,position){
                    return ListTile(
                      title: Text(_unisexList[position]),
                      onTap: (){
                        Navigator.of(context).pushNamed('/categoryTypeProduct',arguments: ProductArg(category: _selectedCategory,typeOfProduct: _unisexList[position]));
                      },
                    );
                  }),
            ),
          ),

          Visibility(
            visible: (_selectedCategory=="Kids")
                ? true
                : false,
            child: Expanded(
              child: ListView.builder(
                  itemCount: _kidsList.length,
                  itemBuilder: (context,position){
                    return ListTile(
                        title: Text(_kidsList[position]),
                        onTap: (){
                          Navigator.of(context).pushNamed('/categoryTypeProduct',arguments: ProductArg(category: _selectedCategory,typeOfProduct: _kidsList[position]));
                        }
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Category"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildColumnAllElements(),
        ),
      )
    );
  }
}

