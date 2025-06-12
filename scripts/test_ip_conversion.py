#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IP地址转换测试脚本
用于验证IP地址转换的正确性

使用方法:
python3 test_ip_conversion.py
"""

import struct
import socket


def ip_to_int(ip_str):
    """将IP地址字符串转换为整数"""
    try:
        return struct.unpack("!I", socket.inet_aton(ip_str))[0]
    except socket.error:
        return 0


def int_to_ip(ip_int):
    """将整数转换为IP地址字符串"""
    return socket.inet_ntoa(struct.pack("!I", ip_int))


def test_ip_conversions():
    """测试IP地址转换"""
    test_cases = [
        "1.0.0.0",
        "1.0.0.255", 
        "192.168.1.1",
        "10.0.0.1",
        "127.0.0.1",
        "255.255.255.255"
    ]
    
    print("IP地址转换测试:")
    print("-" * 50)
    
    for ip in test_cases:
        ip_int = ip_to_int(ip)
        ip_back = int_to_ip(ip_int)
        print(f"{ip:15} -> {ip_int:12} -> {ip_back}")
    
    print("-" * 50)


def test_sample_data():
    """测试示例数据的转换"""
    print("\n示例数据验证:")
    print("-" * 50)
    
    # 从生成的SQL文件中提取的一些数据进行验证
    test_data = [
        (16777216, 16777471, "1.0.0.0", "1.0.0.255"),
        (16777472, 16778239, "1.0.1.0", "1.0.3.255"),
        (234881024, 234946559, "14.0.0.0", "14.0.255.255"),
        (2097152000, 2101346303, "125.0.0.0", "125.63.255.255")
    ]
    
    for start_int, end_int, expected_start, expected_end in test_data:
        actual_start = int_to_ip(start_int)
        actual_end = int_to_ip(end_int)
        
        print(f"范围: {start_int:12} - {end_int:12}")
        print(f"期望: {expected_start:15} - {expected_end}")
        print(f"实际: {actual_start:15} - {actual_end}")
        
        if actual_start == expected_start and actual_end == expected_end:
            print("✓ 转换正确")
        else:
            print("✗ 转换错误")
        print()


def main():
    print("IP地址库转换验证工具")
    print("=" * 50)
    
    test_ip_conversions()
    test_sample_data()
    
    print("验证完成！")


if __name__ == '__main__':
    main()
