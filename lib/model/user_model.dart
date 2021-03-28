class UserModel {
  // DB id
  int id;
  // the name of the user.
  String name;
  // the user is at the moment logger
  bool logged;
  // This propriety meaning that the user make the
  // login one time with google or other meccanism
  bool initialized;

  UserModel({this.id, this.name, this.logged, this.initialized});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}
