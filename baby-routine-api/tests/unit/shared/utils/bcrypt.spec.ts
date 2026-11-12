import { hashPassword, comparePassword } from 'src/shared/utils/bcrypt';

describe('Utils - Bcrypt', () => {
  it('should hash a password', async () => {
    const password = 'mySecretPass123';
    const hash = await hashPassword(password);

    expect(hash).toBeDefined();
    expect(hash).not.toBe(password);
    expect(hash.startsWith('$2a$')).toBe(true); // bcrypt hash prefix
  });

  it('should verify a correct password', async () => {
    const password = 'correctPassword123';
    const hash = await hashPassword(password);

    const isMatch = await comparePassword(password, hash);
    expect(isMatch).toBe(true);
  });

  it('should reject an incorrect password', async () => {
    const password = 'correctPassword123';
    const hash = await hashPassword(password);

    const isMatch = await comparePassword('wrongPassword', hash);
    expect(isMatch).toBe(false);
  });

  it('should return false for empty password', async () => {
    const hash = await hashPassword('somePassword');
    const isMatch = await comparePassword('', hash);
    expect(isMatch).toBe(false);
  });

  it('should produce different hashes for the same password', async () => {
    const password = 'samePassword';
    const hash1 = await hashPassword(password);
    const hash2 = await hashPassword(password);

    expect(hash1).not.toBe(hash2);
    // Both should verify correctly
    expect(await comparePassword(password, hash1)).toBe(true);
    expect(await comparePassword(password, hash2)).toBe(true);
  });

  it('should hash with 12 salt rounds', async () => {
    const password = 'saltRoundsTest123';
    const hash = await hashPassword(password);

    // $2a$12$... means 12 rounds
    const rounds = parseInt(hash.split('$')[2], 10);
    expect(rounds).toBe(12);
  });
});
