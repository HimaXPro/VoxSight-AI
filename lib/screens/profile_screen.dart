import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Ahmad Faruq');
  final _emailCtrl = TextEditingController(text: 'ahmad.faruq@slb-ypab.sch.id');
  final _phoneCtrl = TextEditingController(text: '+62 812-3456-7890');
  final _addressCtrl =
      TextEditingController(text: 'Jl. Gebang Putih No.10, Surabaya');
  final _deviceIdCtrl = TextEditingController(text: 'VS-2024-001X');

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isEditing = false;
  bool _isEmailVerified = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _deviceIdCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _verifyEmail() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context); // Close dialog
      setState(() => _isEmailVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email verified successfully!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.online,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _saveProfile() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated!',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 42),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nameCtrl.text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Pendamping • SLB A YPAB',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personal Information
                _SectionCard(
                  title: 'Personal Information',
                  children: [
                    if (_isEditing) ...[
                      _EditField(
                          label: 'Full Name',
                          controller: _nameCtrl,
                          icon: Icons.person_outline),
                      const SizedBox(height: 12),
                      _EditField(
                          label: 'Phone Number',
                          controller: _phoneCtrl,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _EditField(
                          label: 'Address',
                          controller: _addressCtrl,
                          icon: Icons.home_outlined),
                      const SizedBox(height: 12),
                      _EditFieldWithVerification(
                        label: 'Email',
                        controller: _emailCtrl,
                        icon: Icons.email_outlined,
                        isVerified: _isEmailVerified,
                        onVerify: _verifyEmail,
                      ),
                    ] else ...[
                      _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Full Name',
                          value: _nameCtrl.text),
                      const Divider(height: 20),
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: _phoneCtrl.text),
                      const Divider(height: 20),
                      _InfoRow(
                          icon: Icons.home_outlined,
                          label: 'Address',
                          value: _addressCtrl.text),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _emailCtrl.text,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_isEmailVerified
                                    ? AppColors.online
                                    : AppColors.offline)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isEmailVerified ? 'Verified' : 'Unverified',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _isEmailVerified
                                  ? AppColors.online
                                  : AppColors.offline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Device Information
                _SectionCard(
                  title: 'Device Information',
                  children: [
                    if (_isEditing) ...[
                      _EditField(
                        label: 'VoxSight Device ID',
                        controller: _deviceIdCtrl,
                        icon: Icons.memory_outlined,
                      ),
                    ] else ...[
                      _InfoRow(
                        icon: Icons.memory_outlined,
                        label: 'VoxSight Device ID',
                        value: _deviceIdCtrl.text,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Change Password Section (Only show when editing)
                if (_isEditing) ...[
                  _SectionCard(
                    title: 'Change Password',
                    children: [
                      _EditField(
                        label: 'Current Password',
                        controller: _oldPassCtrl,
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 12),
                      _EditField(
                        label: 'New Password',
                        controller: _newPassCtrl,
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 12),
                      _EditField(
                        label: 'Confirm New Password',
                        controller: _confirmPassCtrl,
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // About & Support
                _SectionCard(
                  title: 'About & Support',
                  children: [
                    _MenuRow(
                        icon: Icons.book_outlined,
                        label: 'User Manual',
                        color: AppColors.primary),
                    const Divider(height: 20),
                    _MenuRow(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        color: AppColors.accentOrange),
                    const Divider(height: 20),
                    _MenuRow(
                        icon: Icons.info_outline,
                        label: 'App Version 1.0.0',
                        color: AppColors.textSecondary,
                        showArrow: false),
                  ],
                ),
                const SizedBox(height: 16),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.accentRed),
                    label: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentRed,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.accentRed, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;

  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          hint: label,
          prefixIcon: icon,
          controller: controller,
          keyboardType: keyboardType,
          isPassword: isPassword,
        ),
      ],
    );
  }
}

class _EditFieldWithVerification extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isVerified;
  final VoidCallback onVerify;

  const _EditFieldWithVerification({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isVerified,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            if (!isVerified)
              GestureDetector(
                onTap: onVerify,
                child: Text(
                  'Verify Now',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              )
            else
              Text(
                'Verified',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.online,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextField(
          hint: label,
          prefixIcon: icon,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool showArrow;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showArrow ? () {} : null,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showArrow)
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textHint),
        ],
      ),
    );
  }
}
