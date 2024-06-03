import 'package:pets/models/forum.dart';
import 'package:pets/models/pet.dart';

class User {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String address;
  final String password;
  final String cp;
  final String birthday;
  // final List<Forum>? foro;
  final List<Pet>? pets;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.address,
    required this.password,
    required this.cp,
    required this.birthday,
    // required this.foro,
    required this.pets,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<Pet> petList = [];
    List<Forum> forumList = [];

    // Verifica si json['pets'] es nulo y convierte a lista de Pet
    if (json['pets'] != null) {
      var petsFromJson = json['pets'] as List?;
      petList = petsFromJson != null
          ? petsFromJson.map((i) => Pet.fromJson(i)).toList()
          : [];
    }

    // Verifica si json['foro'] es nulo y convierte a lista de Forum
    // if (json['foro'] != null) {
    //   var foroFromJson = json['foro'] as List?;
    //   forumList = foroFromJson != null
    //       ? foroFromJson.map((i) => Forum.fromJson(i)).toList()
    //       : [];
    // }

    return User(
      id: json['id'].toString(),
      name: json['name'],
      lastname: json['lastName'],
      email: json['email'],
      address: json['address'],
      password: json['password'],
      cp: json['postalCode'].toString(), // Conversión a String
      birthday: json['birthday'],
      // foro: forumList,
      pets: petList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastname,
      'email': email,
      'address': address,
      'password': password,
      'postalCode': cp,
      'birthday': birthday,
      // 'foro': foro?.map((forum) => forum.toJson()).toList() ?? [],
      'pets': pets?.map((pet) => pet.toJson()).toList() ?? [],
    };
  }
}
