import 'package:pets/models/forum.dart';
import 'package:pets/models/pet.dart';

class User {
  final int id;
  final String? name;
  final String? lastname;
  final String email;
  final String? address;
  final String password;
  final String cp;
  final String? birthday;
  final String? mainImage;
  final List<Forum>? foro;
  final List<Pet> pets;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.address,
    required this.password,
    required this.cp,
    required this.birthday,
    required this.mainImage,
    required this.foro,
    required this.pets,
  });

  factory User.fromJson(Map<String, dynamic> json) {

    List<Pet> petList = [];

    // Verifica si json['pets'] es nulo
    var petsFromJson = json['pets'] as List?;

    // Si petsFromJson es nulo, usa una lista vacía
    petList = petsFromJson != null
        ? petsFromJson.map((i) => Pet.fromJson(i)).toList()
        : [];


    return User(
      id: json['id'],
      name: json['name'],
      lastname: json['lastName'],
      email: json['email'],
      address: json['address'],
      password: json['password'],
      cp: json['postalCode'],
      birthday: json['birthday'],
      mainImage: json['mainimage'],
      foro: [], // Debes definir cómo manejar la lista de foros en tu aplicación
      pets: petList ?? [],
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
      'mainimage': mainImage,
      'foro': foro!.map((forum) => forum.toJson()).toList(),
      'pets': pets.map((pet) => pet.toJson()).toList(),
    };
  }
}
