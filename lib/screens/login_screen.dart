import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'main_navigator.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey untuk validasi form login
  final _formKey = GlobalKey<FormState>();
  // Controller untuk input email dengan nilai default (opsional)
  final _emailCtrl = TextEditingController(text: 'user@voxsight.com');
  // Controller untuk input password dengan nilai default (opsional)
  final _passCtrl = TextEditingController(text: '••••••••');
  // Indikator loading saat proses login
  bool _isLoading = false;

  // Fungsi untuk menangani proses login
  void _login() async {
    // Validasi input pada form
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulasi proses jaringan (delay)
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigasi ke halaman utama jika berhasil login (MainNavigator)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainNavigator(),
            // Animasi transisi fade saat berpindah halaman
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Hapus controller dari memori setelah tidak digunakan
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Header Login (Gradien dan Logo)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary], // Warna gradien utama
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon dan Nama Aplikasi
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'VoxSight AI',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Teks Sambutan
                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to monitor your VoxSight device',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Bagian Form Input (Email dan Password)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey, // Key untuk melacak status validasi form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Label Input Email
                      Text(
                        'Email Address',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Input TextField Email
                      CustomTextField(
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Email is required'
                            : null, // Validasi input kosong
                      ),
                      const SizedBox(height: 18),
                      // Label Input Password
                      Text(
                        'Password',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Input TextField Password
                      CustomTextField(
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true, // Ubah teks menjadi titik-titik
                        controller: _passCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Password is required'
                            : null, // Validasi input kosong
                      ),
                      const SizedBox(height: 10),
                      // Tombol Lupa Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(), // Pindah ke halaman Forgot Password
                            ),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tombol Submit Sign In
                      PrimaryButton(
                        text: 'Sign In',
                        onPressed: _login, // Jalankan fungsi _login saat ditekan
                        isLoading: _isLoading, // Tampilkan indikator loading jika true
                        icon: Icons.login_rounded,
                      ),
                      // Divider dengan teks "OR"
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'OR',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Bagian Tautan untuk Mendaftar (Sign Up)
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(), // Pindah ke halaman Register
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
