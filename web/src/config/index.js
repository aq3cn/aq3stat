/**
 * 前端配置文件
 */

// 应用配置
export const appConfig = {
  // 应用名称
  title: process.env.VUE_APP_TITLE || 'aq3stat - 网站统计系统',
  
  // API基础URL
  baseApi: process.env.VUE_APP_BASE_API || '/api',
  
  // 是否开发环境
  isDev: process.env.NODE_ENV === 'development',
  
  // 是否生产环境
  isProd: process.env.NODE_ENV === 'production'
}

// 统计图标配置
export const iconConfig = [
  { value: '1', label: '样式1', image: '/static/icons/1.gif' },
  { value: '2', label: '样式2', image: '/static/icons/2.gif' },
  { value: '3', label: '样式3', image: '/static/icons/3.gif' },
  { value: '4', label: '样式4', image: '/static/icons/4.gif' },
  { value: '5', label: '样式5', image: '/static/icons/5.gif' },
  { value: 'text', label: '文字样式', image: '' },
  { value: 'no', label: '隐藏图标', image: '' }
]

// 分页配置
export const paginationConfig = {
  // 默认每页显示数量
  pageSize: 10,
  
  // 可选的每页显示数量
  pageSizes: [10, 20, 50, 100],
  
  // 分页布局
  layout: 'total, sizes, prev, pager, next, jumper'
}

// 图表配置
export const chartConfig = {
  // 图表主题
  theme: 'light',
  
  // 图表颜色
  colors: ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C', '#909399'],
  
  // 图表大小
  size: {
    width: '100%',
    height: '400px'
  }
}
