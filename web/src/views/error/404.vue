<template>
  <div class="error-container">
    <div class="error-content">
      <h1>404</h1>
      <h2>页面不存在</h2>
      <p>抱歉，您访问的页面不存在或已被删除</p>
      <el-button type="primary" @click="goHome">返回首页</el-button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Error404',
  methods: {
    goHome() {
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
.error-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  background-color: #f5f7fa;
}

.error-content {
  text-align: center;
  padding: 40px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

h1 {
  font-size: 72px;
  color: #409EFF;
  margin: 0;
}

h2 {
  font-size: 24px;
  color: #303133;
  margin: 20px 0;
}

p {
  font-size: 16px;
  color: #606266;
  margin-bottom: 30px;
}
</style>
