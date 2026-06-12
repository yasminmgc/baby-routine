import request from 'supertest';
import app from 'src/app';
import {
  cleanDatabase,
  createTestUserWithToken,
  createTestUser,
  disconnectPrisma,
} from './helpers';

describe('Auth Routes (Integration)', () => {
  afterAll(async () => {
    await disconnectPrisma();
  });

  beforeEach(async () => {
    await cleanDatabase();
  });

  describe('POST /api/v1/auth/register', () => {
    it('should register a new user and return 201', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test User',
          email: 'test@example.com',
          password: 'Password1',
        });

      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body).toHaveProperty('token');
      expect(res.body.name).toBe('Test User');
      expect(res.body.email).toBe('test@example.com');
      expect(res.body).not.toHaveProperty('passwordHash');
    });

    it('should return 409 when email already exists', async () => {
      await createTestUser('Existing', 'existing@example.com');

      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Another User',
          email: 'existing@example.com',
          password: 'Password1',
        });

      expect(res.status).toBe(409);
      expect(res.body).toHaveProperty('message', 'Email already registered');
    });

    it('should return 400 for invalid data (short password)', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test',
          email: 'test@example.com',
          password: 'short',
        });

      expect(res.status).toBe(400);
    });

    it('should return 400 for invalid data (missing name)', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: 'test@example.com',
          password: 'Password1',
        });

      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/v1/auth/login', () => {
    it('should login with valid credentials and return 200', async () => {
      await createTestUser('Test User', 'test@example.com', 'Password1');

      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'test@example.com',
          password: 'Password1',
        });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('token');
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.email).toBe('test@example.com');
      expect(res.body.user.name).toBe('Test User');
      expect(res.body.user).not.toHaveProperty('passwordHash');
    });

    it('should return 400 with wrong password', async () => {
      await createTestUser('Test User', 'test@example.com', 'Password1');

      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'test@example.com',
          password: 'WrongPassword1',
        });

      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('message', 'Invalid email or password');
    });

    it('should return 400 with non-existent email', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: 'Password1',
        });

      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('message', 'Invalid email or password');
    });
  });

  describe('PATCH /api/v1/auth/fcm-token', () => {
    it('should update FCM token with valid auth and return 200', async () => {
      const { token } = await createTestUserWithToken('Test', 'test@example.com');

      const res = await request(app)
        .patch('/api/v1/auth/fcm-token')
        .set('Authorization', `Bearer ${token}`)
        .send({ fcmToken: 'fcm-token-abc123' });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message', 'FCM token updated');
    });

    it('should return 401 when no auth token provided', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/fcm-token')
        .send({ fcmToken: 'fcm-token-abc123' });

      expect(res.status).toBe(401);
    });

    it('should return 401 when auth token is invalid', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/fcm-token')
        .set('Authorization', 'Bearer invalid-token')
        .send({ fcmToken: 'fcm-token-abc123' });

      expect(res.status).toBe(401);
    });
  });
});
