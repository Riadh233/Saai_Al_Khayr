class User {
  final int? id;
  final String? token;
  final String firstName;
  final String lastName;
  final String password;
  final String? number;
  final String? carNumber;
  final UserRole status;
  final double? lat;
  final double? lng;

  const User({
    this.id,
    this.token,
    required this.lastName,
    required this.firstName,
    required this.password,
    this.number,
    this.carNumber,
    this.status = UserRole.driver,
    this.lat,
    this.lng
  });
Map<String, dynamic> getUpdatedFields(User oldUser, User updatedUser) {
  final Map<String, dynamic> updatedFields = {};

  if (oldUser.firstName != updatedUser.firstName) {
    updatedFields['name'] = updatedUser.firstName;
  }
  if (oldUser.lastName != updatedUser.lastName) {
    updatedFields['famillyName'] = updatedUser.lastName;
  }
  if (oldUser.password != updatedUser.password) {
    updatedFields['email'] = updatedUser.password;
  }
  if (oldUser.number != updatedUser.number) {
    updatedFields['number'] = updatedUser.number;
  }
  if (oldUser.carNumber != updatedUser.carNumber) {
    updatedFields['carNumber'] = updatedUser.carNumber;
  }
  if (oldUser.status != updatedUser.status) {
    updatedFields['role'] = updatedUser.status.name; // or updatedUser.status.toString() if needed
  }

  return updatedFields;
}

  static const empty = User(id: -1, token: '', lastName: '', firstName: '', password: '');

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      lastName: json['famillyname'],
      firstName: json['name'],
      password: json['plain_password'],
      status: getRole(json['role']),
      number: json['phone'],
      carNumber: json['car_number']
    );
  }
  factory User.fromDriverJson(Map<String, dynamic> json) {
    return User(
      lastName: json['famillyname'],
      firstName: json['name'],
      password: '',
      status: UserRole.driver,
      number: json['phone'],
      carNumber: json['car_number']
    );
  }
  factory User.fromMissionsJson(Map<String, dynamic> json) {
    return User(
      lastName: json['famillyname'],
      firstName: json['name'],
      password: '',
      status: UserRole.driver,
      number: '',
      carNumber: ''
    );
  }
  factory User.fromImamJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['name'],
      lastName: json['famillyname'] ,
      password: '',
      status: UserRole.imam,
      number: json['phone'],
    );
  }
  factory User.fromImamWithoutCoordinates(Map<String, dynamic> json){
    return User(id:json['id'], lastName: json['famillyname'], firstName: json['name'], password: '');
  }
  static UserRole getRole(String role){
    if(role == 'imam') {
      return UserRole.imam;
    }
    if(role == 'admin'){
      return UserRole.admin;
    }
    return UserRole.driver;
  }
}
enum UserRole {admin, imam, driver}
