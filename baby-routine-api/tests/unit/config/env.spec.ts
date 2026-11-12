describe('Config - env', () => {
  beforeEach(() => {
    jest.resetModules();
    // Restore env vars that might have been deleted
    process.env.PORT = '3001';
    process.env.NODE_ENV = 'test';
    process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test';
    process.env.JWT_SECRET = 'test-jwt-secret-for-unit-tests';
    process.env.JWT_EXPIRES_IN = '1h';
    process.env.FIREBASE_PROJECT_ID = 'test-project';
    process.env.FIREBASE_CLIENT_EMAIL = 'test@test.com';
    process.env.FIREBASE_PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----\n';
  });

  it('should export a typed config object with all required fields', () => {
    const { env } = require('src/config/env');

    expect(env.PORT).toBe(3001);
    expect(env.NODE_ENV).toBe('test');
    expect(env.DATABASE_URL).toBeDefined();
    expect(env.JWT_SECRET).toBe('test-jwt-secret-for-unit-tests');
    expect(env.JWT_EXPIRES_IN).toBe('1h');
    expect(env.FIREBASE_PROJECT_ID).toBe('test-project');
    expect(env.FIREBASE_CLIENT_EMAIL).toBe('test@test.com');
    expect(env.FIREBASE_PRIVATE_KEY).toBeDefined();
  });

  it('should use default values when env vars are missing', () => {
    delete process.env.PORT;
    delete process.env.NODE_ENV;
    delete process.env.JWT_EXPIRES_IN;

    jest.resetModules();
    const { env } = require('src/config/env');

    expect(env.PORT).toBe(3000);
    expect(env.NODE_ENV).toBe('development');
    expect(env.JWT_EXPIRES_IN).toBe('7d');
  });

  it('should throw when required env vars are missing', () => {
    const fs = require('fs');
    const path = require('path');
    const envPath = path.resolve(process.cwd(), '.env');
    const envBackup = path.resolve(process.cwd(), '.env.backup-test');

    // Temporarily remove .env so dotenv can't load values
    if (fs.existsSync(envPath)) {
      fs.renameSync(envPath, envBackup);
    }
    delete process.env.DATABASE_URL;

    jest.resetModules();
    try {
      expect(() => require('src/config/env')).toThrow('DATABASE_URL');
    } finally {
      // Restore .env regardless of test result
      if (fs.existsSync(envBackup)) {
        fs.renameSync(envBackup, envPath);
      }
    }
  });
});
