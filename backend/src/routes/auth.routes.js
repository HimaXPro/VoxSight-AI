const express = require('express');
const { body } = require('express-validator');
const { validate } = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');
const authController = require('../controllers/auth.controller');

const router = express.Router();

// =============================================
// POST /api/auth/register
// Sesuai register_screen.dart
// =============================================
router.post(
  '/register',
  [
    body('fullName')
      .notEmpty().withMessage('Name is required')
      .trim(),
    body('email')
      .notEmpty().withMessage('Email is required')
      .isEmail().withMessage('Format email tidak valid')
      .normalizeEmail(),
    body('phone')
      .notEmpty().withMessage('Phone is required')
      .trim(),
    body('deviceId')
      .optional()
      .trim(),
    body('role')
      .optional()
      .isIn(['Pengguna (Netra)', 'Pendamping', 'Guru'])
      .withMessage('Role tidak valid'),
    body('password')
      .isLength({ min: 6 }).withMessage('Min 6 characters'),
    body('confirmPassword')
      .custom((value, { req }) => {
        if (value !== req.body.password) {
          throw new Error('Passwords do not match');
        }
        return true;
      }),
    validate,
  ],
  authController.register
);

// =============================================
// POST /api/auth/login
// Sesuai login_screen.dart
// =============================================
router.post(
  '/login',
  [
    body('email')
      .notEmpty().withMessage('Email is required')
      .isEmail().withMessage('Format email tidak valid')
      .normalizeEmail(),
    body('password')
      .notEmpty().withMessage('Password is required'),
    validate,
  ],
  authController.login
);

// =============================================
// POST /api/auth/forgot-password
// Sesuai forgot_password_screen.dart
// =============================================
router.post(
  '/forgot-password',
  [
    body('email')
      .notEmpty().withMessage('Email is required')
      .isEmail().withMessage('Format email tidak valid')
      .normalizeEmail(),
    validate,
  ],
  authController.forgotPassword
);

// =============================================
// POST /api/auth/verify-email
// Sesuai profile_screen.dart (_verifyEmail)
// Membutuhkan autentikasi (user harus login)
// =============================================
router.post('/verify-email', authenticate, authController.verifyEmail);

// =============================================
// POST /api/auth/reset-password
// Sesuai alur baru (tanpa email link)
// Body: email, resetCode, newPassword, confirmNewPassword
// =============================================
router.post('/reset-password', authController.resetPasswordWithCode);

// =============================================
// POST /api/auth/logout
// Sesuai profile_screen.dart (Sign Out button)
// =============================================
router.post('/logout', authenticate, authController.logout);

module.exports = router;
