<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import BaseInput from '@/components/common/BaseInput.vue'
import BaseButton from '@/components/common/BaseButton.vue'

const router = useRouter()
const auth = useAuthStore()

const username = ref('')
const password = ref('')
const error = ref('')

async function handleLogin() {
  error.value = ''
  if (!username.value || !password.value) { error.value = '请输入用户名和密码'; return }
  try {
    await auth.login(username.value, password.value)
    router.push('/playground')
  } catch { error.value = auth.error || '登录失败，请检查账号密码' }
}
</script>

<template>
  <div class="space-y-5">
    <div>
      <h2 class="text-xl font-bold text-white tracking-tight">欢迎回来</h2>
      <p class="text-sm text-base-500 mt-1">登录您的 TokenRelay 账号</p>
    </div>

    <div v-if="error" class="flex items-center gap-2.5 p-3.5 rounded-xl bg-rose-500/5 border border-rose-500/10 text-sm text-rose-400">
      <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
      {{ error }}
    </div>

    <form @submit.prevent="handleLogin" class="space-y-4">
      <BaseInput v-model="username" label="用户名" placeholder="请输入用户名" required />
      <BaseInput v-model="password" label="密码" type="password" placeholder="请输入密码" required />
      <BaseButton type="submit" block :loading="auth.loading" size="lg">登录</BaseButton>
    </form>

    <p class="text-center text-sm text-base-500">
      还没有账号？
      <router-link to="/auth/register" class="text-accent-400 hover:text-accent-300 font-semibold transition-colors">立即注册</router-link>
    </p>
  </div>
</template>
