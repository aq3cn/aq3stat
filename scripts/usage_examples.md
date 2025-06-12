# IP地址库转换工具使用示例

## 快速开始

### 1. 使用示例数据测试

我们提供了一个示例CSV文件，您可以直接使用它来测试转换工具：

```bash
# 进入scripts目录
cd /home/admin/Documents/aq3stat/scripts

# 转换示例数据
python3 simple_ip_converter.py sample_ip_data.csv sample_ip_data.sql range

# 查看生成的SQL文件
head -20 sample_ip_data.sql
```

### 2. 导入到数据库

```bash
# 方法1: 使用mysql命令行
mysql -u root -p aq3stat < sample_ip_data.sql

# 方法2: 在MySQL客户端中执行
mysql -u root -p
USE aq3stat;
SOURCE /home/admin/Documents/aq3stat/scripts/sample_ip_data.sql;
```

### 3. 验证导入结果

```sql
-- 检查记录总数
SELECT COUNT(*) FROM ip_data;

-- 查看前10条记录
SELECT * FROM ip_data LIMIT 10;

-- 测试IP查询功能
SELECT * FROM ip_data 
WHERE 16777216 BETWEEN start_ip AND end_ip;  -- 查询1.0.0.0对应的记录
```

## 实际数据源使用示例

### 1. 纯真IP库 (QQWry.dat)

```bash
# 下载纯真IP库
wget http://www.cz88.net/fox/ip.rar
unrar x ip.rar

# 转换数据（需要安装mysql-connector-python）
pip3 install mysql-connector-python
python3 ip_converter.py --type qqwry --file QQWry.dat --password your_password --clear
```

### 2. GeoIP2数据库

```bash
# 下载GeoLite2数据库
wget https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=YOUR_LICENSE_KEY&suffix=zip

# 解压文件
unzip GeoLite2-Country-CSV_*.zip

# 转换IPv4数据
python3 simple_ip_converter.py GeoLite2-Country-Blocks-IPv4.csv geoip2.sql network

# 导入数据库
mysql -u root -p aq3stat < geoip2.sql
```

### 3. IP2Location数据库

```bash
# 下载IP2Location Lite数据库
wget https://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.CSV.ZIP

# 解压文件
unzip IP2LOCATION-LITE-DB1.CSV.ZIP

# 转换数据
python3 simple_ip_converter.py IP2LOCATION-LITE-DB1.CSV ip2location.sql range

# 导入数据库
mysql -u root -p aq3stat < ip2location.sql
```

## 自定义数据格式示例

### 1. 创建自定义CSV文件

```csv
start_ip,end_ip,address1,address2
192.168.1.1,192.168.1.255,内网地址,局域网
10.0.0.1,10.255.255.255,内网地址,局域网
172.16.0.1,172.31.255.255,内网地址,局域网
8.8.8.8,8.8.8.8,美国,Google DNS
114.114.114.114,114.114.114.114,中国,114DNS
```

### 2. 网络格式CSV文件

```csv
network,country,region,isp
192.168.0.0/16,内网,局域网,私有网络
10.0.0.0/8,内网,局域网,私有网络
172.16.0.0/12,内网,局域网,私有网络
8.8.8.0/24,美国,加利福尼亚,Google
114.114.114.0/24,中国,江苏,114DNS
```

## 性能优化建议

### 1. 大数据量导入优化

```sql
-- 导入前优化设置
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- 禁用索引
ALTER TABLE ip_data DISABLE KEYS;

-- 导入数据
SOURCE your_ip_data.sql;

-- 重新启用索引
ALTER TABLE ip_data ENABLE KEYS;

-- 恢复设置
SET foreign_key_checks = 1;
SET unique_checks = 1;
SET autocommit = 1;
```

### 2. 分批处理大文件

```bash
# 将大CSV文件分割成小文件
split -l 10000 large_ip_data.csv ip_part_

# 分别转换每个部分
for file in ip_part_*; do
    python3 simple_ip_converter.py "$file" "${file}.sql" range
done

# 合并SQL文件
cat ip_part_*.sql > combined_ip_data.sql
```

## 数据验证和测试

### 1. 运行转换测试

```bash
# 验证转换工具的正确性
python3 test_ip_conversion.py
```

### 2. 数据库查询测试

```sql
-- 创建IP查询函数
DELIMITER //
CREATE FUNCTION ip_to_location(ip_address VARCHAR(15))
RETURNS VARCHAR(500)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(500);
    DECLARE ip_int BIGINT;
    
    -- 将IP地址转换为整数
    SET ip_int = INET_ATON(ip_address);
    
    -- 查询IP对应的地址信息
    SELECT CONCAT(address1, ' - ', address2) INTO result
    FROM ip_data 
    WHERE ip_int BETWEEN start_ip AND end_ip 
    LIMIT 1;
    
    RETURN IFNULL(result, '未知地址');
END //
DELIMITER ;

-- 测试查询函数
SELECT ip_to_location('1.0.0.1') as location;
SELECT ip_to_location('114.114.114.114') as location;
SELECT ip_to_location('8.8.8.8') as location;
```

### 3. 性能测试

```sql
-- 创建测试表
CREATE TABLE ip_test_queries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    test_ip VARCHAR(15),
    query_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入测试IP
INSERT INTO ip_test_queries (test_ip) VALUES 
('1.0.0.1'), ('114.114.114.114'), ('8.8.8.8'), 
('192.168.1.1'), ('10.0.0.1'), ('172.16.0.1');

-- 性能测试查询
SELECT 
    t.test_ip,
    i.address1,
    i.address2
FROM ip_test_queries t
LEFT JOIN ip_data i ON INET_ATON(t.test_ip) BETWEEN i.start_ip AND i.end_ip;
```

## 常见问题解决

### 1. 编码问题

```bash
# 检查文件编码
file -i your_data.csv

# 转换编码
iconv -f gbk -t utf-8 input.csv > output.csv
```

### 2. 权限问题

```bash
# 给脚本执行权限
chmod +x *.py

# 检查MySQL权限
mysql -u root -p -e "SHOW GRANTS;"
```

### 3. 内存不足

```bash
# 监控内存使用
free -h

# 增加交换空间
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## 自动化脚本示例

创建一个自动化更新IP数据库的脚本：

```bash
#!/bin/bash
# auto_update_ip.sh

# 配置
DB_USER="root"
DB_PASS="your_password"
DB_NAME="aq3stat"
BACKUP_DIR="/backup/ip_data"
LOG_FILE="/var/log/ip_update.log"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 记录开始时间
echo "$(date): 开始更新IP数据库" >> $LOG_FILE

# 备份现有数据
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME ip_data > $BACKUP_DIR/ip_data_$(date +%Y%m%d).sql

# 下载新数据（示例：使用wget下载）
# wget -O new_ip_data.csv "http://your-ip-data-source.com/data.csv"

# 转换数据
python3 simple_ip_converter.py new_ip_data.csv new_ip_data.sql range

# 导入新数据
mysql -u $DB_USER -p$DB_PASS $DB_NAME < new_ip_data.sql

# 记录完成时间
echo "$(date): IP数据库更新完成" >> $LOG_FILE

# 清理临时文件
rm -f new_ip_data.csv new_ip_data.sql
```

使用crontab定期执行：

```bash
# 编辑crontab
crontab -e

# 添加定时任务（每周日凌晨2点执行）
0 2 * * 0 /path/to/auto_update_ip.sh
```
