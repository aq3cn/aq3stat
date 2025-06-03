import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import './assets/css/global.css'
import * as echarts from 'echarts'

// 使用ElementUI
Vue.use(ElementUI, { size: 'medium' })

// 将echarts挂载到Vue原型上，方便全局使用
Vue.prototype.$echarts = echarts

Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
