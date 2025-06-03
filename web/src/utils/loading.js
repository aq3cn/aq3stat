import Vue from 'vue'

/**
 * 显示全局加载状态
 * @param {string} text 加载提示文本
 */
export function showLoading(text) {
  try {
    if (Vue.prototype.$root && Vue.prototype.$root.$emit) {
      Vue.prototype.$root.$emit('loading:show', text)
    }
  } catch (error) {
    console.warn('Failed to show loading:', error)
  }
}

/**
 * 隐藏全局加载状态
 */
export function hideLoading() {
  try {
    if (Vue.prototype.$root && Vue.prototype.$root.$emit) {
      Vue.prototype.$root.$emit('loading:hide')
    }
  } catch (error) {
    console.warn('Failed to hide loading:', error)
  }
}

/**
 * 使用加载状态包装异步函数
 * @param {Function} fn 异步函数
 * @param {string} text 加载提示文本
 * @returns {Promise} 返回原函数的Promise
 */
export async function withLoading(fn, text = '加载中...') {
  showLoading(text)
  try {
    return await fn()
  } finally {
    hideLoading()
  }
}

/**
 * 创建一个带有加载状态的API请求函数
 * @param {Function} apiFn API请求函数
 * @param {string} text 加载提示文本
 * @returns {Function} 返回包装后的函数
 */
export function createLoadingApi(apiFn, text) {
  return async (...args) => {
    return withLoading(() => apiFn(...args), text)
  }
}
