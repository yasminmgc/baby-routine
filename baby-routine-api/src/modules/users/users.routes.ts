import { Router } from 'express';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import * as usersController from './users.controller';

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: User profile endpoints
 *
 * components:
 *   schemas:
 *     UserProfile:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *         email:
 *           type: string
 *         createdAt:
 *           type: string
 *           format: date-time
 *
 * /users/{id}:
 *   get:
 *     tags: [Users]
 *     summary: Get a user's public profile by ID
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID
 *     responses:
 *       '200':
 *         description: User profile retrieved
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/UserProfile'
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '404':
 *         description: User not found
 *       '500':
 *         description: Internal server error
 */

const router = Router();

router.get(
  '/:id',
  authMiddleware,
  usersController.getUserProfile
);

export default router;
