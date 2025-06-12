import request from '@/utils/request'

// 获取用户列表
export function getUsers(page = 1, pageSize = 10) {
  return request({
    url: '/admin/users',
    method: 'get',
    params: { page, page_size: pageSize }
  })
}

// 更新用户信息（管理员）
export function updateUserByAdmin(id, data) {
  return request({
    url: `/admin/users/${id}`,
    method: 'put',
    data
  })
}

// 重置用户密码（管理员）
export function resetUserPassword(id, data) {
  return request({
    url: `/admin/users/${id}/reset-password`,
    method: 'post',
    data
  })
}

// 删除用户
export function deleteUser(id) {
  return request({
    url: `/admin/users/${id}`,
    method: 'delete'
  })
}

// 获取用户组列表
export function getGroups() {
  return request({
    url: '/admin/groups',
    method: 'get'
  })
}

// 获取用户组详情
export function getGroup(id) {
  return request({
    url: `/admin/groups/${id}`,
    method: 'get'
  })
}

// 创建用户组
export function createGroup(data) {
  return request({
    url: '/admin/groups',
    method: 'post',
    data
  })
}

// 更新用户组
export function updateGroup(id, data) {
  return request({
    url: `/admin/groups/${id}`,
    method: 'put',
    data
  })
}

// 删除用户组
export function deleteGroup(id) {
  return request({
    url: `/admin/groups/${id}`,
    method: 'delete'
  })
}

// 获取系统统计数据
export function getSystemStats() {
  return request({
    url: '/admin/stats',
    method: 'get'
  })
}
