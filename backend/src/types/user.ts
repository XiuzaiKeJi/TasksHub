/**
 * 用户角色枚举
 */
export enum UserRole {
  ADMIN = 'ADMIN',
  MANAGER = 'MANAGER',
  USER = 'USER'
}

/**
 * 用户信息接口
 */
export interface User {
  id: number;
  username: string;
  password: string;
  email: string;
  name: string;
  role: UserRole;
  departmentId?: number;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * 创建用户请求接口
 */
export interface CreateUserRequest {
  username: string;
  password: string;
  email: string;
  name: string;
  role?: UserRole;
  departmentId?: number;
}

/**
 * 更新用户请求接口
 */
export interface UpdateUserRequest {
  username?: string;
  email?: string;
  name?: string;
  role?: UserRole;
  departmentId?: number;
}

/**
 * 登录请求接口
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 登录响应接口
 */
export interface LoginResponse {
  message: string;
  token: string;
  user: Omit<User, 'password'>;
}

/**
 * 修改密码请求接口
 */
export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
} 