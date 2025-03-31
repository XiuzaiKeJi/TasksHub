import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // 清理现有数据
  await prisma.task.deleteMany();
  await prisma.user.deleteMany();
  await prisma.department.deleteMany();

  // 创建部门
  const adminDept = await prisma.department.create({
    data: {
      name: '行政管理部',
    },
  });

  const itDept = await prisma.department.create({
    data: {
      name: '信息技术部',
    },
  });

  // 创建用户
  const adminPassword = await bcrypt.hash('admin123', 10);
  const userPassword = await bcrypt.hash('user123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@taskshub.com',
      name: '系统管理员',
      password: adminPassword,
      role: 'ADMIN',
      departmentId: adminDept.id,
    },
  });

  const manager = await prisma.user.create({
    data: {
      email: 'manager@taskshub.com',
      name: '部门经理',
      password: userPassword,
      role: 'MANAGER',
      departmentId: itDept.id,
    },
  });

  const user = await prisma.user.create({
    data: {
      email: 'user@taskshub.com',
      name: '普通用户',
      password: userPassword,
      role: 'USER',
      departmentId: itDept.id,
    },
  });

  // 创建任务
  const mainTask = await prisma.task.create({
    data: {
      title: '系统开发项目',
      description: '开发行政办公任务中心系统',
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: new Date('2024-09-15'),
      userId: manager.id,
      departmentId: itDept.id,
    },
  });

  await prisma.task.create({
    data: {
      title: '需求分析',
      description: '收集和分析用户需求',
      status: 'DONE',
      priority: 'HIGH',
      dueDate: new Date('2024-04-15'),
      userId: user.id,
      departmentId: itDept.id,
      parentId: mainTask.id,
    },
  });

  await prisma.task.create({
    data: {
      title: '系统设计',
      description: '设计系统架构和数据库',
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: new Date('2024-04-30'),
      userId: user.id,
      departmentId: itDept.id,
      parentId: mainTask.id,
    },
  });

  await prisma.task.create({
    data: {
      title: '开发实现',
      description: '实现系统功能',
      status: 'TODO',
      priority: 'HIGH',
      dueDate: new Date('2024-07-15'),
      userId: user.id,
      departmentId: itDept.id,
      parentId: mainTask.id,
    },
  });

  console.log('测试数据创建完成！');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 
 