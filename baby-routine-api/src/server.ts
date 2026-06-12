import { env } from './config/env';
import app from './app';

app.listen(env.PORT, () => {
  console.log(`Server running on port ${env.PORT}`);
  console.log(`Swagger docs available at http://localhost:${env.PORT}/api/v1/docs`);
});

export default app;
