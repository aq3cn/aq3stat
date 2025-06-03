<template>
  <div class="website-detail">
    <el-card class="box-card">
      <div slot="header" class="clearfix">
        <span>网站详情</span>
        <el-button style="float: right; padding: 3px 0" type="text" @click="goBack">返回</el-button>
      </div>
      
      <div v-if="website">
        <el-descriptions title="网站信息" :column="2" border>
          <el-descriptions-item label="网站名称">{{ website.name }}</el-descriptions-item>
          <el-descriptions-item label="网站URL">{{ website.url }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ website.created_at }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ website.updated_at }}</el-descriptions-item>
          <el-descriptions-item label="是否公开">
            <el-tag :type="website.is_public ? 'success' : 'info'">
              {{ website.is_public ? '公开' : '私有' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="website.status === 'active' ? 'success' : 'warning'">
              {{ website.status === 'active' ? '活跃' : '暂停' }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </div>
      
      <div v-else class="loading">
        <el-loading-text>加载中...</el-loading-text>
      </div>
    </el-card>
  </div>
</template>

<script>
export default {
  name: 'WebsiteDetail',
  data() {
    return {
      website: null,
      loading: false
    }
  },
  created() {
    this.fetchWebsite()
  },
  methods: {
    async fetchWebsite() {
      try {
        this.loading = true
        const id = this.$route.params.id
        // TODO: 实现获取网站详情的API调用
        // const response = await this.$api.website.getDetail(id)
        // this.website = response.data
        
        // 临时数据
        this.website = {
          id: id,
          name: '示例网站',
          url: 'https://example.com',
          is_public: true,
          status: 'active',
          created_at: '2024-01-01 10:00:00',
          updated_at: '2024-01-01 10:00:00'
        }
      } catch (error) {
        this.$message.error('获取网站详情失败')
      } finally {
        this.loading = false
      }
    },
    goBack() {
      this.$router.go(-1)
    }
  }
}
</script>

<style scoped>
.website-detail {
  padding: 20px;
}

.loading {
  text-align: center;
  padding: 50px;
}
</style>
