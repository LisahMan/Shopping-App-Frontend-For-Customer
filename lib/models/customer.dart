class Customer{
  String _customerId;
  String _username;
  String _mobileNumber;
  DateTime _dob;
  String _district;
  String _address;
  String _sex;

  Customer(this._customerId,this._username,this._mobileNumber,this._dob,this._district,this._address,this._sex);

  String get customerId=>this._customerId;
  String get username=>this._username;
  String get mobileNumber=>this._mobileNumber;
  DateTime get dob=>this._dob;
  String get district=>this._district;
  String get address=>this._address;
  String get sex=>this._sex;
}