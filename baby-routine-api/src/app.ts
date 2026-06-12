import express from 'express';
import cors from 'cors';
import { errorMiddleware } from './shared/middlewares/error.middleware';
import { setupSwagger } from './config/swagger';
import authRoutes from './modules/auth/auth.routes';
import usersRoutes from './modules/users/users.routes';
import babiesRoutes from './modules/babies/babies.routes';
import eventsRoutes from './modules/events/events.routes';
import routinesRoutes from './modules/routines/routines.routes';
import remindersRoutes from './modules/reminders/reminders.routes';

const app = express();

app.use(cors());
app.use(express.json());

// Swagger docs
setupSwagger(app);

// Health check
app.get('/api/v1/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', usersRoutes);
app.use('/api/v1/babies', babiesRoutes);
app.use('/api/v1/babies/:babyId/events', eventsRoutes);
app.use('/api/v1/babies/:babyId/routines', routinesRoutes);
app.use('/api/v1/babies/:babyId/reminders', remindersRoutes);

// Global error handler (must be after routes)
app.use(errorMiddleware);

export default app;
