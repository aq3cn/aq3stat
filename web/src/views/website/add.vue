<template>
  <div class="add-website-container">
    <el-card>
      <div slot="header">
        <span>添加网站</span>
      </div>
      
      <el-form ref="websiteForm" :model="websiteForm" :rules="websiteRules" label-width="100px">
        <el-form-item label="网站名称" prop="name">
          <el-input v-model="websiteForm.name" placeholder="请输入网站名称"></el-input>
        </el-form-item>
        
        <el-form-item label="网站地址" prop="url">
          <el-input v-model="websiteForm.url" placeholder="请输入网站地址，以http://或https://开头"></el-input>
        </el-form-item>
        
        <el-form-item label="网站描述" prop="description">
          <el-input v-model="websiteForm.description" type="textarea" :rows="3" placeholder="请输入网站描述"></el-input>
        </el-form-item>
        
        <el-form-item label="是否公开">
          <el-switch v-model="websiteForm.is_public"></el-switch>
          <span class="tips">公开后，其他用户可以查看您的网站统计数据</span>
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
import { createWebsite } from '@/api/website'

export default {
  name: 'AddWebsite',
  data() {
    return {
      websiteForm: {
        name: '',
        url: '',
        description: '',
        is_public: false
      },
      websiteRules: {
        name: [
          { required: true, message: '请输入网站名称', trigger: 'blur' },
          { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
        ],
        url: [
          { required: true, message: '请输入网站地址', trigger: 'blur' },
          { pattern: /^https?:\/\//, message: '网站地址必须以http://或https://开头', trigger: 'blur' }
        ],
        description: [
          { max: 255, message: '长度不能超过 255 个字符', trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    // 提交表单
    submitForm() {
      this.$refs.websiteForm.validate(async valid => {
        if (valid) {
          try {
            await createWebsite(this.websiteForm)
            this.$message.success('添加成功')
            this.$router.push('/websites')
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
      this.$router.push('/websites')
    }
  }
}
</script>

<style scoped>
.add-website-container {
  padding: 20px;
}

.tips {
  font-size: 12px;
  color: #909399;
  margin-left: 10px;
}
</style>
