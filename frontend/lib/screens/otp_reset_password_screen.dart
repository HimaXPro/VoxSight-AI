import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class OtpResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetCode; // kode OTP dari response forgot-password

  const OtpResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetCode,
  });

  @override
  State<OtpResetPasswordScreen> createState() => _OtpResetPasswordScreenState();
}

class _OtpResetPasswordScreenState extends State<OtpResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // OTP tidak diisi otomatis.
    // widget.resetCode hanya dipakai untuk kebutuhan dev/debug & payload, bukan auto-fill UI.
    _otpCtrl.text = '';
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.postJson(
        '/api/auth/reset-password',
        auth: false,
        body: {
          'email': widget.email,
          'resetCode': _otpCtrl.text.trim(),
          'newPassword': _newPassCtrl.text,
          'confirmNewPassword': _confirmPassCtrl.text,
        },
      );

      if (!mounted) return;

      final success = res['success'] == true;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? 'Password berhasil direset!',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.online,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? 'Gagal mereset password',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.offline,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan saat reset password.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.offline,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              // Navbar / Header biru (samakan style LoginScreen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
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
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Judul
                    Text(
                      'Reset Password',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Sub-title
                    Text(
                      'Enter OTP and set your new password',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // OTP
                      Text(
                        'OTP Code',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Masukkan 6 digit kode OTP',
                        prefixIcon: Icons.verified_outlined,
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Kode OTP wajib diisi';
                          if (value.length != 6) {
                            return 'Kode OTP harus 6 digit';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // New password (dipisah section secara visual)
                      Text(
                        'New Password',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Masukkan password baru',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _newPassCtrl,
                        isPassword: true,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Password baru wajib diisi';
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Confirm Password',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Konfirmasi password baru',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _confirmPassCtrl,
                        isPassword: true,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) {
                            return 'Konfirmasi password wajib diisi';
                          }
                          if (value != _newPassCtrl.text.trim()) {
                            return 'Konfirmasi password tidak cocok';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        text: 'Submit',
                        onPressed: _resetPassword,
                        isLoading: _isLoading,
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
