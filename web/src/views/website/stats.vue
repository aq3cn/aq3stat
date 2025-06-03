<template>
  <div class="website-stats-container">
    <el-card>
      <div slot="header">
        <span>{{ website ? website.name : '网站' }}统计数据</span>
      </div>

      <div v-if="loading" class="loading-container">
        <el-skeleton :rows="10" animated />
      </div>
      <div v-else>
        <!-- 网站不存在提示 -->
        <div v-if="websiteNotFound" class="no-data">
          <el-alert
            title="网站不存在"
            description="您访问的网站不存在或已被删除，请检查网站ID是否正确。"
            type="error"
            show-icon
            :closable="false">
          </el-alert>
          <div style="margin-top: 20px; text-align: center;">
            <el-button type="primary" @click="$router.push('/websites')">返回网站列表</el-button>
          </div>
        </div>

        <!-- 数据加载失败提示 -->
        <div v-else-if="!stats" class="no-data">
          <el-alert
            title="暂无统计数据"
            description="该网站还没有统计数据，请先在网站中添加统计代码并等待访问数据。"
            type="info"
            show-icon
            :closable="false">
          </el-alert>
        </div>

        <!-- 数据概览 -->
        <div v-else>
          <div class="data-overview">
            <el-card class="data-card">
              <div class="data-title">今日IP</div>
              <div class="data-value">{{ stats.today_ip_count }}</div>
              <div class="data-compare">
                昨日：{{ stats.yesterday_ip_count }}
                <span :class="compareClass(stats.today_ip_count, stats.yesterday_ip_count)">
                  {{ comparePercent(stats.today_ip_count, stats.yesterday_ip_count) }}
                </span>
              </div>
            </el-card>

            <el-card class="data-card">
              <div class="data-title">今日PV</div>
              <div class="data-value">{{ stats.today_pv_count }}</div>
              <div class="data-compare">
                昨日：{{ stats.yesterday_pv_count }}
                <span :class="compareClass(stats.today_pv_count, stats.yesterday_pv_count)">
                  {{ comparePercent(stats.today_pv_count, stats.yesterday_pv_count) }}
                </span>
              </div>
            </el-card>

            <el-card class="data-card">
              <div class="data-title">当前在线</div>
              <div class="data-value">{{ stats.online_visitors_5min }}</div>
              <div class="data-compare">
                1分钟内：{{ stats.online_visitors_1min }}
                15分钟内：{{ stats.online_visitors_15min }}
              </div>
            </el-card>

            <el-card class="data-card">
              <div class="data-title">新访客</div>
              <div class="data-value">{{ stats.new_visitors }}</div>
              <div class="data-compare">
                回访：{{ stats.returning_visitors }}
                <span>{{ newVisitorPercent }}%</span>
              </div>
            </el-card>
          </div>

          <!-- 统计图表 -->
          <el-tabs v-model="activeTab">
            <el-tab-pane label="访问趋势" name="trend">
              <div class="chart-container" ref="trendChart"></div>
            </el-tab-pane>

            <el-tab-pane label="访问来源" name="source">
              <div class="chart-container" ref="sourceChart"></div>
            </el-tab-pane>

            <el-tab-pane label="访问设备" name="device">
              <div class="chart-container" ref="deviceChart"></div>
            </el-tab-pane>
          </el-tabs>

          <!-- 统计数据表格 -->
          <el-table :data="statsTableData" style="width: 100%; margin-top: 20px" border>
            <el-table-column prop="name" label="时间段" width="180"></el-table-column>
            <el-table-column prop="ip" label="IP数"></el-table-column>
            <el-table-column prop="pv" label="PV数"></el-table-column>
            <el-table-column prop="avg_ip" label="日均IP"></el-table-column>
            <el-table-column prop="avg_pv" label="日均PV"></el-table-column>
          </el-table>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script>
import { getWebsite, getWebsiteStats } from '@/api/website'

export default {
  name: 'WebsiteStats',
  data() {
    return {
      loading: true,
      websiteId: null,
      website: null,
      stats: null,
      activeTab: 'trend',
      trendChart: null,
      sourceChart: null,
      deviceChart: null,
      websiteNotFound: false
    }
  },
  computed: {
    // 新访客百分比
    newVisitorPercent() {
      if (!this.stats) return 0
      const total = this.stats.new_visitors + this.stats.returning_visitors
      if (total === 0) return 0
      return Math.round((this.stats.new_visitors / total) * 100)
    },
    // 统计数据表格
    statsTableData() {
      if (!this.stats) return []
      return [
        {
          name: '今日',
          ip: this.stats.today_ip_count,
          pv: this.stats.today_pv_count,
          avg_ip: this.stats.today_ip_count,
          avg_pv: this.stats.today_pv_count
        },
        {
          name: '昨日',
          ip: this.stats.yesterday_ip_count,
          pv: this.stats.yesterday_pv_count,
          avg_ip: this.stats.yesterday_ip_count,
          avg_pv: this.stats.yesterday_pv_count
        },
        {
          name: '本周',
          ip: this.stats.this_week_ip_count,
          pv: this.stats.this_week_pv_count,
          avg_ip: Math.round(this.stats.this_week_ip_count / 7),
          avg_pv: Math.round(this.stats.this_week_pv_count / 7)
        },
        {
          name: '上周',
          ip: this.stats.last_week_ip_count,
          pv: this.stats.last_week_pv_count,
          avg_ip: Math.round(this.stats.last_week_ip_count / 7),
          avg_pv: Math.round(this.stats.last_week_pv_count / 7)
        },
        {
          name: '本月',
          ip: this.stats.this_month_ip_count,
          pv: this.stats.this_month_pv_count,
          avg_ip: Math.round(this.stats.this_month_ip_count / 30),
          avg_pv: Math.round(this.stats.this_month_pv_count / 30)
        },
        {
          name: '总计',
          ip: this.stats.total_ip_count,
          pv: this.stats.total_pv_count,
          avg_ip: Math.round(this.stats.avg_daily_ip_count),
          avg_pv: Math.round(this.stats.avg_daily_pv_count)
        }
      ]
    }
  },
  created() {
    this.websiteId = parseInt(this.$route.params.id)
    console.log('WebsiteStats created, websiteId:', this.websiteId)
    console.log('ECharts available:', !!this.$echarts)
    this.getWebsiteData()
  },
  watch: {
    // 监听 activeTab 变化，重绘当前显示的图表
    activeTab(newTab) {
      this.$nextTick(() => {
        setTimeout(() => {
          if (newTab === 'trend' && this.trendChart) {
            this.trendChart.resize()
          } else if (newTab === 'source' && this.sourceChart) {
            this.sourceChart.resize()
          } else if (newTab === 'device' && this.deviceChart) {
            this.deviceChart.resize()
          }
        }, 100)
      })
    }
  },
  methods: {
    // 获取网站数据
    async getWebsiteData() {
      this.loading = true

      try {
        // 获取网站信息
        const websiteResponse = await getWebsite(this.websiteId)
        this.website = websiteResponse

        // 获取统计数据
        const statsResponse = await getWebsiteStats(this.websiteId)
        console.log('Stats response:', statsResponse)

        // 确保所有必要的字段都存在，如果不存在则设置默认值
        this.stats = {
          today_ip_count: (statsResponse && statsResponse.today_ip_count) || 0,
          today_pv_count: (statsResponse && statsResponse.today_pv_count) || 0,
          yesterday_ip_count: (statsResponse && statsResponse.yesterday_ip_count) || 0,
          yesterday_pv_count: (statsResponse && statsResponse.yesterday_pv_count) || 0,
          this_week_ip_count: (statsResponse && statsResponse.this_week_ip_count) || 0,
          this_week_pv_count: (statsResponse && statsResponse.this_week_pv_count) || 0,
          last_week_ip_count: (statsResponse && statsResponse.last_week_ip_count) || 0,
          last_week_pv_count: (statsResponse && statsResponse.last_week_pv_count) || 0,
          this_month_ip_count: (statsResponse && statsResponse.this_month_ip_count) || 0,
          this_month_pv_count: (statsResponse && statsResponse.this_month_pv_count) || 0,
          total_ip_count: (statsResponse && statsResponse.total_ip_count) || 0,
          total_pv_count: (statsResponse && statsResponse.total_pv_count) || 0,
          avg_daily_ip_count: (statsResponse && statsResponse.avg_daily_ip_count) || 0,
          avg_daily_pv_count: (statsResponse && statsResponse.avg_daily_pv_count) || 0,
          avg_weekly_ip_count: (statsResponse && statsResponse.avg_weekly_ip_count) || 0,
          avg_weekly_pv_count: (statsResponse && statsResponse.avg_weekly_pv_count) || 0,
          avg_monthly_ip_count: (statsResponse && statsResponse.avg_monthly_ip_count) || 0,
          avg_monthly_pv_count: (statsResponse && statsResponse.avg_monthly_pv_count) || 0,
          online_visitors_1min: (statsResponse && statsResponse.online_visitors_1min) || 0,
          online_visitors_5min: (statsResponse && statsResponse.online_visitors_5min) || 0,
          online_visitors_15min: (statsResponse && statsResponse.online_visitors_15min) || 0,
          new_visitors: (statsResponse && statsResponse.new_visitors) || 0,
          returning_visitors: (statsResponse && statsResponse.returning_visitors) || 0,
          days_since_start: (statsResponse && statsResponse.days_since_start) || 1
        }
      } catch (error) {
        console.error('获取统计数据失败:', error)

        let errorMessage = '未知错误'

        if (error.response) {
          // 服务器返回了错误响应
          if (error.response.status === 404) {
            this.websiteNotFound = true
            errorMessage = '网站不存在或已被删除'
          } else if (error.response.status === 403) {
            errorMessage = '没有权限访问该网站的统计数据'
          } else if (error.response.status === 401) {
            errorMessage = '登录已过期，请重新登录'
          } else if (error.response.data && error.response.data.error) {
            errorMessage = error.response.data.error
          } else {
            errorMessage = `服务器错误 (${error.response.status})`
          }
        } else if (error.request) {
          // 请求发送了但没有收到响应
          errorMessage = '网络连接失败，请检查网络连接'
        } else {
          // 其他错误
          errorMessage = error.message || '请求配置错误'
        }

        this.$message.error('获取数据失败：' + errorMessage)

        // 即使请求失败，也提供默认的统计数据结构
        this.stats = {
          today_ip_count: 0,
          today_pv_count: 0,
          yesterday_ip_count: 0,
          yesterday_pv_count: 0,
          this_week_ip_count: 0,
          this_week_pv_count: 0,
          last_week_ip_count: 0,
          last_week_pv_count: 0,
          this_month_ip_count: 0,
          this_month_pv_count: 0,
          total_ip_count: 0,
          total_pv_count: 0,
          avg_daily_ip_count: 0,
          avg_daily_pv_count: 0,
          avg_weekly_ip_count: 0,
          avg_weekly_pv_count: 0,
          avg_monthly_ip_count: 0,
          avg_monthly_pv_count: 0,
          online_visitors_1min: 0,
          online_visitors_5min: 0,
          online_visitors_15min: 0,
          new_visitors: 0,
          returning_visitors: 0,
          days_since_start: 1
        }
      } finally {
        this.loading = false
        // 确保 loading 状态更新后，DOM 完全渲染后再初始化图表
        this.$nextTick(() => {
          // 再次使用 nextTick 确保 v-else 块已经渲染
          this.$nextTick(() => {
            // 延迟一点时间确保 DOM 元素完全可用
            setTimeout(() => {
              this.initCharts()
            }, 200)
          })
        })
      }
    },
    // 初始化图表
    initCharts() {
      try {
        this.initTrendChart()
        this.initSourceChart()
        this.initDeviceChart()
      } catch (error) {
        console.error('图表初始化失败:', error)
        // 如果初始化失败，尝试重试
        setTimeout(() => {
          this.retryInitCharts()
        }, 500)
      }
    },
    // 重试初始化图表
    retryInitCharts() {
      try {
        if (!this.trendChart && this.$refs.trendChart) {
          this.initTrendChart()
        }
        if (!this.sourceChart && this.$refs.sourceChart) {
          this.initSourceChart()
        }
        if (!this.deviceChart && this.$refs.deviceChart) {
          this.initDeviceChart()
        }
      } catch (error) {
        console.error('图表重试初始化失败:', error)
      }
    },
    // 初始化趋势图表
    initTrendChart() {
      if (!this.stats) {
        console.warn('Stats data not available for trend chart')
        return
      }

      // 检查 DOM 元素是否存在
      if (!this.$refs.trendChart) {
        console.warn('trendChart DOM element not found')
        return
      }

      // 检查 ECharts 是否可用
      if (!this.$echarts) {
        console.error('ECharts not available')
        return
      }

      try {
        this.trendChart = this.$echarts.init(this.$refs.trendChart)
      } catch (error) {
        console.error('Failed to initialize trend chart:', error)
        return
      }

      const option = {
        title: {
          text: '访问趋势'
        },
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['IP', 'PV']
        },
        xAxis: {
          type: 'category',
          data: ['上周', '本周', '昨日', '今日']
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: 'IP',
            type: 'line',
            data: [
              this.stats.last_week_ip_count,
              this.stats.this_week_ip_count,
              this.stats.yesterday_ip_count,
              this.stats.today_ip_count
            ]
          },
          {
            name: 'PV',
            type: 'line',
            data: [
              this.stats.last_week_pv_count,
              this.stats.this_week_pv_count,
              this.stats.yesterday_pv_count,
              this.stats.today_pv_count
            ]
          }
        ]
      }

      this.trendChart.setOption(option)
    },
    // 初始化来源图表（模拟数据）
    initSourceChart() {
      // 检查 DOM 元素是否存在
      if (!this.$refs.sourceChart) {
        console.warn('sourceChart DOM element not found')
        return
      }

      // 检查 ECharts 是否可用
      if (!this.$echarts) {
        console.error('ECharts not available')
        return
      }

      try {
        this.sourceChart = this.$echarts.init(this.$refs.sourceChart)
      } catch (error) {
        console.error('Failed to initialize source chart:', error)
        return
      }

      const option = {
        title: {
          text: '访问来源'
        },
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
          orient: 'vertical',
          left: 10,
          data: ['直接访问', '搜索引擎', '外部链接', '社交媒体', '其他']
        },
        series: [
          {
            name: '访问来源',
            type: 'pie',
            radius: ['50%', '70%'],
            avoidLabelOverlap: false,
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: '30',
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: false
            },
            data: [
              { value: 335, name: '直接访问' },
              { value: 310, name: '搜索引擎' },
              { value: 234, name: '外部链接' },
              { value: 135, name: '社交媒体' },
              { value: 1548, name: '其他' }
            ]
          }
        ]
      }

      this.sourceChart.setOption(option)
    },
    // 初始化设备图表（模拟数据）
    initDeviceChart() {
      // 检查 DOM 元素是否存在
      if (!this.$refs.deviceChart) {
        console.warn('deviceChart DOM element not found')
        return
      }

      // 检查 ECharts 是否可用
      if (!this.$echarts) {
        console.error('ECharts not available')
        return
      }

      try {
        this.deviceChart = this.$echarts.init(this.$refs.deviceChart)
      } catch (error) {
        console.error('Failed to initialize device chart:', error)
        return
      }

      const option = {
        title: {
          text: '访问设备'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        legend: {
          data: ['PC', '移动设备', '平板']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'value',
          boundaryGap: [0, 0.01]
        },
        yAxis: {
          type: 'category',
          data: ['今日', '昨日', '本周', '上周']
        },
        series: [
          {
            name: 'PC',
            type: 'bar',
            data: [320, 302, 1200, 1000]
          },
          {
            name: '移动设备',
            type: 'bar',
            data: [120, 132, 500, 400]
          },
          {
            name: '平板',
            type: 'bar',
            data: [60, 72, 200, 150]
          }
        ]
      }

      this.deviceChart.setOption(option)
    },
    // 比较两个数值的百分比变化
    comparePercent(current, previous) {
      if (previous === 0) return current > 0 ? '+100%' : '0%'
      const percent = ((current - previous) / previous * 100).toFixed(2)
      return percent > 0 ? `+${percent}%` : `${percent}%`
    },
    // 比较两个数值的样式类
    compareClass(current, previous) {
      if (current > previous) return 'up'
      if (current < previous) return 'down'
      return ''
    },
    // 处理窗口大小变化
    handleResize() {
      if (this.trendChart) this.trendChart.resize()
      if (this.sourceChart) this.sourceChart.resize()
      if (this.deviceChart) this.deviceChart.resize()
    }
  },
  // 窗口大小变化时重绘图表
  mounted() {
    window.addEventListener('resize', this.handleResize)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize)
    // 销毁图表实例，释放内存
    if (this.trendChart) {
      this.trendChart.dispose()
      this.trendChart = null
    }
    if (this.sourceChart) {
      this.sourceChart.dispose()
      this.sourceChart = null
    }
    if (this.deviceChart) {
      this.deviceChart.dispose()
      this.deviceChart = null
    }
  }
}
</script>

<style scoped>
.website-stats-container {
  padding: 20px;
}

.loading-container {
  padding: 20px 0;
}

.no-data {
  padding: 40px 20px;
  text-align: center;
}

.data-overview {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 20px;
}

.data-card {
  flex: 1;
  min-width: 200px;
  margin-right: 20px;
  margin-bottom: 20px;
}

.data-card:last-child {
  margin-right: 0;
}

.data-card .data-title {
  font-size: 14px;
  color: #909399;
}

.data-card .data-value {
  font-size: 24px;
  color: #303133;
  margin: 10px 0;
}

.data-card .data-compare {
  font-size: 12px;
  color: #909399;
}

.data-card .data-compare .up {
  color: #f56c6c;
}

.data-card .data-compare .down {
  color: #67c23a;
}

.chart-container {
  width: 100%;
  height: 400px;
}

@media screen and (max-width: 768px) {
  .data-card {
    min-width: 100%;
    margin-right: 0;
  }
}
</style>
