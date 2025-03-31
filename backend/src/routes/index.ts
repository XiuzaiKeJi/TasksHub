import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import departmentRoutes from './department.routes';
import taskRoutes from './task.routes';

const router = Router();

// 健康检查路由
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API版本前缀
const apiPrefix = '/api/v1';

// 注册各模块路由
router.use(`${apiPrefix}/auth`, authRoutes);
router.use(`${apiPrefix}/users`, userRoutes);
router.use(`${apiPrefix}/departments`, departmentRoutes);
router.use(`${apiPrefix}/tasks`, taskRoutes);

export default router; 