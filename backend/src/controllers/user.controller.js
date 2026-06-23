// Import model User untuk operasi database (cari, update, simpan data user)
const User = require('../models/User');

// Import bcryptjs untuk keperluan verifikasi password (meski hash ditangani model)
const bcrypt = require('bcryptjs');

// Import modul path untuk mengolah path/direktori file
const path = require('path');

// =============================================
// GET PROFILE - Sesuai profile_screen.dart
// Return: fullName, email, phone, address, deviceId, role, emailVerified, avatarUrl
// =============================================

// Fungsi getProfile: mengambil data profil user yang sedang login
const getProfile = async (req, res) => {
  try {
    // Cari user di database berdasarkan ID dari token JWT
    // req.user.id sudah tersedia karena request melewati middleware authenticate lebih dulu
    const user = await User.findByPk(req.user.id);

    // Pastikan user masih ada di database
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Kirim data profil user (tanpa field password menggunakan toSafeJSON())
    return res.status(200).json({
      success: true,
      data: user.toSafeJSON(), // Method ini menghapus password sebelum dikirim ke client
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

// Fungsi updateProfile: memperbarui data profil user
const updateProfile = async (req, res) => {
  try {
    // Ambil field-field yang mungkin diubah dari body request
    // Semua field ini opsional — hanya yang dikirim yang akan diupdate
    const { fullName, phone, address, email, deviceId } = req.body;

    // Cari data user di database berdasarkan ID dari token
    const user = await User.findByPk(req.user.id);

    // Pastikan user masih ada
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Khusus untuk email: perlu pengecekan tambahan sebelum diupdate
    // Cek jika email yang dikirim berbeda dari email yang tersimpan saat ini
    if (email && email !== user.email) {
      // Cari apakah email baru sudah dipakai oleh user lain
      const existingUser = await User.findOne({ where: { email } });

      if (existingUser) {
        // Jika email sudah ada di database, tolak update
        return res.status(400).json({
          success: false,
          message: 'Email sudah digunakan oleh user lain.',
        });
      }

      // Jika email baru tersedia, ganti emailnya
      user.email = email;

      // Reset status verifikasi email karena email sudah berubah
      // User perlu verifikasi ulang email barunya
      user.email_verified = false;
    }

    // Update field-field lain jika nilai baru dikirim dari Flutter app
    // Menggunakan if agar field yang tidak dikirim tidak ikut di-reset ke undefined
    if (fullName) user.full_name = fullName;

    // Untuk phone, address, dan deviceId: gunakan !== undefined (bukan truthy check)
    // Karena nilainya bisa saja berupa string kosong '' yang merupakan nilai valid
    if (phone !== undefined) user.phone = phone;
    if (address !== undefined) user.address = address;
    if (deviceId !== undefined) user.device_id = deviceId;

    // Simpan semua perubahan yang sudah di-set ke database sekaligus
    await user.save();

    // Kirim response sukses beserta data profil yang sudah diperbarui
    return res.status(200).json({
      success: true,
      message: 'Profile updated!',
      data: user.toSafeJSON(), // Kirim data terbaru tanpa password
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

// Fungsi changePassword: mengganti password user yang sedang login
const changePassword = async (req, res) => {
  try {
    // Ambil password lama, password baru, dan konfirmasi password baru dari request
    const { oldPassword, newPassword, confirmNewPassword } = req.body;

    // Cari data user di database
    const user = await User.findByPk(req.user.id);

    // Pastikan user masih ada
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Verifikasi password lama: bandingkan dengan hash yang tersimpan di database
    // Ini penting sebagai lapisan keamanan — pastikan yang mengganti password adalah pemilik akun
    const isMatch = await user.comparePassword(oldPassword);

    if (!isMatch) {
      // Jika password lama tidak cocok, tolak permintaan ganti password
      return res.status(400).json({
        success: false,
        message: 'Password lama salah.',
      });
    }

    // Validasi panjang password baru minimal 6 karakter
    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password baru minimal 6 karakter.',
      });
    }

    // Pastikan password baru dan konfirmasinya sama persis
    if (newPassword !== confirmNewPassword) {
      return res.status(400).json({
        success: false,
        message: 'Konfirmasi password tidak cocok.',
      });
    }

    // Set password baru ke field password user
    // Hook beforeUpdate di model User.js akan otomatis hash password ini sebelum disimpan
    user.password = newPassword;

    // Simpan perubahan ke database (hook beforeUpdate berjalan di sini)
    await user.save();

    // Kirim response sukses
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

// Fungsi uploadAvatar: menyimpan foto profil yang diupload user
const uploadAvatar = async (req, res) => {
  try {
    // req.file diisi oleh Multer middleware yang dijalankan sebelum fungsi ini
    // Jika tidak ada file yang diupload, req.file akan bernilai undefined
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'File foto tidak ditemukan.',
      });
    }

    // Cari data user di database
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Buat URL path untuk mengakses foto avatar dari browser/Flutter
    // req.file.filename = nama file yang sudah di-generate Multer (contoh: avatar-1-172345.jpg)
    // URL lengkap: http://localhost:3000/uploads/avatars/avatar-1-172345.jpg
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;

    // Simpan path URL avatar ke kolom avatar_url di database
    user.avatar_url = avatarUrl;

    // Simpan perubahan ke database
    await user.save();

    // Kirim response sukses beserta URL avatar yang bisa langsung digunakan Flutter
    return res.status(200).json({
      success: true,
      message: 'Foto profil berhasil diupload!',
      data: { avatarUrl }, // Flutter bisa langsung gunakan URL ini untuk tampilkan foto
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

// Export semua fungsi controller agar bisa diimport di file routes
module.exports = {
  getProfile,
  updateProfile,
  changePassword,
  uploadAvatar,
};
