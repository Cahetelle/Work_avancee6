import 'package:uuid/uuid.dart';

class Utilisateur {
  String id;
  String username;
  String password;
  String? email;

  Utilisateur({
    String? id,
    required this.username,
    required this.password,
    this.email,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] ?? const Uuid().v4(),
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'],
    );
  }

  @override
  String toString() => 'Utilisateur($username)';
}

