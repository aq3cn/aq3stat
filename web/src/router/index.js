import Vue from 'vue'
import VueRouter from 'vue-router'
import { getToken } from '@/utils/auth'
import store from '@/store'

Vue.use(VueRouter)

// 路由配置
const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index'),
    meta: { title: '登录' }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/register/index'),
    meta: { title: '注册' }
  },
  {
    path: '/',
    component: () => import('@/views/layout/index'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index'),
        meta: { title: '控制面板', requireAuth: true }
      },
      {
        path: 'websites',
        name: 'Websites',
        component: () => import('@/views/website/index'),
        meta: { title: '我的网站', requireAuth: true }
      },
      {
        path: 'websites/add',
        name: 'AddWebsite',
        component: () => import('@/views/website/add'),
        meta: { title: '添加网站', requireAuth: true }
      },
      {
        path: 'websites/edit/:id',
        name: 'EditWebsite',
        component: () => import('@/views/website/edit'),
        meta: { title: '编辑网站', requireAuth: true }
      },
      {
        path: 'websites/:id',
        name: 'WebsiteDetail',
        component: () => import('@/views/website/detail'),
        meta: { title: '网站详情', requireAuth: true }
      },
      {
        path: 'websites/:id/stats',
        name: 'WebsiteStats',
        component: () => import('@/views/website/stats'),
        meta: { title: '网站统计', requireAuth: true }
      },
      {
        path: 'websites/:id/code',
        name: 'TrackingCode',
        component: () => import('@/views/website/code'),
        meta: { title: '统计代码', requireAuth: true }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/profile/index'),
        meta: { title: '个人资料', requireAuth: true }
      },
      {
        path: 'password',
        name: 'Password',
        component: () => import('@/views/profile/password'),
        meta: { title: '修改密码', requireAuth: true }
      },
      {
        path: 'test-echarts',
        name: 'TestECharts',
        component: () => import('@/views/test-echarts'),
        meta: { title: 'ECharts 测试', requireAuth: true }
      }
    ]
  },
  {
    path: '/admin',
    component: () => import('@/views/layout/admin'),
    redirect: '/admin/dashboard',
    meta: { requireAuth: true, requireAdmin: true },
    children: [
      {
        path: 'dashboard',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/dashboard'),
        meta: { title: '管理控制台', requireAuth: true, requireAdmin: true }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/admin/users'),
        meta: { title: '用户管理', requireAuth: true, requireAdmin: true }
      },
      {
        path: 'groups',
        name: 'Groups',
        component: () => import('@/views/admin/groups'),
        meta: { title: '用户组管理', requireAuth: true, requireAdmin: true }
      },
      {
        path: 'groups/add',
        name: 'AddGroup',
        component: () => import('@/views/admin/groups/add'),
        meta: { title: '添加用户组', requireAuth: true, requireAdmin: true }
      },
      {
        path: 'groups/edit/:id',
        name: 'EditGroup',
        component: () => import('@/views/admin/groups/edit'),
        meta: { title: '编辑用户组', requireAuth: true, requireAdmin: true }
      },
      {
        path: 'websites',
        name: 'AdminWebsites',
        component: () => import('@/views/admin/websites'),
        meta: { title: '网站管理', requireAuth: true, requireAdmin: true }
      }
    ]
  },
  {
    path: '/404',
    component: () => import('@/views/error/404'),
    meta: { title: '404' }
  },
  {
    path: '*',
    redirect: '/404'
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

// 全局前置守卫
router.beforeEach(async (to, from, next) => {
  // 设置页面标题
  document.title = to.meta.title ? `${to.meta.title} - aq3stat` : 'aq3stat - 专业、免费、强大的网站统计'

  // 判断该路由是否需要登录权限
  if (to.matched.some(record => record.meta.requireAuth)) {
    // 判断是否已登录
    const hasToken = getToken()
    if (hasToken) {
      // 判断是否已获取用户信息
      if (!store.getters.user) {
        try {
          // 获取用户信息
          await store.dispatch('user/getInfo')

          // 判断该路由是否需要管理员权限
          if (to.matched.some(record => record.meta.requireAdmin) && !store.getters.isAdmin) {
            next({ path: '/' })
          } else {
            next()
          }
        } catch (error) {
          // 获取用户信息失败，清除token并跳转到登录页
          await store.dispatch('user/resetToken')
          next(`/login?redirect=${to.path}`)
        }
      } else {
        // 判断该路由是否需要管理员权限
        if (to.matched.some(record => record.meta.requireAdmin) && !store.getters.isAdmin) {
          next({ path: '/' })
        } else {
          next()
        }
      }
    } else {
      // 未登录则跳转到登录页
      next(`/login?redirect=${to.path}`)
    }
  } else {
    // 不需要登录权限的路由直接放行
    next()
  }
})

export default router
