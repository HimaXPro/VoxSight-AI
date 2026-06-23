// Import framework Express untuk membuat Router
const express = require('express');

// Import fungsi body dari express-validator untuk validasi input dari request body
const { body } = require('express-validator');

// Import Multer: middleware untuk menangani upload file (foto profil/avatar)
const multer = require('multer');

// Import modul path untuk mengolah direktori dan ekstensi file
const path = require('path');

// Import middleware validate untuk mengecek hasil validasi dan mengirim error jika ada
const { validate } = require('../middleware/validate');

// Import middleware authenticate untuk memverifikasi JWT token
const { authenticate } = require('../middleware/auth');

// Import semua fungsi controller yang menangani profil pengguna
const userController = require('../controllers/user.controller');

// Buat instance Router Express untuk mengelompokkan semua route user
const router = express.Router();

// =============================================
// Konfigurasi Multer untuk upload avatar
// =============================================

// Definisikan konfigurasi penyimpanan file menggunakan diskStorage
// diskStorage = simpan file langsung ke hard disk (bukan ke memori/buffer)
const storage = multer.diskStorage({

  // destination: menentukan folder tujuan penyimpanan file yang diupload
  destination: (req, file, cb) => {
    // req  = data request
    // file = informasi file yang sedang diupload (nama asli, tipe, ukuran)
    // cb   = callback function untuk memberitahu Multer lokasi tujuan

    // path.join: gabungkan path direktori secara aman lintas sistem operasi
    // __dirname = direktori file ini (src/routes/)
    // '../../uploads/avatars' = naik 2 level, lalu masuk ke uploads/avatars
    // Hasil: backend/uploads/avatars
    cb(null, path.join(__dirname, '../../uploads/avatars'));
    // null pada cb = tidak ada error
  },

  // filename: menentukan nama file yang akan digunakan saat disimpan di disk
  filename: (req, file, cb) => {
    // Buat suffix unik dengan menggabungkan timestamp dan angka acak
    // Date.now()             = waktu sekarang dalam milliseconds (pasti berbeda setiap saat)
    // Math.random() * 1e9    = angka acak 0 sampai 999999999
    // Math.round()           = bulatkan ke bilangan bulat
    // Kombinasi keduanya memastikan nama file SELALU unik meskipun upload bersamaan
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);

    // Ambil ekstensi dari nama file asli yang diupload user
    // path.extname('foto.jpg') = '.jpg'
    const ext = path.extname(file.originalname);

    // Format nama file akhir: avatar-{userId}-{timestamp}-{random}.{ekstensi}
    // Contoh: avatar-1-1719115200000-123456789.jpg
    // req.user.id sudah tersedia karena authenticate middleware sudah dijalankan
    cb(null, `avatar-${req.user.id}-${uniqueSuffix}${ext}`);
  },
});

// Buat instance Multer dengan konfigurasi yang sudah didefinisikan
const upload = multer({
  storage, // Gunakan konfigurasi diskStorage di atas

  limits: { fileSize: 5 * 1024 * 1024 },
  // Batasi ukuran file maksimal 5 MB
  // 5 * 1024 * 1024 = 5.242.880 bytes = 5 MB
  // File yang lebih besar dari ini akan otomatis ditolak Multer

  // fileFilter: menentukan tipe file apa yang diizinkan untuk diupload
  fileFilter: (req, file, cb) => {
    // Buat regular expression (pola) yang cocok dengan jenis gambar yang diizinkan
    const allowedTypes = /jpeg|jpg|png|gif/;

    // Cek ekstensi file: path.extname ambil ekstensi, toLowerCase() agar tidak case-sensitive
    // allowedTypes.test() = return true jika pola cocok, false jika tidak
    // Contoh: '.JPG'.toLowerCase() = '.jpg' → cocok dengan pola
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());

    // Cek MIME type file (tipe konten yang diklaim oleh browser/client)
    // Contoh MIME type: 'image/jpeg', 'image/png'
    // Double check ini mencegah pengguna mengubah ekstensi file berbahaya menjadi .jpg
    const mimetype = allowedTypes.test(file.mimetype);

    // Hanya izinkan jika BOTH ekstensi DAN MIME type valid
    if (extname && mimetype) {
      return cb(null, true); // null = tidak ada error, true = file diterima
    }

    // Jika tipe file tidak valid, tolak dengan pesan error
    cb(new Error('Hanya file gambar (jpeg, jpg, png, gif) yang diperbolehkan.'));
  },
});

// =============================================
// Global Middleware untuk semua route di file ini
// =============================================

// Terapkan middleware authenticate ke SEMUA route yang didefinisikan di bawah ini
// Berbeda dengan auth.routes.js yang menerapkan authenticate per-route
// Cara ini lebih ringkas karena semua route user memang butuh login
router.use(authenticate);

// =============================================
// GET /api/users/profile
// Sesuai profile_screen.dart (read mode)
// =============================================

// Route GET untuk mengambil data profil user yang sedang login
// Tidak butuh body request karena ID user sudah ada di token JWT
router.get('/profile', userController.getProfile);

// =============================================
// PUT /api/users/profile
// Sesuai profile_screen.dart (edit mode - _saveProfile)
// =============================================

// Route PUT untuk memperbarui data profil user
// PUT = update/ganti resource yang sudah ada (berbeda dengan POST yang membuat baru)
router.put(
  '/profile',
  [
    // Semua field di sini optional karena user mungkin hanya update sebagian data

    // Validasi fullName: jika dikirim, tidak boleh string kosong
    body('fullName').optional().notEmpty().withMessage('Nama tidak boleh kosong').trim(),

    // Validasi email: jika dikirim, harus format email valid
    body('email').optional().isEmail().withMessage('Format email tidak valid').normalizeEmail(),

    // Validasi phone, address, deviceId: opsional, hanya bersihkan whitespace jika ada
    body('phone').optional().trim(),
    body('address').optional().trim(),
    body('deviceId').optional().trim(),

    validate, // Cek semua validasi di atas
  ],
  userController.updateProfile // Jalankan controller updateProfile jika lolos validasi
);

// =============================================
// PUT /api/users/change-password
// Sesuai profile_screen.dart (Change Password section)
// =============================================

// Route PUT untuk mengganti password user yang sedang login
router.put(
  '/change-password',
  [
    // Password lama wajib diisi untuk verifikasi identitas user
    body('oldPassword').notEmpty().withMessage('Password lama wajib diisi'),

    // Password baru minimal 6 karakter
    body('newPassword').isLength({ min: 6 }).withMessage('Password baru minimal 6 karakter'),

    // Konfirmasi password baru wajib diisi dan harus sama dengan newPassword
    body('confirmNewPassword')
      .notEmpty().withMessage('Konfirmasi password wajib diisi')
      .custom((value, { req }) => {
        // Bandingkan confirmNewPassword dengan newPassword
        if (value !== req.body.newPassword) {
          throw new Error('Konfirmasi password tidak cocok');
        }
        return true; // Validasi berhasil
      }),

    validate, // Cek semua validasi, kirim error jika ada yang gagal
  ],
  userController.changePassword // Jalankan controller changePassword jika validasi lolos
);

// =============================================
// POST /api/users/upload-avatar
// Sesuai profile_screen.dart (camera icon overlay di edit mode)
// =============================================

// Route POST untuk mengupload foto profil (avatar) user
router.post(
  '/upload-avatar',

  // upload.single('avatar') = Multer middleware untuk memproses 1 file
  // 'avatar' = nama field dalam form-data yang berisi file gambar
  // Setelah Multer selesai, informasi file tersedia di req.file
  upload.single('avatar'),

  // Jalankan controller uploadAvatar setelah Multer selesai memproses file
  userController.uploadAvatar
);

// Export router agar bisa diimport dan digunakan di app.js
module.exports = router;
