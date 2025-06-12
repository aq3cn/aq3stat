#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
简化的IP地址库转换脚本
将CSV格式的IP地址库转换为aq3stat系统的MySQL INSERT语句

使用方法:
python3 simple_ip_converter.py input.csv output.sql

CSV格式要求:
1. 第一列: 起始IP地址 (如: 192.168.1.1)
2. 第二列: 结束IP地址 (如: 192.168.1.255)
3. 第三列: 地址信息1 (如: 北京市)
4. 第四列: 地址信息2 (如: 联通)

或者网络格式:
1. 第一列: 网络地址 (如: 192.168.1.0/24)
2. 第二列: 国家
3. 第三列: 省市
4. 第四列: ISP
"""

import csv
import struct
import socket
import sys
import os


def ip_to_int(ip_str):
    """将IP地址字符串转换为整数"""
    try:
        return struct.unpack("!I", socket.inet_aton(ip_str))[0]
    except socket.error:
        print(f"无效的IP地址: {ip_str}")
        return 0


def network_to_range(network):
    """将网络地址转换为IP范围"""
    try:
        if '/' in network:
            ip, prefix = network.split('/')
            start_ip = ip_to_int(ip)
            prefix_len = int(prefix)
            end_ip = start_ip + (2 ** (32 - prefix_len)) - 1
            return start_ip, end_ip
        else:
            # 单个IP地址
            ip_int = ip_to_int(network)
            return ip_int, ip_int
    except Exception as e:
        print(f"解析网络地址失败 {network}: {e}")
        return 0, 0


def escape_sql_string(s):
    """转义SQL字符串"""
    if s is None:
        return 'NULL'
    return "'" + str(s).replace("'", "''").replace("\\", "\\\\") + "'"


def convert_csv_to_sql(input_file, output_file, format_type='range'):
    """
    转换CSV文件为SQL插入语句
    
    Args:
        input_file: 输入CSV文件路径
        output_file: 输出SQL文件路径
        format_type: 格式类型 ('range' 或 'network')
    """
    
    print(f"开始转换: {input_file} -> {output_file}")
    
    try:
        with open(input_file, 'r', encoding='utf-8') as infile, \
             open(output_file, 'w', encoding='utf-8') as outfile:
            
            # 写入SQL文件头
            outfile.write("-- IP地址库数据\n")
            outfile.write("-- 由 simple_ip_converter.py 生成\n")
            outfile.write("-- 使用前请确保已连接到正确的数据库\n\n")
            outfile.write("USE aq3stat;\n\n")
            outfile.write("-- 清空现有IP数据（可选）\n")
            outfile.write("-- TRUNCATE TABLE ip_data;\n\n")
            outfile.write("-- 插入IP地址数据\n")
            
            reader = csv.reader(infile)
            
            # 跳过标题行（如果有）
            first_row = next(reader, None)
            if first_row and (first_row[0].lower().startswith('ip') or 
                             first_row[0].lower().startswith('start') or
                             first_row[0].lower().startswith('network')):
                print("跳过标题行")
            else:
                # 如果第一行不是标题，重新处理
                infile.seek(0)
                reader = csv.reader(infile)
            
            batch_count = 0
            total_count = 0
            
            outfile.write("INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES\n")
            
            for row_num, row in enumerate(reader, 1):
                try:
                    if len(row) < 2:
                        continue
                    
                    if format_type == 'network':
                        # 网络格式: network, country, region, isp
                        network = row[0].strip()
                        country = row[1].strip() if len(row) > 1 else ""
                        region = row[2].strip() if len(row) > 2 else ""
                        isp = row[3].strip() if len(row) > 3 else "未知ISP"
                        
                        start_ip, end_ip = network_to_range(network)
                        address1 = f"{country} {region}".strip()
                        address2 = isp
                        
                    else:
                        # 范围格式: start_ip, end_ip, address1, address2
                        start_ip = ip_to_int(row[0].strip())
                        end_ip = ip_to_int(row[1].strip())
                        address1 = row[2].strip() if len(row) > 2 else ""
                        address2 = row[3].strip() if len(row) > 3 else "未知ISP"
                    
                    if start_ip > 0 and end_ip > 0 and start_ip <= end_ip:
                        # 写入SQL语句
                        if batch_count > 0:
                            outfile.write(",\n")
                        
                        outfile.write(f"({start_ip}, {end_ip}, {escape_sql_string(address1)}, {escape_sql_string(address2)})")
                        
                        batch_count += 1
                        total_count += 1
                        
                        # 每1000条记录分批
                        if batch_count >= 1000:
                            outfile.write(";\n\n")
                            outfile.write("INSERT INTO ip_data (start_ip, end_ip, address1, address2) VALUES\n")
                            batch_count = 0
                        
                        if row_num % 10000 == 0:
                            print(f"已处理 {row_num} 行，有效记录 {total_count} 条")
                    
                except Exception as e:
                    print(f"处理第 {row_num} 行时出错: {e}")
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
            
            print(f"转换完成！共生成 {total_count} 条有效记录")
            print(f"SQL文件已保存到: {output_file}")
    
    except Exception as e:
        print(f"转换失败: {e}")


def main():
    if len(sys.argv) < 3:
        print("使用方法:")
        print("  python3 simple_ip_converter.py input.csv output.sql [format]")
        print("")
        print("参数说明:")
        print("  input.csv   - 输入的CSV文件")
        print("  output.sql  - 输出的SQL文件")
        print("  format      - 格式类型 (range 或 network，默认为 range)")
        print("")
        print("CSV格式说明:")
        print("  range格式:   start_ip, end_ip, address1, address2")
        print("  network格式: network, country, region, isp")
        print("")
        print("示例:")
        print("  python3 simple_ip_converter.py ip_data.csv ip_data.sql range")
        print("  python3 simple_ip_converter.py geoip.csv geoip.sql network")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    format_type = sys.argv[3] if len(sys.argv) > 3 else 'range'
    
    if not os.path.exists(input_file):
        print(f"输入文件不存在: {input_file}")
        sys.exit(1)
    
    if format_type not in ['range', 'network']:
        print(f"无效的格式类型: {format_type}")
        print("支持的格式: range, network")
        sys.exit(1)
    
    convert_csv_to_sql(input_file, output_file, format_type)


if __name__ == '__main__':
    main()
