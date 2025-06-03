<template>
  <div class="profile-container">
    <el-card>
      <div slot="header">
        <span>个人资料</span>
      </div>
      
      <el-form ref="profileForm" :model="profileForm" :rules="profileRules" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="profileForm.username" disabled></el-input>
        </el-form-item>
        
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="profileForm.email"></el-input>
        </el-form-item>
        
        <el-form-item label="电话" prop="phone">
          <el-input v-model="profileForm.phone"></el-input>
        </el-form-item>
        
        <el-form-item label="地址" prop="address">
          <el-input v-model="profileForm.address" type="textarea" :rows="3"></el-input>
        </el-form-item>
        
        <el-form-item label="用户组">
          <el-input v-model="profileForm.groupTitle" disabled></el-input>
        </el-form-item>
        
        <el-form-item label="注册时间">
          <el-input v-model="profileForm.createdAt" disabled></el-input>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="updateProfile">保存修改</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { updateUser } from '@/api/auth'

export default {
  name: 'Profile',
  data() {
    return {
      profileForm: {
        username: '',
        email: '',
        phone: '',
        address: '',
        groupTitle: '',
        createdAt: ''
      },
      profileRules: {
        email: [
          { required: true, message: '请输入邮箱地址', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
        ],
        phone: [
          { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    ...mapGetters(['user'])
  },
  created() {
    this.initProfileForm()
  },
  methods: {
    // 初始化表单数据
    initProfileForm() {
      if (this.user) {
        this.profileForm = {
          username: this.user.username,
          email: this.user.email,
          phone: this.user.phone || '',
          address: this.user.address || '',
          groupTitle: this.user.group ? this.user.group.title : '',
          createdAt: new Date(this.user.created_at).toLocaleString()
        }
      }
    },
    // 更新个人资料
    updateProfile() {
      this.$refs.profileForm.validate(async valid => {
        if (valid) {
          try {
            await updateUser(this.user.id, {
              email: this.profileForm.email,
              phone: this.profileForm.phone,
              address: this.profileForm.address
            })
            
            // 更新本地用户信息
            await this.$store.dispatch('user/getInfo')
            
            this.$message.success('个人资料更新成功')
          } catch (error) {
            this.$message.error('更新失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
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
.profile-container {
  padding: 20px;
}
</style>
