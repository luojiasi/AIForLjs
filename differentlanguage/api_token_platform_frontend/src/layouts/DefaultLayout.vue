<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useSettingsStore } from '@/stores/settings'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import AppHeader from '@/components/layout/AppHeader.vue'
import BaseToast from '@/components/common/BaseToast.vue'
import { computed } from 'vue'

const auth = useAuthStore()
const settings = useSettingsStore()

const desktopMargin = computed(() =>
  settings.sidebarState === 'collapsed' ? '72px' : '260px'
)
</script>

<template>
  <div v-if="auth.isLoggedIn" class="min-h-screen bg-base-0">
    <AppSidebar />
    <AppHeader />

    <!-- Main content -->
    <main
      class="main-content pt-16 min-h-screen transition-all duration-300 ease-out pb-20 lg:pb-0"
      :style="{ '--desktop-ml': desktopMargin }"
    >
      <router-view v-slot="{ Component, route }">
        <transition name="slide-up" mode="out-in">
          <component :is="Component" :key="route.path" />
        </transition>
      </router-view>
    </main>

    <!-- Mobile bottom nav -->
    <nav class="lg:hidden fixed bottom-0 left-0 right-0 z-30">
      <div class="glass bg-base-0/90 border-t border-white/[0.06]">
        <div class="flex items-center justify-around px-2 py-1.5">
          <button
            v-for="item in [
              { to: '/playground', label: '对话', icon: 'chat' },
              { to: '/api-keys', label: '密钥', icon: 'key' },
              { to: '/usage', label: '用量', icon: 'chart' },
              { to: '/admin', label: '管理', icon: 'admin', adminOnly: true },
            ]"
            :key="item.to"
            v-show="!item.adminOnly || auth.isAdmin"
            @click="$router.push(item.to)"
            class="flex flex-col items-center gap-0.5 py-1 px-3 rounded-lg transition-colors min-w-0 flex-1"
            :class="$route.path.startsWith(item.to) ? 'text-accent-400' : 'text-base-500'"
          >
            <!-- Chat icon -->
            <svg v-if="item.icon === 'chat'" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
            </svg>
            <!-- Key icon -->
            <svg v-else-if="item.icon === 'key'" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/>
            </svg>
            <!-- Chart icon -->
            <svg v-else-if="item.icon === 'chart'" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 20V10M12 20V4M6 20v-6"/>
            </svg>
            <!-- Admin icon -->
            <svg v-else-if="item.icon === 'admin'" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/>
            </svg>
            <span class="text-[10px] font-medium leading-none">{{ item.label }}</span>
          </button>

          <!-- Menu button -->
          <button
            class="flex flex-col items-center gap-0.5 py-1 px-3 rounded-lg transition-colors min-w-0 text-base-500"
            @click="settings.openMobileSidebar()"
          >
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
              <path d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
            <span class="text-[10px] font-medium leading-none">菜单</span>
          </button>
        </div>
      </div>
    </nav>

    <BaseToast />
  </div>
</template>

<style scoped>
.main-content {
  margin-left: 0;
}
@media (min-width: 1024px) {
  .main-content {
    margin-left: var(--desktop-ml, 260px);
  }
}
</style>