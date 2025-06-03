<template>
  <div class="add-group-container">
    <el-card>
      <div slot="header">
        <span>添加用户组</span>
      </div>
      
      <el-form ref="groupForm" :model="groupForm" :rules="groupRules" label-width="150px">
        <el-form-item label="用户组名称" prop="title">
          <el-input v-model="groupForm.title" placeholder="请输入用户组名称"></el-input>
        </el-form-item>
        
        <el-form-item label="管理员权限">
          <el-switch v-model="groupForm.is_admin"></el-switch>
          <span class="tips">拥有管理员权限的用户可以访问管理后台</span>
        </el-form-item>
        
        <el-form-item label="网站管理权限">
          <el-switch v-model="groupForm.site_admin"></el-switch>
          <span class="tips">拥有网站管理权限的用户可以管理自己的网站</span>
        </el-form-item>
        
        <el-form-item label="用户管理权限">
          <el-switch v-model="groupForm.user_admin"></el-switch>
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
          <el-switch v-model="groupForm.admin_website"></el-switch>
          <span class="tips">拥有此权限的用户可以管理所有网站</span>
        </el-form-item>
        
        <el-form-item label="隐藏统计图标">
          <el-switch v-model="groupForm.hide_icon"></el-switch>
          <span class="tips">拥有此权限的用户可以隐藏统计图标</span>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="submitForm">立即创建</el-button>
          <el-button @click="cancel">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { createGroup } from '@/api/admin'

export default {
  name: 'AddGroup',
  data() {
    return {
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
  methods: {
    // 提交表单
    submitForm() {
      this.$refs.groupForm.validate(async valid => {
        if (valid) {
          try {
            await createGroup(this.groupForm)
            this.$message.success('添加成功')
            this.$router.push('/admin/groups')
          } catch (error) {
            this.$message.error('添加失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
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
.add-group-container {
  padding: 20px;
}

.tips {
  font-size: 12px;
  color: #909399;
  margin-left: 10px;
}
</style>
