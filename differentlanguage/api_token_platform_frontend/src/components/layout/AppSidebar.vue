<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useSettingsStore } from '@/stores/settings'
import { computed, ref, onMounted, onUnmounted } from 'vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const settings = useSettingsStore()
const collapsed = computed(() => settings.sidebarState === 'collapsed')

interface NavItem {
  to: string
  label: string
  icon: string
  adminOnly?: boolean
}

const navItems: NavItem[] = [
  { to: '/playground', label: 'AI 对话', icon: 'chat' },
  { to: '/api-keys', label: 'API 密钥', icon: 'key' },
  { to: '/wallet', label: '我的钱包', icon: 'wallet' },
  { to: '/docs', label: 'API 文档', icon: 'docs' },
  { to: '/usage', label: '用量统计', icon: 'chart' },
  { to: '/admin', label: '管理后台', icon: 'admin', adminOnly: true },
]

function isActive(item: NavItem): boolean {
  return route.path.startsWith(item.to)
}

function handleNavClick(item: NavItem) {
  settings.closeMobileSidebar()
  router.push(item.to)
}

// Swipe to close on mobile
const sidebarEl = ref<HTMLElement | null>(null)
let touchStartX = 0

function onTouchStart(e: TouchEvent) {
  touchStartX = e.touches[0].clientX
}
function onTouchEnd(e: TouchEvent) {
  const dx = e.changedTouches[0].clientX - touchStartX
  if (dx < -60) settings.closeMobileSidebar()
}

onMounted(() => {
  sidebarEl.value?.addEventListener('touchstart', onTouchStart, { passive: true })
  sidebarEl.value?.addEventListener('touchend', onTouchEnd, { passive: true })
})
onUnmounted(() => {
  sidebarEl.value?.removeEventListener('touchstart', onTouchStart)
  sidebarEl.value?.removeEventListener('touchend', onTouchEnd)
})
</script>

<template>
  <!-- Mobile overlay backdrop (tapping it closes sidebar) -->
  <transition name="fade">
    <div
      v-if="settings.mobileSidebarOpen"
      class="lg:hidden fixed inset-0 bg-black/60 backdrop-blur-sm z-35"
      @click="settings.closeMobileSidebar()"
    />
  </transition>

  <aside
    ref="sidebarEl"
    class="fixed left-0 top-0 h-full z-40 flex flex-col transition-all duration-300 ease-out"
    :class="[
      collapsed ? 'lg:w-[72px]' : 'lg:w-[260px]',
      settings.mobileSidebarOpen ? 'translate-x-0 w-[260px]' : '-translate-x-full lg:translate-x-0 lg:w-auto',
    ]"
  >
    <!-- Glass background -->
    <div class="absolute inset-0 glass bg-base-0/70 border-r border-white/[0.06]" />

    <!-- Mobile close button -->
    <button
      class="lg:hidden absolute top-3 right-3 w-8 h-8 rounded-lg bg-white/[0.04] border border-white/[0.06] flex items-center justify-center text-base-400 hover:text-white hover:bg-white/[0.08] transition-colors z-10"
      @click="settings.closeMobileSidebar()"
    >
      <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
    </button>

    <!-- Logo -->
    <div class="relative h-16 flex items-center border-b border-white/[0.05] cursor-pointer select-none"
      :class="collapsed ? 'lg:justify-center lg:px-2' : 'lg:px-5 lg:gap-3 px-5 gap-3'"
      @click="router.push('/playground'); settings.closeMobileSidebar()"
    >
      <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-accent-500 to-accent-600 flex items-center justify-center flex-shrink-0 shadow-lg shadow-accent-500/20">
        <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
        </svg>
      </div>
      <transition name="fade">
        <div v-if="!collapsed || settings.mobileSidebarOpen" class="overflow-hidden whitespace-nowrap lg:block" :class="{ 'hidden': collapsed && !settings.mobileSidebarOpen }">
          <div class="text-base font-bold text-white tracking-tight">TokenRelay</div>
          <div class="text-[10px] text-base-500 font-medium tracking-wider uppercase">API Platform</div>
        </div>
      </transition>
    </div>

    <!-- Navigation -->
    <nav class="relative flex-1 py-4 px-3 space-y-0.5 overflow-y-auto overscroll-contain">
      <template v-for="item in navItems" :key="item.to">
        <button
          v-if="!item.adminOnly || auth.isAdmin"
          @click="handleNavClick(item)"
          class="relative w-full flex items-center rounded-xl transition-all duration-200 group"
          :class="[
            collapsed ? 'lg:justify-center lg:px-2 lg:py-3' : 'lg:px-3 lg:py-2.5 lg:gap-3 px-3 py-2.5 gap-3',
            isActive(item)
              ? 'text-accent-300'
              : 'text-base-400 hover:text-white',
          ]"
        >
          <!-- Active indicator bar -->
          <div
            v-if="isActive(item)"
            class="absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-6 rounded-r-full bg-gradient-to-b from-accent-400 to-accent-600"
          />
          <!-- Active background glow -->
          <div
            v-if="isActive(item)"
            class="absolute inset-1 rounded-xl bg-accent-500/8"
          />

          <!-- Icons -->
          <span class="relative flex-shrink-0 w-5 h-5 flex items-center justify-center">
            <!-- Chat -->
            <svg v-if="item.icon === 'chat'" class="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
            </svg>
            <!-- Key -->
            <svg v-else-if="item.icon === 'key'" class="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/>
            </svg>
            <!-- Wallet -->
            <svg v-else-if="item.icon === 'wallet'" class="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/>
            </svg>
            <!-- Chart -->
            <svg v-else-if="item.icon === 'chart'" class="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 20V10M12 20V4M6 20v-6"/>
            </svg>
            <!-- Admin -->
            <svg v-else-if="item.icon === 'admin'" class="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/>
            </svg>
            <!-- Docs -->
            <svg v-else-if="item.icon === 'docs'" class="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><path d="M14 2v6h6M16 13H8M16 17H8M10 9H8"/>
            </svg>
          </span>

          <transition name="fade">
            <span v-if="!collapsed || settings.mobileSidebarOpen" class="text-[13px] font-medium whitespace-nowrap tracking-tight lg:block" :class="{ 'hidden': collapsed && !settings.mobileSidebarOpen }">{{ item.label }}</span>
          </transition>

          <!-- Tooltip when collapsed (desktop only) -->
          <transition name="fade">
            <div v-if="collapsed && !settings.mobileSidebarOpen" class="hidden lg:block absolute left-full ml-3 px-2.5 py-1.5 rounded-lg bg-base-200 border border-white/[0.08] text-xs font-medium text-white/90 whitespace-nowrap opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity z-50 shadow-xl">
              {{ item.label }}
            </div>
          </transition>
        </button>
      </template>
    </nav>

    <!-- Bottom section: user + collapse (desktop only collapse toggle) -->
    <div class="relative border-t border-white/[0.05]">
      <!-- User -->
      <div
        class="flex items-center p-3 cursor-pointer hover:bg-white/[0.02] transition-colors"
        :class="collapsed ? 'lg:justify-center' : 'lg:px-4 lg:gap-3 px-4 gap-3'"
      >
        <div class="relative flex-shrink-0">
          <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-accent-500 to-accent-600 flex items-center justify-center text-white text-xs font-bold">
            {{ auth.user?.username?.charAt(0)?.toUpperCase() || '?' }}
          </div>
          <div class="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-emerald-500 border-2 border-base-0" />
        </div>
        <transition name="fade">
          <div v-if="!collapsed || settings.mobileSidebarOpen" class="flex-1 min-w-0 overflow-hidden lg:block" :class="{ 'hidden': collapsed && !settings.mobileSidebarOpen }">
            <div class="text-[13px] font-medium text-white/90 truncate">{{ auth.user?.username }}</div>
            <div class="text-[11px] text-base-500 truncate">{{ auth.user?.email || '未设置邮箱' }}</div>
          </div>
        </transition>
      </div>

      <!-- Collapse toggle (desktop only) -->
      <button
        @click="settings.toggleSidebar()"
        class="hidden lg:flex absolute -right-3 top-6 w-6 h-6 rounded-full bg-base-200 border border-white/[0.08] items-center justify-center text-base-500 hover:text-base-300 hover:border-white/[0.12] transition-all shadow-lg"
      >
        <svg class="w-3 h-3 transition-transform duration-300" :class="{ 'rotate-180': collapsed }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M15 18l-6-6 6-6"/>
        </svg>
      </button>
    </div>
  </aside>
</template>
