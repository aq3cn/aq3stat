<template>
  <div class="register-container">
    <div class="register-box">
      <div class="register-title">
        <h3>aq3stat - 用户注册</h3>
      </div>
      <el-form ref="registerForm" :model="registerForm" :rules="registerRules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="registerForm.username" prefix-icon="el-icon-user"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="registerForm.password" prefix-icon="el-icon-lock" type="password"></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="registerForm.confirmPassword" prefix-icon="el-icon-lock" type="password"></el-input>
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="registerForm.email" prefix-icon="el-icon-message"></el-input>
        </el-form-item>
        <el-form-item class="btns">
          <el-button type="primary" @click="register">注册</el-button>
          <el-button @click="goToLogin">返回登录</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { register } from '@/api/auth'

export default {
  name: 'Register',
  data() {
    // 自定义校验规则：确认密码
    const validateConfirmPassword = (rule, value, callback) => {
      if (value !== this.registerForm.password) {
        callback(new Error('两次输入密码不一致'))
      } else {
        callback()
      }
    }
    
    return {
      registerForm: {
        username: '',
        password: '',
        confirmPassword: '',
        email: ''
      },
      registerRules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
          { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请再次输入密码', trigger: 'blur' },
          { validator: validateConfirmPassword, trigger: 'blur' }
        ],
        email: [
          { required: true, message: '请输入邮箱地址', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    register() {
      this.$refs.registerForm.validate(async valid => {
        if (valid) {
          try {
            const { username, password, email } = this.registerForm
            await register({ username, password, email })
            this.$message.success('注册成功，请登录')
            this.$router.push('/login')
          } catch (error) {
            this.$message.error('注册失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
          }
        } else {
          return false
        }
      })
    },
    goToLogin() {
      this.$router.push('/login')
    }
  }
}
</script>

<style scoped>
.register-box {
  width: 450px;
  height: 400px;
  background-color: #fff;
  border-radius: 3px;
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  padding: 0 30px;
  box-sizing: border-box;
}

.register-title {
  text-align: center;
  margin: 20px 0;
}

.btns {
  display: flex;
  justify-content: flex-end;
}
</style>
