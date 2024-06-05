class Config {
  final String host;

  Config({required this.host});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(host: json['host']);
  }
}