import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';
import '../models/transaksi.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_image.dart';

class FormTopUpPage extends StatefulWidget {
  final Game game;

  const FormTopUpPage({super.key, required this.game});

  @override
  State<FormTopUpPage> createState() => _FormTopUpPageState();
}

class _FormTopUpPageState extends State<FormTopUpPage> {
  final idCtrl = TextEditingController();
  final jumlahCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    idCtrl.dispose();
    jumlahCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);
  }

  Future<void> _submit() async {
    final id = idCtrl.text.trim();
    final jumlahText = jumlahCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (id.isEmpty || jumlahText.isEmpty || email.isEmpty) {
      _snack("Semua field wajib diisi!", isError: true);
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(id)) {
      _snack("ID Player hanya boleh berisi angka!", isError: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _snack("Format email tidak valid!", isError: true);
      return;
    }

    final jumlah = int.tryParse(jumlahText);
    if (jumlah == null || jumlah <= 0) {
      _snack("Jumlah harus angka lebih dari 0!", isError: true);
      return;
    }
    if (jumlah > widget.game.stok) {
      _snack("Stok tidak cukup! Tersedia: ${widget.game.stok}",
          isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await SupabaseService.addTransaksi(Transaksi(
        namaGame: widget.game.nama,
        idPlayer: id,
        jumlah: jumlah,
        email: email,
        status: 'pending',
      ));
      if (mounted) {
        _snack("Permintaan berhasil dikirim!");
        Navigator.pop(context);
      }
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppTheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 70, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              // Game logo — pakai GameImage agar support URL & asset
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: AppTheme.radiusMedium,
                                  border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.3),
                                      width: 1.5),
                                ),
                                child: GameImage(
                                  logo: widget.game.logo,
                                  size: 54,
                                  fit: BoxFit.cover,
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(widget.game.nama,
                                      style: AppTheme.titleStyle
                                          .copyWith(color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${widget.game.stok} stok tersedia",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: AppTheme.radiusMedium,
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.25),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.pending_actions_rounded,
                              color: Colors.orange.shade700, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Permintaan akan masuk ke antrian dan diproses oleh admin.",
                            style: AppTheme.bodyStyle.copyWith(
                                color: Colors.orange.shade700,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Detail Top Up",
                      style: AppTheme.titleStyle.copyWith(
                          color:
                              isDark ? Colors.white : AppTheme.primary)),
                  const SizedBox(height: 16),
                  _buildField(
                    ctrl: idCtrl,
                    label: "ID Player",
                    hint: "Masukkan ID in-game kamu",
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    ctrl: jumlahCtrl,
                    label: "Jumlah Top Up",
                    hint: "Berapa item yang kamu butuhkan?",
                    icon: Icons.shopping_bag_outlined,
                    type: TextInputType.number,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    ctrl: emailCtrl,
                    label: "Email",
                    hint: "contoh@email.com",
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient:
                            _loading ? null : AppTheme.primaryGradient,
                        color: _loading ? Colors.grey.shade300 : null,
                        borderRadius: AppTheme.radiusLarge,
                        boxShadow: _loading
                            ? []
                            : [
                                BoxShadow(
                                  color:
                                      AppTheme.primary.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text("Kirim Permintaan",
                                      style: AppTheme.subtitleStyle
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      inputFormatters: inputFormatters,
      style: AppTheme.bodyStyle.copyWith(
          color: isDark ? Colors.white : AppTheme.primary,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTheme.bodyStyle.copyWith(color: Colors.grey),
        hintStyle: AppTheme.bodyStyle
            .copyWith(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryLight, size: 20),
        filled: true,
        fillColor: isDark ? AppTheme.cardDark : Colors.white,
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