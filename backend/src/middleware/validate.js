// Import fungsi validationResult dari express-validator
// Fungsi ini digunakan untuk mengumpulkan semua hasil validasi yang sudah dijalankan sebelumnya
const { validationResult } = require('express-validator');

// Middleware validate: mengecek hasil validasi dan mengirim error jika ada yang gagal
// Dipasang setelah daftar aturan validasi (body(), param(), dll) di dalam array route
const validate = (req, res, next) => {

  // Kumpulkan semua error validasi dari request yang sudah diproses express-validator
  // Berisi daftar field mana saja yang gagal beserta pesan errornya
  const errors = validationResult(req);

  // Cek apakah ada error (isEmpty() = true jika tidak ada error)
  if (!errors.isEmpty()) {
    // Jika ada error validasi, kirim response 400 Bad Request dan hentikan proses
    // (controller tidak akan dieksekusi)
    return res.status(400).json({
      success: false,
      message: 'Validasi gagal',

      // Ubah daftar error menjadi format yang lebih rapi dan mudah dibaca Flutter
      // errors.array() = konversi ke array biasa
      // .map() = transformasi setiap item error ke format baru
      errors: errors.array().map((err) => ({
        field: err.path,    // Nama field yang gagal validasi (contoh: 'email', 'password')
        message: err.msg,   // Pesan error untuk field tersebut (contoh: 'Format email tidak valid')
      })),
    });
  }

  // Jika tidak ada error validasi, lanjutkan ke middleware atau controller berikutnya
  next();
};

// Export fungsi validate dalam bentuk object agar bisa di-destructuring saat diimport
// Contoh penggunaan: const { validate } = require('../middleware/validate')
module.exports = { validate };
