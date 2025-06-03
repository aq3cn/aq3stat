<template>
  <el-container class="container">
    <!-- 头部 -->
    <el-header>
      <div class="logo">
        <img src="@/assets/logo.svg" alt="aq3stat">
        <span>aq3stat 管理后台</span>
      </div>
      <el-dropdown @command="handleCommand">
        <span class="el-dropdown-link">
          {{ user.username }}<i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item command="home">返回前台</el-dropdown-item>
          <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </el-header>

    <el-container>
      <!-- 侧边栏 -->
      <el-aside :width="isCollapse ? '64px' : '200px'">
        <div class="toggle-button" @click="toggleCollapse">|||</div>
        <el-menu
          :default-active="activeMenu"
          :collapse="isCollapse"
          :collapse-transition="false"
          :router="true"
          background-color="#333744"
          text-color="#fff"
          active-text-color="#409EFF">
          <el-menu-item index="/admin/dashboard">
            <i class="el-icon-s-home"></i>
            <span slot="title">控制面板</span>
          </el-menu-item>
          <el-menu-item index="/admin/users">
            <i class="el-icon-user"></i>
            <span slot="title">用户管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/groups">
            <i class="el-icon-s-custom"></i>
            <span slot="title">用户组管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/websites">
            <i class="el-icon-s-grid"></i>
            <span slot="title">网站管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <!-- 主体内容 -->
      <el-main>
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'AdminLayout',
  data() {
    return {
      isCollapse: false
    }
  },
  computed: {
    ...mapGetters(['user']),
    activeMenu() {
      const { path } = this.$route
      return path
    }
  },
  methods: {
    // 切换侧边栏折叠状态
    toggleCollapse() {
      this.isCollapse = !this.isCollapse
    },
    // 处理下拉菜单命令
    handleCommand(command) {
      switch (command) {
        case 'home':
          this.$router.push('/')
          break
        case 'logout':
          this.logout()
          break
      }
    },
    // 退出登录
    async logout() {
      await this.$store.dispatch('user/logout')
      this.$router.push('/login')
      this.$message.success('已退出登录')
    }
  }
}
</script>

<style scoped>
.container {
  height: 100%;
}

.el-header {
  background-color: #373d41;
  display: flex;
  justify-content: space-between;
  padding-left: 0;
  align-items: center;
  color: #fff;
  font-size: 20px;
}

.el-header .logo {
  display: flex;
  align-items: center;
  margin-left: 15px;
}

.el-header .logo img {
  height: 40px;
  margin-right: 15px;
}

.el-dropdown-link {
  cursor: pointer;
  color: #fff;
}

.el-aside {
  background-color: #333744;
  transition: width 0.3s;
}

.toggle-button {
  background-color: #4a5064;
  font-size: 10px;
  line-height: 24px;
  color: #fff;
  text-align: center;
  letter-spacing: 0.2em;
  cursor: pointer;
}

.el-menu {
  border-right: none;
}

.el-main {
  background-color: #eaedf1;
}
</style>
