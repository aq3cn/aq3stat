import request from '@/utils/request'

// 登录
export function login(data) {
  return request({
    url: '/auth/login',
    method: 'post',
    data
  })
}

// 注册
export function register(data) {
  return request({
    url: '/auth/register',
    method: 'post',
    data
  })
}

// 获取当前用户信息
export function getInfo() {
  return request({
    url: '/auth/me',
    method: 'get'
  })
}

// 修改用户信息
export function updateUser(id, data) {
  return request({
    url: `/users/${id}`,
    method: 'put',
    data
  })
}

// 修改密码
export function changePassword(id, data) {
  return request({
    url: `/users/${id}/change-password`,
    method: 'post',
    data
  })
}
