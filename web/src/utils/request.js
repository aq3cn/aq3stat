import axios from 'axios'
import { Message } from 'element-ui'
import store from '@/store'
import router from '@/router'

// 创建axios实例
const service = axios.create({
  baseURL: process.env.VUE_APP_BASE_API, // API的基础URL
  timeout: 10000 // 请求超时时间
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    // 如果存在token，则每个请求都带上token
    if (store.getters.token) {
      config.headers['Authorization'] = 'Bearer ' + store.getters.token
    }
    return config
  },
  error => {
    console.log(error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    // 直接返回响应数据
    return response.data
  },
  error => {
    console.log('err', error)

    // 如果是401错误，说明token过期或无效，需要重新登录
    if (error.response && error.response.status === 401) {
      // 清除token并跳转到登录页
      store.dispatch('user/resetToken').then(() => {
        Message({
          message: '登录已过期，请重新登录',
          type: 'error',
          duration: 5 * 1000
        })
        router.push('/login')
      })
    } else {
      // 显示错误信息
      Message({
        message: error.response ? error.response.data.error || 'Error' : 'Network Error',
        type: 'error',
        duration: 5 * 1000
      })
    }

    return Promise.reject(error)
  }
)

export default service
