const User = require('../models/User');
const bcrypt = require('bcryptjs');
const path = require('path');

// =============================================
// GET PROFILE - Sesuai profile_screen.dart
// Return: fullName, email, phone, address, deviceId, role, emailVerified, avatarUrl
// =============================================
const getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    return res.status(200).json({
      success: true,
      data: user.toSafeJSON(),
    });
  } catch (error) {
    console.error('Get profile error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil profil.',
      error: error.message,
    });
  }
};

// =============================================
// UPDATE PROFILE - Sesuai profile_screen.dart (edit mode)
// Editable fields: fullName, phone, address, email, deviceId
// =============================================
const updateProfile = async (req, res) => {
  try {
    const { fullName, phone, address, email, deviceId } = req.body;
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Cek jika email berubah, pastikan tidak duplikat
    if (email && email !== user.email) {
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email sudah digunakan oleh user lain.',
        });
      }
      user.email = email;
      user.email_verified = false; // Reset verifikasi jika email berubah
    }

    // Update field yang dikirim
    if (fullName) user.full_name = fullName;
    if (phone !== undefined) user.phone = phone;
    if (address !== undefined) user.address = address;
    if (deviceId !== undefined) user.device_id = deviceId;

    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Profile updated!',
      data: user.toSafeJSON(),
    });
  } catch (error) {
    console.error('Update profile error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat update profil.',
      error: error.message,
    });
  }
};

// =============================================
// CHANGE PASSWORD - Sesuai profile_screen.dart (Change Password section)
// Fields: oldPassword, newPassword, confirmNewPassword
// =============================================
const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword, confirmNewPassword } = req.body;
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Verifikasi password lama
    const isMatch = await user.comparePassword(oldPassword);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Password lama salah.',
      });
    }

    // Validasi password baru
    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password baru minimal 6 karakter.',
      });
    }

    // Validasi konfirmasi password
    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({
        success: false,
        message: 'Konfirmasi password tidak cocok.',
      });
    }

    // Update password (hook beforeUpdate akan hash otomatis)
    user.password = newPassword;
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Password berhasil diubah!',
    });
  } catch (error) {
    console.error('Change password error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengubah password.',
      error: error.message,
    });
  }
};

// =============================================
// UPLOAD AVATAR - Sesuai profile_screen.dart (camera icon di edit mode)
// =============================================
const uploadAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'File foto tidak ditemukan.',
      });
    }

    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Simpan path foto avatar
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;
    user.avatar_url = avatarUrl;
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Foto profil berhasil diupload!',
      data: { avatarUrl },
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat upload foto.',
      error: error.message,
    });
  }
};

module.exports = {
  getProfile,
  updateProfile,
  changePassword,
  uploadAvatar,
};
