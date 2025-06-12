#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ip2region数据转换脚本
将ip2region的ip.merge.txt格式转换为aq3stat系统的MySQL格式

ip2region格式说明:
每行格式: start_ip|end_ip|国家|区域|省份|城市|ISP
示例: 1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0

aq3stat格式:
start_ip (bigint): 起始IP整数
end_ip (bigint): 结束IP整数  
address1 (varchar): 地址信息1（省市）
address2 (varchar): 地址信息2（ISP）

使用方法:
python3 ip2region_converter.py ip.merge.txt output.sql
"""

import sys
import os
import struct
import socket


def ip_to_int(ip_str):
    """将IP地址字符串转换为整数"""
    try:
        return struct.unpack("!I", socket.inet_aton(ip_str))[0]
    except socket.error:
        print(f"无效的IP地址: {ip_str}")
        return 0


def escape_sql_string(s):
    """转义SQL字符串"""
    if s is None or s == '0':
        return 'NULL'
    return "'" + str(s).replace("'", "''").replace("\\", "\\\\") + "'"


def parse_ip2region_line(line):
    """
    解析ip2region格式的一行数据
    
    格式: start_ip|end_ip|国家|区域|省份|城市|ISP
    示例: 1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0
    
    返回: (start_ip_int, end_ip_int, address1, address2)
    """
    line = line.strip()
    if not line or line.startswith('#'):
        return None
    
    try:
        parts = line.split('|')
        if len(parts) < 7:
            print(f"格式错误，字段数不足: {line}")
            return None
        
        start_ip_str = parts[0].strip()
        end_ip_str = parts[1].strip()
        country = parts[2].strip()
        region = parts[3].strip()
        province = parts[4].strip()
        city = parts[5].strip()
        isp = parts[6].strip()
        
        # 转换IP地址为整数
        start_ip = ip_to_int(start_ip_str)
        end_ip = ip_to_int(end_ip_str)
        
        if start_ip == 0 or end_ip == 0:
            print(f"IP地址转换失败: {line}")
            return None
        
        if start_ip > end_ip:
            print(f"起始IP大于结束IP: {line}")
            return None
        
        # 构建地址信息
        # address1: 国家 区域 省份 城市
        address_parts = []
        for part in [country, region, province, city]:
            if part and part != '0':
                address_parts.append(part)
        
        address1 = ' '.join(address_parts) if address_parts else '未知地区'
        
        # address2: ISP
        address2 = isp if isp and isp != '0' else '未知ISP'
        
        return (start_ip, end_ip, address1, address2)
    
    except Exception as e:
        print(f"解析行数据时出错: {line}, 错误: {e}")
        return None


def convert_ip2region_to_sql(input_file, output_file):
    """
    转换ip2region格式文件为SQL插入语句
    
    Args:
        input_file: 输入的ip.merge.txt文件路径
        output_file: 输出的SQL文件路径
    """
    
    print(f"开始转换ip2region文件: {input_file} -> {output_file}")
    
    if not os.path.exists(input_file):
        print(f"输入文件不存在: {input_file}")
        return False
    
    try:
        with open(input_file, 'r', encoding='utf-8') as infile, \
             open(output_file, 'w', encoding='utf-8') as outfile:
            
            # 写入SQL文件头
            outfile.write("-- IP地址库数据 (ip2region格式转换)\n")
            outfile.write("-- 由 ip2region_converter.py 生成\n")
            outfile.write("-- 数据来源: ip2region项目\n")
            outfile.write("-- 格式: 国家|区域|省份|城市|ISP\n\n")
            outfile.write("USE aq3stat;\n\n")
            outfile.write("-- 清空现有IP数据（可选）\n")
            outfile.write("-- TRUNCATE TABLE ip_data;\n\n")
            outfile.write("-- 插入IP地址数据\n")
            
            batch_count = 0
            total_count = 0
            error_count = 0
            batch_size = 1000
            
            outfile.write("INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES\n")
            
            for line_num, line in enumerate(infile, 1):
                try:
                    result = parse_ip2region_line(line)
                    if result is None:
                        continue
                    
                    start_ip, end_ip, address1, address2 = result
                    
                    # 写入SQL语句
                    if batch_count > 0:
                        outfile.write(",\n")
                    
                    outfile.write(f"({start_ip}, {end_ip}, {escape_sql_string(address1)}, {escape_sql_string(address2)})")
                    
                    batch_count += 1
                    total_count += 1
                    
                    # 每1000条记录分批
                    if batch_count >= batch_size:
                        outfile.write(";\n\n")
                        outfile.write("INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES\n")
                        batch_count = 0
                    
                    if line_num % 10000 == 0:
                        print(f"已处理 {line_num} 行，有效记录 {total_count} 条，错误 {error_count} 条")
                
                except Exception as e:
                    error_count += 1
                    print(f"处理第 {line_num} 行时出错: {e}")
                    continue
            
            # 结束最后一批
            if batch_count > 0:
                outfile.write(";\n")
            else:
                # 如果没有数据，删除最后的INSERT语句
                outfile.seek(outfile.tell() - len("INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES\n"))
                outfile.truncate()
            
            outfile.write("\n-- 数据导入完成\n")
            outfile.write(f"-- 总共导入 {total_count} 条IP记录\n")
            outfile.write(f"-- 处理错误 {error_count} 条记录\n")
            
            print(f"转换完成！")
            print(f"有效记录: {total_count} 条")
            print(f"错误记录: {error_count} 条")
            print(f"SQL文件已保存到: {output_file}")
            
            return True
    
    except Exception as e:
        print(f"转换失败: {e}")
        return False


def create_sample_ip2region_file(filename):
    """创建示例ip2region格式文件"""
    sample_data = [
        "# ip2region 示例数据文件",
        "# 格式: start_ip|end_ip|国家|区域|省份|城市|ISP",
        "1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0",
        "1.0.1.0|1.0.3.255|中国|0|福建省|福州市|电信",
        "1.0.4.0|1.0.7.255|澳大利亚|0|0|0|0",
        "1.0.8.0|1.0.15.255|中国|华南|广东省|广州市|电信",
        "1.0.16.0|1.0.31.255|日本|0|0|0|0",
        "1.0.32.0|1.0.63.255|中国|0|福建省|福州市|电信",
        "1.0.64.0|1.0.127.255|日本|0|0|0|0",
        "1.0.128.0|1.0.255.255|泰国|0|0|0|0",
        "14.0.0.0|14.0.255.255|中国|华北|北京市|北京市|电信",
        "14.1.0.0|14.127.255.255|中国|华北|北京市|北京市|电信",
        "14.128.0.0|14.191.255.255|中国|华北|北京市|北京市|联通",
        "27.0.0.0|27.15.255.255|中国|华北|北京市|北京市|联通",
        "27.16.0.0|27.31.255.255|中国|华北|北京市|北京市|电信",
        "36.0.0.0|36.15.255.255|中国|华东|上海市|上海市|电信",
        "36.16.0.0|36.31.255.255|中国|华东|上海市|上海市|联通",
        "58.0.0.0|58.63.255.255|中国|华南|广东省|广州市|电信",
        "58.64.0.0|58.127.255.255|中国|华南|广东省|广州市|联通",
        "110.0.0.0|110.63.255.255|中国|华中|湖北省|武汉市|电信",
        "110.64.0.0|110.127.255.255|中国|华中|湖北省|武汉市|联通",
        "8.8.8.8|8.8.8.8|美国|0|0|0|Google",
        "114.114.114.114|114.114.114.114|中国|0|江苏省|南京市|114DNS"
    ]
    
    with open(filename, 'w', encoding='utf-8') as f:
        for line in sample_data:
            f.write(line + '\n')
    
    print(f"示例文件已创建: {filename}")


def test_conversion():
    """测试转换功能"""
    print("测试ip2region转换功能...")
    
    # 测试数据
    test_lines = [
        "1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0",
        "1.0.1.0|1.0.3.255|中国|0|福建省|福州市|电信",
        "14.0.0.0|14.0.255.255|中国|华北|北京市|北京市|电信",
        "8.8.8.8|8.8.8.8|美国|0|0|0|Google"
    ]
    
    print("测试解析结果:")
    print("-" * 80)
    
    for line in test_lines:
        result = parse_ip2region_line(line)
        if result:
            start_ip, end_ip, address1, address2 = result
            print(f"原始: {line}")
            print(f"解析: start_ip={start_ip}, end_ip={end_ip}")
            print(f"      address1='{address1}', address2='{address2}'")
            print()
        else:
            print(f"解析失败: {line}")
    
    print("-" * 80)


def main():
    if len(sys.argv) < 2:
        print("ip2region数据转换工具")
        print("=" * 50)
        print("使用方法:")
        print("  python3 ip2region_converter.py input.txt output.sql")
        print("  python3 ip2region_converter.py --create-sample sample.txt")
        print("  python3 ip2region_converter.py --test")
        print("")
        print("参数说明:")
        print("  input.txt   - 输入的ip.merge.txt文件")
        print("  output.sql  - 输出的SQL文件")
        print("  --create-sample - 创建示例文件")
        print("  --test      - 测试转换功能")
        print("")
        print("ip2region格式说明:")
        print("  每行格式: start_ip|end_ip|国家|区域|省份|城市|ISP")
        print("  示例: 1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0")
        print("")
        print("下载ip2region数据:")
        print("  https://github.com/lionsoul2014/ip2region/blob/master/data/ip.merge.txt")
        sys.exit(1)
    
    if sys.argv[1] == '--test':
        test_conversion()
        return
    
    if sys.argv[1] == '--create-sample':
        if len(sys.argv) < 3:
            filename = 'sample_ip2region.txt'
        else:
            filename = sys.argv[2]
        create_sample_ip2region_file(filename)
        return
    
    if len(sys.argv) < 3:
        print("错误: 缺少输出文件参数")
        print("使用方法: python3 ip2region_converter.py input.txt output.sql")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"输入文件不存在: {input_file}")
        sys.exit(1)
    
    success = convert_ip2region_to_sql(input_file, output_file)
    if success:
        print("\n转换完成！可以使用以下命令导入数据库:")
        print(f"mysql -u root -p aq3stat < {output_file}")
    else:
        print("转换失败！")
        sys.exit(1)


if __name__ == '__main__':
    main()
