import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_image.dart';
import 'form_topup_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Game> games = [];
  bool isLoading = true;
  late AnimationController _staggerCtrl;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _loadGames();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('home_games')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'games',
          callback: (payload) {
            if (mounted) _loadGames();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => isLoading = true);
    try {
      games = await SupabaseService.fetchGames();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal memuat: $e"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
        _staggerCtrl.forward(from: 0);
      }
    }
  }

  List<Color> _cardColors(int index) {
    const gradients = [
      [Color(0xFF0D3B24), Color(0xFF1A6B41)],
      [Color(0xFF1A237E), Color(0xFF283593)],
      [Color(0xFF4A148C), Color(0xFF6A1B9A)],
      [Color(0xFFB71C1C), Color(0xFFD32F2F)],
      [Color(0xFF004D40), Color(0xFF00695C)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -40,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Top Up Game",
                              style: AppTheme.displayStyle.copyWith(
                                  color: Colors.white, fontSize: 24)),
                          const SizedBox(height: 4),
                          Text("Pilih game untuk top up",
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
                onPressed: _loadGames,
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
          else if (games.isEmpty)
            SliverFillRemaining(child: _emptyState(isDark))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildGameCard(i, isDark),
                  childCount: games.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameCard(int index, bool isDark) {
    final game = games[index];
    final colors = _cardColors(index);
    final delay = index * 0.1;

    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (_, child) {
        final t = (_staggerCtrl.value - delay).clamp(0.0, 1.0);
        final curved = Curves.easeOut.transform(t);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curved)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FormTopUpPage(game: game)),
          );
          _loadGames();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppTheme.radiusLarge,
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -15,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GameImage(
                      logo: game.logo,
                      size: 60,
                      fit: BoxFit.cover,
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.nama,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: game.stok > 0
                                ? Colors.white.withOpacity(0.2)
                                : Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                game.stok > 0
                                    ? Icons.inventory_2_outlined
                                    : Icons.remove_circle_outline,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                game.stok > 0
                                    ? "${game.stok} stok"
                                    : "Habis",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.games_outlined,
                size: 48, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 20),
          Text("Belum ada game",
              style: AppTheme.titleStyle.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.primary)),
          const SizedBox(height: 8),
          Text("Tambah game di halaman Inventory",
              style: AppTheme.bodyStyle.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}