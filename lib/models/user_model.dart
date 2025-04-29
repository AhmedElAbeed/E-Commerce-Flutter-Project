class UserModel {
  String? uid;
  String? email;
  String? name;
  String? role; // <-- NEW field

  UserModel({this.uid, this.email, this.name, this.role});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role ?? 'user', // default role
    };
  }
}
