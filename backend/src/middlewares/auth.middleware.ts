import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface JwtPayload {
  id: number;
  username: string;
  role: string;
}

/**
 * 认证中间件：验证用户是否登录
 */
export const authenticate = (req: Request, res: Response, next: NextFunction): void => {
  try {
    // 从请求头获取认证令牌
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ message: '未授权，请先登录' });
      return;
    }

    // 提取令牌
    const token = authHeader.split(' ')[1];
    
    // 验证令牌
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret') as JwtPayload;

    // 将用户信息添加到请求对象
    (req as any).user = decoded;
    
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({ message: '无效的令牌，请重新登录' });
    } else if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({ message: '令牌已过期，请重新登录' });
    } else {
      console.error('Authentication error:', error);
      res.status(500).json({ message: '服务器错误，认证失败' });
    }
  }
};

/**
 * 角色授权中间件：验证用户是否有指定角色
 */
export const authorize = (roles: string[]): ((req: Request, res: Response, next: NextFunction) => void) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      // 检查是否已经通过认证
      const user = (req as any).user;
      if (!user) {
        res.status(401).json({ message: '未授权，请先登录' });
        return;
      }

      // 验证角色
      if (!roles.includes(user.role)) {
        res.status(403).json({ message: '权限不足，无法访问该资源' });
        return;
      }

      next();
    } catch (error) {
      console.error('Authorization error:', error);
      res.status(500).json({ message: '服务器错误，授权失败' });
    }
  };
}; 