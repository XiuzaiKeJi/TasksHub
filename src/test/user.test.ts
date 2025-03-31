import { PrismaClient } from '@prisma/client';
import { User } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

describe('用户管理测试', () => {
  let testUser: User;

  beforeEach(async () => {
    // 创建测试用户
    const password = await bcrypt.hash('test123', 10);
    testUser = await prisma.user.create({
      data: {
        email: 'test@example.com',
        name: '测试用户',
        password,
        role: 'USER',
      },
    });
  });

  afterEach(async () => {
    // 清理测试数据
    await prisma.user.deleteMany();
  });

  test('创建用户', async () => {
    const password = await bcrypt.hash('newuser123', 10);
    const user = await prisma.user.create({
      data: {
        email: 'newuser@example.com',
        name: '新用户',
        password,
        role: 'USER',
      },
    });

    expect(user).toBeDefined();
    expect(user.email).toBe('newuser@example.com');
    expect(user.name).toBe('新用户');
    expect(user.role).toBe('USER');
  });

  test('查询用户', async () => {
    const user = await prisma.user.findUnique({
      where: { id: testUser.id },
    });

    expect(user).toBeDefined();
    expect(user?.email).toBe(testUser.email);
    expect(user?.name).toBe(testUser.name);
  });

  test('更新用户', async () => {
    const updatedUser = await prisma.user.update({
      where: { id: testUser.id },
      data: { name: '更新后的用户' },
    });

    expect(updatedUser.name).toBe('更新后的用户');
  });

  test('删除用户', async () => {
    await prisma.user.delete({
      where: { id: testUser.id },
    });

    const deletedUser = await prisma.user.findUnique({
      where: { id: testUser.id },
    });

    expect(deletedUser).toBeNull();
  });
}); 