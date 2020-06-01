class Shop{
  String _shopId;
  String _shopName;
  String _district;
  String _address;
  String _phoneNumber;
  String _shopPic;
  String _description;
  DateTime _date;
  int _views;
  bool _liked;

  //Shop(this._shopId,this._shopOwner,this._shopName,this._district,this._address,this._phoneNumber,this._shopPic,this._description,this._date,this._views);

  Shop(String shopId,String shopName,String district,String address,String phoneNumber,String shopPic,String description,DateTime date,int views){
   this._shopId=shopId;
   this._shopName=shopName;
   this._district=district;
   this._address=address;
   this._phoneNumber=phoneNumber;
   this._shopPic=shopPic;
   this._description=description;
   this._date = date;
   this._views=views;
  }

  String get shopId=>this._shopId;
  String get shopName=>this._shopName;
  String get district=>this._district;
  String get address =>this._address;
  String get phoneNumber=>this._phoneNumber;
  String get shopPic=>this._shopPic;
  String get description=>this._description;
  int get views => this._views;
  DateTime get date=>this._date;
  bool get liked=>this._liked;

  void set shopId(String shopId){
    this._shopId=shopId;
  }

  void set shopName(String shopName){
    this._shopName = shopName;
  }

  void set district(String district){
    this._district = district;
  }

  void set address(String address){
    this._address = address;
  }

  void set phoneNumber(String phoneNumber){
    this._phoneNumber=phoneNumber;
  }

  void set shopPic(String shopPic){
    this._shopPic = shopPic;
  }

  void set description(String description){
    this._description = description;
  }

  void set date(DateTime date){
    this._date = date;
  }

  void set views(int views){
    this._views = views;
  }

  void set liked(bool liked){
    this._liked = liked;
  }
}