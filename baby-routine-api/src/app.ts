import express from 'express';
import cors from 'cors';
import { errorMiddleware } from './shared/middlewares/error.middleware';
import { setupSwagger } from './config/swagger';

const app = express();

app.use(cors());
app.use(express.json());

// Swagger docs
setupSwagger(app);

// Health check
app.get('/api/v1/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes will be registered here as modules are implemented

// Global error handler (must be after routes)
app.use(errorMiddleware);

export default app;
