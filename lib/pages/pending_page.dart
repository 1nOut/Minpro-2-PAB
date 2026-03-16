import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';
import '../models/transaksi.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class PendingPage extends StatefulWidget {
  const PendingPage({super.key});

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  List<Transaksi> pending = [];
  List<Game> games = [];
  bool isLoading = true;
  RealtimeChannel? _channelTransaksi;
  RealtimeChannel? _channelGames;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    // Subscribe perubahan transaksi
    _channelTransaksi = Supabase.instance.client
        .channel('pending_transaksi')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transaksi',
          callback: (payload) {
            if (mounted) _load();
          },
        )
        .subscribe();

    // Subscribe perubahan games (untuk info stok terkini)
    _channelGames = Supabase.instance.client
        .channel('pending_games')
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
    _channelTransaksi?.unsubscribe();
    _channelGames?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res = await Future.wait([
        SupabaseService.fetchPending(),
        SupabaseService.fetchGames(),
      ]);
      setState(() {
        pending = res[0] as List<Transaksi>;
        games = res[1] as List<Game>;
      });
    } catch (e) {
      _snack("Gagal memuat: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Game? _game(String nama) {
    try {
      return games.firstWhere(
          (g) => g.nama.toLowerCase() == nama.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> _konfirmasi(Transaksi t) async {
    final game = _game(t.namaGame);
    if (game == null) {
      _snack("Game tidak ditemukan!", isError: true);
      return;
    }
    if (t.jumlah > game.stok) {
      _snack("Stok kurang! Tersedia: ${game.stok}", isError: true);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(transaksi: t, game: game),
    );
    if (ok != true) return;
    try {
      await SupabaseService.konfirmasiTopUp(
        transaksiId: t.id!,
        gameId: game.id,
        jumlah: t.jumlah,
        stokSaatIni: game.stok,
      );
      _snack("Top Up ${t.namaGame} berhasil diproses!");
    } catch (e) {
      _snack("Gagal: $e", isError: true);
    }
  }

  Future<void> _tolak(Transaksi t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.cardDark
                : Colors.white,
        title: Text("Tolak Permintaan",
            style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.primary)),
        content: Text(
            "Yakin ingin menolak permintaan dari ${t.idPlayer}?",
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
              child: Text("Tolak & Hapus",
                  style: AppTheme.subtitleStyle
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await SupabaseService.deleteTransaksi(t.id!);
        _snack("Permintaan ditolak.");
      } catch (e) {
        _snack("Gagal: $e", isError: true);
      }
    }
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
            backgroundColor: const Color(0xFFD35400),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade800,
                      Colors.orange.shade600
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
                          color: Colors.white.withOpacity(0.06),
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
                          Row(
                            children: [
                              Text("Antrian Pending",
                                  style: AppTheme.displayStyle.copyWith(
                                      color: Colors.white,
                                      fontSize: 22)),
                              const SizedBox(width: 12),
                              if (pending.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withOpacity(0.25),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text("${pending.length}",
                                      style:
                                          GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      )),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Proses permintaan top up",
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
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white70),
              ),
            ],
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryLight),
              ),
            )
          else if (pending.isEmpty)
            SliverFillRemaining(child: _emptyState(isDark))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCard(pending[i], isDark),
                  childCount: pending.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(Transaksi t, bool isDark) {
    final game = _game(t.namaGame);
    final cukup = game != null && t.jumlah <= game.stok;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(
          color: cukup
              ? Colors.orange.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cukup
                    ? [Colors.orange.shade700, Colors.orange.shade500]
                    : [Colors.red.shade700, Colors.red.shade500],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Icon(
                  cukup
                      ? Icons.hourglass_top_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                    cukup
                        ? "Menunggu Proses"
                        : "Stok Tidak Cukup",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const Spacer(),
                if (t.createdAt != null)
                  Text(
                    DateFormat('dd MMM · HH:mm')
                        .format(t.createdAt!.toLocal()),
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: AppTheme.radiusSmall,
                      ),
                      child: Text(t.namaGame,
                          style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: AppTheme.radiusSmall,
                      ),
                      child: Text("+${t.jumlah} item",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRow(isDark, Icons.person_outline_rounded,
                    "ID Player", t.idPlayer),
                const SizedBox(height: 8),
                _infoRow(isDark, Icons.email_outlined, "Email", t.email),
                const SizedBox(height: 8),
                _infoRow(
                  isDark,
                  Icons.inventory_2_outlined,
                  "Stok Tersedia",
                  game != null
                      ? "${game.stok} item"
                      : "Game tidak ditemukan",
                  valueColor: game != null
                      ? (cukup ? AppTheme.accentDark : Colors.red.shade600)
                      : Colors.grey,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _tolak(t),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.red.shade400, width: 1.5),
                            borderRadius: AppTheme.radiusMedium,
                          ),
                          child: Center(
                            child: Text("Tolak",
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.red.shade500,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: cukup ? () => _konfirmasi(t) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: cukup
                                ? const LinearGradient(colors: [
                                    Color(0xFF0D3B24),
                                    Color(0xFF1A6B41)
                                  ])
                                : null,
                            color:
                                cukup ? null : Colors.grey.shade200,
                            borderRadius: AppTheme.radiusMedium,
                            boxShadow: cukup
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: cukup
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    size: 18),
                                const SizedBox(width: 6),
                                Text("Proses Top Up",
                                    style: GoogleFonts.plusJakartaSans(
                                        color: cukup
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(bool isDark, IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppTheme.primaryLight),
        ),
        const SizedBox(width: 10),
        Text("$label: ",
            style: AppTheme.labelStyle.copyWith(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyStyle.copyWith(
              color: valueColor ??
                  (isDark ? Colors.white : AppTheme.primary),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded,
                size: 52, color: Colors.green.shade400),
          ),
          const SizedBox(height: 20),
          Text("Semua Sudah Diproses!",
              style: AppTheme.titleStyle.copyWith(
                  color: isDark ? Colors.white : AppTheme.primary)),
          const SizedBox(height: 8),
          Text("Tidak ada antrian top up saat ini",
              style: AppTheme.bodyStyle.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final Transaksi transaksi;
  final Game game;

  const _ConfirmDialog({required this.transaksi, required this.game});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text("Konfirmasi Top Up",
                    style: AppTheme.titleStyle
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text("Pastikan data sudah benar",
                    style: AppTheme.bodyStyle
                        .copyWith(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _row(isDark, "Game", transaksi.namaGame),
                _row(isDark, "ID Player", transaksi.idPlayer),
                _row(isDark, "Email", transaksi.email),
                _row(isDark, "Jumlah", "${transaksi.jumlah} item"),
                const Divider(height: 24),
                _row(isDark, "Stok Setelah",
                    "${game.stok - transaksi.jumlah} item",
                    highlight: true),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Batal",
              style:
                  AppTheme.subtitleStyle.copyWith(color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.radiusSmall),
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Proses Sekarang",
                style: AppTheme.subtitleStyle
                    .copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _row(bool isDark, String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTheme.labelStyle.copyWith(color: Colors.grey)),
          Text(value,
              style: AppTheme.subtitleStyle.copyWith(
                color: highlight
                    ? AppTheme.accentDark
                    : (isDark ? Colors.white : AppTheme.primary),
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}