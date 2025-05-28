import 'dart:convert';

List<User> userFromJsonArry(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

class User {
  final int id;
  final String name;
  final String email;

  User({
    this.id,
    this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json['name'],
      email: json['email'],
    );
  }
}
