const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const bcrypt = require('bcryptjs');

// Model User - sesuai dengan register_screen.dart & profile_screen.dart
const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  full_name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      notEmpty: { msg: 'Nama lengkap wajib diisi' },
    },
  },
  email: {
    type: DataTypes.STRING(150),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: { msg: 'Format email tidak valid' },
      notEmpty: { msg: 'Email wajib diisi' },
    },
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
  address: {
    type: DataTypes.STRING(255),
    allowNull: true,
  },
  device_id: {
    type: DataTypes.STRING(50),
    allowNull: true, // Opsional, sesuai register_screen validator => null
  },
  role: {
    type: DataTypes.STRING(30),
    allowNull: false,
    defaultValue: 'Pendamping',
    validate: {
      isIn: {
        args: [['Pengguna (Netra)', 'Pendamping', 'Guru']],
        msg: 'Role harus salah satu dari: Pengguna (Netra), Pendamping, Guru',
      },
    },
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      len: {
        args: [6, 255],
        msg: 'Password minimal 6 karakter',
      },
    },
  },
  avatar_url: {
    type: DataTypes.STRING(255),
    allowNull: true,
  },
  email_verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  tableName: 'users',
  timestamps: true,
  underscored: true, // created_at, updated_at
  hooks: {
    // Hash password sebelum disimpan ke database
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
    // Hash password saat update jika password berubah
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
  },
});

// Method untuk membandingkan password
User.prototype.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Method untuk mengembalikan data user tanpa password
User.prototype.toSafeJSON = function () {
  const values = { ...this.get() };
  delete values.password;
  return values;
};

module.exports = User;
