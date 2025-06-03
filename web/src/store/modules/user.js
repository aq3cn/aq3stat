import { login, getInfo } from '@/api/auth'
import { getToken, setToken, removeToken } from '@/utils/auth'

const state = {
  token: getToken(),
  user: null
}

const mutations = {
  SET_TOKEN: (state, token) => {
    state.token = token
  },
  SET_USER: (state, user) => {
    state.user = user
  }
}

const actions = {
  // 用户登录
  login({ commit }, userInfo) {
    const { username, password } = userInfo
    return new Promise((resolve, reject) => {
      login({ username: username.trim(), password: password })
        .then(response => {
          const { token, user } = response
          commit('SET_TOKEN', token)
          commit('SET_USER', user)
          setToken(token)
          resolve(user)
        })
        .catch(error => {
          reject(error)
        })
    })
  },

  // 获取用户信息
  getInfo({ commit, state }) {
    return new Promise((resolve, reject) => {
      getInfo()
        .then(response => {
          if (!response) {
            reject('Verification failed, please Login again.')
          }
          commit('SET_USER', response)
          resolve(response)
        })
        .catch(error => {
          reject(error)
        })
    })
  },

  // 退出登录
  logout({ commit }) {
    return new Promise(resolve => {
      commit('SET_TOKEN', '')
      commit('SET_USER', null)
      removeToken()
      resolve()
    })
  },

  // 重置token
  resetToken({ commit }) {
    return new Promise(resolve => {
      commit('SET_TOKEN', '')
      commit('SET_USER', null)
      removeToken()
      resolve()
    })
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
