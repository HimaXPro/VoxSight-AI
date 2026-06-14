const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');

// Import Routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');

const app = express();

// =============================================
// Middleware
// =============================================

// CORS - agar Flutter app bisa akses API
app.use(cors());

// Parse JSON body
app.use(express.json());

// Parse URL-encoded body
app.use(express.urlencoded({ extended: true }));

// Logger - tampilkan request log di console
app.use(morgan('dev'));

// Static files - untuk serve uploaded avatars
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// =============================================
// Routes
// =============================================

// Auth routes (register, login, forgot-password, verify-email, logout)
app.use('/api/auth', authRoutes);

// User routes (profile, change-password, upload-avatar)
app.use('/api/users', userRoutes);

// =============================================
// Health check endpoint
// =============================================
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'VoxSight AI Backend is running!',
    timestamp: new Date().toISOString(),
  });
});

// =============================================
// 404 Handler
// =============================================
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} tidak ditemukan.`,
  });
});

// =============================================
// Error Handler
// =============================================
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error.',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

module.exports = app;
