// Import framework Express dan buat instance Router
// Router adalah mini-aplikasi Express untuk mengelompokkan route yang berhubungan
const express = require('express');

// Import fungsi body dari express-validator untuk mendefinisikan aturan validasi field
const { body } = require('express-validator');

// Import middleware validate untuk mengecek hasil validasi dan kirim error jika ada
const { validate } = require('../middleware/validate');

// Import middleware authenticate untuk memverifikasi JWT token pada route yang dilindungi
const { authenticate } = require('../middleware/auth');

// Import semua fungsi controller autentikasi
const authController = require('../controllers/auth.controller');

// Buat instance Router Express untuk mengelompokkan semua route autentikasi
const router = express.Router();

// =============================================
// POST /api/auth/register
// Sesuai register_screen.dart
// =============================================

// Route POST untuk pendaftaran akun baru
// Array middleware dieksekusi berurutan sebelum controller dijalankan
router.post(
  '/register',   // Endpoint: POST /api/auth/register (prefix /api/auth dari app.js)
  [
    // Validasi field 'fullName': tidak boleh kosong dan hapus spasi di awal/akhir
    body('fullName')
      .notEmpty().withMessage('Name is required')
      .trim(), // Hapus whitespace di awal dan akhir string

    // Validasi field 'email': tidak boleh kosong, harus format email valid
    body('email')
      .notEmpty().withMessage('Email is required')
      .isEmail().withMessage('Format email tidak valid') // Harus ada @ dan domain
      .normalizeEmail(), // Normalisasi: ubah ke huruf kecil, bersihkan format

    // Validasi field 'phone': tidak boleh kosong
    body('phone')
      .notEmpty().withMessage('Phone is required')
      .trim(),

    // Validasi field 'deviceId': opsional (boleh tidak dikirim)
    body('deviceId')
      .optional() // Jika tidak ada di request, validasi dilewati
      .trim(),

    // Validasi field 'role': opsional, tapi jika ada harus salah satu dari 3 nilai
    body('role')
      .optional()
      .isIn(['Pengguna (Netra)', 'Pendamping', 'Guru'])
      .withMessage('Role tidak valid'),

    // Validasi field 'password': minimal 6 karakter
    body('password')
      .isLength({ min: 6 }).withMessage('Min 6 characters'),

    // Validasi field 'confirmPassword': harus sama persis dengan password
    body('confirmPassword')
      .custom((value, { req }) => {
        // value = nilai confirmPassword yang dikirim
        // { req } = destructuring untuk mengakses object request dan membaca req.body.password
        if (value !== req.body.password) {
          // Lempar error jika tidak cocok, pesan akan ditangkap oleh validate middleware
          throw new Error('Passwords do not match');
        }
        return true; // Return true menandakan validasi berhasil
      }),

    // Middleware terakhir: kumpulkan semua hasil validasi di atas
    // Jika ada yang gagal → kirim response 400 dan hentikan proses (controller tidak dijalankan)
    validate,
  ],
  // Jika semua validasi lolos, jalankan fungsi register di controller
  authController.register
);

// =============================================
// POST /api/auth/login
// Sesuai login_screen.dart
// =============================================

// Route POST untuk login pengguna
router.post(
  '/login',  // Endpoint: POST /api/auth/login
  [
    // Validasi email: tidak boleh kosong dan harus format valid
    body('email')
      .notEmpty().withMessage('Email is required')
      .isEmail().withMessage('Format email tidak valid')
      .normalizeEmail(),

    // Validasi password: tidak boleh kosong (panjang minimal dicek di controller)
    body('password')
      .notEmpty().withMessage('Password is required'),

    validate, // Cek hasil validasi, stop jika ada error
  ],
  authController.login // Jalankan fungsi login jika validasi lolos
);

// =============================================
// POST /api/auth/forgot-password
// Sesuai forgot_password_screen.dart
// =============================================

// Route POST untuk meminta kode OTP reset password
router.post(
  '/forgot-password',  // Endpoint: POST /api/auth/forgot-password
  [
    // Hanya butuh validasi email untuk mengirim OTP
    body('email')
      .notEmpty().withMessage('Email is required')
      .isEmail().withMessage('Format email tidak valid')
      .normalizeEmail(),

    validate, // Cek validasi email
  ],
  authController.forgotPassword // Jalankan fungsi forgotPassword jika validasi lolos
);

// =============================================
// POST /api/auth/verify-email
// Sesuai profile_screen.dart (_verifyEmail)
// Membutuhkan autentikasi (user harus login)
// =============================================

// Route POST untuk memverifikasi email pengguna
// authenticate dijalankan DULU: jika token tidak valid, verifyEmail tidak akan dipanggil
router.post('/verify-email', authenticate, authController.verifyEmail);

// =============================================
// POST /api/auth/reset-password
// Sesuai alur baru (tanpa email link)
// Body: email, resetCode, newPassword, confirmNewPassword
// =============================================

// Route POST untuk mereset password menggunakan kode OTP
// Tidak pakai authenticate karena user belum login saat melakukan reset password
router.post('/reset-password', authController.resetPasswordWithCode);

// =============================================
// POST /api/auth/logout
// Sesuai profile_screen.dart (Sign Out button)
// =============================================

// Route POST untuk logout pengguna
// authenticate dipasang untuk memastikan hanya user yang login yang bisa logout
router.post('/logout', authenticate, authController.logout);

// Export router agar bisa diimport dan digunakan di app.js
module.exports = router;
