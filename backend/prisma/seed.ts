import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  try {
    console.log('开始导入开发环境数据...');
    
    // 清理现有数据
    console.log('清理现有数据...');
    await prisma.task.deleteMany();
    await prisma.user.deleteMany();
    
    // 创建管理员用户
    console.log('创建用户...');
    const adminPassword = await bcrypt.hash('admin123', 10);
    const admin = await prisma.user.create({
      data: {
        email: 'admin@example.com',
        name: '管理员',
        password: adminPassword,
        role: 'ADMIN',
      },
    });
    
    // 创建普通用户
    const userPassword = await bcrypt.hash('user123', 10);
    const user = await prisma.user.create({
      data: {
        email: 'user@example.com',
        name: '测试用户',
        password: userPassword,
        role: 'USER',
      },
    });
    
    // 创建任务样例
    console.log('创建任务示例...');
    await prisma.task.create({
      data: {
        title: '完成项目计划',
        description: '制定详细的项目实施计划',
        status: 'TODO',
        priority: 'HIGH',
        dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 一周后
        userId: admin.id,
      },
    });
    
    await prisma.task.create({
      data: {
        title: '准备周报',
        description: '整理本周工作内容，准备周五汇报',
        status: 'IN_PROGRESS',
        priority: 'MEDIUM',
        dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 两天后
        userId: user.id,
      },
    });
    
    await prisma.task.create({
      data: {
        title: '系统更新',
        description: '更新系统到最新版本',
        status: 'DONE',
        priority: 'LOW',
        dueDate: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 两天前
        userId: admin.id,
      },
    });
    
    console.log('开发环境数据导入完成！');
  } catch (error) {
    console.error('导入数据时出错:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 