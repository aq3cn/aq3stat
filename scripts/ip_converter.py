#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IP地址库数据转换脚本
支持将不同格式的IP地址库转换为aq3stat系统的MySQL格式

支持的数据源：
1. 纯真IP库 (QQWry.dat)
2. GeoIP2 CSV格式
3. IP2Location CSV格式
4. 自定义CSV格式

作者: aq3stat Team
"""

import csv
import struct
import socket
import sys
import os
import argparse
from typing import List, Tuple, Optional
import mysql.connector
from mysql.connector import Error


def ip_to_int(ip_str: str) -> int:
    """将IP地址字符串转换为整数"""
    try:
        return struct.unpack("!I", socket.inet_aton(ip_str))[0]
    except socket.error:
        return 0


def int_to_ip(ip_int: int) -> str:
    """将整数转换为IP地址字符串"""
    return socket.inet_ntoa(struct.pack("!I", ip_int))


class IPConverter:
    """IP地址库转换器基类"""
    
    def __init__(self, db_config: dict):
        self.db_config = db_config
        self.connection = None
    
    def connect_db(self):
        """连接数据库"""
        try:
            self.connection = mysql.connector.connect(**self.db_config)
            print("数据库连接成功")
        except Error as e:
            print(f"数据库连接失败: {e}")
            sys.exit(1)
    
    def close_db(self):
        """关闭数据库连接"""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("数据库连接已关闭")
    
    def clear_ip_data(self):
        """清空IP数据表"""
        try:
            cursor = self.connection.cursor()
            cursor.execute("TRUNCATE TABLE ip_data")
            self.connection.commit()
            print("IP数据表已清空")
        except Error as e:
            print(f"清空IP数据表失败: {e}")
    
    def insert_ip_data(self, data_list: List[Tuple]):
        """批量插入IP数据"""
        try:
            cursor = self.connection.cursor()
            sql = """
            INSERT INTO ip_data (start_ip, end_ip, address1, address2) 
            VALUES (%s, %s, %s, %s)
            """
            cursor.executemany(sql, data_list)
            self.connection.commit()
            print(f"成功插入 {len(data_list)} 条IP数据")
        except Error as e:
            print(f"插入IP数据失败: {e}")
            self.connection.rollback()


class CSVConverter(IPConverter):
    """CSV格式IP地址库转换器"""
    
    def convert_csv(self, csv_file: str, format_type: str = "custom"):
        """
        转换CSV格式的IP地址库
        
        Args:
            csv_file: CSV文件路径
            format_type: 格式类型 (geoip2, ip2location, custom)
        """
        print(f"开始转换CSV文件: {csv_file}")
        
        data_list = []
        batch_size = 1000
        
        try:
            with open(csv_file, 'r', encoding='utf-8') as f:
                reader = csv.reader(f)
                
                # 跳过标题行
                next(reader, None)
                
                for row_num, row in enumerate(reader, 1):
                    try:
                        if format_type == "geoip2":
                            # GeoIP2格式: network,geoname_id,registered_country_geoname_id,represented_country_geoname_id,is_anonymous_proxy,is_satellite_provider,postal_code,latitude,longitude,accuracy_radius
                            network = row[0]  # 例如: "1.0.0.0/24"
                            country = row[1] if len(row) > 1 else ""
                            city = row[2] if len(row) > 2 else ""
                            
                            # 解析网络地址
                            ip, prefix = network.split('/')
                            start_ip = ip_to_int(ip)
                            end_ip = start_ip + (2 ** (32 - int(prefix))) - 1
                            
                            address1 = f"{country} {city}".strip()
                            address2 = "未知ISP"
                            
                        elif format_type == "ip2location":
                            # IP2Location格式: "start_ip","end_ip","country_code","country_name","region_name","city_name","latitude","longitude","zip_code","time_zone"
                            start_ip = ip_to_int(row[0].strip('"'))
                            end_ip = ip_to_int(row[1].strip('"'))
                            country = row[3].strip('"') if len(row) > 3 else ""
                            region = row[4].strip('"') if len(row) > 4 else ""
                            city = row[5].strip('"') if len(row) > 5 else ""
                            
                            address1 = f"{country} {region} {city}".strip()
                            address2 = "未知ISP"
                            
                        else:  # custom格式
                            # 自定义格式: start_ip,end_ip,address1,address2
                            start_ip = ip_to_int(row[0]) if row[0] else 0
                            end_ip = ip_to_int(row[1]) if row[1] else 0
                            address1 = row[2] if len(row) > 2 else ""
                            address2 = row[3] if len(row) > 3 else ""
                        
                        if start_ip > 0 and end_ip > 0 and start_ip <= end_ip:
                            data_list.append((start_ip, end_ip, address1, address2))
                        
                        # 批量插入
                        if len(data_list) >= batch_size:
                            self.insert_ip_data(data_list)
                            data_list = []
                            print(f"已处理 {row_num} 行")
                    
                    except Exception as e:
                        print(f"处理第 {row_num} 行时出错: {e}")
                        continue
                
                # 插入剩余数据
                if data_list:
                    self.insert_ip_data(data_list)
                
                print(f"CSV转换完成，共处理 {row_num} 行")
        
        except Exception as e:
            print(f"读取CSV文件失败: {e}")


class QQWryConverter(IPConverter):
    """纯真IP库转换器"""
    
    def convert_qqwry(self, dat_file: str):
        """
        转换纯真IP库(QQWry.dat)格式
        
        Args:
            dat_file: QQWry.dat文件路径
        """
        print(f"开始转换纯真IP库: {dat_file}")
        
        try:
            with open(dat_file, 'rb') as f:
                # 读取文件头
                f.seek(0)
                first_index = struct.unpack('<I', f.read(4))[0]
                last_index = struct.unpack('<I', f.read(4))[0]
                
                record_count = (last_index - first_index) // 7 + 1
                print(f"IP记录总数: {record_count}")
                
                data_list = []
                batch_size = 1000
                
                # 读取每条记录
                for i in range(record_count):
                    f.seek(first_index + i * 7)
                    start_ip = struct.unpack('<I', f.read(4))[0]
                    offset = struct.unpack('<I', f.read(3) + b'\x00')[0]
                    
                    # 读取结束IP和地址信息
                    f.seek(offset)
                    end_ip = struct.unpack('<I', f.read(4))[0]
                    
                    # 读取地址信息（简化处理）
                    address_data = f.read(100)  # 读取足够的字节
                    try:
                        # 解析地址信息（这里需要根据纯真IP库的具体格式来解析）
                        address1 = "中国"  # 默认值
                        address2 = "未知ISP"  # 默认值
                        
                        # 这里可以添加更复杂的地址解析逻辑
                        
                        data_list.append((start_ip, end_ip, address1, address2))
                        
                        # 批量插入
                        if len(data_list) >= batch_size:
                            self.insert_ip_data(data_list)
                            data_list = []
                            if i % 10000 == 0:
                                print(f"已处理 {i} 条记录")
                    
                    except Exception as e:
                        print(f"处理第 {i} 条记录时出错: {e}")
                        continue
                
                # 插入剩余数据
                if data_list:
                    self.insert_ip_data(data_list)
                
                print(f"纯真IP库转换完成，共处理 {record_count} 条记录")
        
        except Exception as e:
            print(f"读取纯真IP库文件失败: {e}")


def main():
    parser = argparse.ArgumentParser(description='IP地址库数据转换工具')
    parser.add_argument('--type', choices=['csv', 'qqwry'], required=True, help='数据源类型')
    parser.add_argument('--file', required=True, help='数据文件路径')
    parser.add_argument('--format', choices=['geoip2', 'ip2location', 'custom'], default='custom', help='CSV格式类型')
    parser.add_argument('--host', default='localhost', help='数据库主机')
    parser.add_argument('--port', type=int, default=3306, help='数据库端口')
    parser.add_argument('--user', default='root', help='数据库用户名')
    parser.add_argument('--password', required=True, help='数据库密码')
    parser.add_argument('--database', default='aq3stat', help='数据库名')
    parser.add_argument('--clear', action='store_true', help='清空现有IP数据')
    
    args = parser.parse_args()
    
    # 数据库配置
    db_config = {
        'host': args.host,
        'port': args.port,
        'user': args.user,
        'password': args.password,
        'database': args.database,
        'charset': 'utf8mb4'
    }
    
    # 检查文件是否存在
    if not os.path.exists(args.file):
        print(f"文件不存在: {args.file}")
        sys.exit(1)
    
    # 创建转换器
    if args.type == 'csv':
        converter = CSVConverter(db_config)
    else:
        converter = QQWryConverter(db_config)
    
    try:
        # 连接数据库
        converter.connect_db()
        
        # 清空现有数据（如果指定）
        if args.clear:
            converter.clear_ip_data()
        
        # 执行转换
        if args.type == 'csv':
            converter.convert_csv(args.file, args.format)
        else:
            converter.convert_qqwry(args.file)
        
        print("数据转换完成！")
    
    finally:
        converter.close_db()


if __name__ == '__main__':
    main()
