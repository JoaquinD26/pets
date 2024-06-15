import 'dart:convert';

class Pet {
  int id;
  String name;
  String animal;
  String race;
  double weight;
  int gender;
  int chip;
  String petImg;
  List<String> eventos;

  Pet({
    required this.id,
    required this.name,
    required this.animal,
    required this.race,
    required this.weight,
    required this.gender,
    required this.chip,
    required this.petImg,
    required this.eventos,
  });

  // Factory constructor to create a Pet from JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? 0,
      name: utf8.decode(json['name'].toString().codeUnits),
      animal: utf8.decode(json['animal'].toString().codeUnits),
      race: json['race'] != null ? utf8.decode(json['race'].toString().codeUnits)  : '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      gender: json['gender'] ?? 0,
      chip: json['chip'] ?? 0,
      petImg: json['profileImage'] ?? '',
      eventos: List<String>.from(json['eventos'] ?? []),
    );
  }

  // Method to convert a Pet to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'animal': animal,
      'race': race,
      'weight': weight,
      'gender': gender,
      'chip': chip,
      'profileImage': petImg,
      'eventos': eventos,
    };
  }
}
