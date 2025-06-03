<template>
  <div class="error-handler">
    <el-dialog
      title="错误"
      :visible.sync="dialogVisible"
      width="500px"
      :show-close="false"
      :close-on-click-modal="false"
      :close-on-press-escape="false">
      <div class="error-content">
        <div class="error-icon">
          <i class="el-icon-error"></i>
        </div>
        <div class="error-message">
          <h3>{{ errorTitle }}</h3>
          <p>{{ errorMessage }}</p>
        </div>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="reload">刷新页面</el-button>
        <el-button type="primary" @click="goHome">返回首页</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'ErrorHandler',
  data() {
    return {
      dialogVisible: false,
      errorTitle: '发生错误',
      errorMessage: '应用程序遇到了一个未知错误，请刷新页面或返回首页。'
    }
  },
  created() {
    // 全局错误处理
    window.onerror = (message, source, lineno, colno, error) => {
      this.showError('JavaScript错误', `${message}\n位置: ${source}:${lineno}:${colno}`)
      return true
    }
    
    // 捕获未处理的Promise错误
    window.addEventListener('unhandledrejection', event => {
      this.showError('Promise错误', event.reason ? event.reason.message || event.reason : '未知Promise错误')
    })
    
    // 捕获Vue错误
    this.$root.$on('error', (error, info) => {
      this.showError('Vue错误', error.message || error)
    })
  },
  methods: {
    showError(title, message) {
      this.errorTitle = title || '发生错误'
      this.errorMessage = message || '应用程序遇到了一个未知错误，请刷新页面或返回首页。'
      this.dialogVisible = true
    },
    reload() {
      window.location.reload()
    },
    goHome() {
      this.dialogVisible = false
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
.error-content {
  display: flex;
  align-items: flex-start;
}

.error-icon {
  font-size: 48px;
  color: #f56c6c;
  margin-right: 20px;
}

.error-message h3 {
  margin-top: 0;
  margin-bottom: 10px;
  color: #303133;
}

.error-message p {
  margin: 0;
  color: #606266;
  white-space: pre-wrap;
  word-break: break-word;
}
</style>
