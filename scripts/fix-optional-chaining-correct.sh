#!/bin/bash

# 修复Vue文件中的可选链操作符
find web/src -name "*.vue" -type f -exec sed -i 's/error\.response && error\.response\.data && error\.response\.data\.error ? error\.response\.data\.error || '\''未知错误'\''/error.response \&\& error.response.data \&\& error.response.data.error ? error.response.data.error : '\''未知错误'\''/g' {} \;

echo "已修复所有Vue文件中的可选链操作符"
