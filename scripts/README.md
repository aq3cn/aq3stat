# aq3stat IP地址库转换工具集

本目录包含了将各种格式的IP地址库转换为aq3stat系统MySQL格式的完整工具集。

## 🛠️ 工具列表

### 1. 完整转换器 (ip_converter.py)
- **功能**: 功能最全面的转换工具
- **特点**: 直接写入数据库，支持多种格式
- **依赖**: mysql-connector-python
- **支持格式**: 纯真IP库、GeoIP2、IP2Location、自定义CSV

### 2. 简化转换器 (simple_ip_converter.py)
- **功能**: 轻量级转换工具
- **特点**: 生成SQL文件，无需数据库连接
- **依赖**: 无
- **支持格式**: CSV格式（范围和网络两种）

### 3. ip2region转换器 (ip2region_converter.py) ⭐
- **功能**: 专门转换ip2region格式
- **特点**: 支持标准化的ip2region数据格式
- **依赖**: 无
- **支持格式**: ip2region的ip.merge.txt格式

### 4. 转换测试工具 (test_ip_conversion.py)
- **功能**: 验证IP地址转换的正确性
- **特点**: 测试各种IP转换算法
- **依赖**: 无

## 📊 支持的数据源

| 数据源 | 格式 | 推荐工具 | 特点 |
|--------|------|----------|------|
| **ip2region** | `ip\|ip\|国家\|区域\|省份\|城市\|ISP` | ip2region_converter.py | ⭐ 推荐，数据质量高 |
| **纯真IP库** | QQWry.dat (二进制) | ip_converter.py | 中文数据，覆盖中国 |
| **GeoIP2** | CSV网络格式 | simple_ip_converter.py | 全球数据，免费版可用 |
| **IP2Location** | CSV范围格式 | simple_ip_converter.py | 详细地理信息 |
| **自定义CSV** | 自定义格式 | simple_ip_converter.py | 灵活自定义 |

## 🚀 快速开始

### 推荐方案：使用ip2region数据

```bash
# 1. 下载ip2region数据
wget https://github.com/lionsoul2014/ip2region/raw/master/data/ip.merge.txt

# 2. 转换为SQL格式
python3 ip2region_converter.py ip.merge.txt ip2region.sql

# 3. 导入数据库
mysql -u root -p aq3stat < ip2region.sql

# 4. 验证导入
mysql -u root -p aq3stat -e "SELECT COUNT(*) FROM ip_data;"
```

### 测试方案：使用示例数据

```bash
# 1. 创建示例数据
python3 ip2region_converter.py --create-sample sample.txt

# 2. 转换示例数据
python3 ip2region_converter.py sample.txt sample.sql

# 3. 导入测试数据
mysql -u root -p aq3stat < sample.sql
```

## 📁 文件说明

### 转换工具
- `ip_converter.py` - 完整转换器（需要数据库连接）
- `simple_ip_converter.py` - 简化转换器（生成SQL文件）
- `ip2region_converter.py` - ip2region专用转换器
- `test_ip_conversion.py` - 转换测试工具

### 示例数据
- `sample_ip_data.csv` - CSV格式示例数据
- `sample_ip2region.txt` - ip2region格式示例数据
- `sample_ip_data.sql` - 转换后的SQL示例
- `sample_ip2region.sql` - ip2region转换后的SQL示例

### 文档
- `IP_DATABASE_GUIDE.md` - 完整使用指南
- `ip2region_usage.md` - ip2region专用指南
- `usage_examples.md` - 使用示例集合
- `README.md` - 本文件

## 🔧 使用方法

### ip2region转换器（推荐）

```bash
# 基本用法
python3 ip2region_converter.py input.txt output.sql

# 创建示例文件
python3 ip2region_converter.py --create-sample sample.txt

# 测试功能
python3 ip2region_converter.py --test

# 查看帮助
python3 ip2region_converter.py
```

### 简化转换器

```bash
# 转换范围格式CSV
python3 simple_ip_converter.py input.csv output.sql range

# 转换网络格式CSV
python3 simple_ip_converter.py input.csv output.sql network

# 查看帮助
python3 simple_ip_converter.py
```

### 完整转换器

```bash
# 转换CSV数据
python3 ip_converter.py --type csv --file data.csv --format custom --password yourpass

# 转换纯真IP库
python3 ip_converter.py --type qqwry --file QQWry.dat --password yourpass

# 查看帮助
python3 ip_converter.py --help
```

## 📈 性能对比

| 工具 | 处理速度 | 内存占用 | 依赖 | 适用场景 |
|------|----------|----------|------|----------|
| ip2region_converter.py | ⭐⭐⭐⭐⭐ | 低 | 无 | 推荐，日常使用 |
| simple_ip_converter.py | ⭐⭐⭐⭐ | 低 | 无 | CSV数据转换 |
| ip_converter.py | ⭐⭐⭐ | 中 | 有 | 复杂格式，直接入库 |

## 🎯 最佳实践

### 1. 数据源选择
- **首选**: ip2region - 数据质量高，格式标准
- **备选**: GeoIP2 - 全球覆盖，免费版可用
- **特殊**: 纯真IP库 - 中国地区数据详细

### 2. 转换流程
1. **测试**: 先用示例数据测试转换
2. **备份**: 转换前备份现有数据
3. **验证**: 转换后验证数据完整性
4. **优化**: 根据数据量调整数据库参数

### 3. 性能优化
```sql
-- 导入前优化
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;
ALTER TABLE ip_data DISABLE KEYS;

-- 导入数据
SOURCE your_data.sql;

-- 导入后恢复
ALTER TABLE ip_data ENABLE KEYS;
SET foreign_key_checks = 1;
SET unique_checks = 1;
SET autocommit = 1;
```

## 🔍 数据验证

### 验证转换结果
```bash
# 运行转换测试
python3 test_ip_conversion.py

# 检查SQL文件
head -20 output.sql
tail -10 output.sql
wc -l output.sql
```

### 验证数据库导入
```sql
-- 检查记录数
SELECT COUNT(*) FROM ip_data;

-- 检查数据范围
SELECT MIN(start_ip), MAX(end_ip) FROM ip_data;

-- 检查地址信息
SELECT DISTINCT address2 FROM ip_data LIMIT 10;

-- 测试查询
SELECT * FROM ip_data 
WHERE INET_ATON('8.8.8.8') BETWEEN start_ip AND end_ip;
```

## 🆘 故障排除

### 常见问题

1. **编码错误**
   ```bash
   iconv -f gbk -t utf-8 input.txt > output.txt
   ```

2. **权限问题**
   ```bash
   chmod +x *.py
   ```

3. **内存不足**
   ```bash
   # 分批处理大文件
   split -l 10000 large_file.txt part_
   ```

4. **数据库连接失败**
   - 检查用户名密码
   - 确认数据库服务运行
   - 验证网络连接

### 获取帮助

- 查看详细文档: `IP_DATABASE_GUIDE.md`
- ip2region专用指南: `ip2region_usage.md`
- 使用示例: `usage_examples.md`
- 运行测试: `python3 test_ip_conversion.py`

## 📝 更新日志

- **v1.3** - 添加ip2region转换器支持
- **v1.2** - 添加简化转换器
- **v1.1** - 添加完整转换器
- **v1.0** - 初始版本

## 📄 许可证

本工具集遵循MIT许可证。使用第三方IP数据库时请遵守相应的许可证条款。

---

**推荐使用ip2region转换器获得最佳的数据质量和转换体验！** ⭐
