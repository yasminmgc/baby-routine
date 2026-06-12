import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import { registerSchema, loginSchema, fcmTokenSchema } from './auth.schemas';
import * as authController from './auth.controller';

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentication endpoints (register, login, FCM token)
 *
 * components:
 *   schemas:
 *     UserRegister:
 *       type: object
 *       required:
 *         - name
 *         - email
 *         - password
 *       properties:
 *         name:
 *           type: string
 *           description: User's full name
 *         email:
 *           type: string
 *           format: email
 *           description: User's email address
 *         password:
 *           type: string
 *           format: password
 *           minLength: 8
 *           description: Password (min 8 chars, 1 uppercase, 1 number)
 *     Login:
 *       type: object
 *       required:
 *         - email
 *         - password
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *         password:
 *           type: string
 *           format: password
 *     FcmToken:
 *       type: object
 *       required:
 *         - fcmToken
 *       properties:
 *         fcmToken:
 *           type: string
 *           description: Firebase Cloud Messaging device token
 *     RegisterResponse:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *         email:
 *           type: string
 *         token:
 *           type: string
 *     LoginResponse:
 *       type: object
 *       properties:
 *         token:
 *           type: string
 *         user:
 *           type: object
 *           properties:
 *             id:
 *               type: string
 *               format: uuid
 *             name:
 *               type: string
 *             email:
 *               type: string
 *             createdAt:
 *               type: string
 *               format: date-time
 *
 * /auth/register:
 *   post:
 *     tags: [Auth]
 *     summary: Register a new user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UserRegister'
 *     responses:
 *       '201':
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RegisterResponse'
 *       '400':
 *         description: Validation error (invalid data format)
 *       '409':
 *         description: Email already registered
 *       '500':
 *         description: Internal server error
 *
 * /auth/login:
 *   post:
 *     tags: [Auth]
 *     summary: Authenticate a user and return a JWT token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Login'
 *     responses:
 *       '200':
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/LoginResponse'
 *       '400':
 *         description: Invalid credentials or validation error
 *       '500':
 *         description: Internal server error
 *
 * /auth/fcm-token:
 *   patch:
 *     tags: [Auth]
 *     summary: Update the FCM push notification token for the authenticated user
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/FcmToken'
 *     responses:
 *       '200':
 *         description: FCM token updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *       '400':
 *         description: Validation error (invalid data format)
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '500':
 *         description: Internal server error
 */

const router = Router();

router.post(
  '/register',
  validate({ body: registerSchema }),
  authController.register
);

router.post(
  '/login',
  validate({ body: loginSchema }),
  authController.login
);

router.patch(
  '/fcm-token',
  authMiddleware,
  validate({ body: fcmTokenSchema }),
  authController.updateFcmToken
);

export default router;
