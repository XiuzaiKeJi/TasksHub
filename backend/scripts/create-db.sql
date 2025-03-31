-- 创建开发数据库
CREATE DATABASE IF NOT EXISTS taskshub_dev;

-- 创建测试数据库
CREATE DATABASE IF NOT EXISTS taskshub_test;

-- 创建用户并授权
CREATE USER IF NOT EXISTS 'taskshub_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON taskshub_dev.* TO 'taskshub_user'@'localhost';
GRANT ALL PRIVILEGES ON taskshub_test.* TO 'taskshub_user'@'localhost';
FLUSH PRIVILEGES; 