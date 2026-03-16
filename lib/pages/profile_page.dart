import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  String get _email => SupabaseService.currentUser?.email ?? '-';
  String get _createdAt {
    final raw = SupabaseService.currentUser?.createdAt;
    if (raw == null) return '-';
    final dt = DateTime.parse(raw).toLocal();
    return '${dt.day.toString().padLeft(2, '0')} '
        '${_bulan(dt.month)} ${dt.year}';
  }

  String _bulan(int m) {
    const b = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return b[m];
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _gantiPassword() async {
    final old = _oldPassCtrl.text.trim();
    final newP = _newPassCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();

    if (old.isEmpty || newP.isEmpty || confirm.isEmpty) {
      _snack("Semua field wajib diisi!", isError: true);
      return;
    }
    if (newP != confirm) {
      _snack("Password baru tidak cocok!", isError: true);
      return;
    }
    if (newP.length < 6) {
      _snack("Password baru minimal 6 karakter!", isError: true);
      return;
    }
    if (old == newP) {
      _snack("Password baru tidak boleh sama dengan yang lama!",
          isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      // Verifikasi password lama dengan re-login
      await SupabaseService.login(_email, old);

      // Ganti password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newP),
      );

      _oldPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      _snack("Password berhasil diubah!");
    } on AuthException catch (e) {
      _snack("Password lama salah: ${e.message}", isError: true);
    } catch (e) {
      _snack("Gagal: $e", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
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
          // AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppTheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
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
                    Positioned(
                      left: -20,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(0.07),
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
                          Text("Profil Akun",
                              style: AppTheme.displayStyle.copyWith(
                                  color: Colors.white, fontSize: 24)),
                          const SizedBox(height: 4),
                          Text("Kelola informasi akunmu",
                              style: AppTheme.bodyStyle
                                  .copyWith(color: Colors.white60)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info Akun ──────────────────────────────
                  _sectionLabel("Informasi Akun", isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: AppTheme.radiusLarge,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _email.isNotEmpty
                                    ? _email[0].toUpperCase()
                                    : '?',
                                style: AppTheme.displayStyle.copyWith(
                                    color: Colors.white, fontSize: 28),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _infoTile(
                          isDark,
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: _email,
                        ),
                        const Divider(height: 24),
                        // Bergabung sejak
                        _infoTile(
                          isDark,
                          icon: Icons.calendar_today_outlined,
                          label: "Bergabung sejak",
                          value: _createdAt,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Ganti Password ────────────────────────
                  _sectionLabel("Ganti Password", isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: AppTheme.radiusLarge,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        _passField(
                          ctrl: _oldPassCtrl,
                          label: "Password Lama",
                          obscure: _obscureOld,
                          isDark: isDark,
                          onToggle: () =>
                              setState(() => _obscureOld = !_obscureOld),
                        ),
                        const SizedBox(height: 14),
                        _passField(
                          ctrl: _newPassCtrl,
                          label: "Password Baru",
                          obscure: _obscureNew,
                          isDark: isDark,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        const SizedBox(height: 14),
                        _passField(
                          ctrl: _confirmPassCtrl,
                          label: "Konfirmasi Password Baru",
                          obscure: _obscureConfirm,
                          isDark: isDark,
                          onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _loading ? null : _gantiPassword,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: _loading
                                  ? null
                                  : AppTheme.primaryGradient,
                              color:
                                  _loading ? Colors.grey.shade300 : null,
                              borderRadius: AppTheme.radiusMedium,
                              boxShadow:
                                  _loading ? [] : AppTheme.cardShadow,
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_reset_rounded,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Text("Simpan Password Baru",
                                            style: AppTheme.subtitleStyle
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: AppTheme.titleStyle.copyWith(
          color: isDark ? Colors.white : AppTheme.primary, fontSize: 16),
    );
  }

  Widget _infoTile(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
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
        const SizedBox(width: 14),
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

  Widget _passField({
    required TextEditingController ctrl,
    required String label,
    required bool obscure,
    required bool isDark,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: AppTheme.bodyStyle.copyWith(
          color: isDark ? Colors.white : AppTheme.primary,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyStyle.copyWith(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppTheme.primaryLight, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
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
}