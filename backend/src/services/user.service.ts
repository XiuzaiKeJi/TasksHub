import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { CreateUserRequest, UpdateUserRequest } from '../types/user';

const prisma = new PrismaClient();

export class UserService {
  /**
   * 获取所有用户
   */
  async getAllUsers() {
    return prisma.user.findMany({
      select: {
        id: true,
        username: true,
        email: true,
        name: true,
        role: true,
        departmentId: true,
        createdAt: true,
        updatedAt: true,
        // 排除密码字段
        password: false,
      }
    });
  }

  /**
   * 根据ID获取用户
   */
  async getUserById(id: number) {
    return prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        username: true,
        email: true,
        name: true,
        role: true,
        departmentId: true,
        createdAt: true,
        updatedAt: true,
        // 排除密码字段
        password: false,
      }
    });
  }

  /**
   * 创建用户
   */
  async createUser(userData: CreateUserRequest) {
    // 检查用户名是否已存在
    const existingUsername = await prisma.user.findUnique({
      where: { username: userData.username }
    });
    if (existingUsername) {
      throw new Error('用户名已存在');
    }

    // 检查邮箱是否已存在
    const existingEmail = await prisma.user.findUnique({
      where: { email: userData.email }
    });
    if (existingEmail) {
      throw new Error('邮箱已被使用');
    }

    // 加密密码
    const hashedPassword = await bcrypt.hash(userData.password, 10);

    // 创建用户
    const newUser = await prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword
      }
    });

    // 排除密码字段
    const { password, ...userWithoutPassword } = newUser;
    return userWithoutPassword;
  }

  /**
   * 更新用户
   */
  async updateUser(id: number, userData: UpdateUserRequest) {
    // 检查用户是否存在
    const user = await prisma.user.findUnique({
      where: { id }
    });
    if (!user) {
      throw new Error('用户不存在');
    }

    // 如果更新用户名，检查是否已存在
    if (userData.username) {
      const existingUsername = await prisma.user.findUnique({
        where: { username: userData.username }
      });
      if (existingUsername && existingUsername.id !== id) {
        throw new Error('用户名已存在');
      }
    }

    // 如果更新邮箱，检查是否已存在
    if (userData.email) {
      const existingEmail = await prisma.user.findUnique({
        where: { email: userData.email }
      });
      if (existingEmail && existingEmail.id !== id) {
        throw new Error('邮箱已被使用');
      }
    }

    // 更新用户
    const updatedUser = await prisma.user.update({
      where: { id },
      data: userData
    });

    // 排除密码字段
    const { password, ...userWithoutPassword } = updatedUser;
    return userWithoutPassword;
  }

  /**
   * 删除用户
   */
  async deleteUser(id: number) {
    // 检查用户是否存在
    const user = await prisma.user.findUnique({
      where: { id }
    });
    if (!user) {
      throw new Error('用户不存在');
    }

    // 删除用户
    await prisma.user.delete({
      where: { id }
    });

    return true;
  }

  /**
   * 修改密码
   */
  async changePassword(id: number, oldPassword: string, newPassword: string) {
    // 检查用户是否存在
    const user = await prisma.user.findUnique({
      where: { id }
    });
    if (!user) {
      throw new Error('用户不存在');
    }

    // 验证旧密码
    const isOldPasswordValid = await bcrypt.compare(oldPassword, user.password);
    if (!isOldPasswordValid) {
      throw new Error('旧密码不正确');
    }

    // 加密新密码
    const hashedNewPassword = await bcrypt.hash(newPassword, 10);

    // 更新密码
    await prisma.user.update({
      where: { id },
      data: { password: hashedNewPassword }
    });

    return true;
  }
} 