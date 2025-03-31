import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { validationResult } from 'express-validator';

const prisma = new PrismaClient();

/**
 * 用户登录
 */
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    // 验证请求数据
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { username, password } = req.body;

    // 查找用户
    const user = await prisma.user.findUnique({
      where: { username }
    });

    // 验证用户存在
    if (!user) {
      res.status(401).json({ message: '用户名或密码错误' });
      return;
    }

    // 验证密码
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      res.status(401).json({ message: '用户名或密码错误' });
      return;
    }

    // 生成JWT令牌
    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role },
      process.env.JWT_SECRET || 'default-secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    // 返回令牌和用户信息（排除密码）
    const { password: _, ...userWithoutPassword } = user;
    res.status(200).json({
      message: '登录成功',
      token,
      user: userWithoutPassword
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: '服务器错误，登录失败' });
  }
};

/**
 * 用户注册
 */
export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    // 验证请求数据
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { username, password, email, name, role = 'USER' } = req.body;

    // 检查用户是否已存在
    const existingUser = await prisma.user.findUnique({
      where: { username }
    });

    if (existingUser) {
      res.status(409).json({ message: '用户名已存在' });
      return;
    }

    // 检查邮箱是否已存在
    const existingEmail = await prisma.user.findUnique({
      where: { email }
    });

    if (existingEmail) {
      res.status(409).json({ message: '邮箱已被使用' });
      return;
    }

    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 10);

    // 创建用户
    const newUser = await prisma.user.create({
      data: {
        username,
        password: hashedPassword,
        email,
        name,
        role
      }
    });

    // 生成JWT令牌
    const token = jwt.sign(
      { id: newUser.id, username: newUser.username, role: newUser.role },
      process.env.JWT_SECRET || 'default-secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    // 返回令牌和用户信息（排除密码）
    const { password: _, ...userWithoutPassword } = newUser;
    res.status(201).json({
      message: '注册成功',
      token,
      user: userWithoutPassword
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ message: '服务器错误，注册失败' });
  }
};

/**
 * 用户登出（仅清除客户端令牌，服务端无需处理）
 */
export const logout = (req: Request, res: Response): void => {
  res.status(200).json({ message: '登出成功' });
};

/**
 * 获取当前用户信息
 */
export const getCurrentUser = async (req: Request, res: Response): Promise<void> => {
  try {
    // 从请求中获取用户ID（通过auth中间件设置）
    const userId = (req as any).user?.id;

    if (!userId) {
      res.status(401).json({ message: '未授权，请先登录' });
      return;
    }

    // 查询用户信息
    const user = await prisma.user.findUnique({
      where: { id: Number(userId) }
    });

    if (!user) {
      res.status(404).json({ message: '用户不存在' });
      return;
    }

    // 返回用户信息（排除密码）
    const { password, ...userWithoutPassword } = user;
    res.status(200).json(userWithoutPassword);
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(500).json({ message: '服务器错误，获取用户信息失败' });
  }
}; 