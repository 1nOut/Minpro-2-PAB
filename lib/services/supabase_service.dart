import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';
import '../models/transaksi.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;


  static Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> register(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;


  static Future<String> uploadGameImage(File imageFile) async {
    final fileExt = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'logos/$fileName';

    await _client.storage.from('game-logos').upload(
          filePath,
          imageFile,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
            upsert: false,
          ),
        );

    return _client.storage.from('game-logos').getPublicUrl(filePath);
  }

  static Future<String> uploadGameImageBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final fileExt = fileName.split('.').last.toLowerCase();
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'logos/$uniqueName';

    await _client.storage.from('game-logos').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
            upsert: false,
          ),
        );

    return _client.storage.from('game-logos').getPublicUrl(filePath);
  }


  static Future<List<Game>> fetchGames() async {
    final data = await _client
        .from('games')
        .select()
        .order('nama', ascending: true);
    return (data as List).map((e) => Game.fromMap(e)).toList();
  }

  static Future<void> addGame(Game game) async {
    await _client.from('games').insert(game.toMap());
  }

  static Future<void> updateGameStok(String id, int stok) async {
    await _client.from('games').update({'stok': stok}).eq('id', id);
  }

  static Future<void> deleteGame(String id) async {
    await _client.from('games').delete().eq('id', id);
  }


  static Future<List<Transaksi>> fetchPending() async {
    final data = await _client
        .from('transaksi')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true);
    return (data as List).map((e) => Transaksi.fromMap(e)).toList();
  }

  static Future<List<Transaksi>> fetchSelesai() async {
    final data = await _client
        .from('transaksi')
        .select()
        .eq('status', 'selesai')
        .order('created_at', ascending: false);
    return (data as List).map((e) => Transaksi.fromMap(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchSelesaiWithCreator() async {
    final transaksiData = await _client
        .from('transaksi')
        .select()
        .eq('status', 'selesai')
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> result = [];

    for (final t in transaksiData as List) {
      final map = Map<String, dynamic>.from(t);

      try {
        final userId = t['user_id'];
        if (userId != null) {
          final profile = await _client
              .from('profiles')
              .select('email')
              .eq('id', userId)
              .maybeSingle();
          map['creator_email'] = profile?['email'];
        } else {
          map['creator_email'] = null;
        }
      } catch (_) {
        map['creator_email'] = null;
      }

      result.add(map);
    }

    return result;
  }

  static Future<void> addTransaksi(Transaksi transaksi) async {
    final userId = currentUser?.id;
    final map = transaksi.toMap();
    map['user_id'] = userId;
    await _client.from('transaksi').insert(map);
  }

  static Future<void> konfirmasiTopUp({
    required String transaksiId,
    required String gameId,
    required int jumlah,
    required int stokSaatIni,
  }) async {
    await _client
        .from('transaksi')
        .update({'status': 'selesai'})
        .eq('id', transaksiId);
    await _client
        .from('games')
        .update({'stok': stokSaatIni - jumlah})
        .eq('id', gameId);
  }

  static Future<void> updateTransaksi(String id, Transaksi transaksi) async {
    await _client.from('transaksi').update(transaksi.toMap()).eq('id', id);
  }

  static Future<void> deleteTransaksi(String id) async {
    await _client.from('transaksi').delete().eq('id', id);
  }

  static Future<void> deleteTransaksiMultiple(List<String> ids) async {
    await _client.from('transaksi').delete().inFilter('id', ids);
  }
}