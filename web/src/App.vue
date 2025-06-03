<!--
 * @Author: xxx@xxx.com
 * @Date: 2025-05-22 19:10:48
 * @LastEditors: xxx@xxx.com
 * @LastEditTime: 2025-05-22 19:27:33
 * @FilePath: \cnzz1\web\src\App.vue
 * @Description: 
 * 
 * Copyright (c) 2022 by xxx@xxx.com, All Rights Reserved. 
-->
<template>
  <div id="app">
    <router-view />
    <error-handler ref="errorHandler" />
    <loading :loading="isLoading" :text="loadingText" />
  </div>
</template>

<script>
import ErrorHandler from '@/components/ErrorHandler'
import Loading from '@/components/Loading'

export default {
  name: 'App',
  components: {
    ErrorHandler,
    Loading
  },
  data() {
    return {
      isLoading: false,
      loadingText: '加载中...'
    }
  },
  created() {
    // 注册全局事件总线，用于控制加载状态
    this.$root.$on('loading:show', (text) => {
      this.loadingText = text || '加载中...'
      this.isLoading = true
    })

    this.$root.$on('loading:hide', () => {
      this.isLoading = false
    })
  },
  errorCaptured(err, vm, info) {
    // 将错误传递给错误处理组件
    this.$refs.errorHandler.showError('应用错误', err.message || err)
    return false // 阻止错误继续传播
  }
}
</script>

<style>
#app {
  font-family: 'Microsoft YaHei', Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  height: 100%;
}

html,
body {
  margin: 0;
  padding: 0;
  height: 100%;
}
</style>
