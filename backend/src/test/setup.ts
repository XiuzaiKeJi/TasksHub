import { PrismaClient } from '@prisma/client';
import { beforeAll, afterAll } from '@jest/globals';

const prisma = new PrismaClient();

beforeAll(async () => {
  // 测试环境初始化
  process.env.NODE_ENV = 'test';
  process.env.TEST_DATABASE_URL = 'mysql://taskshub_user:test123@localhost:3306/taskshub_test';
  
  // 清理测试数据库
  await prisma.task.deleteMany();
  await prisma.user.deleteMany();
  await prisma.department.deleteMany();
});

afterAll(async () => {
  // 清理测试数据
  await prisma.task.deleteMany();
  await prisma.user.deleteMany();
  await prisma.department.deleteMany();
  
  // 断开数据库连接
  await prisma.$disconnect();
}); 