class Pet {
  final String id;
  final String nombre;
  final String tipoAnimal;
  final String raza;
  final double peso;
  final String genero;
  final bool chip;
  final String idUsuario;
  final String imagen;
  final List<String> eventos;

  Pet({
    required this.id,
    required this.nombre,
    required this.tipoAnimal,
    required this.raza,
    required this.peso,
    required this.genero,
    required this.chip,
    required this.idUsuario,
    required this.imagen,
    required this.eventos,
  });

  // Factory constructor to create a Pet from JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? '',
      nombre: json['name'] ?? '',
      tipoAnimal: json['animal'] ?? '',
      raza: json['race'] ?? '',
      peso: json['weight'] ?? 0.0,
      genero: json['gender'] ?? '',
      chip: json['chip'] ?? 0,
      idUsuario: json['id_user'] ?? '',
      imagen: json['petImg'] ?? '',
      eventos: List<String>.from(json['eventos'] ?? []),
    );
  }

  // Method to convert a Pet to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'name': nombre ?? '',
      'animal': tipoAnimal ?? '',
      'race': raza ?? '',
      'weight': peso ?? 0.0,
      'gender': genero ?? '',
      'chip': chip ?? 0,
      'id_user': idUsuario ?? '',
      'petImg': imagen ?? '',
      'eventos': eventos ?? [],
    };
  }
}
