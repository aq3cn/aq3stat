<template>
  <div v-if="loading" class="loading-container">
    <div class="loading-wrapper">
      <div class="loading-spinner">
        <i class="el-icon-loading"></i>
      </div>
      <div class="loading-text">{{ text }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Loading',
  props: {
    loading: {
      type: Boolean,
      default: false
    },
    text: {
      type: String,
      default: '加载中...'
    }
  }
}
</script>

<style scoped>
.loading-container {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.7);
  z-index: 9999;
  display: flex;
  justify-content: center;
  align-items: center;
}

.loading-wrapper {
  background-color: rgba(0, 0, 0, 0.7);
  padding: 20px;
  border-radius: 5px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.loading-spinner {
  font-size: 32px;
  color: #fff;
}

.loading-text {
  margin-top: 10px;
  color: #fff;
  font-size: 14px;
}
</style>
