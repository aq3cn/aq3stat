<template>
  <div class="edit-group-container">
    <el-card>
      <div slot="header">
        <span>编辑用户组</span>
      </div>
      
      <div v-if="loading" class="loading-container">
        <el-skeleton :rows="8" animated />
      </div>
      <div v-else>
        <el-form ref="groupForm" :model="groupForm" :rules="groupRules" label-width="150px">
          <el-form-item label="用户组名称" prop="title">
            <el-input v-model="groupForm.title" placeholder="请输入用户组名称" :disabled="isAdminGroup"></el-input>
          </el-form-item>
          
          <el-form-item label="管理员权限">
            <el-switch v-model="groupForm.is_admin" :disabled="isAdminGroup"></el-switch>
            <span class="tips">拥有管理员权限的用户可以访问管理后台</span>
          </el-form-item>
          
          <el-form-item label="网站管理权限">
            <el-switch v-model="groupForm.site_admin"></el-switch>
            <span class="tips">拥有网站管理权限的用户可以管理自己的网站</span>
          </el-form-item>
          
          <el-form-item label="用户管理权限">
            <el-switch v-model="groupForm.user_admin" :disabled="isAdminGroup"></el-switch>
            <span class="tips">拥有用户管理权限的用户可以管理其他用户</span>
          </el-form-item>
          
          <el-form-item label="实时统计权限">
            <el-switch v-model="groupForm.run_time_stat"></el-switch>
            <span class="tips">拥有实时统计权限的用户可以查看实时统计数据</span>
          </el-form-item>
          
          <el-form-item label="客户端统计权限">
            <el-switch v-model="groupForm.client_stat"></el-switch>
            <span class="tips">拥有客户端统计权限的用户可以查看客户端统计数据</span>
          </el-form-item>
          
          <el-form-item label="管理所有网站">
            <el-switch v-model="groupForm.admin_website" :disabled="isAdminGroup"></el-switch>
            <span class="tips">拥有此权限的用户可以管理所有网站</span>
          </el-form-item>
          
          <el-form-item label="隐藏统计图标">
            <el-switch v-model="groupForm.hide_icon"></el-switch>
            <span class="tips">拥有此权限的用户可以隐藏统计图标</span>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="submitForm">保存修改</el-button>
            <el-button @click="cancel">取消</el-button>
          </el-form-item>
        </el-form>
      </div>
    </el-card>
  </div>
</template>

<script>
import { getGroup, updateGroup } from '@/api/admin'

export default {
  name: 'EditGroup',
  data() {
    return {
      loading: true,
      groupId: null,
      groupForm: {
        title: '',
        is_admin: false,
        site_admin: true,
        user_admin: false,
        run_time_stat: true,
        client_stat: true,
        admin_website: false,
        hide_icon: false
      },
      groupRules: {
        title: [
          { required: true, message: '请输入用户组名称', trigger: 'blur' },
          { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    isAdminGroup() {
      return this.groupForm.title === 'Administrator'
    }
  },
  created() {
    this.groupId = parseInt(this.$route.params.id)
    this.getGroupData()
  },
  methods: {
    // 获取用户组数据
    async getGroupData() {
      try {
        this.loading = true
        const response = await getGroup(this.groupId)
        this.groupForm = {
          title: response.title,
          is_admin: response.is_admin,
          site_admin: response.site_admin,
          user_admin: response.user_admin,
          run_time_stat: response.run_time_stat,
          client_stat: response.client_stat,
          admin_website: response.admin_website,
          hide_icon: response.hide_icon
        }
      } catch (error) {
        this.$message.error('获取用户组数据失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      } finally {
        this.loading = false
      }
    },
    // 提交表单
    submitForm() {
      this.$refs.groupForm.validate(async valid => {
        if (valid) {
          try {
            await updateGroup(this.groupId, this.groupForm)
            this.$message.success('修改成功')
            this.$router.push('/admin/groups')
          } catch (error) {
            this.$message.error('修改失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
          }
        } else {
          return false
        }
      })
    },
    // 取消
    cancel() {
      this.$router.push('/admin/groups')
    }
  }
}
</script>

<style scoped>
.edit-group-container {
  padding: 20px;
}

.loading-container {
  padding: 20px 0;
}

.tips {
  font-size: 12px;
  color: #909399;
  margin-left: 10px;
}
</style>
