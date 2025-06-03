#!/bin/bash

# 修复所有文件中的 uint 类型参数和转换
echo "修复所有文件中的 uint 类型..."

# 修复函数参数中的 uint 类型
find internal -name "*.go" -type f -exec sed -i 's/websiteID uint/websiteID int/g' {} \;
find internal -name "*.go" -type f -exec sed -i 's/userID uint/userID int/g' {} \;
find internal -name "*.go" -type f -exec sed -i 's/id uint/id int/g' {} \;

# 修复类型转换
find internal -name "*.go" -type f -exec sed -i 's/uint(id)/id/g' {} \;
find internal -name "*.go" -type f -exec sed -i 's/userID\.(uint)/userID.(int)/g' {} \;
find internal -name "*.go" -type f -exec sed -i 's/groupID\.(uint)/groupID.(int)/g' {} \;

# 修复比较操作
find internal -name "*.go" -type f -exec sed -i 's/!= userID\.(uint)/!= userID.(int)/g' {} \;

# 修复 API 控制器中的类型转换
find internal/api -name "*.go" -type f -exec sed -i 's/strconv.ParseUint(\([^,]*\), 10, 32)/strconv.Atoi(\1)/g' {} \;

echo "类型修复完成！"
