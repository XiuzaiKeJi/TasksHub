# 数据库优化指南

本文档提供了在资源受限环境中优化MySQL数据库配置的指南，以减少内存占用并提高性能。

## MySQL 内存优化配置

以下是针对低内存服务器（1-2GB）的MySQL优化配置。将这些设置添加到 `/etc/mysql/my.cnf` 或 `/etc/mysql/mysql.conf.d/mysqld.cnf` 文件中：

```ini
[mysqld]
# 减少全局缓冲区大小
innodb_buffer_pool_size = 128M  # 默认通常是128M-1G
innodb_log_buffer_size = 4M     # 默认是16M
key_buffer_size = 16M           # 默认是128M

# 减少每个连接的内存使用
sort_buffer_size = 2M           # 默认是2-8M
read_buffer_size = 256K         # 默认是128K-2M
read_rnd_buffer_size = 512K     # 默认是256K-4M
join_buffer_size = 256K         # 默认是256K-4M
tmp_table_size = 16M            # 默认是16-64M
max_heap_table_size = 16M       # 默认是16-64M

# 减少并发连接数
max_connections = 30            # 默认通常是151或更高

# 禁用性能开销大的功能
performance_schema = OFF        # 在低内存系统上禁用性能模式
skip-host-cache                 # 禁用主机缓存表
skip-name-resolve               # 禁用DNS解析

# 查询缓存（仅适用于MySQL 5.7及更早版本，MySQL 8已移除此功能）
# query_cache_size = 8M         # MySQL 5.7中可设置为较小值
# query_cache_type = 1

# 表缓存设置
table_open_cache = 256          # 默认是2000左右
table_definition_cache = 256    # 默认是1400左右

# InnoDB设置
innodb_flush_log_at_trx_commit = 0  # 提高性能但降低ACID合规性
innodb_flush_method = O_DIRECT      # 避免双重缓冲
innodb_file_per_table = 1           # 每个表使用单独的文件
```

> **警告**：某些设置（如 `innodb_flush_log_at_trx_commit = 0`）会降低数据安全性以换取性能。仅在开发环境中使用，生产环境中请谨慎考虑。

## 按需启动数据库

对于开发环境，建议仅在需要时启动MySQL服务，以节省系统资源：

```bash
# 启动数据库
sudo systemctl start mysql

# 停止数据库
sudo systemctl stop mysql

# 查看状态
sudo systemctl status mysql
```

也可以使用我们的服务管理脚本：

```bash
/home/TasksHub/scripts/manage-services.sh start-db
```

## 使用连接池

在后端应用中，使用连接池可以减少数据库连接开销并提高性能。在我们的Prisma配置中，已设置了连接池：

```typescript
// prisma/prisma.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // 连接池配置
  log: ['query', 'info', 'warn', 'error'],
  // 最小连接数
  connection: {
    min: 1,
    max: 5  // 在低内存系统上保持较低的最大连接数
  }
});

export default prisma;
```

## 查询优化

1. **合理使用索引**：确保常用的查询字段有适当的索引
2. **限制查询结果**：始终使用LIMIT限制结果集大小
3. **避免SELECT ***：只查询需要的字段
4. **分页处理大结果集**：使用分页API而不是一次返回大量数据

## 监控数据库性能

使用以下命令监控MySQL内存使用情况：

```bash
# 查看MySQL进程内存使用
ps aux | grep mysql

# 查看MySQL状态
mysqladmin -u root -p status

# 查看MySQL变量
mysql -u root -p -e "SHOW VARIABLES LIKE '%buffer%';"
```

## 定期维护

定期进行以下维护操作可以保持数据库性能：

1. **表分析**：`ANALYZE TABLE table_name;`
2. **表优化**：`OPTIMIZE TABLE table_name;`
3. **表碎片整理**：对于InnoDB表，可以使用ALTER TABLE命令
4. **定期备份**：使用我们的备份脚本 `/home/TasksHub/backend/scripts/backup-db.sh`

通过以上优化措施，MySQL可以在低内存环境中稳定运行，同时保持合理的性能水平。 