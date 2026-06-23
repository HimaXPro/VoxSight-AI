// Import class Sequelize dari package sequelize
// Kurung kurawal { } adalah destructuring: ambil hanya property Sequelize dari module
const { Sequelize } = require('sequelize');

// Muat variabel dari file .env agar process.env bisa diakses di file ini
require('dotenv').config();

// Buat instance koneksi database baru menggunakan Sequelize
// Parameter: (nama_database, username, password, opsi_koneksi)
const sequelize = new Sequelize(
  process.env.DB_NAME,      // Nama database yang diambil dari file .env
  process.env.DB_USER,      // Username PostgreSQL dari file .env
  process.env.DB_PASSWORD,  // Password PostgreSQL dari file .env
  {
    host: process.env.DB_HOST,   // Alamat server database (biasanya 'localhost')
    port: process.env.DB_PORT,   // Port PostgreSQL (default bawaan PostgreSQL: 5432)
    dialect: 'postgres',         // Beritahu Sequelize bahwa kita menggunakan PostgreSQL

    logging: false,
    // false = tidak tampilkan query SQL di terminal (lebih bersih)
    // Ganti ke: logging: console.log jika ingin melihat query SQL saat debugging

    pool: {
      // Konfigurasi connection pool: kumpulan koneksi siap pakai agar lebih efisien
      // Lebih hemat dari membuat koneksi baru setiap kali ada request masuk

      max: 5,
      // Maksimal 5 koneksi database yang boleh dibuka secara bersamaan

      min: 0,
      // Minimal 0 koneksi (semua koneksi bisa ditutup saat tidak ada aktivitas)

      acquire: 30000,
      // Waktu tunggu maksimal (30 detik) untuk mendapat koneksi dari pool
      // Jika melebihi batas ini, Sequelize akan lempar error timeout

      idle: 10000,
      // Koneksi yang tidak digunakan selama 10 detik akan otomatis dilepas dari pool
    },
  }
);

// Export instance sequelize agar bisa diimport di file lain
// Digunakan di: server.js (untuk authenticate & sync) dan models/User.js
module.exports = sequelize;
