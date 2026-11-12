import request from 'supertest';
import app from 'src/app';
import {
  cleanDatabase,
  createTestUserWithToken,
  createTestUser,
  createTestBaby,
  disconnectPrisma,
  prisma,
} from './helpers';

describe('Events Routes (Integration)', () => {
  afterAll(async () => {
    await disconnectPrisma();
  });

  beforeEach(async () => {
    await cleanDatabase();
  });

  describe('POST /api/v1/babies/:babyId/events', () => {
    it('should create a feeding event and return 201', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const res = await request(app)
        .post(`/api/v1/babies/${baby.id}/events`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          eventType: 'feeding',
          details: {
            feedingType: 'bottle',
            amountMl: 120,
          },
          notes: 'Drank well',
        });

      expect(res.status).toBe(201);
      expect(res.body.eventType).toBe('feeding');
      expect(res.body.status).toBe('completed');
      expect(res.body.details).toMatchObject({ feedingType: 'bottle', amountMl: 120 });
      expect(res.body.notes).toBe('Drank well');
      expect(res.body).toHaveProperty('id');
      expect(res.body.babyId).toBe(baby.id);
    });

    it('should create a sleep event with valid details and return 201', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const res = await request(app)
        .post(`/api/v1/babies/${baby.id}/events`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          eventType: 'sleep',
          details: {
            startTime: '2026-05-08T14:00:00.000Z',
            endTime: '2026-05-08T15:30:00.000Z',
            durationMin: 90,
            location: 'crib',
          },
        });

      expect(res.status).toBe(201);
      expect(res.body.eventType).toBe('sleep');
      expect(res.body.details).toMatchObject({
        startTime: '2026-05-08T14:00:00.000Z',
        endTime: '2026-05-08T15:30:00.000Z',
        durationMin: 90,
        location: 'crib',
      });
    });

    it('should create a diaper event and return 201', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const res = await request(app)
        .post(`/api/v1/babies/${baby.id}/events`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          eventType: 'diaper',
          details: {
            type: 'both',
            color: 'yellow',
            consistency: 'normal',
            rash: false,
          },
        });

      expect(res.status).toBe(201);
      expect(res.body.eventType).toBe('diaper');
      expect(res.body.details).toMatchObject({ type: 'both', color: 'yellow' });
    });

    it('should return 403 when user is not a caregiver', async () => {
      const { user: owner } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(owner.id, 'Baby');

      const { token: strangerToken } = await createTestUserWithToken(
        'Stranger',
        'stranger@example.com',
      );

      const res = await request(app)
        .post(`/api/v1/babies/${baby.id}/events`)
        .set('Authorization', `Bearer ${strangerToken}`)
        .send({
          eventType: 'feeding',
          details: { feedingType: 'bottle' },
        });

      expect(res.status).toBe(403);
    });

    it('should return 401 without auth token', async () => {
      const { user } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby');

      const res = await request(app)
        .post(`/api/v1/babies/${baby.id}/events`)
        .send({
          eventType: 'feeding',
          details: { feedingType: 'bottle' },
        });

      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/v1/babies/:babyId/events', () => {
    it('should list events with pagination', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      // Create a few events
      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'feeding',
          occurredAt: new Date('2026-06-10T10:00:00Z'),
          status: 'completed',
          details: { feedingType: 'bottle', amountMl: 120 },
        },
      });
      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'sleep',
          occurredAt: new Date('2026-06-10T14:00:00Z'),
          status: 'completed',
          details: { durationMin: 90 },
        },
      });
      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'diaper',
          occurredAt: new Date('2026-06-10T16:00:00Z'),
          status: 'completed',
          details: { type: 'pee' },
        },
      });

      const res = await request(app)
        .get(`/api/v1/babies/${baby.id}/events`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('data');
      expect(res.body).toHaveProperty('pagination');
      expect(res.body.data.length).toBe(3);
      expect(res.body.pagination.total).toBe(3);
      expect(res.body.pagination.page).toBe(1);
    });

    it('should filter events by type', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'feeding',
          occurredAt: new Date(),
          status: 'completed',
          details: { feedingType: 'bottle' },
        },
      });
      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'sleep',
          occurredAt: new Date(),
          status: 'completed',
          details: { durationMin: 90 },
        },
      });

      const res = await request(app)
        .get(`/api/v1/babies/${baby.id}/events?type=feeding`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].eventType).toBe('feeding');
    });

    it('should filter events by date range', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'feeding',
          occurredAt: new Date('2026-06-08T10:00:00Z'),
          status: 'completed',
          details: { feedingType: 'bottle' },
        },
      });
      await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'diaper',
          occurredAt: new Date('2026-06-12T10:00:00Z'),
          status: 'completed',
          details: { type: 'pee' },
        },
      });

      const res = await request(app)
        .get(`/api/v1/babies/${baby.id}/events?startDate=2026-06-09&endDate=2026-06-13`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].eventType).toBe('diaper');
    });

    it('should return 403 when user is not a caregiver', async () => {
      const { user: owner } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(owner.id, 'Baby');

      const { token: strangerToken } = await createTestUserWithToken(
        'Stranger',
        'stranger@example.com',
      );

      const res = await request(app)
        .get(`/api/v1/babies/${baby.id}/events`)
        .set('Authorization', `Bearer ${strangerToken}`);

      expect(res.status).toBe(403);
    });
  });

  describe('PUT /api/v1/babies/:babyId/events/:id', () => {
    it('should update an event', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const event = await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'feeding',
          occurredAt: new Date(),
          status: 'completed',
          details: { feedingType: 'bottle', amountMl: 120 },
          notes: 'Original notes',
        },
      });

      const res = await request(app)
        .put(`/api/v1/babies/${baby.id}/events/${event.id}`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          notes: 'Updated notes',
          status: 'completed',
        });

      expect(res.status).toBe(200);
      expect(res.body.notes).toBe('Updated notes');
      expect(res.body.eventType).toBe('feeding');
    });

    it('should return 403 when user is not a caregiver', async () => {
      const { user: owner } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(owner.id, 'Baby');

      const event = await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: owner.id,
          eventType: 'feeding',
          occurredAt: new Date(),
          status: 'completed',
          details: { feedingType: 'bottle' },
        },
      });

      const { token: strangerToken } = await createTestUserWithToken(
        'Stranger',
        'stranger@example.com',
      );

      const res = await request(app)
        .put(`/api/v1/babies/${baby.id}/events/${event.id}`)
        .set('Authorization', `Bearer ${strangerToken}`)
        .send({ notes: 'Hacked' });

      expect(res.status).toBe(403);
    });
  });

  describe('DELETE /api/v1/babies/:babyId/events/:id', () => {
    it('should delete an event and return 204', async () => {
      const { user, token } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(user.id, 'Baby Luna');

      const event = await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: user.id,
          eventType: 'feeding',
          occurredAt: new Date(),
          status: 'completed',
          details: { feedingType: 'bottle' },
        },
      });

      const res = await request(app)
        .delete(`/api/v1/babies/${baby.id}/events/${event.id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(204);

      // Verify event was deleted
      const deleted = await prisma.routineEvent.findUnique({ where: { id: event.id } });
      expect(deleted).toBeNull();
    });

    it('should return 403 when user is not a caregiver', async () => {
      const { user: owner } = await createTestUserWithToken('Owner', 'owner@example.com');
      const baby = await createTestBaby(owner.id, 'Baby');

      const event = await prisma.routineEvent.create({
        data: {
          babyId: baby.id,
          userId: owner.id,
          eventType: 'feeding',
          occurredAt: new Date(),
          status: 'completed',
          details: { feedingType: 'bottle' },
        },
      });

      const { token: strangerToken } = await createTestUserWithToken(
        'Stranger',
        'stranger@example.com',
      );

      const res = await request(app)
        .delete(`/api/v1/babies/${baby.id}/events/${event.id}`)
        .set('Authorization', `Bearer ${strangerToken}`);

      expect(res.status).toBe(403);
    });
  });
});
