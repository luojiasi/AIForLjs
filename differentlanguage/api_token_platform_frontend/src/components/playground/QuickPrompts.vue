<script setup lang="ts">
import { QUICK_PROMPTS } from '@/constants/models'
defineEmits<{ select: [content: string] }>()
</script>

<template>
  <div class="flex flex-wrap gap-1.5">
    <button
      v-for="p in QUICK_PROMPTS" :key="p.label"
      @click="$emit('select', p.content)"
      class="text-[11px] px-3 py-1.5 rounded-full bg-white/[0.03] text-base-400 hover:text-white hover:bg-white/[0.06] border border-white/[0.04] hover:border-white/[0.08] transition-all font-medium"
    >
      {{ p.label }}
    </button>
  </div>
</template>
