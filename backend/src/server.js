// Memuat variabel lingkungan dari file .env ke dalam process.env
// Harus dipanggil paling pertama sebelum file lain agar semua config tersedia
require('dotenv').config();

// Import konfigurasi Express (middleware, routes, error handler) dari app.js
const app = require('./app');

// Import instance koneksi Sequelize ke PostgreSQL
const sequelize = require('./config/database');

// Import fungsi untuk mengisi database dengan data awal (dummy data)
const { seedDatabase } = require('./seeders/seed');

// Modul bawaan Node.js untuk operasi file system (cek & buat folder)
const fs = require('fs');

// Modul bawaan Node.js untuk menggabungkan path direktori secara aman
const path = require('path');

// Ambil PORT dari file .env, jika tidak ada gunakan 3000 sebagai default
const PORT = process.env.PORT || 3000;

// Buat path lengkap ke folder uploads/avatars
// __dirname = direktori file ini (src/), lalu naik satu level ke uploads/avatars
const uploadsDir = path.join(__dirname, '../uploads/avatars');

// Cek apakah folder uploads/avatars sudah ada
if (!fs.existsSync(uploadsDir)) {
  // Jika belum ada, buat folder beserta semua folder parent-nya
  // recursive: true = buat folder bertingkat sekaligus jika belum ada
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Fungsi async untuk menjalankan server secara berurutan
// Menggunakan async karena operasi database bersifat asynchronous (perlu await)
const startServer = async () => {
  try {
    // Tes apakah koneksi ke database PostgreSQL berhasil
    // Jika gagal (DB mati, password salah, dll), akan langsung masuk catch
    await sequelize.authenticate();
    console.log('✅ Database PostgreSQL terhubung!');

    // Sinkronkan semua model (User.js, dll) dengan tabel di database
    // alter: true = perbarui struktur tabel yang sudah ada tanpa hapus data
    await sequelize.sync({ alter: true });
    console.log('✅ Tabel database berhasil disinkronisasi!');

    // Jalankan seeder untuk mengisi data awal (contoh: admin default)
    await seedDatabase();

    // Mulai server Express dan dengarkan koneksi masuk di port yang ditentukan
    app.listen(PORT, () => {
      console.log('');
      console.log(' ================================');
      console.log(` VoxSight AI Backend`);
      // Tampilkan URL server yang berjalan
      console.log(` Server berjalan di: http://localhost:${PORT}`);
      // Tampilkan URL untuk cek kesehatan server
      console.log(` Health check: http://localhost:${PORT}/api/health`);
      console.log(' ================================');
      console.log('');
      // Tampilkan daftar semua endpoint yang tersedia
      console.log(' Available endpoints:');
      console.log('   POST   /api/auth/register');
      console.log('   POST   /api/auth/login');
      console.log('   POST   /api/auth/forgot-password');
      console.log('   POST   /api/auth/verify-email     (🔒 auth required)');
      console.log('   POST   /api/auth/logout            (🔒 auth required)');
      console.log('   GET    /api/users/profile           (🔒 auth required)');
      console.log('   PUT    /api/users/profile           (🔒 auth required)');
      console.log('   PUT    /api/users/change-password   (🔒 auth required)');
      console.log('   POST   /api/users/upload-avatar     (🔒 auth required)');
      console.log('');
    });
  } catch (error) {
    // Jika ada kesalahan (DB tidak konek, port sudah dipakai, dll)
    console.error('❌ Gagal memulai server:', error);

    // Hentikan proses Node.js dengan kode 1 (menandakan ada error)
    // Kode 0 = sukses, kode selain 0 = ada masalah
    process.exit(1);
  }
};

// Panggil fungsi startServer untuk memulai keseluruhan aplikasi
startServer();
