describe('Utils - JWT', () => {
  beforeEach(() => {
    jest.resetModules();
    // Restore default env vars
    process.env.JWT_SECRET = 'test-jwt-secret-for-unit-tests';
    process.env.JWT_EXPIRES_IN = '1h';
  });

  it('should sign and verify a token successfully', () => {
    const { signToken, verifyToken } = require('src/shared/utils/jwt');

    const payload = { sub: 'user-123', email: 'user@test.com' };
    const token = signToken(payload);

    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    expect(token.split('.')).toHaveLength(3); // JWT has 3 parts

    const decoded = verifyToken(token);
    expect(decoded.sub).toBe('user-123');
    expect(decoded.email).toBe('user@test.com');
  });

  it('should include expiration in the token', () => {
    const { signToken, verifyToken } = require('src/shared/utils/jwt');

    const token = signToken({ sub: 'user-456', email: 'test@test.com' });
    const decoded = verifyToken(token);

    expect(decoded.exp).toBeDefined();
    expect(typeof decoded.exp).toBe('number');
  });

  it('should throw on invalid token', () => {
    const { verifyToken } = require('src/shared/utils/jwt');

    expect(() => verifyToken('invalid.token.here')).toThrow();
  });

  it('should throw on expired token', () => {
    // Override expiresIn for this test
    jest.resetModules();
    process.env.JWT_SECRET = 'test-jwt-secret-for-unit-tests';
    process.env.JWT_EXPIRES_IN = '0s';
    const { signToken, verifyToken } = require('src/shared/utils/jwt');

    const token = signToken({ sub: 'user-789', email: 'e@x.com' });

    // Token with 0s expiry is already expired
    expect(() => verifyToken(token)).toThrow();
  });

  it('should throw on tampered token', () => {
    const { signToken, verifyToken } = require('src/shared/utils/jwt');

    const token = signToken({ sub: 'user-abc', email: 'a@b.com' });
    const tampered = token.slice(0, -1) + 'X';

    expect(() => verifyToken(tampered)).toThrow();
  });
});
