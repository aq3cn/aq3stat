<template>
  <div class="users-container">
    <el-card>
      <div slot="header">
        <span>用户管理</span>
      </div>

      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="请输入用户名"></el-input>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="searchForm.email" placeholder="请输入邮箱"></el-input>
        </el-form-item>
        <el-form-item label="用户组">
          <el-select v-model="searchForm.groupId" placeholder="请选择用户组">
            <el-option label="全部" value=""></el-option>
            <el-option v-for="group in groups" :key="group.id" :label="group.title" :value="group.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchUsers">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="users" style="width: 100%" border>
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="username" label="用户名" width="120"></el-table-column>
        <el-table-column prop="email" label="邮箱"></el-table-column>
        <el-table-column prop="group.title" label="用户组" width="120"></el-table-column>
        <el-table-column prop="created_at" label="注册时间" width="180">
          <template slot-scope="scope">
            {{ new Date(scope.row.created_at).toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              @click="editUser(scope.row)">编辑</el-button>
            <el-button
              size="mini"
              type="warning"
              @click="resetPassword(scope.row)">重置密码</el-button>
            <el-button
              size="mini"
              type="danger"
              @click="deleteUser(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="pagination.page"
        :page-sizes="[10, 20, 50, 100]"
        :page-size="pagination.pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="pagination.total">
      </el-pagination>

      <!-- 编辑用户对话框 -->
      <el-dialog title="编辑用户" :visible.sync="editDialogVisible" width="500px">
        <el-form :model="editForm" :rules="editRules" ref="editForm" label-width="100px">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="editForm.username" disabled></el-input>
          </el-form-item>
          <el-form-item label="邮箱" prop="email">
            <el-input v-model="editForm.email"></el-input>
          </el-form-item>
          <el-form-item label="用户组" prop="groupId">
            <el-select v-model="editForm.groupId" placeholder="请选择用户组">
              <el-option v-for="group in groups" :key="group.id" :label="group.title" :value="group.id"></el-option>
            </el-select>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="updateUser">确定</el-button>
        </div>
      </el-dialog>

      <!-- 重置密码对话框 -->
      <el-dialog title="重置密码" :visible.sync="passwordDialogVisible" width="400px">
        <el-form :model="passwordForm" :rules="passwordRules" ref="passwordForm" label-width="100px">
          <el-form-item label="用户名">
            <el-input v-model="passwordForm.username" disabled></el-input>
          </el-form-item>
          <el-form-item label="新密码" prop="newPassword">
            <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="请输入新密码"></el-input>
          </el-form-item>
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input v-model="passwordForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码"></el-input>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="passwordDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="confirmResetPassword">确定</el-button>
        </div>
      </el-dialog>
    </el-card>
  </div>
</template>

<script>
import { getUsers, deleteUser, updateUserByAdmin, resetUserPassword, getGroups } from '@/api/admin'

export default {
  name: 'UserManagement',
  data() {
    return {
      searchForm: {
        username: '',
        email: '',
        groupId: ''
      },
      users: [],
      groups: [],
      pagination: {
        page: 1,
        pageSize: 10,
        total: 0
      },
      editDialogVisible: false,
      editForm: {
        id: null,
        username: '',
        email: '',
        groupId: null
      },
      editRules: {
        email: [
          { required: true, message: '请输入邮箱地址', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
        ],
        groupId: [
          { required: true, message: '请选择用户组', trigger: 'change' }
        ]
      },
      passwordDialogVisible: false,
      passwordForm: {
        id: null,
        username: '',
        newPassword: '',
        confirmPassword: ''
      },
      passwordRules: {
        newPassword: [
          { required: true, message: '请输入新密码', trigger: 'blur' },
          { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请再次输入新密码', trigger: 'blur' },
          { validator: this.validateConfirmPassword, trigger: 'blur' }
        ]
      }
    }
  },
  created() {
    this.getGroups()
    this.getUsers()
  },
  methods: {
    // 自定义校验规则：确认密码
    validateConfirmPassword(rule, value, callback) {
      if (value !== this.passwordForm.newPassword) {
        callback(new Error('两次输入密码不一致'))
      } else {
        callback()
      }
    },
    // 获取用户组列表
    async getGroups() {
      try {
        const response = await getGroups()
        this.groups = response
      } catch (error) {
        this.$message.error('获取用户组失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      }
    },
    // 获取用户列表
    async getUsers() {
      try {
        const response = await getUsers(this.pagination.page, this.pagination.pageSize)
        this.users = response.users
        this.pagination.total = response.total
      } catch (error) {
        this.$message.error('获取用户列表失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      }
    },
    // 搜索用户
    searchUsers() {
      this.pagination.page = 1
      this.getUsers()
    },
    // 重置搜索
    resetSearch() {
      this.searchForm = {
        username: '',
        email: '',
        groupId: ''
      }
      this.searchUsers()
    },
    // 编辑用户
    editUser(user) {
      this.editForm = {
        id: user.id,
        username: user.username,
        email: user.email,
        groupId: user.group_id
      }
      this.editDialogVisible = true
    },
    // 更新用户
    updateUser() {
      this.$refs.editForm.validate(async valid => {
        if (valid) {
          try {
            await updateUserByAdmin(this.editForm.id, {
              email: this.editForm.email,
              group_id: this.editForm.groupId
            })
            this.$message.success('更新成功')
            this.editDialogVisible = false
            this.getUsers()
          } catch (error) {
            this.$message.error('更新失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
          }
        } else {
          return false
        }
      })
    },
    // 重置密码
    resetPassword(user) {
      this.passwordForm = {
        id: user.id,
        username: user.username,
        newPassword: '',
        confirmPassword: ''
      }
      this.passwordDialogVisible = true
    },
    // 确认重置密码
    confirmResetPassword() {
      this.$refs.passwordForm.validate(async valid => {
        if (valid) {
          try {
            await resetUserPassword(this.passwordForm.id, {
              new_password: this.passwordForm.newPassword
            })
            this.$message.success('密码重置成功')
            this.passwordDialogVisible = false
            // 清空表单
            this.passwordForm = {
              id: null,
              username: '',
              newPassword: '',
              confirmPassword: ''
            }
          } catch (error) {
            this.$message.error('重置失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
          }
        } else {
          return false
        }
      })
    },
    // 删除用户
    deleteUser(user) {
      this.$confirm(`确认删除用户 ${user.username}?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          await deleteUser(user.id)
          this.$message.success('删除成功')
          this.getUsers()
        } catch (error) {
          this.$message.error('删除失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
        }
      }).catch(() => {
        this.$message.info('已取消删除')
      })
    },
    // 处理每页显示数量变化
    handleSizeChange(val) {
      this.pagination.pageSize = val
      this.getUsers()
    },
    // 处理页码变化
    handleCurrentChange(val) {
      this.pagination.page = val
      this.getUsers()
    }
  }
}
</script>

<style scoped>
.users-container {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}

.el-pagination {
  margin-top: 20px;
  text-align: right;
}
</style>
