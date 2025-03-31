import { Router } from 'express';
import { body, param, query } from 'express-validator';
// 暂时使用空控制器，后续实现
const taskController = {
  getAllTasks: (req: any, res: any) => {
    res.status(501).json({ message: '获取所有任务功能尚未实现' });
  },
  getTaskById: (req: any, res: any) => {
    res.status(501).json({ message: '获取指定任务功能尚未实现' });
  },
  createTask: (req: any, res: any) => {
    res.status(501).json({ message: '创建任务功能尚未实现' });
  },
  updateTask: (req: any, res: any) => {
    res.status(501).json({ message: '更新任务功能尚未实现' });
  },
  deleteTask: (req: any, res: any) => {
    res.status(501).json({ message: '删除任务功能尚未实现' });
  },
  assignTask: (req: any, res: any) => {
    res.status(501).json({ message: '分配任务功能尚未实现' });
  },
  updateTaskStatus: (req: any, res: any) => {
    res.status(501).json({ message: '更新任务状态功能尚未实现' });
  },
  getSubTasks: (req: any, res: any) => {
    res.status(501).json({ message: '获取子任务功能尚未实现' });
  }
};

const router = Router();

// 获取所有任务
router.get(
  '/',
  [
    query('status').isString().optional().withMessage('状态必须是字符串'),
    query('assigneeId').isNumeric().optional().withMessage('负责人ID必须是数字'),
    query('departmentId').isNumeric().optional().withMessage('部门ID必须是数字'),
    query('priority').isString().optional().withMessage('优先级必须是字符串')
  ],
  taskController.getAllTasks
);

// 获取指定任务
router.get(
  '/:id',
  param('id').isNumeric().withMessage('任务ID必须是数字'),
  taskController.getTaskById
);

// 创建任务
router.post(
  '/',
  [
    body('title').isString().notEmpty().withMessage('任务标题不能为空'),
    body('description').isString().optional().withMessage('任务描述必须是字符串'),
    body('dueDate').isISO8601().optional().withMessage('截止日期格式不正确'),
    body('priority').isString().optional().withMessage('优先级必须是字符串'),
    body('status').isString().optional().withMessage('状态必须是字符串'),
    body('assigneeId').isNumeric().optional().withMessage('负责人ID必须是数字'),
    body('departmentId').isNumeric().optional().withMessage('部门ID必须是数字'),
    body('parentId').isNumeric().optional().withMessage('父任务ID必须是数字')
  ],
  taskController.createTask
);

// 更新任务
router.put(
  '/:id',
  [
    param('id').isNumeric().withMessage('任务ID必须是数字'),
    body('title').isString().optional().withMessage('任务标题必须是字符串'),
    body('description').isString().optional().withMessage('任务描述必须是字符串'),
    body('dueDate').isISO8601().optional().withMessage('截止日期格式不正确'),
    body('priority').isString().optional().withMessage('优先级必须是字符串'),
    body('status').isString().optional().withMessage('状态必须是字符串')
  ],
  taskController.updateTask
);

// 删除任务
router.delete(
  '/:id',
  param('id').isNumeric().withMessage('任务ID必须是数字'),
  taskController.deleteTask
);

// 分配任务
router.post(
  '/:id/assign',
  [
    param('id').isNumeric().withMessage('任务ID必须是数字'),
    body('assigneeId').isNumeric().notEmpty().withMessage('负责人ID不能为空')
  ],
  taskController.assignTask
);

// 更新任务状态
router.patch(
  '/:id/status',
  [
    param('id').isNumeric().withMessage('任务ID必须是数字'),
    body('status').isString().notEmpty().withMessage('状态不能为空')
  ],
  taskController.updateTaskStatus
);

// 获取子任务
router.get(
  '/:id/subtasks',
  param('id').isNumeric().withMessage('任务ID必须是数字'),
  taskController.getSubTasks
);

export default router; 