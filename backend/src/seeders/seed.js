const User = require('../models/User');

// Seed data sesuai dengan data hardcoded di frontend
const seedDatabase = async () => {
  try {
    // Cek apakah sudah ada data user
    const userCount = await User.count();
    if (userCount > 0) {
      console.log('📦 Database sudah memiliki data, skip seeding.');
      return;
    }

    console.log('🌱 Seeding database...');

    // =============================================
    // Buat user default sesuai profile_screen.dart
    // Name: Ahmad Faruq
    // Email: ahmad.faruq@slb-ypab.sch.id
    // Phone: +62 812-3456-7890
    // Address: Jl. Gebang Putih No.10, Surabaya
    // Device ID: VS-2024-001X
    // Role: Pendamping
    // =============================================
    await User.create({
      full_name: 'Ahmad Faruq',
      email: 'ahmad.faruq@slb-ypab.sch.id',
      phone: '+62 812-3456-7890',
      address: 'Jl. Gebang Putih No.10, Surabaya',
      device_id: 'VS-2024-001X',
      role: 'Pendamping',
      password: 'password123', // Akan di-hash otomatis oleh hook beforeCreate
      email_verified: false,
      is_active: true,
    });

    // User kedua untuk testing login_screen.dart (email default: user@voxsight.com)
    await User.create({
      full_name: 'User VoxSight',
      email: 'user@voxsight.com',
      phone: '+62 813-0000-0000',
      address: 'Surabaya',
      device_id: null,
      role: 'Pengguna (Netra)',
      password: 'password123',
      email_verified: true,
      is_active: true,
    });

    // User ketiga (role Guru) untuk testing
    await User.create({
      full_name: 'Ibu Siti Rahmawati',
      email: 'siti.guru@slb-ypab.sch.id',
      phone: '+62 815-9876-5432',
      address: 'Jl. Raya Darmo No.55, Surabaya',
      device_id: null,
      role: 'Guru',
      password: 'password123',
      email_verified: true,
      is_active: true,
    });

    console.log('✅ Seeding selesai! 3 user berhasil dibuat.');
    console.log('   📧 ahmad.faruq@slb-ypab.sch.id / password123 (Pendamping)');
    console.log('   📧 user@voxsight.com / password123 (Pengguna Netra)');
    console.log('   📧 siti.guru@slb-ypab.sch.id / password123 (Guru)');
  } catch (error) {
    console.error('❌ Seeding error:', error);
  }
};

module.exports = { seedDatabase };
