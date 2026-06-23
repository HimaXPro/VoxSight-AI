// Import framework Express untuk membuat web server dan menangani HTTP request
const express = require('express');

// Import package CORS (Cross-Origin Resource Sharing)
// Dibutuhkan agar Flutter app yang berjalan di domain/port berbeda bisa akses API ini
const cors = require('cors');

// Import Morgan: middleware untuk mencatat (log) setiap request HTTP di terminal
const morgan = require('morgan');

// Import modul path bawaan Node.js untuk bekerja dengan path direktori
const path = require('path');

// Import definisi route untuk fitur autentikasi (register, login, dll)
const authRoutes = require('./routes/auth.routes');

// Import definisi route untuk fitur manajemen user (profil, ganti password, dll)
const userRoutes = require('./routes/user.routes');

// Buat instance aplikasi Express
const app = express();

// =============================================
// Middleware
// =============================================

// Aktifkan CORS agar Flutter app dari origin manapun bisa mengakses API ini
// Tanpa ini, browser/Flutter akan memblokir request karena beda domain/port
app.use(cors());

// Middleware untuk mengurai (parse) body request berformat JSON
// Contoh: { "email": "user@gmail.com", "password": "123456" } bisa dibaca via req.body
app.use(express.json());

// Middleware untuk mengurai body berformat URL-encoded (format submit form HTML)
// extended: true = mendukung objek dan array dalam body
app.use(express.urlencoded({ extended: true }));

// Aktifkan Morgan logger dengan format 'dev' (tampil berwarna dan ringkas di terminal)
// Setiap request akan tampil seperti: "POST /api/auth/login 200 45ms"
app.use(morgan('dev'));

// Sajikan folder uploads/ sebagai static file yang bisa diakses langsung via URL
// Contoh: http://localhost:3000/uploads/avatars/avatar-1-xyz.jpg
// path.join(__dirname, '../uploads') = src/../uploads = folder uploads di root backend
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// =============================================
// Routes
// =============================================

// Daftarkan semua route dari auth.routes.js dengan prefix /api/auth
// Contoh hasil: POST /api/auth/login, POST /api/auth/register
app.use('/api/auth', authRoutes);

// Daftarkan semua route dari user.routes.js dengan prefix /api/users
// Contoh hasil: GET /api/users/profile, PUT /api/users/change-password
app.use('/api/users', userRoutes);

// =============================================
// Health check endpoint
// =============================================

// Endpoint GET untuk mengecek apakah server sedang berjalan dengan normal
// Berguna untuk monitoring atau pengecekan awal koneksi dari Flutter app
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'VoxSight AI Backend is running!',
    // Kirim waktu sekarang dalam format ISO agar bisa tahu kapan server merespons
    timestamp: new Date().toISOString(),
  });
});

// =============================================
// 404 Handler
// =============================================

// Middleware ini dijalankan jika tidak ada route yang cocok dengan URL yang diminta
// Harus diletakkan SETELAH semua route agar bisa menangkap route yang tidak terdaftar
app.use((req, res) => {
  res.status(404).json({
    success: false,
    // req.originalUrl = URL asli yang diminta client, ditampilkan di pesan error
    message: `Route ${req.originalUrl} tidak ditemukan.`,
  });
});

// =============================================
// Error Handler
// =============================================

// Middleware penanganan error global — harus punya 4 parameter (err, req, res, next)
// Express mengenali ini sebagai error handler karena ada parameter 'err' di posisi pertama
app.use((err, req, res, next) => {
  // Cetak detail error ke terminal server untuk keperluan debugging
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error.',
    // Tampilkan detail error hanya saat mode development, sembunyikan saat production
    // Ini untuk keamanan: jangan bocorkan detail teknis ke pengguna umum
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// Export app agar bisa diimport dan digunakan di server.js
module.exports = app;
