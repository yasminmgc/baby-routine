import request from 'supertest';
import app from 'src/app';
import {
  cleanDatabase,
  createTestUserWithToken,
  createTestUser,
  createTestBaby,
  generateToken,
  disconnectPrisma,
} from './helpers';

describe('Babies Routes (Integration)', () => {
  afterAll(async () => {
    await disconnectPrisma();
  });

  beforeEach(async () => {
    await cleanDatabase();
  });

  describe('POST /api/v1/babies', () => {
    it('should create a baby and return 201 with currentUserRole owner', async () => {
      const { token } = await createTestUserWithToken('Owner', 'owner@example.com');

      const res = await request(app)
        .post('/api/v1/babies')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Baby Luna',
          birthDate: '2025-06-01',
          gender: 'female',
          initialWeightKg: 3.5,
          initialHeightCm: 50,
          allergies: 'None',
        });

      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.name).toBe('Baby Luna');
      expect(res.body.gender).toBe('female');
      expect(res.body.currentUserRole).toBe('owner');
    });

    it('should return 401 without auth token', async () => {
      const res = await request(app)
        .post('/api/v1/babies')
        .send({
          name: 'Baby Test',
          birthDate: '2025-06-01',
        });

      expect(res.status).toBe(401);
    });

    it('should return 400 with invalid body (missing name)', async () => {
      const { token } = await createTestUserWithToken('User', 'user@example.com');

      const res = await request(app)
        .post('/api/v1/babies')
        .set('Authorization', `Bearer ${token}`)
        .send({
          birthDate: '2025-06-01',
        });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/babies', () => {
    it('should list babies for authenticated user', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');

      // Create a baby directly
      await createTestBaby(user.id, 'Baby One');

      const res = await request(app)
        .get('/api/v1/babies')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it('should return 401 without auth token', async () => {
      const res = await request(app).get('/api/v1/babies');

      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/v1/babies/:id', () => {
    it('should return baby when user is caregiver (200)', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const res = await request(app)
        .get(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Baby Luna');
      expect(res.body.currentUserRole).toBe('owner');
    });

    it('should return 403 when user is NOT a caregiver', async () => {
      // Create a baby owned by user1
      const { user: user1 } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user1.id, 'Secret Baby');

      // user2 is not a caregiver of this baby
      const { token: token2 } = await createTestUserWithToken('Stranger', 'stranger@example.com');

      const res = await request(app)
        .get(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${token2}`);

      expect(res.status).toBe(403);
    });

    it('should return 401 without auth token', async () => {
      const { user } = await createTestUserWithToken('Owner', 'owner2@example.com');
      const baby = await createTestBaby(user.id, 'Baby');

      const res = await request(app).get(`/api/v1/babies/${baby.id}`);

      expect(res.status).toBe(401);
    });
  });

  describe('PUT /api/v1/babies/:id', () => {
    it('should update baby when user is caregiver (200)', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const res = await request(app)
        .put(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Baby Luna Updated',
          allergies: 'Peanuts',
        });

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Baby Luna Updated');
      expect(res.body.allergies).toBe('Peanuts');
      expect(res.body.currentUserRole).toBe('owner');
    });

    it('should return 403 when user is not a caregiver', async () => {
      const { user: user1 } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user1.id, 'Baby');

      const { token: token2 } = await createTestUserWithToken('Stranger', 'stranger@example.com');

      const res = await request(app)
        .put(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${token2}`)
        .send({ name: 'Hacked' });

      expect(res.status).toBe(403);
    });
  });

  describe('DELETE /api/v1/babies/:id', () => {
    it('should delete baby when user is owner (204)', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby To Delete');

      const res = await request(app)
        .delete(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(204);
    });

    it('should return 403 when user is caregiver but not owner', async () => {
      const { user: ownerUser } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(ownerUser.id, 'Baby');

      // Create caregiver user and add them to the baby
      const { user: caregiverUser, token: caregiverToken } = await createTestUserWithToken(
        'Caregiver',
        'caregiver@example.com',
      );

      // Directly add caregiver to baby via Prisma
      const { prisma } = await import('./helpers');
      await prisma.babyCaregiver.create({
        data: {
          babyId: baby.id,
          userId: caregiverUser.id,
          role: 'caregiver',
        },
      });

      const res = await request(app)
        .delete(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${caregiverToken}`);

      expect(res.status).toBe(403);
    });

    it('should return 403 when user is not a caregiver at all', async () => {
      const { user: ownerUser } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(ownerUser.id, 'Baby');

      const { token: strangerToken } = await createTestUserWithToken(
        'Stranger',
        'stranger@example.com',
      );

      const res = await request(app)
        .delete(`/api/v1/babies/${baby.id}`)
        .set('Authorization', `Bearer ${strangerToken}`);

      expect(res.status).toBe(403);
    });
  });
});
