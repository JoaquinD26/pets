class Pet {
  final int id;
  final String name;
  final String animal;
  final String race;
  final double weight;
  final int gender;
  final bool chip;
  final String idUser;
  final String petImg;
  final List<String> eventos;

  Pet({
    required this.id,
    required this.name,
    required this.animal,
    required this.race,
    required this.weight,
    required this.gender,
    required this.chip,
    required this.idUser,
    required this.petImg,
    required this.eventos,
  });

  // Factory constructor to create a Pet from JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      animal: json['animal'] ?? '',
      race: json['race'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      gender: json['gender'] ?? 0,
      chip: json['chip'] ?? false,
      idUser: json['id_user'] ?? '',
      petImg: json['petImg'] ?? '',
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
      'id_user': idUser,
      'petImg': petImg,
      'eventos': eventos,
    };
  }
}
