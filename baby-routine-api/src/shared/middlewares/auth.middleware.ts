import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';
import { AppError } from '../errors/AppError';

export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    throw new AppError('Authentication required', 401, 'UNAUTHORIZED');
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    throw new AppError('Invalid authorization format', 401, 'UNAUTHORIZED');
  }

  const token = parts[1];

  try {
    const decoded = verifyToken(token);
    req.userId = decoded.sub!;
  } catch {
    throw new AppError('Invalid or expired token', 401, 'UNAUTHORIZED');
  }

  next();
}
