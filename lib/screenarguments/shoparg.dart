import "package:projectx_customer_app/models/shop.dart";

class ShopArg{
  String _shopId;
  String _district;
  String _location;
  String _searchItem;
  String _category;
  String _typeOfProduct;
  String _calledFrom;
  List<int> _shopInfoList;

  ShopArg({shopId,district,location,searchItem,category,typeOfProduct,calledFrom,shopInfoList}){
    this._shopId = shopId;
    this._district = district;
    this._location = location;
    this._searchItem = searchItem;
    this._category = category;
    this._typeOfProduct = typeOfProduct;
    this._calledFrom = calledFrom;
    this._shopInfoList=shopInfoList;
  }
  
  String get shopId=>this._shopId;
  String get district=>this._district;
  String get location=>this._location;
  String get searchItem=>this._searchItem;
  String get category=>this._category;
  String get typeOfProduct=>this._typeOfProduct;
  String get calledFrom=>this._calledFrom;
  List<int> get shopInfoList=>this._shopInfoList;
}