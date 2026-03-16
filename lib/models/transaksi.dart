class Transaksi {
  final String? id;
  String namaGame;
  String idPlayer;
  int jumlah;
  String email;
  String status; 
  DateTime? createdAt;

  Transaksi({
    this.id,
    required this.namaGame,
    required this.idPlayer,
    required this.jumlah,
    required this.email,
    this.status = 'pending',
    this.createdAt,
  });

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'].toString(),
      namaGame: map['nama_game'] ?? '',
      idPlayer: map['id_player'] ?? '',
      jumlah: map['jumlah'] ?? 0,
      email: map['email'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_game': namaGame,
      'id_player': idPlayer,
      'jumlah': jumlah,
      'email': email,
      'status': status,
    };
  }
}
