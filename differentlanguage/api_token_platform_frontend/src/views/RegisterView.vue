<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import BaseInput from '@/components/common/BaseInput.vue'
import BaseButton from '@/components/common/BaseButton.vue'

const router = useRouter()
const auth = useAuthStore()
const username = ref('')
const password = ref('')
const confirm = ref('')
const email = ref('')
const error = ref('')
const registered = ref(false)

const strength = computed(() => {
  const p = password.value; let s = 0
  if (p.length >= 6) s++
  if (p.length >= 10) s++
  if (/[A-Z]/.test(p)) s++
  if (/[0-9]/.test(p)) s++
  if (/[^A-Za-z0-9]/.test(p)) s++
  return s
})

const strengthLabel = computed(() => ['', '弱', '较弱', '一般', '较强', '强'][strength.value])
const strengthColor = computed(() => ['', 'bg-rose-500', 'bg-rose-400', 'bg-amber-400', 'bg-emerald-400', 'bg-emerald-500'][strength.value])

async function handleRegister() {
  error.value = ''
  if (!username.value || !password.value) { error.value = '请输入用户名和密码'; return }
  if (password.value !== confirm.value) { error.value = '两次输入的密码不一致'; return }
  if (password.value.length < 6) { error.value = '密码长度至少 6 位'; return }
  try {
    await auth.register(username.value, password.value, email.value || undefined)
    registered.value = true
  } catch { error.value = auth.error || '注册失败' }
}
</script>

<template>
  <div class="space-y-5">
    <div>
      <h2 class="text-xl font-bold text-white tracking-tight">创建账号</h2>
      <p class="text-sm text-base-500 mt-1">加入 TokenRelay，开始使用 AI API</p>
    </div>

    <div v-if="error" class="flex items-center gap-2.5 p-3.5 rounded-xl bg-rose-500/5 border border-rose-500/10 text-sm text-rose-400">
      <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
      {{ error }}
    </div>

    <!-- Success state -->
    <div v-if="registered" class="p-5 rounded-xl bg-emerald-500/5 border border-emerald-500/10 text-center space-y-3">
      <div class="w-14 h-14 rounded-full bg-emerald-500/10 flex items-center justify-center mx-auto">
        <svg class="w-7 h-7 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M20 6L9 17l-5-5"/></svg>
      </div>
      <h3 class="text-lg font-bold text-white">注册成功</h3>
      <p class="text-sm text-base-400 leading-relaxed">您的账号已创建，正在等待管理员审批。审批通过后即可登录使用。</p>
      <router-link to="/auth/login" class="inline-block text-sm font-semibold text-accent-400 hover:text-accent-300 transition-colors">前往登录</router-link>
    </div>

    <form v-else @submit.prevent="handleRegister" class="space-y-4">
      <BaseInput v-model="username" label="用户名" placeholder="请输入用户名" required />
      <BaseInput v-model="email" label="邮箱（可选）" type="email" placeholder="请输入邮箱" />
      <div>
        <BaseInput v-model="password" label="密码" type="password" placeholder="至少 6 位字符" required />
        <div v-if="password" class="flex items-center gap-1 mt-1.5">
          <div v-for="i in 5" :key="i" class="h-1 flex-1 rounded-full transition-colors duration-200" :class="i <= strength ? strengthColor : 'bg-white/[0.06]'" />
          <span v-if="strength > 0" class="text-[10px] font-semibold ml-1.5 text-base-500">{{ strengthLabel }}</span>
        </div>
      </div>
      <BaseInput v-model="confirm" label="确认密码" type="password" placeholder="再次输入密码" required />
      <BaseButton type="submit" block :loading="auth.loading" size="lg">注册</BaseButton>
    </form>

    <p v-if="!registered" class="text-center text-sm text-base-500">
      已有账号？
      <router-link to="/auth/login" class="text-accent-400 hover:text-accent-300 font-semibold transition-colors">立即登录</router-link>
    </p>
  </div>
</template>
