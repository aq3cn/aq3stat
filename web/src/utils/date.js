/**
 * 日期格式化工具函数
 */

/**
 * 格式化日期
 * @param {Date|string|number} date 日期对象、日期字符串或时间戳
 * @param {string} format 格式化模板，如 'YYYY-MM-DD HH:mm:ss'
 * @returns {string} 格式化后的日期字符串
 */
export function formatDate(date, format = 'YYYY-MM-DD HH:mm:ss') {
  if (!date) return ''
  
  // 转换为Date对象
  const dateObj = typeof date === 'object' ? date : new Date(date)
  
  // 如果日期无效，返回空字符串
  if (isNaN(dateObj.getTime())) return ''
  
  const year = dateObj.getFullYear()
  const month = dateObj.getMonth() + 1
  const day = dateObj.getDate()
  const hours = dateObj.getHours()
  const minutes = dateObj.getMinutes()
  const seconds = dateObj.getSeconds()
  
  // 替换格式化模板中的占位符
  return format
    .replace(/YYYY/g, year)
    .replace(/YY/g, String(year).slice(2))
    .replace(/MM/g, padZero(month))
    .replace(/M/g, month)
    .replace(/DD/g, padZero(day))
    .replace(/D/g, day)
    .replace(/HH/g, padZero(hours))
    .replace(/H/g, hours)
    .replace(/hh/g, padZero(hours % 12 || 12))
    .replace(/h/g, hours % 12 || 12)
    .replace(/mm/g, padZero(minutes))
    .replace(/m/g, minutes)
    .replace(/ss/g, padZero(seconds))
    .replace(/s/g, seconds)
    .replace(/A/g, hours < 12 ? 'AM' : 'PM')
    .replace(/a/g, hours < 12 ? 'am' : 'pm')
}

/**
 * 获取相对时间描述
 * @param {Date|string|number} date 日期对象、日期字符串或时间戳
 * @returns {string} 相对时间描述，如"刚刚"、"5分钟前"、"2小时前"等
 */
export function getRelativeTime(date) {
  if (!date) return ''
  
  // 转换为Date对象
  const dateObj = typeof date === 'object' ? date : new Date(date)
  
  // 如果日期无效，返回空字符串
  if (isNaN(dateObj.getTime())) return ''
  
  const now = new Date()
  const diff = now.getTime() - dateObj.getTime()
  
  // 计算时间差
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)
  const months = Math.floor(days / 30)
  const years = Math.floor(months / 12)
  
  // 根据时间差返回相应的描述
  if (seconds < 60) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 30) return `${days}天前`
  if (months < 12) return `${months}个月前`
  return `${years}年前`
}

/**
 * 获取日期范围
 * @param {string} type 范围类型：today, yesterday, thisWeek, lastWeek, thisMonth, lastMonth
 * @returns {Array} 包含开始日期和结束日期的数组
 */
export function getDateRange(type) {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  
  switch (type) {
    case 'today':
      return [today, new Date(today.getTime() + 24 * 60 * 60 * 1000 - 1)]
    
    case 'yesterday':
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000)
      return [yesterday, new Date(today.getTime() - 1)]
    
    case 'thisWeek': {
      const day = today.getDay() || 7 // 将周日的0转换为7
      const startOfWeek = new Date(today.getTime() - (day - 1) * 24 * 60 * 60 * 1000)
      const endOfWeek = new Date(startOfWeek.getTime() + 7 * 24 * 60 * 60 * 1000 - 1)
      return [startOfWeek, endOfWeek]
    }
    
    case 'lastWeek': {
      const day = today.getDay() || 7 // 将周日的0转换为7
      const startOfThisWeek = new Date(today.getTime() - (day - 1) * 24 * 60 * 60 * 1000)
      const startOfLastWeek = new Date(startOfThisWeek.getTime() - 7 * 24 * 60 * 60 * 1000)
      const endOfLastWeek = new Date(startOfThisWeek.getTime() - 1)
      return [startOfLastWeek, endOfLastWeek]
    }
    
    case 'thisMonth': {
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
      const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999)
      return [startOfMonth, endOfMonth]
    }
    
    case 'lastMonth': {
      const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
      const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999)
      return [startOfLastMonth, endOfLastMonth]
    }
    
    default:
      return [today, new Date(today.getTime() + 24 * 60 * 60 * 1000 - 1)]
  }
}

/**
 * 数字补零
 * @param {number} num 数字
 * @returns {string} 补零后的字符串
 */
function padZero(num) {
  return String(num).padStart(2, '0')
}
