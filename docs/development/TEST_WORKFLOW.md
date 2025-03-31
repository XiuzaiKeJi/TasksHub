# Git 工作流程测试

本文档用于测试 Git 工作流程是否正常工作。

## 测试步骤

1. 创建功能分支
   ```bash
   git checkout develop
   git checkout -b feature/PREP-003-git-workflow
   ```

2. 修改文件
   - 创建新文件
   - 提交更改

3. 推送到远程
   ```bash
   git push -u origin feature/PREP-003-git-workflow
   ```

4. 创建 Pull Request
   - 从 feature/PREP-003-git-workflow 到 develop
   - 等待代码审查
   - 合并到 develop

## 预期结果

- [x] 分支创建成功
- [x] 文件修改成功
- [x] 推送成功
- [ ] Pull Request 创建成功
- [ ] 代码审查通过
- [ ] 合并成功

## 测试说明

### 分支保护规则测试
- [ ] main 分支保护规则生效
- [ ] develop 分支保护规则生效
- [ ] 直接推送到受保护分支被阻止
- [ ] 需要 Pull Request 审查
- [ ] 需要状态检查通过

### 工作流程测试
- [ ] 功能分支创建正常
- [ ] 代码提交正常
- [ ] 远程推送正常
- [ ] Pull Request 创建正常
- [ ] 代码审查流程正常
- [ ] 合并流程正常

## 注意事项

1. 确保遵循提交信息规范
2. 确保代码符合编码规范
3. 确保所有测试通过
4. 确保文档更新完整 