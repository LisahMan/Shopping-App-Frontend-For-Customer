import 'package:projectx_customer_app/models/product.dart';

class ProductArg{
  String _productId;
  String _category;
  String _typeOfProduct;
  String _color;
  String _size;
  String _calledFrom;
  Product _product;

  ProductArg({product,productId,category,typeOfProduct,color,size,calledFrom}){
    this._product = product;
    this._productId = productId;
    this._category = category;
    this._typeOfProduct = typeOfProduct;
    this._color = color;
    this._size = size;
    this._calledFrom = calledFrom;
  }

  Product get product=>this._product;
  String get productId=>this._productId;
  String get category=>this._category;
  String get typeOfProduct=>this._typeOfProduct;
  String get color=>this._color;
  String get size=>this._size;
  String get calledFrom=>this._calledFrom;
}