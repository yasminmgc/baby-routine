// Jest setup - run before all tests
import dotenv from 'dotenv';

dotenv.config(); // Load .env from project root (DATABASE_URL comes from here)

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-jwt-secret-for-unit-tests';
process.env.JWT_EXPIRES_IN = '1h';
process.env.FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'test-project';
process.env.FIREBASE_CLIENT_EMAIL = process.env.FIREBASE_CLIENT_EMAIL || 'test@test.com';
process.env.FIREBASE_PRIVATE_KEY = process.env.FIREBASE_PRIVATE_KEY || '-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----\n';
process.env.PORT = '3001';
