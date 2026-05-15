<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'accent'
    size?: 'sm' | 'md'
    dot?: boolean
  }>(),
  { variant: 'default', size: 'sm', dot: false },
)
</script>

<template>
  <span
    class="inline-flex items-center gap-1.5 rounded-lg font-semibold tracking-tight"
    :class="[
      {
        default: 'bg-white/[0.04] text-base-400 border border-white/[0.04]',
        success: 'bg-emerald-500/8 text-emerald-400 border border-emerald-500/10',
        warning: 'bg-amber-500/8 text-amber-400 border border-amber-500/10',
        danger: 'bg-rose-500/8 text-rose-400 border border-rose-500/10',
        info: 'bg-cyan-500/8 text-cyan-400 border border-cyan-500/10',
        accent: 'bg-accent-500/8 text-accent-400 border border-accent-500/10',
      }[variant],
      size === 'sm' ? 'text-[11px] px-2 py-0.5' : 'text-xs px-2.5 py-1',
    ]"
  >
    <span v-if="dot" class="w-1.5 h-1.5 rounded-full" :class="{
      'bg-base-500': variant === 'default',
      'bg-emerald-400': variant === 'success',
      'bg-amber-400': variant === 'warning',
      'bg-rose-400': variant === 'danger',
      'bg-cyan-400': variant === 'info',
      'bg-accent-400': variant === 'accent',
    }" />
    <slot />
  </span>
</template>
