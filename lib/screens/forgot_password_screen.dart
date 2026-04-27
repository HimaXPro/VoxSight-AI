import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // GlobalKey digunakan untuk memvalidasi state dari Form
  final _formKey = GlobalKey<FormState>();
  // Controller untuk mengambil teks inputan email
  final _emailCtrl = TextEditingController();
  // Menyimpan status loading saat proses pengiriman link reset
  bool _isLoading = false;

  // Fungsi untuk mengirimkan link reset password
  void _sendResetLink() async {
    // Memeriksa apakah inputan pada form sudah valid
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Mensimulasikan proses jaringan dengan delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        // Menampilkan pesan sukses menggunakan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reset link sent to your email!',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.online,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Kembali ke halaman sebelumnya setelah berhasil
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    // Membersihkan controller untuk mencegah kebocoran memori (memory leak)
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Latar belakang utama layar
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Header dengan Gradien
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tombol Kembali
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Judul Header
                    Text(
                      'Reset Password',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Deskripsi Bawah Judul
                    Text(
                      'Enter your email to receive a password reset link',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Bagian Form Input
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey, // Key untuk form validasi
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Email Address',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Input TextField untuk Email
                      CustomTextField(
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Email is required'
                            : null, // Validasi tidak boleh kosong
                      ),
                      const SizedBox(height: 32),
                      // Tombol Submit Reset Link
                      PrimaryButton(
                        text: 'Send Reset Link',
                        onPressed: _sendResetLink,
                        isLoading: _isLoading, // Tampilkan loading indicator jika true
                        icon: Icons.send_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
