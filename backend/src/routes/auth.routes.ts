import { Router } from 'express';
import { body } from 'express-validator';
import * as authController from '../controllers/auth.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

// 用户登录
router.post(
  '/login',
  [
    body('username').isString().notEmpty().withMessage('用户名不能为空'),
    body('password').isString().notEmpty().withMessage('密码不能为空')
  ],
  authController.login
);

// 用户注册
router.post(
  '/register',
  [
    body('username').isString().notEmpty().withMessage('用户名不能为空'),
    body('password').isString().notEmpty().withMessage('密码不能为空'),
    body('email').isEmail().withMessage('邮箱格式不正确'),
    body('name').isString().notEmpty().withMessage('姓名不能为空'),
    body('role').isString().optional().withMessage('角色必须是字符串')
  ],
  authController.register
);

// 用户登出
router.post('/logout', authController.logout);

// 获取当前用户信息（需要认证）
router.get('/me', authenticate, authController.getCurrentUser);

export default router; 