// Import library jsonwebtoken untuk membuat JWT token saat login berhasil
const jwt = require('jsonwebtoken');

// Import model User untuk operasi database (cari user, buat user, update, dll)
const User = require('../models/User');

// =============================================
// REGISTER - Sesuai register_screen.dart
// Fields: fullName, email, phone, deviceId (optional), role, password
// =============================================

// Fungsi register: menangani pendaftaran akun baru
// Menggunakan async karena ada operasi database yang perlu ditunggu (await)
const register = async (req, res) => {
  try {
    // Ambil semua data yang dikirim dari Flutter app melalui body request
    // Destructuring: langsung pisahkan setiap field dari req.body
    const { fullName, email, phone, deviceId, role, password } = req.body;

    // Cari apakah sudah ada user dengan email yang sama di database
    // findOne() = cari satu record, where: { email } = kondisi pencariannya
    const existingUser = await User.findOne({ where: { email } });

    // Jika email sudah terdaftar, tolak pendaftaran
    if (existingUser) {
      // 400 = Bad Request: data yang dikirim tidak valid atau sudah ada konflik
      return res.status(400).json({
        success: false,
        message: 'Email sudah terdaftar. Silakan gunakan email lain.',
      });
    }

    // Buat user baru dan simpan ke database
    // Hook beforeCreate di model User.js akan otomatis hash password sebelum disimpan
    const user = await User.create({
      full_name: fullName,        // Mapping nama field dari request ke nama kolom di DB
      email,                      // Shorthand ES6: email: email (nama sama)
      phone,
      device_id: deviceId || null, // Jika deviceId tidak dikirim, simpan null di database
      role: role || 'Pendamping',  // Jika role tidak dipilih, gunakan 'Pendamping' sebagai default
      password,                    // Akan di-hash secara otomatis oleh hook beforeCreate
    });

    // Kirim response sukses dengan data user yang baru dibuat
    // 201 = Created: berhasil membuat resource baru di server
    return res.status(201).json({
      success: true,
      message: 'Akun berhasil dibuat! Silakan login.',
      data: {
        // Kirim hanya data yang aman — JANGAN sertakan password
        id: user.id,
        fullName: user.full_name,
        email: user.email,
        role: user.role,
      },
    });

  } catch (error) {
    // Cetak error ke terminal server untuk membantu proses debugging
    console.error('Register error:', error);

    // Kirim response error ke client jika ada kesalahan yang tidak terduga
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mendaftar.',
      error: error.message, // Detail pesan error teknis
    });
  }
};

// =============================================
// LOGIN - Sesuai login_screen.dart
// Fields: email, password
// Returns: JWT token + user data
// =============================================

// Fungsi login: memverifikasi kredensial dan mengeluarkan JWT token
const login = async (req, res) => {
  try {
    // Ambil email dan password dari body request yang dikirim Flutter app
    const { email, password } = req.body;

    // Cari user di database berdasarkan email yang diinput
    const user = await User.findOne({ where: { email } });

    // Jika tidak ada user dengan email tersebut, tolak login
    if (!user) {
      // 401 = Unauthorized: tidak dikenali atau kredensial salah
      // Pesan sengaja dibuat umum (tidak spesifik) agar attacker tidak tahu mana yang salah
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    // Cek apakah akun user masih aktif (is_active = true)
    if (!user.is_active) {
      // 403 = Forbidden: server tahu siapa user-nya tapi tidak mengizinkan akses
      return res.status(403).json({
        success: false,
        message: 'Akun Anda telah dinonaktifkan.',
      });
    }

    // Bandingkan password yang diinput dengan hash yang tersimpan di database
    // Menggunakan method comparePassword yang didefinisikan di model User.js
    const isMatch = await user.comparePassword(password);

    // Jika password tidak cocok dengan hash di database, tolak login
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    // Buat JWT token baru untuk sesi login user ini
    const token = jwt.sign(
      // Payload: data yang akan disimpan di dalam token (bisa dibaca tapi tidak diubah)
      // JANGAN masukkan data sensitif seperti password ke dalam payload!
      { id: user.id, email: user.email, role: user.role },

      // Secret key: kunci rahasia yang hanya diketahui server
      // Digunakan untuk menandatangani token agar tidak bisa dipalsukan
      process.env.JWT_SECRET,

      // Opsi: token akan kedaluwarsa setelah 7 hari (bisa diubah di .env)
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Kirim response sukses beserta token dan data user
    return res.status(200).json({
      success: true,
      message: 'Login berhasil!',
      data: {
        token, // Token JWT yang harus disimpan Flutter app untuk request selanjutnya
        user: user.toSafeJSON(), // Data user tanpa field password
      },
    });

  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat login.',
      error: error.message,
    });
  }
};

// Tempat penyimpanan OTP sementara di memori server menggunakan struktur data Map
// Map adalah struktur data key-value: email → { code, expiresAt }
// Contoh isi: "user@gmail.com" → { code: "482031", expiresAt: 1719116100000 }
// Catatan: data ini akan hilang jika server direstart (tidak tersimpan di database)
const resetOtpStore = new Map();

// Fungsi untuk membuat kode OTP 6 digit secara acak
function generateResetCode6Digit() {
  // Math.random()         = angka desimal acak antara 0 sampai 1 (contoh: 0.4820)
  // * 1000000             = kalikan sehingga menjadi 0 sampai 999999.99 (contoh: 482031.6)
  // Math.floor()          = bulatkan ke bawah, hilangkan desimal (contoh: 482031)
  // String()              = ubah angka ke teks (contoh: "482031")
  // .padStart(6, '0')     = jika kurang dari 6 karakter, tambah '0' di depan
  //                         contoh: "34" menjadi "000034"
  return String(Math.floor(Math.random() * 1000000)).padStart(6, '0');
}

// =============================================
// FORGOT PASSWORD - Sesuai forgot_password_screen.dart
// =============================================

// Fungsi forgotPassword: generate OTP dan kirimkan ke email pengguna
const forgotPassword = async (req, res) => {
  try {
    // Ambil email dari body request
    const { email } = req.body;

    // Cek apakah email yang dimasukkan terdaftar di database
    const user = await User.findOne({ where: { email } });

    // Jika email tidak ditemukan di database, hentikan proses
    if (!user) {
      // 404 = Not Found: resource yang dicari tidak ada
      return res.status(404).json({
        success: false,
        message: 'Email tidak ditemukan dalam sistem.',
      });
    }

    // Generate kode OTP 6 digit secara acak
    const resetCode = generateResetCode6Digit();

    // Hitung waktu kedaluwarsa OTP: sekarang + 15 menit (dalam milliseconds)
    // Date.now()                = waktu sekarang dalam ms (misal: 1719115200000)
    // Number(...) || 15*60*1000 = ambil dari .env atau gunakan 15 menit sebagai default
    const expiresAt =
      Date.now() + Number(process.env.RESET_CODE_EXPIRES_MS || 15 * 60 * 1000);

    // Simpan kode OTP beserta waktu kedaluarsanya ke Map menggunakan email sebagai key
    resetOtpStore.set(email, { code: resetCode, expiresAt });

    // Status apakah pengiriman email berhasil
    let emailSent = false;
    // Pesan error jika pengiriman email gagal
    let emailError = null;

    // Ambil konfigurasi SMTP dari environment variable
    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS;

    // Hanya kirim email jika konfigurasi SMTP sudah diset di file .env
    if (smtpUser && smtpPass) {
      try {
        // Import nodemailer di dalam blok ini karena hanya dibutuhkan secara kondisional
        const nodemailer = require('nodemailer');

        // Ambil konfigurasi SMTP dari .env atau gunakan nilai default Gmail
        const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com';
        const smtpPort = Number(process.env.SMTP_PORT || 587); // Port 587 = STARTTLS
        // process.env selalu string, jadi gunakan === 'true' untuk konversi ke boolean
        const smtpSecure = process.env.SMTP_SECURE === 'true';

        // Buat koneksi (transporter) ke SMTP server
        const transporter = nodemailer.createTransport({
          host: smtpHost,   // Server email (contoh: smtp.gmail.com)
          port: smtpPort,   // Port SMTP
          secure: smtpSecure, // true = SSL (port 465), false = STARTTLS (port 587)
          auth: {
            user: smtpUser, // Email pengirim dari .env
            pass: smtpPass, // Password/App Password dari .env
          },
        });

        // Ambil alamat pengirim dari .env atau gunakan email SMTP sebagai fallback
        const fromEmail = process.env.SMTP_FROM || smtpUser;

        // Kirim email berisi kode OTP ke email pengguna
        await transporter.sendMail({
          from: fromEmail,  // Pengirim email
          to: email,        // Penerima email (email pengguna yang minta reset)
          subject: 'VoxSight AI - OTP Password Reset',
          // Isi pesan email dalam format teks biasa
          text:
            `Halo ${user.full_name || ''},\n\n` +
            `Kode OTP reset password Anda adalah: ${resetCode}\n\n` +
            `Kode berlaku selama 15 menit.\n\n` +
            `Jika Anda tidak meminta reset password, abaikan email ini.\n`,
        });

        // Tandai bahwa email berhasil terkirim
        emailSent = true;

      } catch (e) {
        // Jika pengiriman email gagal, simpan pesan errornya
        // Tapi tidak menghentikan proses (OTP tetap dibuat dan dikirim ke response)
        emailError = e.message;
      }
    }

    // Kirim response sukses ke Flutter app
    // Ternary operator: kondisi ? nilaiJikaTrue : nilaiJikaFalse
    return res.status(200).json({
      success: true,
      message: emailSent
        ? 'OTP reset code telah dikirim ke email Anda.'
        : 'OTP reset code dibuat. (Email mungkin tidak terkirim, cek dev/debug info di app).',
      data: {
        resetCode,   // Kode OTP dikirim ke response sebagai fallback untuk testing/development
        emailSent,   // Informasi apakah email berhasil dikirim
        emailError,  // Detail error jika email gagal (null jika berhasil)
      },
    });

  } catch (error) {
    console.error('Forgot password error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat membuat reset code.',
      error: error.message,
    });
  }
};

// =============================================
// RESET PASSWORD WITH OTP
// Body: email, resetCode, newPassword, confirmNewPassword
// =============================================

// Fungsi resetPasswordWithCode: verifikasi OTP dan update password baru
const resetPasswordWithCode = async (req, res) => {
  try {
    // Ambil semua field yang diperlukan dari body request
    const { email, resetCode, newPassword, confirmNewPassword } = req.body;

    // Validasi manual satu per satu untuk setiap field yang wajib ada
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email wajib diisi.' });
    }
    if (!resetCode) {
      return res.status(400).json({ success: false, message: 'Reset code wajib diisi.' });
    }
    // String() memastikan newPassword dikonversi ke string sebelum cek panjangnya
    if (!newPassword || String(newPassword).length < 6) {
      return res.status(400).json({ success: false, message: 'Password baru minimal 6 karakter.' });
    }
    // Pastikan password baru dan konfirmasinya sama persis
    if (!confirmNewPassword || newPassword !== confirmNewPassword) {
      return res.status(400).json({ success: false, message: 'Konfirmasi password tidak cocok.' });
    }

    // Cari user berdasarkan email di database
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Email tidak ditemukan dalam sistem.' });
    }

    // Ambil data OTP yang tersimpan dari Map menggunakan email sebagai key
    const record = resetOtpStore.get(email);

    // Jika tidak ada OTP untuk email ini (belum request atau sudah pernah dipakai)
    if (!record) {
      return res.status(400).json({ success: false, message: 'Reset code tidak ditemukan atau sudah dipakai.' });
    }

    // Cek apakah OTP sudah melewati waktu kedaluarsanya
    // record.expiresAt = batas waktu OTP dalam milliseconds
    // Date.now()       = waktu sekarang dalam milliseconds
    if (record.expiresAt < Date.now()) {
      // Hapus OTP yang sudah expired dari Map agar tidak menumpuk
      resetOtpStore.delete(email);
      return res.status(400).json({ success: false, message: 'Reset code sudah kedaluwarsa.' });
    }

    // Bandingkan kode OTP yang diinput user dengan yang tersimpan di Map
    // String() pada keduanya untuk memastikan perbandingan dilakukan sebagai teks
    if (String(record.code) !== String(resetCode)) {
      return res.status(400).json({ success: false, message: 'Reset code salah.' });
    }

    // Semua validasi lolos — update password user dengan password baru
    // Hook beforeUpdate di model User.js akan otomatis hash password baru ini
    user.password = newPassword;
    await user.save(); // Simpan perubahan ke database

    // Hapus OTP dari Map setelah berhasil digunakan (one-time use)
    // Mencegah kode OTP yang sama dipakai berkali-kali
    resetOtpStore.delete(email);

    // Kirim response sukses
    return res.status(200).json({
      success: true,
      message: 'Password berhasil direset!',
    });

  } catch (error) {
    console.error('Reset password error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mereset password.',
      error: error.message,
    });
  }
};

// =============================================
// VERIFY EMAIL - Sesuai profile_screen.dart (_verifyEmail)
// Simulasi verifikasi email
// =============================================

// Fungsi verifyEmail: menandai email pengguna sebagai sudah diverifikasi
const verifyEmail = async (req, res) => {
  try {
    // Ambil ID user dari req.user yang sudah diisi oleh middleware authenticate
    const userId = req.user.id;

    // Cari user di database berdasarkan primary key (ID)
    const user = await User.findByPk(userId);

    // Pastikan user masih ada di database
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Ubah status verifikasi email menjadi true
    user.email_verified = true;

    // Simpan perubahan ke database
    await user.save();

    // Kirim response sukses
    return res.status(200).json({
      success: true,
      message: 'Email verified successfully!',
    });

  } catch (error) {
    console.error('Verify email error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat verifikasi email.',
      error: error.message,
    });
  }
};

// =============================================
// LOGOUT
// Di sisi client, cukup hapus token dari storage
// =============================================

// Fungsi logout: memberikan konfirmasi logout dari sisi server
// JWT bersifat stateless sehingga token tidak disimpan di server
// Token cukup dihapus dari storage Flutter app (SharedPreferences/SecureStorage)
const logout = async (req, res) => {
  try {
    // Langsung kirim response sukses karena tidak ada operasi server yang perlu dilakukan
    return res.status(200).json({
      success: true,
      message: 'Logout berhasil.',
    });
  } catch (error) {
    console.error('Logout error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat logout.',
      error: error.message,
    });
  }
};

// Export semua fungsi controller agar bisa diimport di file routes
module.exports = {
  register,
  login,
  forgotPassword,
  resetPasswordWithCode,
  verifyEmail,
  logout,
};
