# ip2region数据转换使用指南

## 什么是ip2region

ip2region是一个离线IP地址定位库，具有以下特点：

- **高性能**: 10微秒级别的查询效率
- **大容量**: 支持亿级别的IP数据段
- **标准化**: 固定的数据格式 `国家|区域|省份|城市|ISP`
- **准确性**: 数据来源于纯真和淘宝IP数据库

## 数据格式说明

### ip2region原始格式

每行数据格式：`start_ip|end_ip|国家|区域|省份|城市|ISP`

**示例**:
```
1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0
1.0.1.0|1.0.3.255|中国|0|福建省|福州市|电信
14.0.0.0|14.0.255.255|中国|华北|北京市|北京市|电信
8.8.8.8|8.8.8.8|美国|0|0|0|Google
```

**字段说明**:
- `start_ip`: 起始IP地址
- `end_ip`: 结束IP地址
- `国家`: 国家名称
- `区域`: 区域信息（如华北、华南等）
- `省份`: 省份名称
- `城市`: 城市名称
- `ISP`: 网络服务提供商

**注意**: 缺省的地域信息用 `0` 表示

### aq3stat转换后格式

转换为aq3stat系统的MySQL格式：

```sql
INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES
(16777216, 16777471, '澳大利亚', '未知ISP'),
(16777472, 16778239, '中国 福建省 福州市', '电信'),
(234881024, 234946559, '中国 华北 北京市 北京市', '电信'),
(134744072, 134744072, '美国', 'Google');
```

**转换规则**:
- IP地址转换为32位整数
- `address1`: 组合国家、区域、省份、城市信息
- `address2`: ISP信息
- 值为 `0` 的字段会被忽略或替换为默认值

## 获取ip2region数据

### 1. 从GitHub下载

```bash
# 下载最新的ip.merge.txt文件
wget https://github.com/lionsoul2014/ip2region/raw/master/data/ip.merge.txt

# 或者克隆整个项目
git clone https://github.com/lionsoul2014/ip2region.git
cd ip2region/data/
```

### 2. 数据文件说明

- `ip.merge.txt`: 原始IP数据文件，包含全球IP地址段信息
- 文件大小: 约几MB
- 数据量: 数十万条IP段记录
- 更新频率: 不定期更新

## 使用转换工具

### 1. 基本转换

```bash
# 转换ip2region数据为SQL格式
python3 ip2region_converter.py ip.merge.txt ip2region.sql

# 导入到数据库
mysql -u root -p aq3stat < ip2region.sql
```

### 2. 创建测试数据

```bash
# 创建示例文件用于测试
python3 ip2region_converter.py --create-sample sample_ip2region.txt

# 转换示例文件
python3 ip2region_converter.py sample_ip2region.txt sample.sql

# 查看转换结果
head -20 sample.sql
```

### 3. 测试转换功能

```bash
# 运行内置测试
python3 ip2region_converter.py --test
```

输出示例：
```
测试ip2region转换功能...
测试解析结果:
--------------------------------------------------------------------------------
原始: 1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0
解析: start_ip=16777216, end_ip=16777471
      address1='澳大利亚', address2='未知ISP'

原始: 1.0.1.0|1.0.3.255|中国|0|福建省|福州市|电信
解析: start_ip=16777472, end_ip=16778239
      address1='中国 福建省 福州市', address2='电信'
```

## 完整使用流程

### 步骤1: 准备环境

```bash
# 进入scripts目录
cd /home/admin/Documents/aq3stat/scripts

# 确保Python3可用
python3 --version
```

### 步骤2: 下载数据

```bash
# 下载ip2region数据文件
wget https://github.com/lionsoul2014/ip2region/raw/master/data/ip.merge.txt

# 检查文件
wc -l ip.merge.txt
head -5 ip.merge.txt
```

### 步骤3: 转换数据

```bash
# 转换为SQL格式
python3 ip2region_converter.py ip.merge.txt ip2region.sql

# 检查转换结果
head -20 ip2region.sql
tail -10 ip2region.sql
```

### 步骤4: 导入数据库

```bash
# 备份现有数据（可选）
mysqldump -u root -p aq3stat ip_data > ip_data_backup.sql

# 导入新数据
mysql -u root -p aq3stat < ip2region.sql

# 验证导入结果
mysql -u root -p aq3stat -e "SELECT COUNT(*) FROM ip_data;"
```

### 步骤5: 测试查询

```sql
-- 测试IP查询
SELECT * FROM ip_data 
WHERE INET_ATON('1.0.1.1') BETWEEN start_ip AND end_ip;

-- 查看数据分布
SELECT address2, COUNT(*) as count 
FROM ip_data 
GROUP BY address2 
ORDER BY count DESC 
LIMIT 10;
```

## 性能优化建议

### 1. 大文件处理

对于大型ip.merge.txt文件：

```bash
# 检查文件大小
ls -lh ip.merge.txt

# 如果文件很大，可以分批处理
split -l 100000 ip.merge.txt ip_part_

# 分别转换每个部分
for file in ip_part_*; do
    python3 ip2region_converter.py "$file" "${file}.sql"
done

# 合并SQL文件
cat ip_part_*.sql > combined_ip2region.sql
```

### 2. 数据库优化

```sql
-- 导入前优化
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- 禁用索引
ALTER TABLE ip_data DISABLE KEYS;

-- 导入数据
SOURCE ip2region.sql;

-- 重新启用索引
ALTER TABLE ip_data ENABLE KEYS;

-- 恢复设置
SET foreign_key_checks = 1;
SET unique_checks = 1;
SET autocommit = 1;
```

## 常见问题

### Q: 转换时出现编码错误

A: 确保文件使用UTF-8编码：
```bash
file -i ip.merge.txt
iconv -f gbk -t utf-8 ip.merge.txt > ip.merge.utf8.txt
```

### Q: 数据导入失败

A: 检查以下项目：
- 数据库连接是否正常
- 表结构是否正确
- 磁盘空间是否充足
- MySQL配置是否合适

### Q: 查询性能慢

A: 优化建议：
- 确保start_ip和end_ip字段有索引
- 使用INET_ATON()函数转换IP
- 考虑使用内存表或缓存

### Q: 数据精度问题

A: ip2region数据说明：
- 数据来源于公开的IP数据库
- 精度可能不是100%准确
- 商业应用建议购买商用数据

## 数据更新

### 定期更新流程

```bash
#!/bin/bash
# update_ip2region.sh

# 配置
BACKUP_DIR="/backup/ip_data"
LOG_FILE="/var/log/ip2region_update.log"

# 创建备份
mkdir -p $BACKUP_DIR
mysqldump -u root -p$DB_PASS aq3stat ip_data > $BACKUP_DIR/ip_data_$(date +%Y%m%d).sql

# 下载新数据
wget -O ip.merge.txt.new https://github.com/lionsoul2014/ip2region/raw/master/data/ip.merge.txt

# 检查文件是否有更新
if ! cmp -s ip.merge.txt ip.merge.txt.new; then
    echo "$(date): 发现新数据，开始更新" >> $LOG_FILE
    
    # 转换数据
    python3 ip2region_converter.py ip.merge.txt.new ip2region_new.sql
    
    # 导入数据
    mysql -u root -p$DB_PASS aq3stat < ip2region_new.sql
    
    # 更新文件
    mv ip.merge.txt.new ip.merge.txt
    rm ip2region_new.sql
    
    echo "$(date): 数据更新完成" >> $LOG_FILE
else
    echo "$(date): 数据无更新" >> $LOG_FILE
    rm ip.merge.txt.new
fi
```

### 设置定时任务

```bash
# 编辑crontab
crontab -e

# 添加定时任务（每周检查更新）
0 2 * * 0 /path/to/update_ip2region.sh
```

## 总结

ip2region转换器为aq3stat系统提供了：

1. **标准化数据**: 统一的IP地址库格式
2. **高质量数据**: 来源于知名IP数据库
3. **简单易用**: 一键转换和导入
4. **性能优化**: 支持大文件和批量处理
5. **持续更新**: 支持定期数据更新

通过使用ip2region数据，aq3stat系统可以提供更准确的访问来源地理信息统计。
