import dotenv from 'dotenv';
import path from 'path';

// 根据环境加载不同的环境变量文件
const environment = process.env.NODE_ENV || 'development';
const envFile = environment === 'production' 
  ? '.env.production' 
  : environment === 'test' 
    ? '.env.test' 
    : '.env';

// 加载环境变量
dotenv.config({ path: path.resolve(process.cwd(), envFile) });

// 必要的环境变量列表
const requiredEnvVars = [
  'DATABASE_URL',
  'JWT_SECRET'
];

// 验证环境变量
const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);
if (missingEnvVars.length > 0) {
  throw new Error(`缺少必要的环境变量: ${missingEnvVars.join(', ')}`);
}

// 导出环境变量配置
export default {
  // 服务器配置
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: environment,
  
  // 数据库配置
  databaseUrl: process.env.DATABASE_URL as string,
  
  // JWT配置
  jwtSecret: process.env.JWT_SECRET as string,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '24h',
  
  // 日志配置
  logLevel: process.env.LOG_LEVEL || 'info',
  
  // 跨域配置
  corsOrigin: process.env.CORS_ORIGIN || '*'
}; 