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
    window.addEventListener('resize', this.handleResize)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize)
    if (this.visitChart) {
      this.visitChart.dispose()
      this.visitChart = null
    }
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

        // 初始化并更新图表
        this.$nextTick(() => {
          this.initVisitChart()
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
      if (!this.$refs.visitChart) {
        return
      }

      if (!this.$echarts) {
        return
      }

      try {
        // 如果图表已存在，先销毁
        if (this.visitChart) {
          this.visitChart.dispose()
        }

        this.visitChart = this.$echarts.init(this.$refs.visitChart)
        this.updateVisitChart()
      } catch (error) {
        console.error('图表初始化失败:', error)
      }
    },

    // 更新访问趋势图表
    updateVisitChart() {
      console.log('更新图表数据...')
      console.log('图表实例:', this.visitChart)

      if (!this.visitChart) {
        console.error('图表实例不存在')
        return
      }

      // 准备图表数据
      console.log('原始趋势数据:', this.trendData)

      const dates = this.trendData.map(item => {
        const date = new Date(item.date)
        return `${date.getMonth() + 1}月${date.getDate()}日`
      })
      const pvData = this.trendData.map(item => item.pv)
      const ipData = this.trendData.map(item => item.ip)

      console.log('处理后的数据:', { dates, pvData, ipData })

      const option = {
        title: {
          text: '访问趋势（最近7天）',
          left: 'center'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'cross'
          }
        },
        legend: {
          data: ['PV', 'IP'],
          top: 30
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          top: '15%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          data: dates.length > 0 ? dates : ['暂无数据']
        },
        yAxis: {
          type: 'value',
          min: 0
        },
        series: [
          {
            name: 'PV',
            type: 'line',
            smooth: true,
            symbol: 'circle',
            symbolSize: 6,
            lineStyle: {
              color: '#409EFF',
              width: 2
            },
            areaStyle: {
              color: {
                type: 'linear',
                x: 0,
                y: 0,
                x2: 0,
                y2: 1,
                colorStops: [{
                  offset: 0, color: 'rgba(64, 158, 255, 0.3)'
                }, {
                  offset: 1, color: 'rgba(64, 158, 255, 0.1)'
                }]
              }
            },
            data: pvData.length > 0 ? pvData : [0]
          },
          {
            name: 'IP',
            type: 'line',
            smooth: true,
            symbol: 'circle',
            symbolSize: 6,
            lineStyle: {
              color: '#67C23A',
              width: 2
            },
            areaStyle: {
              color: {
                type: 'linear',
                x: 0,
                y: 0,
                x2: 0,
                y2: 1,
                colorStops: [{
                  offset: 0, color: 'rgba(103, 194, 58, 0.3)'
                }, {
                  offset: 1, color: 'rgba(103, 194, 58, 0.1)'
                }]
              }
            },
            data: ipData.length > 0 ? ipData : [0]
          }
        ]
      }

      console.log('图表配置:', option)

      try {
        this.visitChart.setOption(option, true)
        console.log('图表配置设置成功')
      } catch (error) {
        console.error('设置图表配置失败:', error)
      }
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
