# IP地址库数据转换指南

本指南介绍如何将不同来源的IP地址库数据转换为aq3stat系统的MySQL格式。

## 数据库表结构

aq3stat系统使用以下表结构存储IP地址信息：

```sql
CREATE TABLE `ip_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_ip` bigint(20) unsigned NOT NULL COMMENT '起始IP',
  `end_ip` bigint(20) unsigned NOT NULL COMMENT '结束IP',
  `address1` varchar(255) DEFAULT NULL COMMENT '地址信息1（省市）',
  `address2` varchar(255) DEFAULT NULL COMMENT '地址信息2（ISP）',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_start_ip` (`start_ip`),
  KEY `idx_end_ip` (`end_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 支持的数据源

### 1. 纯真IP库 (QQWry.dat)

**下载地址**: http://www.cz88.net/

**特点**:
- 中文IP地址库，主要覆盖中国大陆地区
- 二进制格式，需要专门的解析工具
- 更新频率较高，数据相对准确

**使用方法**:
```bash
python3 ip_converter.py --type qqwry --file QQWry.dat --password your_password --clear
```

### 2. GeoIP2 (MaxMind)

**下载地址**: https://dev.maxmind.com/geoip/geoip2/geolite2/

**特点**:
- 全球IP地址库，覆盖范围广
- 提供免费的GeoLite2版本
- CSV格式，易于处理
- 包含经纬度信息

**CSV格式示例**:
```csv
network,geoname_id,registered_country_geoname_id,represented_country_geoname_id,is_anonymous_proxy,is_satellite_provider
1.0.0.0/24,2077456,2077456,,0,0
1.0.1.0/24,1814991,1814991,,0,0
```

**使用方法**:
```bash
# 使用完整转换器
python3 ip_converter.py --type csv --file GeoLite2-Country-Blocks-IPv4.csv --format geoip2 --password your_password --clear

# 使用简化转换器
python3 simple_ip_converter.py GeoLite2-Country-Blocks-IPv4.csv geoip2.sql network
```

### 3. IP2Location

**下载地址**: https://lite.ip2location.com/

**特点**:
- 提供免费的Lite版本
- CSV格式，包含详细的地理信息
- 支持IPv4和IPv6

**CSV格式示例**:
```csv
"1.0.0.0","1.0.0.255","AU","Australia","Queensland","Brisbane","-27.46794","153.02809","4000","+10:00"
"1.0.1.0","1.0.3.255","CN","China","Fujian","Fuzhou","26.06139","119.30611","350000","+08:00"
```

**使用方法**:
```bash
# 使用完整转换器
python3 ip_converter.py --type csv --file IP2LOCATION-LITE-DB1.CSV --format ip2location --password your_password --clear

# 使用简化转换器
python3 simple_ip_converter.py IP2LOCATION-LITE-DB1.CSV ip2location.sql range
```

### 4. ip2region

**下载地址**: https://github.com/lionsoul2014/ip2region

**特点**:
- 离线IP地址定位库，查询速度极快
- 数据格式标准化，包含详细的地理信息
- 支持亿级别的IP数据段
- 数据来源于纯真和淘宝IP数据库

**数据格式示例**:
```
# 格式: start_ip|end_ip|国家|区域|省份|城市|ISP
1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0
1.0.1.0|1.0.3.255|中国|0|福建省|福州市|电信
14.0.0.0|14.0.255.255|中国|华北|北京市|北京市|电信
```

**使用方法**:
```bash
# 下载ip2region数据文件
wget https://github.com/lionsoul2014/ip2region/raw/master/data/ip.merge.txt

# 转换数据
python3 ip2region_converter.py ip.merge.txt ip2region.sql

# 导入数据库
mysql -u root -p aq3stat < ip2region.sql
```

### 5. 自定义CSV格式

如果您有自己的IP地址数据，可以按照以下格式准备CSV文件：

**范围格式**:
```csv
start_ip,end_ip,address1,address2
192.168.1.1,192.168.1.255,北京市,联通
10.0.0.1,10.0.0.255,上海市,电信
```

**网络格式**:
```csv
network,country,region,isp
192.168.1.0/24,中国,北京市,联通
10.0.0.0/24,中国,上海市,电信
```

## 转换工具使用说明

### 1. 完整转换器 (ip_converter.py)

功能强大的转换工具，支持直接写入数据库。

**安装依赖**:
```bash
pip3 install mysql-connector-python
```

**使用方法**:
```bash
python3 ip_converter.py [选项]

选项:
  --type {csv,qqwry}     数据源类型
  --file FILE            数据文件路径
  --format {geoip2,ip2location,custom}  CSV格式类型
  --host HOST            数据库主机 (默认: localhost)
  --port PORT            数据库端口 (默认: 3306)
  --user USER            数据库用户名 (默认: root)
  --password PASSWORD    数据库密码 (必需)
  --database DATABASE    数据库名 (默认: aq3stat)
  --clear                清空现有IP数据
```

**示例**:
```bash
# 转换GeoIP2数据
python3 ip_converter.py --type csv --file GeoLite2.csv --format geoip2 --password mypassword --clear

# 转换自定义CSV数据
python3 ip_converter.py --type csv --file my_ip_data.csv --format custom --password mypassword

# 转换纯真IP库
python3 ip_converter.py --type qqwry --file QQWry.dat --password mypassword --clear
```

### 2. 简化转换器 (simple_ip_converter.py)

轻量级转换工具，生成SQL文件，无需数据库连接。

### 3. ip2region转换器 (ip2region_converter.py)

专门用于转换ip2region格式数据的工具。

**使用方法**:
```bash
python3 ip2region_converter.py input.txt output.sql

参数:
  input.txt   - 输入的ip.merge.txt文件
  output.sql  - 输出的SQL文件

选项:
  --create-sample filename - 创建示例文件
  --test                   - 测试转换功能
```

**示例**:
```bash
# 转换ip2region数据
python3 ip2region_converter.py ip.merge.txt ip2region.sql

# 创建示例文件
python3 ip2region_converter.py --create-sample sample.txt

# 测试转换功能
python3 ip2region_converter.py --test
```

**导入生成的SQL文件**:
```bash
mysql -u root -p aq3stat < ip2region.sql
```

### 4. 简化转换器使用方法
```bash
python3 simple_ip_converter.py input.csv output.sql [format]

参数:
  input.csv   - 输入的CSV文件
  output.sql  - 输出的SQL文件
  format      - 格式类型 (range 或 network，默认为 range)
```

**示例**:
```bash
# 转换范围格式的CSV
python3 simple_ip_converter.py ip_ranges.csv ip_data.sql range

# 转换网络格式的CSV
python3 simple_ip_converter.py networks.csv ip_data.sql network
```

**导入生成的SQL文件**:
```bash
mysql -u root -p aq3stat < ip_data.sql
```

## 数据处理建议

### 1. 数据清理

在导入数据前，建议进行以下清理：

- 去除重复的IP段
- 验证IP地址格式
- 统一地址信息格式
- 处理特殊字符

### 2. 性能优化

- 使用批量插入提高导入速度
- 在导入前禁用索引，导入后重建
- 使用事务确保数据一致性

```sql
-- 禁用索引
ALTER TABLE ip_data DISABLE KEYS;

-- 导入数据
SOURCE ip_data.sql;

-- 重建索引
ALTER TABLE ip_data ENABLE KEYS;
```

### 3. 数据验证

导入完成后，验证数据：

```sql
-- 检查记录总数
SELECT COUNT(*) FROM ip_data;

-- 检查IP范围是否合理
SELECT * FROM ip_data WHERE start_ip > end_ip;

-- 检查地址信息
SELECT DISTINCT address1 FROM ip_data LIMIT 10;
SELECT DISTINCT address2 FROM ip_data LIMIT 10;
```

## 常见问题

### Q: 转换过程中出现编码错误怎么办？

A: 确保CSV文件使用UTF-8编码，可以使用以下命令转换：
```bash
iconv -f gbk -t utf-8 input.csv > output.csv
```

### Q: 数据库连接失败怎么办？

A: 检查以下项目：
- 数据库服务是否运行
- 用户名和密码是否正确
- 网络连接是否正常
- 防火墙设置

### Q: 导入的数据量很大，如何提高性能？

A: 可以采用以下方法：
- 增加MySQL的`innodb_buffer_pool_size`
- 使用`LOAD DATA INFILE`命令
- 分批导入数据
- 临时禁用外键检查

### Q: 如何更新IP地址库？

A: 建议的更新流程：
1. 备份现有数据
2. 清空ip_data表
3. 导入新数据
4. 验证数据完整性

## 许可证和使用条款

使用第三方IP地址库时，请注意：

- **纯真IP库**: 免费使用，但有使用条款限制
- **GeoIP2**: 免费版本有使用限制，商业使用需要付费
- **IP2Location**: 免费版本精度有限，完整版本需要付费

请在使用前仔细阅读相关的许可证条款。
