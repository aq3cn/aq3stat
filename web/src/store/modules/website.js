import { getWebsites, getWebsite, getWebsiteStats } from '@/api/website'

const state = {
  websites: [],
  currentWebsite: null,
  websiteStats: null
}

const mutations = {
  SET_WEBSITES: (state, websites) => {
    state.websites = websites
  },
  SET_CURRENT_WEBSITE: (state, website) => {
    state.currentWebsite = website
  },
  SET_WEBSITE_STATS: (state, stats) => {
    state.websiteStats = stats
  },
  ADD_WEBSITE: (state, website) => {
    state.websites.push(website)
  },
  UPDATE_WEBSITE: (state, website) => {
    const index = state.websites.findIndex(w => w.id === website.id)
    if (index !== -1) {
      state.websites.splice(index, 1, website)
    }
    if (state.currentWebsite && state.currentWebsite.id === website.id) {
      state.currentWebsite = website
    }
  },
  REMOVE_WEBSITE: (state, id) => {
    state.websites = state.websites.filter(w => w.id !== id)
    if (state.currentWebsite && state.currentWebsite.id === id) {
      state.currentWebsite = null
    }
  }
}

const actions = {
  // 获取用户的网站列表
  getWebsites({ commit }) {
    return new Promise((resolve, reject) => {
      getWebsites()
        .then(response => {
          commit('SET_WEBSITES', response)
          resolve(response)
        })
        .catch(error => {
          reject(error)
        })
    })
  },

  // 获取网站详情
  getWebsite({ commit }, id) {
    return new Promise((resolve, reject) => {
      getWebsite(id)
        .then(response => {
          commit('SET_CURRENT_WEBSITE', response)
          resolve(response)
        })
        .catch(error => {
          reject(error)
        })
    })
  },

  // 获取网站统计数据
  getWebsiteStats({ commit }, id) {
    return new Promise((resolve, reject) => {
      getWebsiteStats(id)
        .then(response => {
          commit('SET_WEBSITE_STATS', response)
          resolve(response)
        })
        .catch(error => {
          reject(error)
        })
    })
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
