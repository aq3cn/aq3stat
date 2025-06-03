<template>
  <div class="password-container">
    <el-card>
      <div slot="header">
        <span>修改密码</span>
      </div>
      
      <el-form ref="passwordForm" :model="passwordForm" :rules="passwordRules" label-width="100px">
        <el-form-item label="当前密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" show-password></el-input>
        </el-form-item>
        
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" show-password></el-input>
        </el-form-item>
        
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password></el-input>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="changePassword">修改密码</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { changePassword } from '@/api/auth'

export default {
  name: 'ChangePassword',
  data() {
    // 自定义校验规则：确认密码
    const validateConfirmPassword = (rule, value, callback) => {
      if (value !== this.passwordForm.newPassword) {
        callback(new Error('两次输入密码不一致'))
      } else {
        callback()
      }
    }
    
    return {
      passwordForm: {
        oldPassword: '',
        newPassword: '',
        confirmPassword: ''
      },
      passwordRules: {
        oldPassword: [
          { required: true, message: '请输入当前密码', trigger: 'blur' }
        ],
        newPassword: [
          { required: true, message: '请输入新密码', trigger: 'blur' },
          { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请再次输入新密码', trigger: 'blur' },
          { validator: validateConfirmPassword, trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    ...mapGetters(['user'])
  },
  methods: {
    // 修改密码
    changePassword() {
      this.$refs.passwordForm.validate(async valid => {
        if (valid) {
          try {
            await changePassword(this.user.id, {
              old_password: this.passwordForm.oldPassword,
              new_password: this.passwordForm.newPassword
            })
            
            this.$message.success('密码修改成功，请重新登录')
            
            // 退出登录
            await this.$store.dispatch('user/logout')
            this.$router.push('/login')
          } catch (error) {
            this.$message.error('修改失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
          }
        } else {
          return false
        }
      })
    }
  }
}
</script>

<style scoped>
.password-container {
  padding: 20px;
}
</style>
