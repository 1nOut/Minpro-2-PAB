import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../pages/home_page.dart';
import 'inventory_page.dart';
import 'pending_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainPage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    InventoryPage(),
    PendingPage(),
    RiwayatPage(),
  ];

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.cardDark
                : Colors.white,
        title: Text("Keluar",
            style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.primary)),
        content: Text("Apakah kamu yakin ingin keluar?",
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
              borderRadius: AppTheme.radiusSmall,
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Keluar",
                  style: AppTheme.subtitleStyle
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await SupabaseService.logout();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, "Home"),
                _navItem(1, Icons.inventory_2_rounded,
                    Icons.inventory_2_outlined, "Inventory"),
                _navItem(2, Icons.pending_actions_rounded,
                    Icons.pending_actions_outlined, "Pending"),
                _navItem(3, Icons.history_rounded,
                    Icons.history_outlined, "Riwayat"),
                // Settings
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showMenu(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.more_horiz_rounded,
                            color: Colors.grey.shade400, size: 24),
                        const SizedBox(height: 4),
                        Text("Menu",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData active, IconData inactive, String label) {
    final isActive = _index == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? active : inactive,
                  key: ValueKey(isActive),
                  color: isActive ? AppTheme.primaryLight : Colors.grey.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppTheme.primaryLight
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            _menuTile(
              icon: Icons.person_outline_rounded,
              label: "Profil & Akun",
              color: AppTheme.primaryLight,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfilePage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _menuTile(
              icon: widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              label:
                  widget.isDarkMode ? "Light Mode" : "Dark Mode",
              color: AppTheme.primaryLight,
              onTap: () {
                Navigator.pop(context);
                widget.onToggleTheme();
              },
            ),
            const SizedBox(height: 12),
            _menuTile(
              icon: Icons.logout_rounded,
              label: "Keluar",
              color: Colors.red.shade600,
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppTheme.radiusMedium,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: AppTheme.radiusSmall,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label,
                style: AppTheme.subtitleStyle.copyWith(
                    color: isDark ? Colors.white : AppTheme.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}