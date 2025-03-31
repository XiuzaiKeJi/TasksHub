import { lazy } from 'react';
import { RouteObject } from 'react-router-dom';
import MainLayout from '@/layouts/MainLayout';

const Login = lazy(() => import('@/pages/Login'));
const Dashboard = lazy(() => import('@/pages/Dashboard'));
const NotFound = lazy(() => import('@/pages/NotFound'));

export const routes: RouteObject[] = [
  {
    path: '/login',
    element: <Login />,
  },
  {
    path: '/',
    element: <MainLayout />,
    children: [
      {
        index: true,
        element: <Dashboard />,
      },
      {
        path: 'users',
        element: <div>用户管理</div>,
      },
      {
        path: 'departments',
        element: <div>部门管理</div>,
      },
      {
        path: 'tasks',
        element: <div>任务管理</div>,
      },
      {
        path: '*',
        element: <NotFound />,
      },
    ],
  },
]; 