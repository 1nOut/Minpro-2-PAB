import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_image.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Game> games = [];
  bool isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('inventory_games')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'games',
          callback: (payload) {
            if (mounted) _load();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      games = await SupabaseService.fetchGames();
    } catch (e) {
      _snack("Gagal memuat: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color _stokColor(int stok) {
    if (stok == 0) return Colors.red.shade600;
    if (stok < 500) return Colors.orange.shade600;
    return AppTheme.accentDark;
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontWeight: FontWeight.w500)),
      backgroundColor:
          isError ? Colors.red.shade600 : AppTheme.accentDark,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showAddDialog() {
    final namaCtrl = TextEditingController();
    final stokCtrl = TextEditingController();
    XFile? selectedImage;
    Uint8List? imageBytes;
    bool isUploading = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Tambah Game Baru",
                  style: AppTheme.titleStyle.copyWith(
                      color: isDark ? Colors.white : AppTheme.primary)),
              const SizedBox(height: 4),
              Text("Lengkapi informasi game",
                  style: AppTheme.bodyStyle.copyWith(color: Colors.grey)),
              const SizedBox(height: 24),
              Text("Logo / Gambar Game",
                  style: AppTheme.labelStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : Colors.grey.shade600)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    final bytes = await picked.readAsBytes();
                    setS(() {
                      selectedImage = picked;
                      imageBytes = bytes;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: selectedImage != null
                        ? Colors.transparent
                        : (isDark
                            ? AppTheme.cardDark
                            : Colors.grey.shade50),
                    borderRadius: AppTheme.radiusLarge,
                    border: Border.all(
                      color: selectedImage != null
                          ? AppTheme.primaryLight
                          : Colors.grey.shade300,
                      width: selectedImage != null ? 2 : 1.5,
                    ),
                  ),
                  child: selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: AppTheme.radiusLarge,
                              child: kIsWeb
                                  ? Image.memory(imageBytes!,
                                      width: double.infinity,
                                      height: 130,
                                      fit: BoxFit.cover)
                                  : Image.file(
                                      File(selectedImage!.path),
                                      width: double.infinity,
                                      height: 130,
                                      fit: BoxFit.cover),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text("Ganti",
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: AppTheme.primaryLight,
                                  size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text("Tap untuk pilih gambar",
                                style: AppTheme.subtitleStyle.copyWith(
                                    color: AppTheme.primaryLight)),
                            const SizedBox(height: 4),
                            Text("Dari galeri perangkatmu",
                                style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),
              _sheetField(namaCtrl, "Nama Game",
                  Icons.games_rounded, isDark),
              const SizedBox(height: 14),
              _sheetField(stokCtrl, "Stok Awal",
                  Icons.inventory_2_outlined, isDark,
                  type: TextInputType.number),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: isUploading
                    ? null
                    : () async {
                        final nama = namaCtrl.text.trim();
                        final stok =
                            int.tryParse(stokCtrl.text.trim());
                        if (selectedImage == null) {
                          _snack("Pilih gambar game terlebih dahulu!",
                              isError: true);
                          return;
                        }
                        if (nama.isEmpty) {
                          _snack("Nama game wajib diisi!",
                              isError: true);
                          return;
                        }
                        if (stok == null || stok < 0) {
                          _snack("Stok tidak valid!", isError: true);
                          return;
                        }
                        setS(() => isUploading = true);
                        try {
                          final imageUrl = await SupabaseService
                              .uploadGameImageBytes(
                            bytes: imageBytes!,
                            fileName: selectedImage!.name,
                          );
                          await SupabaseService.addGame(Game(
                            id: '',
                            nama: nama,
                            logo: imageUrl,
                            stok: stok,
                          ));
                          if (ctx.mounted) Navigator.pop(ctx);
                          _snack("Game '$nama' berhasil ditambahkan!");
                        } catch (e) {
                          _snack("Gagal: $e", isError: true);
                        } finally {
                          if (ctx.mounted)
                            setS(() => isUploading = false);
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient:
                        isUploading ? null : AppTheme.primaryGradient,
                    color: isUploading ? Colors.grey.shade300 : null,
                    borderRadius: AppTheme.radiusMedium,
                    boxShadow:
                        isUploading ? [] : AppTheme.cardShadow,
                  ),
                  child: Center(
                    child: isUploading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text("Mengupload...",
                                  style: AppTheme.subtitleStyle
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.save_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text("Tambah Game",
                                  style: AppTheme.subtitleStyle
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showEditDialog(Game game) {
    final stokCtrl =
        TextEditingController(text: game.stok.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GameImage(logo: game.logo, size: 48),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Edit Stok",
                        style: AppTheme.titleStyle.copyWith(
                            color:
                                isDark ? Colors.white : AppTheme.primary)),
                    Text(game.nama,
                        style: AppTheme.subtitleStyle
                            .copyWith(color: AppTheme.primaryLight)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sheetField(stokCtrl, "Jumlah Stok Baru",
                Icons.inventory_2_outlined, isDark,
                type: TextInputType.number),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final stok = int.tryParse(stokCtrl.text);
                if (stok == null || stok < 0) {
                  _snack("Stok tidak valid!", isError: true);
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await SupabaseService.updateGameStok(game.id, stok);
                  _snack("Stok ${game.nama} berhasil diperbarui!");
                } catch (e) {
                  _snack("Gagal: $e", isError: true);
                }
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.radiusMedium,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Center(
                  child: Text("Simpan Perubahan",
                      style: AppTheme.subtitleStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGame(Game game) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.cardDark
                : Colors.white,
        title: Text("Hapus Game", style: AppTheme.titleStyle),
        content: Text(
            "Yakin hapus ${game.nama}? Data tidak dapat dikembalikan.",
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal",
                style: AppTheme.subtitleStyle
                    .copyWith(color: AppTheme.primaryLight)),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: AppTheme.radiusSmall),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Hapus",
                  style: AppTheme.subtitleStyle
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await SupabaseService.deleteGame(game.id);
        _snack("${game.nama} berhasil dihapus!");
      } catch (e) {
        _snack("Gagal: $e", isError: true);
      }
    }
  }

  Widget _sheetField(TextEditingController ctrl, String label,
      IconData icon, bool isDark,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: AppTheme.bodyStyle.copyWith(
          color: isDark ? Colors.white : AppTheme.primary,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyStyle.copyWith(color: Colors.grey),
        prefixIcon:
            Icon(icon, color: AppTheme.primaryLight, size: 20),
        filled: true,
        fillColor: isDark ? AppTheme.bgDark : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide:
              const BorderSide(color: AppTheme.primaryLight, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Inventory",
                              style: AppTheme.displayStyle.copyWith(
                                  color: Colors.white, fontSize: 24)),
                          const SizedBox(height: 4),
                          Text("${games.length} game terdaftar",
                              style: AppTheme.bodyStyle
                                  .copyWith(color: Colors.white60)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showAddDialog,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryLight)),
            )
          else if (games.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_outlined,
                          size: 48, color: AppTheme.primaryLight),
                    ),
                    const SizedBox(height: 20),
                    Text("Belum ada game",
                        style: AppTheme.titleStyle.copyWith(
                            color: isDark
                                ? Colors.white
                                : AppTheme.primary)),
                    const SizedBox(height: 8),
                    Text("Tap + untuk menambah game",
                        style: AppTheme.bodyStyle
                            .copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildItem(games[i], isDark),
                  childCount: games.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(Game game, bool isDark) {
    final stokColor = _stokColor(game.stok);
    final stokPct =
        game.stok > 0 ? (game.stok / 5000).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          GameImage(logo: game.logo, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.nama,
                    style: AppTheme.subtitleStyle.copyWith(
                        color:
                            isDark ? Colors.white : AppTheme.primary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 13, color: stokColor),
                    const SizedBox(width: 4),
                    Text(
                      game.stok > 0
                          ? "${game.stok} item"
                          : "Stok Habis",
                      style: AppTheme.labelStyle
                          .copyWith(color: stokColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stokPct,
                    minHeight: 5,
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(stokColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _actionBtn(
                icon: Icons.edit_outlined,
                color: AppTheme.primaryLight,
                onTap: () => _showEditDialog(game),
              ),
              const SizedBox(height: 8),
              _actionBtn(
                icon: Icons.delete_outline_rounded,
                color: Colors.red.shade500,
                onTap: () => _deleteGame(game),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}