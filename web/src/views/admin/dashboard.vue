<template>
  <div class="admin-dashboard-container">
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card>
          <div slot="header">
            <span>系统概览</span>
          </div>

          <div v-if="loading" class="loading-container">
            <el-skeleton :rows="6" animated />
          </div>

          <div v-else>
            <el-row :gutter="20">
            <el-col :xs="24" :sm="12" :md="6">
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="el-icon-user"></i>
                </div>
                <div class="stat-info">
                  <div class="stat-title">用户数</div>
                  <div class="stat-value">{{ stats.userCount }}</div>
                </div>
              </div>
            </el-col>

            <el-col :xs="24" :sm="12" :md="6">
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="el-icon-s-grid"></i>
                </div>
                <div class="stat-info">
                  <div class="stat-title">网站数</div>
                  <div class="stat-value">{{ stats.websiteCount }}</div>
                </div>
              </div>
            </el-col>

            <el-col :xs="24" :sm="12" :md="6">
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="el-icon-view"></i>
                </div>
                <div class="stat-info">
                  <div class="stat-title">今日PV</div>
                  <div class="stat-value">{{ stats.todayPV }}</div>
                </div>
              </div>
            </el-col>

            <el-col :xs="24" :sm="12" :md="6">
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="el-icon-s-custom"></i>
                </div>
                <div class="stat-info">
                  <div class="stat-title">今日IP</div>
                  <div class="stat-value">{{ stats.todayIP }}</div>
                </div>
              </div>
            </el-col>
          </el-row>

          <div class="chart-container" ref="visitChart"></div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :xs="24" :sm="12">
        <el-card>
          <div slot="header">
            <span>最近注册用户</span>
          </div>

          <el-table :data="recentUsers" style="width: 100%">
            <el-table-column prop="username" label="用户名" width="120"></el-table-column>
            <el-table-column prop="email" label="邮箱"></el-table-column>
            <el-table-column prop="created_at" label="注册时间" width="180">
              <template slot-scope="scope">
                {{ new Date(scope.row.created_at).toLocaleString() }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12">
        <el-card>
          <div slot="header">
            <span>最近添加网站</span>
          </div>

          <el-table :data="recentWebsites" style="width: 100%">
            <el-table-column prop="name" label="网站名称" width="120"></el-table-column>
            <el-table-column prop="url" label="网站地址">
              <template slot-scope="scope">
                <a :href="scope.row.url" target="_blank">{{ scope.row.url }}</a>
              </template>
            </el-table-column>
            <el-table-column prop="created_at" label="添加时间" width="180">
              <template slot-scope="scope">
                {{ new Date(scope.row.created_at).toLocaleString() }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { getSystemStats } from '@/api/admin'

export default {
  name: 'AdminDashboard',
  data() {
    return {
      loading: true,
      stats: {
        userCount: 0,
        websiteCount: 0,
        todayPV: 0,
        todayIP: 0,
        totalPV: 0,
        totalIP: 0
      },
      recentUsers: [],
      recentWebsites: [],
      trendData: [],
      visitChart: null
    }
  },
  mounted() {
    this.loadSystemStats()

    this.$nextTick(() => {
      this.initVisitChart()
    })

    window.addEventListener('resize', this.handleResize)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize)
  },
  methods: {
    // 加载系统统计数据
    async loadSystemStats() {
      try {
        this.loading = true
        const response = await getSystemStats()

        this.stats = {
          userCount: response.userCount || 0,
          websiteCount: response.websiteCount || 0,
          todayPV: response.todayPV || 0,
          todayIP: response.todayIP || 0,
          totalPV: response.totalPV || 0,
          totalIP: response.totalIP || 0
        }

        this.recentUsers = response.recentUsers || []
        this.recentWebsites = response.recentWebsites || []
        this.trendData = response.trendData || []

        // 更新图表
        this.$nextTick(() => {
          this.updateVisitChart()
        })
      } catch (error) {
        console.error('获取系统统计数据失败:', error)
        this.$message.error('获取系统统计数据失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      } finally {
        this.loading = false
      }
    },

    // 初始化访问趋势图表
    initVisitChart() {
      if (!this.$refs.visitChart) return
      this.visitChart = this.$echarts.init(this.$refs.visitChart)
      this.updateVisitChart()
    },

    // 更新访问趋势图表
    updateVisitChart() {
      if (!this.visitChart) return

      // 准备图表数据
      const dates = this.trendData.map(item => {
        const date = new Date(item.date)
        return `${date.getMonth() + 1}月${date.getDate()}日`
      })
      const pvData = this.trendData.map(item => item.pv)
      const ipData = this.trendData.map(item => item.ip)

      const option = {
        title: {
          text: '访问趋势（最近7天）'
        },
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['PV', 'IP']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          data: dates.length > 0 ? dates : ['暂无数据']
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: 'PV',
            type: 'line',
            data: pvData.length > 0 ? pvData : [0]
          },
          {
            name: 'IP',
            type: 'line',
            data: ipData.length > 0 ? ipData : [0]
          }
        ]
      }

      this.visitChart.setOption(option)
    },
    // 处理窗口大小变化
    handleResize() {
      if (this.visitChart) this.visitChart.resize()
    }
  }
}
</script>

<style scoped>
.admin-dashboard-container {
  padding: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
  margin-bottom: 20px;
}

.stat-icon {
  font-size: 48px;
  color: #409EFF;
  margin-right: 20px;
}

.stat-info {
  flex: 1;
}

.stat-title {
  font-size: 14px;
  color: #909399;
}

.stat-value {
  font-size: 24px;
  color: #303133;
  margin-top: 5px;
}

.chart-container {
  width: 100%;
  height: 400px;
  margin-top: 20px;
}

.loading-container {
  padding: 40px;
  text-align: center;
}
</style>
