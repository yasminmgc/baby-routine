import { Router } from 'express';
import { validate } from '../../shared/middlewares/validate.middleware';
import { authMiddleware } from '../../shared/middlewares/auth.middleware';
import {
  createBabySchema,
  updateBabySchema,
  babyIdParamsSchema,
  addCaregiverSchema,
  caregiverParamsSchema,
} from './babies.schemas';
import * as babiesController from './babies.controller';

/**
 * @swagger
 * tags:
 *   name: Babies
 *   description: Baby management (CRUD and caregiver operations)
 *
 * components:
 *   schemas:
 *     CreateBaby:
 *       type: object
 *       required:
 *         - name
 *         - birthDate
 *       properties:
 *         name:
 *           type: string
 *         birthDate:
 *           type: string
 *           format: date
 *         gender:
 *           type: string
 *           enum: [male, female, other]
 *         initialWeightKg:
 *           type: number
 *         initialHeightCm:
 *           type: number
 *         allergies:
 *           type: string
 *     UpdateBaby:
 *       type: object
 *       properties:
 *         name:
 *           type: string
 *         birthDate:
 *           type: string
 *           format: date
 *         gender:
 *           type: string
 *           enum: [male, female, other]
 *         initialWeightKg:
 *           type: number
 *         initialHeightCm:
 *           type: number
 *         allergies:
 *           type: string
 *     Baby:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *         birthDate:
 *           type: string
 *           format: date-time
 *         gender:
 *           type: string
 *           nullable: true
 *         initialWeightKg:
 *           type: number
 *           nullable: true
 *         initialHeightCm:
 *           type: number
 *           nullable: true
 *         allergies:
 *           type: string
 *           nullable: true
 *         currentUserRole:
 *           type: string
 *           enum: [owner, caregiver]
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *     AddCaregiver:
 *       type: object
 *       required:
 *         - email
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *     Caregiver:
 *       type: object
 *       properties:
 *         userId:
 *           type: string
 *           format: uuid
 *         role:
 *           type: string
 *           enum: [owner, caregiver]
 *         user:
 *           $ref: '#/components/schemas/UserProfile'
 *
 * /babies:
 *   post:
 *     tags: [Babies]
 *     summary: Create a new baby (owner role assigned automatically)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateBaby'
 *     responses:
 *       '201':
 *         description: Baby created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Baby'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Babies]
 *     summary: List all babies the authenticated user is a caregiver of
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       '200':
 *         description: List of babies with roles
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Baby'
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '500':
 *         description: Internal server error
 *
 * /babies/{id}:
 *   get:
 *     tags: [Babies]
 *     summary: Get a baby by ID (caregiver access required)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     responses:
 *       '200':
 *         description: Baby details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Baby'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not a caregiver of this baby
 *       '404':
 *         description: Baby not found
 *       '500':
 *         description: Internal server error
 *   put:
 *     tags: [Babies]
 *     summary: Update a baby (caregiver access required)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateBaby'
 *     responses:
 *       '200':
 *         description: Baby updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Baby'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not a caregiver of this baby
 *       '404':
 *         description: Baby not found
 *       '500':
 *         description: Internal server error
 *   delete:
 *     tags: [Babies]
 *     summary: Delete a baby (owner only)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     responses:
 *       '204':
 *         description: Baby deleted successfully
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not the owner
 *       '404':
 *         description: Baby not found
 *       '500':
 *         description: Internal server error
 *
 * /babies/{id}/caregivers:
 *   post:
 *     tags: [Babies]
 *     summary: Add a caregiver to a baby by email (owner only)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/AddCaregiver'
 *     responses:
 *       '200':
 *         description: Caregiver added successfully
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '404':
 *         description: Baby or user not found
 *       '409':
 *         description: User is already a caregiver
 *       '500':
 *         description: Internal server error
 *   get:
 *     tags: [Babies]
 *     summary: List all caregivers of a baby
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *     responses:
 *       '200':
 *         description: List of caregivers
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Caregiver'
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not a caregiver
 *       '500':
 *         description: Internal server error
 *
 * /babies/{id}/caregivers/{userId}:
 *   delete:
 *     tags: [Babies]
 *     summary: Remove a caregiver from a baby (owner only)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Baby ID
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: User ID to remove
 *     responses:
 *       '200':
 *         description: Caregiver removed successfully
 *       '400':
 *         description: Validation error
 *       '401':
 *         description: Unauthorized — missing or invalid JWT token
 *       '403':
 *         description: Forbidden — user is not the owner
 *       '404':
 *         description: Baby or caregiver not found
 *       '500':
 *         description: Internal server error
 */

const router = Router();

router.use(authMiddleware);

router.post(
  '/',
  validate({ body: createBabySchema }),
  babiesController.create
);

router.get(
  '/',
  babiesController.list
);

router.get(
  '/:id',
  validate({ params: babyIdParamsSchema }),
  babiesController.getById
);

router.put(
  '/:id',
  validate({ params: babyIdParamsSchema, body: updateBabySchema }),
  babiesController.update
);

router.delete(
  '/:id',
  validate({ params: babyIdParamsSchema }),
  babiesController.remove
);

// Caregiver routes
router.post(
  '/:id/caregivers',
  validate({ params: babyIdParamsSchema, body: addCaregiverSchema }),
  babiesController.addCaregiver
);

router.get(
  '/:id/caregivers',
  validate({ params: babyIdParamsSchema }),
  babiesController.listCaregivers
);

router.delete(
  '/:id/caregivers/:userId',
  validate({ params: caregiverParamsSchema }),
  babiesController.removeCaregiver
);

export default router;
