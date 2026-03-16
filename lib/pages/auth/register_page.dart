import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const RegisterPage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _snack("Semua field wajib diisi!", isError: true);
      return;
    }
    if (pass != confirm) {
      _snack("Password tidak cocok!", isError: true);
      return;
    }
    if (pass.length < 6) {
      _snack("Password minimal 6 karakter!", isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.register(email, pass);

      await SupabaseService.logout();

      if (mounted) {
        _snack("Registrasi berhasil! Silakan login.");
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _snack(e.message, isError: true);
    } catch (_) {
      _snack("Terjadi kesalahan. Coba lagi.", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontWeight: FontWeight.w500)),
      backgroundColor: isError ? const Color(0xFFE74C3C) : AppTheme.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.onToggleTheme,
                        icon: Icon(
                          widget.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Buat Akun\nBaru",
                          style: AppTheme.displayStyle
                              .copyWith(color: Colors.white, height: 1.1)),
                      const SizedBox(height: 8),
                      Text("Daftar dan mulai kelola top up",
                          style: AppTheme.bodyStyle
                              .copyWith(color: Colors.white60)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.surfaceLight,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, -8),
                            )
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(28, 32, 28, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Informasi Akun",
                                  style: AppTheme.titleStyle.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppTheme.primary,
                                  )),
                              const SizedBox(height: 24),
                              _field(emailCtrl, "Email",
                                  Icons.email_outlined,
                                  type: TextInputType.emailAddress,
                                  isDark: isDark),
                              const SizedBox(height: 16),
                              _field(passCtrl, "Password",
                                  Icons.lock_outline_rounded,
                                  obscure: _obscurePass,
                                  isDark: isDark,
                                  suffix: IconButton(
                                    icon: Icon(
                                        _obscurePass
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                        size: 20),
                                    onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass),
                                  )),
                              const SizedBox(height: 16),
                              _field(confirmCtrl, "Konfirmasi Password",
                                  Icons.lock_outline_rounded,
                                  obscure: _obscureConfirm,
                                  isDark: isDark,
                                  suffix: IconButton(
                                    icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                        size: 20),
                                    onPressed: () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm),
                                  )),
                              const SizedBox(height: 28),
                              GestureDetector(
                                onTap: _loading ? null : _register,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: _loading
                                        ? null
                                        : AppTheme.primaryGradient,
                                    color: _loading
                                        ? Colors.grey.shade300
                                        : null,
                                    borderRadius: AppTheme.radiusMedium,
                                    boxShadow: _loading
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: AppTheme.primary
                                                  .withOpacity(0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            )
                                          ],
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
                                        : Text("Daftar Sekarang",
                                            style: AppTheme.subtitleStyle
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text("Sudah punya akun? ",
                                      style: AppTheme.bodyStyle.copyWith(
                                          color: Colors.grey.shade500)),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text("Masuk",
                                        style: AppTheme.subtitleStyle
                                            .copyWith(
                                                color:
                                                    AppTheme.primaryLight)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
    Widget? suffix,
    required bool isDark,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: AppTheme.bodyStyle.copyWith(
          color: isDark ? Colors.white : AppTheme.primary,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyStyle.copyWith(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppTheme.primaryLight, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? AppTheme.cardDark : Colors.grey.shade50,
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