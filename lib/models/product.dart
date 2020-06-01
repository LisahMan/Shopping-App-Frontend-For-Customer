import 'package:projectx_customer_app/models/shop.dart';

class Product{

  String _productId;
  String _name;
  String _shopId;
  String _shopName;
  String _category;
  String _typeOfProduct;
  int _price;
  bool _negotiable;
  String _color;
  String _size;
  String _description;
  DateTime _date;
  int _views;
  List<dynamic> _productImages;
  String _bagId;


  Product(this._productId,this._name,this._shopId,this._shopName,this._category,this._typeOfProduct,this._price,this._negotiable,this._color,this._size,this._description,this._date,this._productImages,this._views);

  String get productId => this._productId;
  String get name => this._name;
  String get shopId => this._shopId;
  String get shopName => this._shopName;
  String get category => this._category;
  String get typeOfProduct => this._typeOfProduct;
  int get price => this._price;
  bool get negotiable => this._negotiable;
  String get color => this._color;
  String get size => this._size;
  String get description => this._description;
  DateTime get date => this._date;
  int get views => this._views;
  List<dynamic> get productImages => this._productImages;
  String get bagId =>this._bagId;

  set productId(String productId){
    this._productId = productId;
  }

  set name(String name){
    this._name = name;
  }

  set shopId(String shopId){
    this._shopId = shopId;
  }

  set shopName(String shopName){
    this._shopName = shopName;
  }

  set category(String category){
    this._category = category;
  }

  set typeOfProduct(String typeOfProduct){
    this._typeOfProduct = typeOfProduct;
  }

  set price(int price){
    this._price = price;
  }

  set negotiable(bool negotiable){
    this._negotiable = negotiable;
  }

  set color(String color){
    this._color = color;
  }

  set size(String size){
    this._size = size;
  }

  set description(String description){
    this._description = description;
  }

  set productImages(List<dynamic> productImages){
    this._productImages = productImages;
  }

  set date(DateTime date){
    this._date = date;
  }

  set views(int views){
    this._views = views;
  }

  set bagId(String bagId){
    this._bagId = bagId;
  }


}