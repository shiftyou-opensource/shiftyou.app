class UserModel {
  // DB id
  int id;
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
      {required this.id,
      required this.name,
      required this.email,
      required this.logged,
      required this.initialized});

  void bind(UserModel userModel) {
    this.id = userModel.id;
    this.name = userModel.name;
    this.email = userModel.email;
    this.initialized = userModel.initialized;
    this.logged = userModel.logged;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "logged": logged,
    };
  }
}
