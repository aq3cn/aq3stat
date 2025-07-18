-- IP地址库数据 (ip2region格式转换)
-- 由 ip2region_converter.py 生成
-- 数据来源: ip2region项目
-- 格式: 国家|区域|省份|城市|ISP

USE aq3stat;

-- 清空现有IP数据（可选）
-- TRUNCATE TABLE ip_data;

-- 插入IP地址数据
INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES
(16777216, 16777471, '澳大利亚', '未知ISP'),
(16777472, 16778239, '中国 福建省 福州市', '电信'),
(16778240, 16779263, '澳大利亚', '未知ISP'),
(16779264, 16781311, '中国 华南 广东省 广州市', '电信'),
(16781312, 16785407, '日本', '未知ISP'),
(16785408, 16793599, '中国 福建省 福州市', '电信'),
(16793600, 16809983, '日本', '未知ISP'),
(16809984, 16842751, '泰国', '未知ISP'),
(234881024, 234946559, '中国 华北 北京市 北京市', '电信'),
(234946560, 243269631, '中国 华北 北京市 北京市', '电信'),
(243269632, 247463935, '中国 华北 北京市 北京市', '联通'),
(452984832, 454033407, '中国 华北 北京市 北京市', '联通'),
(454033408, 455081983, '中国 华北 北京市 北京市', '电信'),
(603979776, 605028351, '中国 华东 上海市 上海市', '电信'),
(605028352, 606076927, '中国 华东 上海市 上海市', '联通'),
(973078528, 977272831, '中国 华南 广东省 广州市', '电信'),
(977272832, 981467135, '中国 华南 广东省 广州市', '联通'),
(1845493760, 1849688063, '中国 华中 湖北省 武汉市', '电信'),
(1849688064, 1853882367, '中国 华中 湖北省 武汉市', '联通'),
(134744072, 134744072, '美国', 'Google'),
(1920103026, 1920103026, '中国 江苏省 南京市', '114DNS');

-- 数据导入完成
-- 总共导入 21 条IP记录
-- 处理错误 0 条记录
