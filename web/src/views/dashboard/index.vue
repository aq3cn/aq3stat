<template>
  <div class="dashboard-container">
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card>
          <div slot="header">
            <span>欢迎使用 aq3stat 网站统计系统</span>
          </div>
          <div v-if="loading" class="loading-container">
            <el-skeleton :rows="6" animated />
          </div>
          <div v-else>
            <div v-if="websites.length === 0" class="empty-container">
              <el-empty description="您还没有添加网站">
                <el-button type="primary" @click="addWebsite">添加网站</el-button>
              </el-empty>
            </div>
            <div v-else>
              <h3>我的网站</h3>
              <el-table :data="websites" style="width: 100%" border>
                <el-table-column prop="name" label="网站名称" width="180"></el-table-column>
                <el-table-column prop="url" label="网站地址">
                  <template slot-scope="scope">
                    <a :href="scope.row.url" target="_blank">{{ scope.row.url }}</a>
                  </template>
                </el-table-column>
                <el-table-column prop="is_public" label="是否公开" width="100">
                  <template slot-scope="scope">
                    <el-tag :type="scope.row.is_public ? 'success' : 'info'">
                      {{ scope.row.is_public ? '公开' : '私有' }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="500">
                  <template slot-scope="scope">
                    <el-button
                      size="mini"
                      type="primary"
                      @click="viewStats(scope.row.id)">查看统计</el-button>
                    <el-button
                      size="mini"
                      @click="getCode(scope.row.id)">获取代码</el-button>
                    <el-button
                      size="mini"
                      type="danger"
                      @click="deleteWebsite(scope.row.id)">删除</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <div class="add-button">
                <el-button type="primary" @click="addWebsite">添加网站</el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { deleteWebsite } from '@/api/website'

export default {
  name: 'Dashboard',
  data() {
    return {
      loading: true
    }
  },
  computed: {
    ...mapGetters(['websites'])
  },
  created() {
    this.getWebsites()
  },
  methods: {
    // 获取网站列表
    async getWebsites() {
      try {
        this.loading = true
        await this.$store.dispatch('website/getWebsites')
      } catch (error) {
        this.$message.error('获取网站列表失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      } finally {
        this.loading = false
      }
    },
    // 添加网站
    addWebsite() {
      this.$router.push('/websites/add')
    },
    // 查看统计
    viewStats(id) {
      this.$router.push(`/websites/${id}/stats`)
    },
    // 获取代码
    getCode(id) {
      this.$router.push(`/websites/${id}/code`)
    },
    // 删除网站
    deleteWebsite(id) {
      this.$confirm('此操作将永久删除该网站及其所有统计数据, 是否继续?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          await deleteWebsite(id)
          this.$message.success('删除成功')
          this.getWebsites()
        } catch (error) {
          this.$message.error('删除失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
        }
      }).catch(() => {
        this.$message.info('已取消删除')
      })
    }
  }
}
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
}

.loading-container {
  padding: 20px 0;
}

.empty-container {
  padding: 40px 0;
  text-align: center;
}

.add-button {
  margin-top: 20px;
  text-align: center;
}
</style>
