<script setup lang="ts">
defineProps<{
  label: string
  value: string | number
  unit?: string
  trend?: 'up' | 'down' | 'stable'
  trendValue?: string
  accent?: boolean
}>()
</script>

<template>
  <div
    class="rounded-2xl border border-white/[0.05] p-5 transition-all duration-300 hover:border-white/[0.1] hover:shadow-lg hover:shadow-black/20"
    :class="accent ? 'bg-gradient-to-br from-accent-500/5 to-transparent' : 'bg-base-100'"
  >
    <div class="text-[12px] font-semibold text-base-500 tracking-wide uppercase mb-3">{{ label }}</div>
    <div class="flex items-baseline gap-1.5">
      <span class="text-[28px] font-extrabold text-white tracking-tight tabular-nums">{{ value }}</span>
      <span v-if="unit" class="text-sm font-medium text-base-500">{{ unit }}</span>
    </div>
    <div v-if="trend && trendValue" class="flex items-center gap-1.5 mt-3 text-xs font-semibold" :class="{
      'text-emerald-400': trend === 'up',
      'text-rose-400': trend === 'down',
      'text-base-500': trend === 'stable',
    }">
      <svg v-if="trend === 'up'" class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
      <svg v-else-if="trend === 'down'" class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M19 12l-7 7-7-7"/></svg>
      <svg v-else class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M5 12h14"/></svg>
      <span>{{ trendValue }}</span>
    </div>
  </div>
</template>
