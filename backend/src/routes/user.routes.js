const express = require('express');
const { body } = require('express-validator');
const multer = require('multer');
const path = require('path');
const { validate } = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');
const userController = require('../controllers/user.controller');

const router = express.Router();

// Konfigurasi Multer untuk upload avatar
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads/avatars'));
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, `avatar-${req.user.id}-${uniqueSuffix}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Max 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (extname && mimetype) {
      return cb(null, true);
    }
    cb(new Error('Hanya file gambar (jpeg, jpg, png, gif) yang diperbolehkan.'));
  },
});

// Semua route di bawah ini membutuhkan autentikasi
router.use(authenticate);

// =============================================
// GET /api/users/profile
// Sesuai profile_screen.dart (read mode)
// =============================================
router.get('/profile', userController.getProfile);

// =============================================
// PUT /api/users/profile
// Sesuai profile_screen.dart (edit mode - _saveProfile)
// =============================================
router.put(
  '/profile',
  [
    body('fullName').optional().notEmpty().withMessage('Nama tidak boleh kosong').trim(),
    body('email').optional().isEmail().withMessage('Format email tidak valid').normalizeEmail(),
    body('phone').optional().trim(),
    body('address').optional().trim(),
    body('deviceId').optional().trim(),
    validate,
  ],
  userController.updateProfile
);

// =============================================
// PUT /api/users/change-password
// Sesuai profile_screen.dart (Change Password section)
// =============================================
router.put(
  '/change-password',
  [
    body('oldPassword').notEmpty().withMessage('Password lama wajib diisi'),
    body('newPassword').isLength({ min: 6 }).withMessage('Password baru minimal 6 karakter'),
    body('confirmNewPassword')
      .notEmpty().withMessage('Konfirmasi password wajib diisi')
      .custom((value, { req }) => {
        if (value !== req.body.newPassword) {
          throw new Error('Konfirmasi password tidak cocok');
        }
        return true;
      }),
    validate,
  ],
  userController.changePassword
);

// =============================================
// POST /api/users/upload-avatar
// Sesuai profile_screen.dart (camera icon overlay di edit mode)
// =============================================
router.post('/upload-avatar', upload.single('avatar'), userController.uploadAvatar);

module.exports = router;
