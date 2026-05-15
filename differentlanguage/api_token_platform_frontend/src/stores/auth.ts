import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types/auth'
import { authApi, setAccessToken, removeAccessToken } from '@/api'
import { ApiError } from '@/api/client'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const isLoggedIn = computed(() => !!token.value && !!user.value)
  const isAdmin = computed(() => user.value?.role === 'admin' || user.value?.role === 'super_admin')
  const isSuperAdmin = computed(() => user.value?.role === 'super_admin')

  function initFromStorage() {
    const stored = localStorage.getItem('tokenrelay_access_token')
    const storedUser = localStorage.getItem('tokenrelay_user')
    if (stored && storedUser) {
      token.value = stored
      try {
        user.value = JSON.parse(storedUser)
      } catch {
        logout()
      }
    }
  }

  async function login(username: string, password: string) {
    loading.value = true
    error.value = null
    try {
      const data = await authApi.login({ username, password })
      token.value = data.access_token
      user.value = data.user
      setAccessToken(data.access_token)
      localStorage.setItem('tokenrelay_user', JSON.stringify(data.user))
    } catch (e) {
      if (e instanceof ApiError) {
        error.value = e.detail
      } else {
        error.value = '登录失败，请检查网络连接'
      }
      throw e
    } finally {
      loading.value = false
    }
  }

  async function register(username: string, password: string, email?: string) {
    loading.value = true
    error.value = null
    try {
      const data = await authApi.register({ username, password, email })
      token.value = data.access_token
      user.value = data.user
      setAccessToken(data.access_token)
      localStorage.setItem('tokenrelay_user', JSON.stringify(data.user))
    } catch (e) {
      if (e instanceof ApiError) {
        error.value = e.detail
      } else {
        error.value = '注册失败，请检查网络连接'
      }
      throw e
    } finally {
      loading.value = false
    }
  }

  function logout() {
    token.value = null
    user.value = null
    removeAccessToken()
    localStorage.removeItem('tokenrelay_user')
  }

  return {
    user,
    token,
    loading,
    error,
    isLoggedIn,
    isAdmin,
    isSuperAdmin,
    initFromStorage,
    login,
    register,
    logout,
  }
})
