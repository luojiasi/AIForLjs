<script setup lang="ts">
import { useToast } from '@/composables/useToast'
const { toasts, removeToast } = useToast()
</script>

<template>
  <div class="fixed top-4 right-4 z-50 flex flex-col gap-2 pointer-events-none max-w-[420px]">
    <transition-group name="slide-up">
      <div
        v-for="toast in toasts" :key="toast.id"
        class="pointer-events-auto relative overflow-hidden glass border rounded-xl shadow-2xl shadow-black/30 flex items-start gap-3 px-4 py-3 text-sm"
        :class="{
          'bg-emerald-500/5 border-emerald-500/15 text-emerald-400': toast.type === 'success',
          'bg-rose-500/5 border-rose-500/15 text-rose-400': toast.type === 'error',
          'bg-amber-500/5 border-amber-500/15 text-amber-400': toast.type === 'warning',
          'bg-accent-500/5 border-accent-500/15 text-accent-400': toast.type === 'info',
        }"
      >
        <!-- Progress bar -->
        <div class="absolute bottom-0 left-0 h-0.5 bg-current opacity-30 rounded-full"
          style="width: 100%; animation: toast-timer 4s linear forwards;"
          :style="{ animationDuration: (toast.duration || 4000) + 'ms' }"
        />

        <!-- Icon -->
        <svg v-if="toast.type === 'success'" class="w-5 h-5 flex-shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><path d="M9 12l2 2 4-4"/>
        </svg>
        <svg v-else-if="toast.type === 'error'" class="w-5 h-5 flex-shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/>
        </svg>
        <svg v-else-if="toast.type === 'warning'" class="w-5 h-5 flex-shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><path d="M12 9v4M12 17h.01"/>
        </svg>
        <svg v-else class="w-5 h-5 flex-shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>
        </svg>

        <span class="flex-1 text-[13px] leading-relaxed">{{ toast.message }}</span>

        <button @click="removeToast(toast.id)" class="flex-shrink-0 p-0.5 -mr-1 -mt-0.5 rounded hover:bg-white/[0.06] opacity-50 hover:opacity-100 transition-all">
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
        </button>

      </div>
    </transition-group>
  </div>
</template>
