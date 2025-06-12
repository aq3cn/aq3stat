import request from '@/utils/request'

// 获取用户的网站列表
export function getWebsites() {
  return request({
    url: '/websites',
    method: 'get'
  })
}

// 获取网站详情
export function getWebsite(id) {
  return request({
    url: `/websites/${id}`,
    method: 'get'
  })
}

// 创建网站
export function createWebsite(data) {
  return request({
    url: '/websites',
    method: 'post',
    data
  })
}

// 更新网站
export function updateWebsite(id, data) {
  return request({
    url: `/websites/${id}`,
    method: 'put',
    data
  })
}

// 删除网站
export function deleteWebsite(id) {
  return request({
    url: `/websites/${id}`,
    method: 'delete'
  })
}

// 获取网站统计代码
export function getTrackingCode(id, iconType = '1') {
  return request({
    url: `/websites/${id}/tracking-code`,
    method: 'get',
    params: { icon: iconType }
  })
}

// 获取网站统计数据
export function getWebsiteStats(id) {
  return request({
    url: `/websites/${id}/stats`,
    method: 'get'
  })
}

// 获取网站访问来源统计
export function getWebsiteRefererStats(id) {
  return request({
    url: `/websites/${id}/referer-stats`,
    method: 'get'
  })
}

// 获取网站设备统计
export function getWebsiteDeviceStats(id) {
  return request({
    url: `/websites/${id}/device-stats`,
    method: 'get'
  })
}

// 获取公开的网站列表
export function getPublicWebsites(page = 1, pageSize = 10) {
  return request({
    url: '/websites/public',
    method: 'get',
    params: { page, page_size: pageSize }
  })
}
