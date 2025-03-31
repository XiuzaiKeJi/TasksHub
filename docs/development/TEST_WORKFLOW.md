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

- [ ] 分支创建成功
- [ ] 文件修改成功
- [ ] 推送成功
- [ ] Pull Request 创建成功
- [ ] 代码审查通过
- [ ] 合并成功 