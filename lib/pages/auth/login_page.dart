import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const LoginPage(
      {super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
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
    super.dispose();
  }

  Future<void> _login() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      _snack("Email dan password wajib diisi!", isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.login(
          emailCtrl.text.trim(), passCtrl.text.trim());
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
      shape:
          RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Theme toggle
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: widget.onToggleTheme,
                      icon: Icon(
                        widget.isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                // Hero section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: AppTheme.radiusMedium,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.games_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 20),
                      Text("Selamat\nDatang Kembali",
                          style: AppTheme.displayStyle
                              .copyWith(color: Colors.white, height: 1.1)),
                      const SizedBox(height: 8),
                      Text("Masuk untuk kelola top up game",
                          style: AppTheme.bodyStyle
                              .copyWith(color: Colors.white60)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Card form
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
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Login Akun",
                                  style: AppTheme.titleStyle.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppTheme.primary,
                                  )),
                              const SizedBox(height: 24),
                              _buildField(
                                controller: emailCtrl,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: passCtrl,
                                label: "Password",
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                isDark: isDark,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildPrimaryButton(
                                label: "Masuk",
                                loading: _loading,
                                onTap: _login,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Belum punya akun? ",
                                      style: AppTheme.bodyStyle.copyWith(
                                          color: Colors.grey.shade500)),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RegisterPage(
                                          isDarkMode: widget.isDarkMode,
                                          onToggleTheme:
                                              widget.onToggleTheme,
                                        ),
                                      ),
                                    ),
                                    child: Text("Daftar Sekarang",
                                        style: AppTheme.subtitleStyle
                                            .copyWith(
                                                color: AppTheme.primaryLight)),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppTheme.bodyStyle.copyWith(
          color: isDark ? Colors.white : AppTheme.primary,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyStyle.copyWith(color: Colors.grey),
        prefixIcon:
            Icon(icon, color: AppTheme.primaryLight, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? AppTheme.cardDark
            : Colors.grey.shade50,
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

  Widget _buildPrimaryButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: loading ? null : AppTheme.primaryGradient,
          color: loading ? Colors.grey.shade300 : null,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(label,
                  style: AppTheme.subtitleStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
