<template>
  <div class="test-echarts">
    <h2>ECharts 测试页面</h2>
    <div>ECharts 可用性: {{ echartsAvailable ? '✅ 可用' : '❌ 不可用' }}</div>
    <div>DOM 元素状态: {{ domElementStatus }}</div>
    <div>图表实例状态: {{ chartInstanceStatus }}</div>
    
    <el-button @click="testChart" type="primary">测试图表</el-button>
    <el-button @click="clearChart" type="danger">清除图表</el-button>
    
    <div ref="testChart" style="width: 600px; height: 400px; border: 1px solid #ccc; margin-top: 20px;"></div>
  </div>
</template>

<script>
export default {
  name: 'TestECharts',
  data() {
    return {
      testChartInstance: null
    }
  },
  computed: {
    echartsAvailable() {
      return !!this.$echarts
    },
    domElementStatus() {
      return this.$refs.testChart ? '✅ DOM 元素存在' : '❌ DOM 元素不存在'
    },
    chartInstanceStatus() {
      return this.testChartInstance ? '✅ 图表实例已创建' : '❌ 图表实例未创建'
    }
  },
  mounted() {
    console.log('TestECharts mounted')
    console.log('ECharts:', this.$echarts)
    console.log('DOM element:', this.$refs.testChart)
  },
  methods: {
    testChart() {
      console.log('Testing chart...')
      
      if (!this.$echarts) {
        this.$message.error('ECharts 不可用')
        return
      }
      
      if (!this.$refs.testChart) {
        this.$message.error('DOM 元素不存在')
        return
      }
      
      try {
        this.testChartInstance = this.$echarts.init(this.$refs.testChart)
        
        const option = {
          title: {
            text: '测试图表'
          },
          tooltip: {},
          xAxis: {
            data: ['A', 'B', 'C', 'D', 'E']
          },
          yAxis: {},
          series: [{
            name: '测试数据',
            type: 'bar',
            data: [5, 20, 36, 10, 10]
          }]
        }
        
        this.testChartInstance.setOption(option)
        this.$message.success('图表创建成功')
      } catch (error) {
        console.error('Chart creation failed:', error)
        this.$message.error('图表创建失败: ' + error.message)
      }
    },
    clearChart() {
      if (this.testChartInstance) {
        this.testChartInstance.dispose()
        this.testChartInstance = null
        this.$message.success('图表已清除')
      }
    }
  },
  beforeDestroy() {
    if (this.testChartInstance) {
      this.testChartInstance.dispose()
    }
  }
}
</script>

<style scoped>
.test-echarts {
  padding: 20px;
}
</style>
