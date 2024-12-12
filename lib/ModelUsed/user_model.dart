class UserModel {
  String? uid;
  String? name;
  String? email;
  String? profilePic;

  UserModel({this.uid, this.name, this.email, this.profilePic});

  UserModel.fromJson(Map<String, dynamic> map) {
    uid = map["uid"] ?? "";
    name = map["name"] ?? "";
    email = map["email"] ?? "";
    profilePic = map["profilePic"] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "profilePic": profilePic
    }; //toJson should contains key names used in fromJson
  }
}
