const jwt = require('jsonwebtoken');
const User = require('../models/User');

// =============================================
// REGISTER - Sesuai register_screen.dart
// Fields: fullName, email, phone, deviceId (optional), role, password
// =============================================
const register = async (req, res) => {
  try {
    const { fullName, email, phone, deviceId, role, password } = req.body;

    // Cek apakah email sudah terdaftar
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email sudah terdaftar. Silakan gunakan email lain.',
      });
    }

    // Buat user baru
    const user = await User.create({
      full_name: fullName,
      email,
      phone,
      device_id: deviceId || null,
      role: role || 'Pendamping',
      password,
    });

    return res.status(201).json({
      success: true,
      message: 'Akun berhasil dibuat! Silakan login.',
      data: {
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mendaftar.',
      error: error.message,
    });
  }
};

// =============================================
// LOGIN - Sesuai login_screen.dart
// Fields: email, password
// Returns: JWT token + user data
// =============================================
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Cari user berdasarkan email
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    // Cek apakah akun aktif
    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Akun Anda telah dinonaktifkan.',
      });
    }

    // Bandingkan password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Login berhasil!',
      data: {
        token,
        user: user.toSafeJSON(),
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat login.',
      error: error.message,
    });
  }
};

const resetOtpStore = new Map(); // email -> { code, expiresAt }

function generateResetCode6Digit() {
  // 000000 - 999999 (pad 6 digit)
  return String(Math.floor(Math.random() * 1000000)).padStart(6, '0');
}

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    // Cek apakah email terdaftar
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Email tidak ditemukan dalam sistem.',
      });
    }

    const resetCode = generateResetCode6Digit();
    const expiresAt =
      Date.now() + Number(process.env.RESET_CODE_EXPIRES_MS || 15 * 60 * 1000);

    resetOtpStore.set(email, { code: resetCode, expiresAt });

    // Optional: kirim OTP via email jika SMTP config ada
    let emailSent = false;
    let emailError = null;

    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS;

    if (smtpUser && smtpPass) {
      try {
        const nodemailer = require('nodemailer');

        const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com';
        const smtpPort = Number(process.env.SMTP_PORT || 587);
        const smtpSecure = process.env.SMTP_SECURE === 'true';

        const transporter = nodemailer.createTransport({
          host: smtpHost,
          port: smtpPort,
          secure: smtpSecure,
          auth: { user: smtpUser, pass: smtpPass },
        });

        const fromEmail = process.env.SMTP_FROM || smtpUser;

        await transporter.sendMail({
          from: fromEmail,
          to: email,
          subject: 'VoxSight AI - OTP Password Reset',
          text:
            `Halo ${user.full_name || ''},\n\n` +
            `Kode OTP reset password Anda adalah: ${resetCode}\n\n` +
            `Kode berlaku selama 15 menit.\n\n` +
            `Jika Anda tidak meminta reset password, abaikan email ini.\n`,
        });

        emailSent = true;
      } catch (e) {
        emailError = e.message;
      }
    }

    // Hybrid response: jika email terkirim, kode tetap di-return agar UI/dev bisa dites.
    // (Jika ingin disembunyikan, nanti bisa diubah: data hanya jika DEV mode.)
    return res.status(200).json({
      success: true,
      message: emailSent
        ? 'OTP reset code telah dikirim ke email Anda.'
        : 'OTP reset code dibuat. (Email mungkin tidak terkirim, cek dev/debug info di app).',
      data: {
        resetCode, // dev/debug fallback
        emailSent,
        emailError,
      },
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat membuat reset code.',
      error: error.message,
    });
  }
};

// =============================================
// RESET PASSWORD WITH OTP
// Body: email, resetCode, newPassword, confirmNewPassword
// =============================================
const resetPasswordWithCode = async (req, res) => {
  try {
    const { email, resetCode, newPassword, confirmNewPassword } = req.body;

    if (!email) {
      return res.status(400).json({ success: false, message: 'Email wajib diisi.' });
    }
    if (!resetCode) {
      return res.status(400).json({ success: false, message: 'Reset code wajib diisi.' });
    }
    if (!newPassword || String(newPassword).length < 6) {
      return res.status(400).json({ success: false, message: 'Password baru minimal 6 karakter.' });
    }
    if (!confirmNewPassword || newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Konfirmasi password tidak cocok.' });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Email tidak ditemukan dalam sistem.' });
    }

    const record = resetOtpStore.get(email);
    if (!record) {
      return res.status(400).json({ success: false, message: 'Reset code tidak ditemukan atau sudah dipakai.' });
    }

    if (record.expiresAt < Date.now()) {
      resetOtpStore.delete(email);
      return res.status(400).json({ success: false, message: 'Reset code sudah kedaluwarsa.' });
    }

    if (String(record.code) !== String(resetCode)) {
      return res.status(400).json({ success: false, message: 'Reset code salah.' });
    }

    user.password = newPassword;
    await user.save();

    resetOtpStore.delete(email);

    return res.status(200).json({
      success: true,
      message: 'Password berhasil direset!',
    });
  } catch (error) {
    console.error('Reset password error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mereset password.',
      error: error.message,
    });
  }
};

// =============================================
// VERIFY EMAIL - Sesuai profile_screen.dart (_verifyEmail)
// Simulasi verifikasi email
// =============================================
const verifyEmail = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Update status email_verified
    user.email_verified = true;
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Email verified successfully!',
    });
  } catch (error) {
    console.error('Verify email error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat verifikasi email.',
      error: error.message,
    });
  }
};

// =============================================
// LOGOUT
// Di sisi client, cukup hapus token dari storage
// =============================================
const logout = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: 'Logout berhasil.',
    });
  } catch (error) {
    console.error('Logout error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat logout.',
      error: error.message,
    });
  }
};

module.exports = {
  register,
  login,
  forgotPassword,
  resetPasswordWithCode,
  verifyEmail,
  logout,
};
