<template>
  <div class="tracking-code-container">
    <el-card>
      <div slot="header">
        <span>统计代码</span>
      </div>
      
      <div v-if="loading" class="loading-container">
        <el-skeleton :rows="6" animated />
      </div>
      <div v-else>
        <el-alert
          title="请将以下代码添加到您的网站页面中，放在</body>标签之前"
          type="info"
          :closable="false">
        </el-alert>
        
        <div class="code-options">
          <span>统计图标样式：</span>
          <el-radio-group v-model="iconType" @change="getTrackingCode">
            <el-radio label="1">样式1</el-radio>
            <el-radio label="2">样式2</el-radio>
            <el-radio label="3">样式3</el-radio>
            <el-radio label="4">样式4</el-radio>
            <el-radio label="5">样式5</el-radio>
            <el-radio label="text">文字样式</el-radio>
            <el-radio label="no">隐藏图标</el-radio>
          </el-radio-group>
        </div>
        
        <div class="code-box">
          <pre>{{ trackingCode }}</pre>
        </div>
        
        <div class="code-actions">
          <el-button type="primary" @click="copyCode">复制代码</el-button>
          <el-button @click="goBack">返回</el-button>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script>
import { getWebsite, getTrackingCode } from '@/api/website'

export default {
  name: 'TrackingCode',
  data() {
    return {
      loading: true,
      websiteId: null,
      website: null,
      trackingCode: '',
      iconType: '1'
    }
  },
  created() {
    this.websiteId = parseInt(this.$route.params.id)
    this.getWebsiteData()
  },
  methods: {
    // 获取网站数据
    async getWebsiteData() {
      try {
        this.loading = true
        const response = await getWebsite(this.websiteId)
        this.website = response
        this.getTrackingCode()
      } catch (error) {
        this.$message.error('获取网站数据失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
        this.loading = false
      }
    },
    // 获取统计代码
    async getTrackingCode() {
      try {
        const response = await getTrackingCode(this.websiteId, this.iconType)
        this.trackingCode = response.tracking_code
      } catch (error) {
        this.$message.error('获取统计代码失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      } finally {
        this.loading = false
      }
    },
    // 复制代码
    copyCode() {
      const textarea = document.createElement('textarea')
      textarea.value = this.trackingCode
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand('copy')
      document.body.removeChild(textarea)
      this.$message.success('代码已复制到剪贴板')
    },
    // 返回
    goBack() {
      this.$router.push('/websites')
    }
  }
}
</script>

<style scoped>
.tracking-code-container {
  padding: 20px;
}

.loading-container {
  padding: 20px 0;
}

.code-options {
  margin: 20px 0;
}

.code-box {
  background-color: #f5f7fa;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 20px;
  overflow-x: auto;
}

.code-box pre {
  margin: 0;
  white-space: pre-wrap;
  word-wrap: break-word;
  font-family: Consolas, Monaco, 'Andale Mono', monospace;
  font-size: 14px;
  line-height: 1.5;
}

.code-actions {
  margin-top: 20px;
}
</style>
