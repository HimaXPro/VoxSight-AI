import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _deviceIdCtrl = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'Pendamping';

  final List<String> _roles = ['Pengguna (Netra)', 'Pendamping', 'Guru'];

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akun berhasil dibuat! Silakan login.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.online,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _deviceIdCtrl.dispose();
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
              // Header
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
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Register to start using VoxSight AI',
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
                      const SizedBox(height: 4),
                      _label('Full Name'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        controller: _nameCtrl,
                        validator: (v) =>
                            v!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Email Address'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Phone Number'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Enter your phone number',
                        prefixIcon: Icons.phone_outlined,
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.isEmpty ? 'Phone is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Device ID'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Enter your VoxSight Device ID',
                        prefixIcon: Icons.memory_outlined,
                        controller: _deviceIdCtrl,
                        validator: (v) => null, // Opsional
                      ),
                      const SizedBox(height: 16),
                      _label('Role'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            items: _roles
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedRole = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Password'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Create a password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passCtrl,
                        validator: (v) => v!.length < 6
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Confirm Password'),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Repeat your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _confirmCtrl,
                        validator: (v) => v != _passCtrl.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: 'Create Account',
                        onPressed: _register,
                        isLoading: _isLoading,
                        icon: Icons.person_add_outlined,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
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

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
