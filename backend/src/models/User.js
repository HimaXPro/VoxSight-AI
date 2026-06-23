// Import DataTypes dari Sequelize untuk mendefinisikan tipe data setiap kolom
const { DataTypes } = require('sequelize');

// Import instance koneksi database yang sudah dikonfigurasi di config/database.js
const sequelize = require('../config/database');

// Import library bcryptjs untuk hashing dan verifikasi password secara aman
const bcrypt = require('bcryptjs');

// Definisikan model 'User' yang akan menjadi representasi tabel 'users' di database
// Parameter 1: nama model ('User')
// Parameter 2: objek yang mendefinisikan setiap kolom beserta tipe dan validasinya
const User = sequelize.define('User', {

  // Kolom id: nomor unik untuk setiap baris data user
  id: {
    type: DataTypes.INTEGER,   // Tipe data bilangan bulat (1, 2, 3, ...)
    primaryKey: true,          // Jadikan kolom ini sebagai primary key (identifier unik)
    autoIncrement: true,       // Otomatis bertambah 1 setiap kali ada user baru dibuat
  },

  // Kolom full_name: nama lengkap pengguna
  full_name: {
    type: DataTypes.STRING(100), // Tipe teks dengan panjang maksimal 100 karakter
    allowNull: false,            // Kolom ini wajib diisi, tidak boleh kosong (NULL)
    validate: {
      // Validasi di level model (dicek sebelum data disimpan ke database)
      notEmpty: { msg: 'Nama lengkap wajib diisi' }, // Tidak boleh string kosong ''
    },
  },

  // Kolom email: alamat email pengguna (dipakai untuk login)
  email: {
    type: DataTypes.STRING(150), // Tipe teks maksimal 150 karakter
    allowNull: false,            // Wajib diisi
    unique: true,                // Tidak boleh ada 2 user dengan email yang sama
    validate: {
      isEmail: { msg: 'Format email tidak valid' }, // Harus mengandung @ dan domain
      notEmpty: { msg: 'Email wajib diisi' },
    },
  },

  // Kolom phone: nomor telepon pengguna
  phone: {
    type: DataTypes.STRING(20), // Tipe teks maksimal 20 karakter
    allowNull: true,            // Opsional, boleh tidak diisi (NULL diperbolehkan)
  },

  // Kolom address: alamat tempat tinggal pengguna
  address: {
    type: DataTypes.STRING(255), // Tipe teks maksimal 255 karakter
    allowNull: true,             // Opsional
  },

  // Kolom device_id: ID perangkat smart glasses yang dimiliki pengguna
  device_id: {
    type: DataTypes.STRING(50), // Tipe teks maksimal 50 karakter
    allowNull: true,            // Opsional (tidak semua user punya smart glasses)
  },

  // Kolom role: peran/jenis pengguna dalam aplikasi
  role: {
    type: DataTypes.STRING(30),
    allowNull: false,
    defaultValue: 'Pendamping', // Nilai default jika tidak dipilih saat registrasi
    validate: {
      isIn: {
        // Nilai role hanya boleh salah satu dari 3 pilihan ini
        args: [['Pengguna (Netra)', 'Pendamping', 'Guru']],
        msg: 'Role harus salah satu dari: Pengguna (Netra), Pendamping, Guru',
      },
    },
  },

  // Kolom password: kata sandi pengguna (akan disimpan dalam bentuk hash, bukan teks asli)
  password: {
    type: DataTypes.STRING(255), // Hash bcrypt bisa mencapai ~60 karakter, beri ruang 255
    allowNull: false,            // Wajib diisi
    validate: {
      len: {
        args: [6, 255],          // Panjang password harus antara 6 sampai 255 karakter
        msg: 'Password minimal 6 karakter',
      },
    },
  },

  // Kolom avatar_url: path/URL foto profil pengguna
  avatar_url: {
    type: DataTypes.STRING(255), // Menyimpan path seperti: /uploads/avatars/avatar-1-xyz.jpg
    allowNull: true,             // Opsional, tidak semua user upload foto
  },

  // Kolom email_verified: status apakah email sudah diverifikasi
  email_verified: {
    type: DataTypes.BOOLEAN, // Hanya menyimpan nilai true atau false
    defaultValue: false,     // Saat baru daftar, email belum diverifikasi
  },

  // Kolom is_active: status apakah akun pengguna masih aktif
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true, // Akun aktif secara default saat pertama kali dibuat
    // Bisa diset false untuk menonaktifkan akun tanpa menghapus datanya (soft delete)
  },

}, {
  // Nama tabel di database yang akan digunakan (override default Sequelize yang pakai 'Users')
  tableName: 'users',

  // Otomatis buat dan kelola kolom created_at dan updated_at
  timestamps: true,

  // Gunakan format snake_case untuk nama kolom otomatis (created_at, updated_at)
  // Bukan camelCase (createdAt, updatedAt) yang merupakan default Sequelize
  underscored: true,

  hooks: {
    // Hooks adalah fungsi yang otomatis dijalankan sebelum atau sesudah operasi database

    // beforeCreate: dijalankan SEBELUM data user baru disimpan ke database
    beforeCreate: async (user) => {
      if (user.password) {
        // Generate "salt": data acak yang akan dikombinasikan dengan password
        // Angka 10 = cost factor (semakin besar = semakin aman tapi lebih lambat prosesnya)
        const salt = await bcrypt.genSalt(10);

        // Hash password asli menggunakan salt yang sudah dibuat
        // Hasil: string acak ~60 karakter yang tidak bisa dikembalikan ke aslinya
        // Contoh: "123456" → "$2a$10$xyz...randomchars...abc"
        user.password = await bcrypt.hash(user.password, salt);
      }
    },

    // beforeUpdate: dijalankan SEBELUM data user yang sudah ada diperbarui
    beforeUpdate: async (user) => {
      // Hanya hash ulang password jika field password memang berubah
      // Mencegah password di-hash berkali-kali (yang akan merusak datanya)
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
  },
});

// Tambahkan method comparePassword ke semua instance objek User
// Method ini digunakan saat login untuk memverifikasi password yang diinput user
User.prototype.comparePassword = async function (candidatePassword) {
  // bcrypt.compare() tahu cara membandingkan teks biasa dengan hash
  // Return true jika password cocok dengan hash, false jika tidak
  return bcrypt.compare(candidatePassword, this.password);
};

// Tambahkan method toSafeJSON ke semua instance objek User
// Digunakan sebelum mengirim data user ke client (Flutter app)
// PENTING: Jangan pernah kirim field password ke client!
User.prototype.toSafeJSON = function () {
  // this.get() = ambil semua nilai kolom user sebagai plain JavaScript object
  // Spread operator { ...obj } = salin semua properti ke objek baru
  const values = { ...this.get() };

  // Hapus field password dari salinan objek tersebut
  delete values.password;

  // Kembalikan data user yang aman (tanpa password)
  return values;
};

// Export model User agar bisa diimport dan digunakan di file controller
module.exports = User;
