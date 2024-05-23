import 'package:pets/models/Forum.dart';
import 'package:pets/models/pet.dart';

class User {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String address;
  final String password;
  final int cp;
  final String birthday;
  final String mainImage;
  final List<Forum> foro;
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
    return User(
      id: json['id'],
      name: json['name'],
      lastname: json['lastname'],
      email: json['email'],
      address: json['address'],
      password: json['password'],
      cp: json['cp'],
      birthday: json['birthday'],
      mainImage: json['mainimage'],
      foro: [], // Debes definir cómo manejar la lista de foros en tu aplicación
      pets: [], // Debes definir cómo manejar la lista de mascotas en tu aplicación
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'address': address,
      'password': password,
      'cp': cp,
      'birthday': birthday,
      'mainimage': mainImage,
      'foro': foro.map((forum) => forum.toJson()).toList(),
      'pets': pets.map((pet) => pet.toJson()).toList(),
    };
  }
}
