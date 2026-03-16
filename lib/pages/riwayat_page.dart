import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> riwayat = [];
  bool isLoading = true;
  bool selectionMode = false;
  Set<String> selectedIds = {};
  String search = '';
  String filterGame = 'Semua';
  List<String> gameOptions = ['Semua'];
  RealtimeChannel? _channel;

  List<Map<String, dynamic>> get filtered => riwayat.where((t) {
        final q = search.toLowerCase();
        final matchSearch = q.isEmpty ||
            (t['id_player'] ?? '').toLowerCase().contains(q) ||
            (t['email'] ?? '').toLowerCase().contains(q) ||
            (t['nama_game'] ?? '').toLowerCase().contains(q);
        return matchSearch &&
            (filterGame == 'Semua' || t['nama_game'] == filterGame);
      }).toList();

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('riwayat_transaksi')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transaksi',
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
      final data = await SupabaseService.fetchSelesaiWithCreator();
      final games =
          data.map((t) => t['nama_game'] as String).toSet().toList();
      setState(() {
        riwayat = data;
        gameOptions = ['Semua', ...games];
      });
    } catch (e) {
      _snack("Gagal: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _hapus() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.cardDark
                : Colors.white,
        title: Text("Hapus Riwayat", style: AppTheme.titleStyle),
        content: Text(
            "Hapus ${selectedIds.length} transaksi terpilih?",
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
        await SupabaseService.deleteTransaksiMultiple(
            selectedIds.toList());
        setState(() {
          selectedIds.clear();
          selectionMode = false;
        });
        _snack("Riwayat berhasil dihapus!");
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

  void _showDetail(Map<String, dynamic> t, bool isDark) {
    final createdAt = t['created_at'] != null
        ? DateTime.parse(t['created_at']).toLocal()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: AppTheme.radiusLarge,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppTheme.radiusMedium,
                      ),
                      child: const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Transaksi Selesai",
                            style: AppTheme.subtitleStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        if (createdAt != null)
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(createdAt),
                            style: AppTheme.bodyStyle.copyWith(
                                color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _detailRow(isDark, Icons.games_rounded, "Game",
                  t['nama_game'] ?? '-'),
              const SizedBox(height: 12),
              _detailRow(isDark, Icons.person_outline_rounded,
                  "ID Player", t['id_player'] ?? '-'),
              const SizedBox(height: 12),
              _detailRow(isDark, Icons.email_outlined, "Email",
                  t['email'] ?? '-'),
              const SizedBox(height: 12),
              _detailRow(isDark, Icons.shopping_bag_outlined, "Jumlah",
                  "${t['jumlah']} item"),
              const Divider(height: 28),
              _detailRow(
                isDark,
                Icons.person_pin_outlined,
                "Dibuat oleh",
                t['creator_email'] ?? 'Tidak diketahui',
                valueColor: AppTheme.primaryLight,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(bool isDark, IconData icon, String label,
      String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTheme.labelStyle
                      .copyWith(color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.subtitleStyle.copyWith(
                  color: valueColor ??
                      (isDark ? Colors.white : AppTheme.primary),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = filtered;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppTheme.primary,
            leading: selectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white),
                    onPressed: () => setState(() {
                      selectionMode = false;
                      selectedIds.clear();
                    }),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.cardGradient),
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
                          Text(
                            selectionMode
                                ? "${selectedIds.length} dipilih"
                                : "Riwayat Selesai",
                            style: AppTheme.displayStyle.copyWith(
                                color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text("${list.length} transaksi",
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
              if (selectionMode)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white),
                  onPressed: selectedIds.isEmpty ? null : _hapus,
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.white70),
                  onPressed: _load,
                ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setState(() => search = v),
                    style: AppTheme.bodyStyle.copyWith(
                        color:
                            isDark ? Colors.white : AppTheme.primary),
                    decoration: InputDecoration(
                      hintText: "Cari ID Player, Email, Game...",
                      hintStyle: AppTheme.bodyStyle
                          .copyWith(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppTheme.primaryLight, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppTheme.cardDark
                          : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.radiusMedium,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gameOptions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final opt = gameOptions[i];
                        final active = filterGame == opt;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => filterGame = opt),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? AppTheme.primaryGradient
                                  : null,
                              color: active
                                  ? null
                                  : (isDark
                                      ? AppTheme.cardDark
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(opt,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white60
                                          : Colors.grey.shade600),
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryLight),
              ),
            )
          else if (list.isEmpty)
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
                      child: const Icon(Icons.history_rounded,
                          size: 48, color: AppTheme.primaryLight),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      riwayat.isEmpty
                          ? "Belum ada riwayat"
                          : "Tidak ditemukan",
                      style: AppTheme.titleStyle.copyWith(
                          color: isDark
                              ? Colors.white70
                              : AppTheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      riwayat.isEmpty
                          ? "Transaksi selesai akan muncul di sini"
                          : "Coba kata kunci lain",
                      style: AppTheme.bodyStyle
                          .copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCard(list[i], isDark),
                  childCount: list.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _hapusSatu(Map<String, dynamic> t) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusLarge),
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        title: Text("Hapus Transaksi",
            style: AppTheme.titleStyle.copyWith(
                color: isDark ? Colors.white : AppTheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yakin hapus transaksi ini?",
                style:
                    AppTheme.bodyStyle.copyWith(color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: AppTheme.radiusMedium,
                border:
                    Border.all(color: Colors.red.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['nama_game'] ?? '',
                      style: AppTheme.subtitleStyle.copyWith(
                          color: isDark
                              ? Colors.white
                              : AppTheme.primary)),
                  const SizedBox(height: 4),
                  Text("ID: ${t['id_player']}",
                      style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey, fontSize: 13)),
                  Text("Email: ${t['email']}",
                      style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey, fontSize: 13)),
                  Text("Jumlah: ${t['jumlah']} item",
                      style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
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
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_rounded,
                  color: Colors.white, size: 16),
              label: Text("Hapus",
                  style: AppTheme.subtitleStyle
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await SupabaseService.deleteTransaksi(t['id'].toString());
        _snack("Transaksi berhasil dihapus!");
      } catch (e) {
        _snack("Gagal: $e", isError: true);
      }
    }
  }

  Widget _buildCard(Map<String, dynamic> t, bool isDark) {
    final id = t['id'].toString();
    final isSelected = selectedIds.contains(id);
    final createdAt = t['created_at'] != null
        ? DateTime.parse(t['created_at']).toLocal()
        : null;

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _hapusSatu(t);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: AppTheme.radiusLarge,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_rounded,
                color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text("Hapus",
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: GestureDetector(
        onLongPress: () => setState(() {
          selectionMode = true;
          selectedIds.add(id);
        }),
        onTap: () {
          if (selectionMode) {
            setState(() {
              if (isSelected) {
                selectedIds.remove(id);
                if (selectedIds.isEmpty) selectionMode = false;
              } else {
                selectedIds.add(id);
              }
            });
          } else {
            _showDetail(t, isDark);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.08)
                : (isDark ? AppTheme.cardDark : Colors.white),
            borderRadius: AppTheme.radiusLarge,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryLight
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected ? [] : AppTheme.softShadow,
          ),
          child: Row(
            children: [
              if (selectionMode)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryLight
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: AppTheme.radiusMedium,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(t['nama_game'] ?? '',
                              style: AppTheme.subtitleStyle.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.primary),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text("+${t['jumlah']}",
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.accentDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t['id_player'] ?? '',
                        style: AppTheme.bodyStyle.copyWith(
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontSize: 13)),
                    Text(t['email'] ?? '',
                        style: AppTheme.bodyStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 12)),
                    if (createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 11,
                                color: Colors.grey.shade400),
                            const SizedBox(width: 3),
                            Text(
                              DateFormat('dd MMM yyyy · HH:mm')
                                  .format(createdAt),
                              style: AppTheme.labelStyle.copyWith(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    if (t['creator_email'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.person_pin_outlined,
                                size: 11,
                                color: AppTheme.primaryLight
                                    .withOpacity(0.7)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                t['creator_email'],
                                style: AppTheme.labelStyle.copyWith(
                                    color: AppTheme.primaryLight
                                        .withOpacity(0.7),
                                    fontWeight: FontWeight.w400),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (!selectionMode) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _hapusSatu(t),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade500, size: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}