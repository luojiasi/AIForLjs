<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useSettingsStore } from '@/stores/settings'

const auth = useAuthStore()
const settings = useSettingsStore()
const router = useRouter()

const dropdownOpen = ref(false)

function handleLogout() {
  dropdownOpen.value = false
  auth.logout()
  router.push('/auth/login')
}

const desktopLeft = computed(() =>
  settings.sidebarState === 'collapsed' ? '72px' : '260px'
)

const quotaPercent = auth.user
  ? Math.min(100, ((auth.user.quota_used || 0) / (auth.user.quota_total || 1)) * 100)
  : 0

const pageTitle = computed(() => {
  const name = String(router.currentRoute.value.name || '')
  const map: Record<string, string> = {
    'playground': 'AI 对话',
    'api-keys': 'API 密钥',
    'docs': 'API 文档',
    'usage': '用量统计',
    'admin': '管理后台',
  }
  return map[name] || name || '首页'
})
</script>

<template>
  <header
    class="app-header fixed top-0 right-0 h-16 z-30 flex items-center justify-between px-4 lg:px-6 transition-all duration-300 ease-out"
    :style="{ '--desktop-left': desktopLeft }"
  >
    <!-- Glass background -->
    <div class="absolute inset-0 glass bg-base-0/70 border-b border-white/[0.05]" />

    <!-- Left section -->
    <div class="relative flex items-center gap-3 lg:gap-4">
      <!-- Mobile menu toggle -->
      <button
        class="lg:hidden p-2 -ml-2 rounded-lg text-base-400 hover:text-white hover:bg-white/[0.04] transition-colors"
        @click="settings.openMobileSidebar()"
      >
        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
          <path d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
      </button>

      <!-- Page title (mobile) -->
      <span class="lg:hidden text-sm font-semibold text-white/90">{{ pageTitle }}</span>

      <!-- Breadcrumb (desktop) -->
      <nav class="hidden lg:flex items-center gap-1.5 text-sm">
        <span class="text-base-500">平台</span>
        <svg class="w-3 h-3 text-base-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <path d="M9 18l6-6-6-6"/>
        </svg>
        <span class="text-base-300 font-medium">{{ pageTitle }}</span>
      </nav>
    </div>

    <!-- Right section -->
    <div class="relative flex items-center gap-2 lg:gap-3">
      <!-- Quota indicator (compact on mobile) -->
      <div v-if="auth.user" class="hidden sm:flex items-center gap-2 px-2.5 py-1.5 rounded-full bg-white/[0.03] border border-white/[0.05]">
        <span class="text-[10px] text-base-500 font-medium tracking-wide hidden lg:inline">额度</span>
        <div class="w-14 lg:w-20 h-1 rounded-full bg-white/[0.06] overflow-hidden">
          <div
            class="h-full rounded-full bg-gradient-to-r transition-all duration-500 ease-out"
            :class="quotaPercent > 90 ? 'from-rose-500 to-rose-400' : quotaPercent > 70 ? 'from-amber-500 to-amber-400' : 'from-accent-500 to-accent-400'"
            :style="{ width: `${quotaPercent}%` }"
          />
        </div>
        <span class="text-[10px] lg:text-[11px] text-base-400 font-mono tabular-nums">{{ ((auth.user.quota_used || 0) / 1000).toFixed(0) }}K</span>
      </div>

      <!-- User dropdown -->
      <div class="relative">
        <button
          @click="dropdownOpen = !dropdownOpen"
          class="flex items-center gap-2 p-1 lg:pr-2.5 rounded-xl hover:bg-white/[0.04] transition-colors"
        >
          <div class="w-7 h-7 lg:w-8 lg:h-8 rounded-xl bg-gradient-to-br from-accent-500 to-accent-600 flex items-center justify-center text-white text-[10px] lg:text-xs font-bold shadow-sm shadow-accent-500/20">
            {{ auth.user?.username?.charAt(0)?.toUpperCase() || '?' }}
          </div>
          <span class="hidden sm:block text-[13px] font-medium text-white/90">{{ auth.user?.username }}</span>
          <svg class="w-3.5 h-3.5 text-base-500 hidden sm:block" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <path d="M6 9l6 6 6-6"/>
          </svg>
        </button>

        <transition name="scale">
          <div
            v-if="dropdownOpen"
            class="absolute right-0 top-full mt-2 w-56 bg-base-100 border border-white/[0.08] rounded-2xl shadow-2xl shadow-black/30 overflow-hidden py-1.5 z-50"
          >
            <div class="px-4 py-3 border-b border-white/[0.05]">
              <div class="text-sm font-semibold text-white/90">{{ auth.user?.username }}</div>
              <div class="text-xs text-base-500 mt-0.5">{{ auth.user?.email || '未设置邮箱' }}</div>
              <div class="text-[10px] text-base-600 mt-1">{{ auth.user?.role === 'admin' ? '管理员' : '普通用户' }}</div>
            </div>
            <div class="px-1.5 py-1.5">
              <button
                @click="handleLogout"
                class="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm text-base-400 hover:text-rose-400 hover:bg-rose-500/5 transition-colors"
              >
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/>
                </svg>
                退出登录
              </button>
            </div>
          </div>
        </transition>

        <div v-if="dropdownOpen" class="fixed inset-0 z-40" @click="dropdownOpen = false" />
      </div>
    </div>
  </header>
</template>

<style scoped>
.app-header {
  left: 0;
}
@media (min-width: 1024px) {
  .app-header {
    left: var(--desktop-left, 260px);
  }
}
</style>
