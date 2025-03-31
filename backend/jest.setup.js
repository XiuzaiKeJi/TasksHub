// 设置测试环境变量
process.env.NODE_ENV = 'test';

// 设置测试超时时间
jest.setTimeout(10000);

// 全局测试设置
beforeAll(() => {
  // 在所有测试开始前执行
  console.log('开始运行测试...');
});

afterAll(() => {
  // 在所有测试结束后执行
  console.log('测试运行完成');
});

// 模拟全局对象
global.console = {
  ...console,
  // 保持测试输出简洁
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  info: jest.fn(),
  debug: jest.fn(),
}; 