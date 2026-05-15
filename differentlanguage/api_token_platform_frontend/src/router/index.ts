import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import AuthLayout from '@/layouts/AuthLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/auth',
    component: AuthLayout,
    children: [
      {
        path: 'login',
        name: 'Login',
        component: () => import('@/views/LoginView.vue'),
      },
      {
        path: 'register',
        name: 'Register',
        component: () => import('@/views/RegisterView.vue'),
      },
    ],
  },
  {
    path: '/',
    component: DefaultLayout,
    redirect: '/playground',
    children: [
      {
        path: 'playground',
        name: 'Playground',
        component: () => import('@/views/PlaygroundView.vue'),
      },
      {
        path: 'api-keys',
        name: 'ApiKeys',
        component: () => import('@/views/ApiKeysView.vue'),
      },
      {
        path: 'usage',
        name: 'Usage',
        component: () => import('@/views/UsageView.vue'),
      },
      {
        path: 'admin',
        name: 'Admin',
        component: () => import('@/views/AdminView.vue'),
      },
      {
        path: 'wallet',
        name: 'Wallet',
        component: () => import('@/views/WalletView.vue'),
      },
      {
        path: 'docs',
        name: 'Docs',
        component: () => import('@/views/DocsView.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  auth.initFromStorage()

  const isAuthPage = to.path.startsWith('/auth')

  if (!auth.isLoggedIn && !isAuthPage) {
    return { path: '/auth/login' }
  }

  if (auth.isLoggedIn && isAuthPage) {
    return { path: '/playground' }
  }

  if (to.path === '/admin' && !auth.isAdmin) {
    return { path: '/playground' }
  }
})

export default router
