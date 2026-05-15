<script setup lang="ts">
import { computed } from 'vue'

let uid = 0
const gradId = `quota-grad-${++uid}`

const props = defineProps<{ used: number; total: number; label?: string }>()

const pct = computed(() => Math.min(100, Math.max(0, (props.used / props.total) * 100)))
const dashOffset = computed(() => {
  const circumference = 2 * Math.PI * 54
  return circumference * (1 - pct.value / 100)
})
const color = computed(() => {
  if (pct.value > 90) return { stop1: '#f43f5e', stop2: '#fb7185' }
  if (pct.value > 70) return { stop1: '#f59e0b', stop2: '#fbbf24' }
  return { stop1: '#6366f1', stop2: '#8b5cf6' }
})
</script>

<template>
  <div class="flex items-center gap-6">
    <!-- Ring -->
    <div class="relative flex-shrink-0 w-[136px] h-[136px]">
      <svg viewBox="0 0 120 120" class="w-full h-full -rotate-90">
        <defs>
          <linearGradient :id="gradId" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" :stop-color="color.stop1" />
            <stop offset="100%" :stop-color="color.stop2" />
          </linearGradient>
        </defs>
        <circle cx="60" cy="60" r="54" fill="none" stroke="rgba(255,255,255,0.04)" stroke-width="8" />
        <circle
          cx="60" cy="60" r="54" fill="none"
          :stroke="`url(#${gradId})`"
          stroke-width="8" stroke-linecap="round"
          :stroke-dasharray="2 * Math.PI * 54"
          :stroke-dashoffset="dashOffset"
          class="transition-all duration-1000 ease-out"
        />
      </svg>
      <div class="absolute inset-0 flex flex-col items-center justify-center">
        <span class="text-2xl font-extrabold text-white tabular-nums tracking-tight">{{ pct.toFixed(1) }}%</span>
        <span class="text-[11px] font-semibold text-base-500 mt-0.5">已使用</span>
      </div>
    </div>

    <!-- Stats -->
    <div v-if="label" class="flex-1 space-y-4">
      <div class="text-sm font-semibold text-base-300">{{ label }}</div>
      <div class="grid grid-cols-2 gap-3">
        <div class="p-3 rounded-xl bg-white/[0.02] border border-white/[0.03]">
          <div class="text-[11px] text-base-500 font-medium mb-0.5">已使用</div>
          <div class="text-sm font-bold text-white/90 font-mono tabular-nums">{{ (used / 1_000_000).toFixed(2) }}M</div>
        </div>
        <div class="p-3 rounded-xl bg-white/[0.02] border border-white/[0.03]">
          <div class="text-[11px] text-base-500 font-medium mb-0.5">总配额</div>
          <div class="text-sm font-bold text-white/90 font-mono tabular-nums">{{ (total / 1_000_000).toFixed(0) }}M</div>
        </div>
      </div>
    </div>
  </div>
</template>
