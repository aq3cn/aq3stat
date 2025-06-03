<template>
  <div class="websites-container">
    <el-card>
      <div slot="header">
        <span>网站管理</span>
      </div>
      
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="网站名称">
          <el-input v-model="searchForm.name" placeholder="请输入网站名称"></el-input>
        </el-form-item>
        <el-form-item label="网站地址">
          <el-input v-model="searchForm.url" placeholder="请输入网站地址"></el-input>
        </el-form-item>
        <el-form-item label="是否公开">
          <el-select v-model="searchForm.isPublic" placeholder="请选择">
            <el-option label="全部" value=""></el-option>
            <el-option label="公开" value="true"></el-option>
            <el-option label="私有" value="false"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchWebsites">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
      
      <el-table :data="websites" style="width: 100%" border>
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="name" label="网站名称" width="150"></el-table-column>
        <el-table-column prop="url" label="网站地址">
          <template slot-scope="scope">
            <a :href="scope.row.url" target="_blank">{{ scope.row.url }}</a>
          </template>
        </el-table-column>
        <el-table-column prop="user.username" label="所属用户" width="120"></el-table-column>
        <el-table-column prop="is_public" label="是否公开" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.is_public ? 'success' : 'info'">
              {{ scope.row.is_public ? '公开' : '私有' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180">
          <template slot-scope="scope">
            {{ new Date(scope.row.created_at).toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              @click="viewStats(scope.row.id)">查看统计</el-button>
            <el-button
              size="mini"
              type="danger"
              @click="deleteWebsite(scope.row)">删除</el-button>
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
    </el-card>
  </div>
</template>

<script>
import { getPublicWebsites, deleteWebsite } from '@/api/website'

export default {
  name: 'WebsiteManagement',
  data() {
    return {
      searchForm: {
        name: '',
        url: '',
        isPublic: ''
      },
      websites: [],
      pagination: {
        page: 1,
        pageSize: 10,
        total: 0
      }
    }
  },
  created() {
    this.getWebsites()
  },
  methods: {
    // 获取网站列表
    async getWebsites() {
      try {
        const response = await getPublicWebsites(this.pagination.page, this.pagination.pageSize)
        this.websites = response.websites
        this.pagination.total = response.total
      } catch (error) {
        this.$message.error('获取网站列表失败：' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : '未知错误'))
      }
    },
    // 搜索网站
    searchWebsites() {
      this.pagination.page = 1
      this.getWebsites()
    },
    // 重置搜索
    resetSearch() {
      this.searchForm = {
        name: '',
        url: '',
        isPublic: ''
      }
      this.searchWebsites()
    },
    // 查看统计
    viewStats(id) {
      this.$router.push(`/websites/${id}/stats`)
    },
    // 删除网站
    deleteWebsite(website) {
      this.$confirm(`确认删除网站 ${website.name}?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          await deleteWebsite(website.id)
          this.$message.success('删除成功')
          this.getWebsites()
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
      this.getWebsites()
    },
    // 处理页码变化
    handleCurrentChange(val) {
      this.pagination.page = val
      this.getWebsites()
    }
  }
}
</script>

<style scoped>
.websites-container {
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
