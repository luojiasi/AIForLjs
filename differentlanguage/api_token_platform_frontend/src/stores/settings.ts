import { defineStore } from 'pinia'
import { ref } from 'vue'

export type ThemeMode = 'dark' | 'light'
export type SidebarState = 'expanded' | 'collapsed'

export const useSettingsStore = defineStore('settings', () => {
  const theme = ref<ThemeMode>('dark')
  const sidebarState = ref<SidebarState>('expanded')
  const mobileSidebarOpen = ref(false)

  function toggleTheme() {
    theme.value = theme.value === 'dark' ? 'light' : 'dark'
    document.documentElement.classList.toggle('dark', theme.value === 'dark')
  }

  function toggleSidebar() {
    sidebarState.value =
      sidebarState.value === 'expanded' ? 'collapsed' : 'expanded'
  }

  function openMobileSidebar() {
    mobileSidebarOpen.value = true
  }

  function closeMobileSidebar() {
    mobileSidebarOpen.value = false
  }

  return {
    theme,
    sidebarState,
    mobileSidebarOpen,
    toggleTheme,
    toggleSidebar,
    openMobileSidebar,
    closeMobileSidebar,
  }
})
