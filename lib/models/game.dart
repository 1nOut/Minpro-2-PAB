class Game {
  final String id;
  String nama;
  String logo;
  int stok;

  Game({
    required this.id,
    required this.nama,
    required this.logo,
    required this.stok,
  });

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'].toString(),
      nama: map['nama'] ?? '',
      logo: map['logo'] ?? 'assets/image/ml.png',
      stok: map['stok'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'logo': logo,
      'stok': stok,
    };
  }
}
