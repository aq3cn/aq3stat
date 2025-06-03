import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import website from './modules/website'
import getters from './getters'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    user,
    website
  },
  getters
})

export default store
