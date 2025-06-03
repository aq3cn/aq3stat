<template>
  <div class="edit-website-container">
    <el-card>
      <div slot="header">
        <span>编辑网站</span>
      </div>
      
      <div v-if="loading" class="loading-container">
        <el-skeleton :rows="6" animated />
      </div>
      <div v-else>
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
            <el-button type="primary" @click="submitForm">保存修改</el-button>
            <el-button @click="cancel">取消</el-button>
          </el-form-item>
        </el-form>
      </div>
    </el-card>
  </div>
</template>

<script>
import { getWebsite, updateWebsite } from '@/api/website'

export default {
  name: 'EditWebsite',
  data() {
    return {
      loading: true,
      websiteId: null,
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
  created() {
    this.websiteId = parseInt(this.$route.params.id)
    this.getWebsiteData()
  },
  methods: {
    // 获取网站数据
    async getWebsiteData() {
      try {
        this.loading = true
        const response = await getWebsite(this.websiteId)
        this.websiteForm = {
          name: response.name,
          url: response.url,
          description: response.description,
          is_public: response.is_public
        }
      } catch (error) {
        this.$message.error('获取网站数据失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      } finally {
        this.loading = false
      }
    },
    // 提交表单
    submitForm() {
      this.$refs.websiteForm.validate(async valid => {
        if (valid) {
          try {
            await updateWebsite(this.websiteId, this.websiteForm)
            this.$message.success('修改成功')
            this.$router.push('/websites')
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
      this.$router.push('/websites')
    }
  }
}
</script>

<style scoped>
.edit-website-container {
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
