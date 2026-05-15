<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
    size?: 'xs' | 'sm' | 'md' | 'lg'
    loading?: boolean
    disabled?: boolean
    block?: boolean
  }>(),
  { variant: 'primary', size: 'md', loading: false, disabled: false, block: false },
)
defineEmits<{ click: [] }>()
</script>

<template>
  <button
    :disabled="disabled || loading"
    class="inline-flex items-center justify-center font-semibold tracking-tight rounded-xl transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-accent-500/50 focus-visible:ring-offset-2 focus-visible:ring-offset-base-0 active:scale-[0.97]"
    :class="[
      {
        primary: 'bg-gradient-to-br from-accent-500 to-accent-600 text-white shadow-lg shadow-accent-500/20 hover:shadow-accent-500/30 hover:from-accent-400 hover:to-accent-500 disabled:opacity-40 disabled:shadow-none',
        secondary: 'bg-white/[0.05] text-white/80 border border-white/[0.08] hover:bg-white/[0.08] hover:border-white/[0.12] disabled:opacity-40',
        ghost: 'text-base-400 hover:text-white hover:bg-white/[0.04] disabled:opacity-40',
        danger: 'bg-rose-500/10 text-rose-400 border border-rose-500/15 hover:bg-rose-500/20 hover:text-rose-300 disabled:opacity-40',
      }[variant],
      {
        xs: 'text-xs px-2.5 py-1.5 gap-1.5 rounded-lg',
        sm: 'text-xs px-3.5 py-2 gap-1.5',
        md: 'text-[13px] px-4 py-2.5 gap-2',
        lg: 'text-sm px-6 py-3 gap-2.5',
      }[size],
      block ? 'w-full' : '',
    ]"
    @click="$emit('click')"
  >
    <!-- Spinner -->
    <svg v-if="loading" class="animate-spin w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none">
      <circle class="opacity-20" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3.5" />
      <path class="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
    </svg>
    <slot />
  </button>
</template>
