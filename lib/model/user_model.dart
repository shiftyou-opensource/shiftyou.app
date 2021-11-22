class UserModel {
  // DB id
  int? id;
  // the name of the user.
  String name;
  // Email of the user
  String email;
  // the user is at the moment logger
  bool logged;
  // This propriety meaning that the user make the
  // login one time with google or other mechanism
  bool initialized;

  UserModel(
      {this.id,
      required this.name,
      required this.email,
      required this.logged,
      required this.initialized});

  void bind(UserModel userModel) {
    if (userModel.id != null) this.id = userModel.id;
    this.name = userModel.name;
    this.email = userModel.email;
    this.initialized = userModel.initialized;
    this.logged = userModel.logged;
  }

  Map<String, dynamic> toMap({bool update = false}) {
    var mapEncoding = {
      "name": name,
      "email": email,
      "logged": logged == true ? 1 : 0,
    };
    if (id != null && !update) {
      mapEncoding["id"] = id!;
    }
    return mapEncoding;
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, logged: $logged, initialized: $initialized}';
  }
}
