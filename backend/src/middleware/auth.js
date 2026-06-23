// Import library jsonwebtoken untuk memverifikasi JWT token yang dikirim client
const jwt = require('jsonwebtoken');

// Import model User untuk mencari data pengguna di database berdasarkan ID dari token
const User = require('../models/User');

// Middleware authenticate: memverifikasi apakah request memiliki token JWT yang valid
// Dipasang di route-route yang membutuhkan login (protected routes)
// Parameter: req (data request), res (untuk kirim response), next (lanjut ke handler berikutnya)
const authenticate = async (req, res, next) => {
  try {
    // Ambil nilai header 'Authorization' dari request yang masuk
    // Format yang diharapkan: "Bearer eyJhbGciOiJIUzI1NiJ9.xxx.yyy"
    const authHeader = req.headers.authorization;

    // Cek dua kondisi: apakah header ada DAN apakah diawali kata "Bearer "
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // Jika tidak ada token atau formatnya salah, tolak request
      // 401 = Unauthorized: client belum melakukan autentikasi
      return res.status(401).json({
        success: false,
        message: 'Akses ditolak. Token tidak ditemukan.',
      });
    }

    // Pisahkan string "Bearer eyJhbG..." berdasarkan spasi
    // Hasil split: ['Bearer', 'eyJhbG...']
    // Index [1] = ambil bagian kedua yaitu token JWT-nya saja
    const token = authHeader.split(' ')[1];

    // Verifikasi token: cek apakah valid dan belum kedaluwarsa
    // jwt.verify() akan melempar error jika token palsu atau expired
    // Jika valid, 'decoded' berisi payload token: { id, email, role, iat, exp }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Cari user di database berdasarkan ID yang tersimpan di dalam token
    // findByPk = find by primary key (mencari berdasarkan kolom id)
    const user = await User.findByPk(decoded.id);

    // Cek dua kondisi: apakah user masih ada di DB DAN apakah akunnya masih aktif
    if (!user || !user.is_active) {
      // User tidak ditemukan (mungkin sudah dihapus) atau akunnya dinonaktifkan
      return res.status(401).json({
        success: false,
        message: 'Token tidak valid atau user tidak aktif.',
      });
    }

    // Simpan data user ke dalam object request (req.user)
    // Sehingga controller yang dipanggil selanjutnya bisa akses: req.user.id, req.user.email, dll
    req.user = user;

    // Lanjutkan ke middleware atau controller berikutnya dalam chain
    next();

  } catch (error) {
    // Tangani error spesifik dari library jsonwebtoken

    if (error.name === 'JsonWebTokenError') {
      // Error ini muncul jika token palsu, dimanipulasi, atau formatnya salah
      return res.status(401).json({
        success: false,
        message: 'Token tidak valid.',
      });
    }

    if (error.name === 'TokenExpiredError') {
      // Error ini muncul jika token sudah melewati masa berlakunya (misal: 7 hari)
      return res.status(401).json({
        success: false,
        message: 'Token sudah kadaluarsa. Silakan login kembali.',
      });
    }

    // Tangani error lain yang tidak terduga (bukan dari JWT)
    return res.status(500).json({
      success: false,
      message: 'Server error pada autentikasi.',
    });
  }
};

// Export fungsi authenticate dalam bentuk object
// Sehingga bisa di-destructuring saat diimport: const { authenticate } = require('./auth')
module.exports = { authenticate };
