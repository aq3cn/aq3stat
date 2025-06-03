<template>
  <div class="groups-container">
    <el-card>
      <div slot="header">
        <span>用户组管理</span>
        <el-button style="float: right; padding: 3px 0" type="text" @click="addGroup">添加用户组</el-button>
      </div>
      
      <el-table :data="groups" style="width: 100%" border>
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="title" label="用户组名称" width="150"></el-table-column>
        <el-table-column label="管理员权限" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.is_admin ? 'success' : 'info'">
              {{ scope.row.is_admin ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="网站管理权限" width="120">
          <template slot-scope="scope">
            <el-tag :type="scope.row.site_admin ? 'success' : 'info'">
              {{ scope.row.site_admin ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="用户管理权限" width="120">
          <template slot-scope="scope">
            <el-tag :type="scope.row.user_admin ? 'success' : 'info'">
              {{ scope.row.user_admin ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="实时统计权限" width="120">
          <template slot-scope="scope">
            <el-tag :type="scope.row.run_time_stat ? 'success' : 'info'">
              {{ scope.row.run_time_stat ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="客户端统计权限" width="120">
          <template slot-scope="scope">
            <el-tag :type="scope.row.client_stat ? 'success' : 'info'">
              {{ scope.row.client_stat ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              @click="editGroup(scope.row)">编辑</el-button>
            <el-button
              size="mini"
              type="danger"
              @click="deleteGroup(scope.row)"
              :disabled="scope.row.title === 'Administrator'">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { getGroups, deleteGroup } from '@/api/admin'

export default {
  name: 'GroupManagement',
  data() {
    return {
      groups: []
    }
  },
  created() {
    this.getGroups()
  },
  methods: {
    // 获取用户组列表
    async getGroups() {
      try {
        const response = await getGroups()
        this.groups = response
      } catch (error) {
        this.$message.error('获取用户组失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      }
    },
    // 添加用户组
    addGroup() {
      this.$router.push('/admin/groups/add')
    },
    // 编辑用户组
    editGroup(group) {
      this.$router.push(`/admin/groups/edit/${group.id}`)
    },
    // 删除用户组
    deleteGroup(group) {
      if (group.title === 'Administrator') {
        this.$message.warning('不能删除管理员组')
        return
      }
      
      this.$confirm(`确认删除用户组 ${group.title}?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          await deleteGroup(group.id)
          this.$message.success('删除成功')
          this.getGroups()
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
.groups-container {
  padding: 20px;
}
</style>
