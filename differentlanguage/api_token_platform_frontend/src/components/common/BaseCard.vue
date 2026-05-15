<script setup lang="ts">
withDefaults(
  defineProps<{
    padding?: boolean
    hover?: boolean
    glass?: boolean
  }>(),
  { padding: true, hover: false, glass: false },
)
</script>

<template>
  <div
    class="rounded-2xl transition-all duration-300"
    :class="[
      glass
        ? 'glass bg-base-100/50 border border-white/[0.05]'
        : 'bg-base-100 border border-white/[0.05]',
      padding ? 'p-5' : '',
      hover ? 'hover:border-white/[0.1] hover:shadow-xl hover:shadow-black/20 hover:-translate-y-0.5' : '',
    ]"
  >
    <slot />
  </div>
</template>
