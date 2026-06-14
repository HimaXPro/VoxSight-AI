require('dotenv').config();
const app = require('./app');
const sequelize = require('./config/database');
const { seedDatabase } = require('./seeders/seed');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

// Pastikan folder uploads/avatars ada
const uploadsDir = path.join(__dirname, '../uploads/avatars');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Start server
const startServer = async () => {
  try {
    // Test koneksi database
    await sequelize.authenticate();
    console.log('✅ Database PostgreSQL terhubung!');

    // Sync semua model ke database (buat tabel jika belum ada)
    await sequelize.sync({ alter: true });
    console.log('✅ Tabel database berhasil disinkronisasi!');

    // Jalankan seeder untuk data awal
    await seedDatabase();

    // Start Express server
    app.listen(PORT, () => {
      console.log('');
      console.log(' ================================');
      console.log(` VoxSight AI Backend`);
      console.log(` Server berjalan di: http://localhost:${PORT}`);
      console.log(` Health check: http://localhost:${PORT}/api/health`);
      console.log(' ================================');
      console.log('');
      console.log(' Available endpoints:');
      console.log('   POST   /api/auth/register');
      console.log('   POST   /api/auth/login');
      console.log('   POST   /api/auth/forgot-password');
      console.log('   POST   /api/auth/verify-email     ( auth required)');
      console.log('   POST   /api/auth/logout            ( auth required)');
      console.log('   GET    /api/users/profile           ( auth required)');
      console.log('   PUT    /api/users/profile           ( auth required)');
      console.log('   PUT    /api/users/change-password   ( auth required)');
      console.log('   POST   /api/users/upload-avatar     ( auth required)');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Gagal memulai server:', error);
    process.exit(1);
  }
};

startServer();
