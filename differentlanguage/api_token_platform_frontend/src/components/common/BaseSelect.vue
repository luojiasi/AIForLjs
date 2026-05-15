<script setup lang="ts" generic="T extends string">
defineProps<{
  modelValue: T
  options: { value: T; label: string; description?: string }[]
  label?: string
}>()
defineEmits<{ 'update:modelValue': [value: T] }>()
</script>

<template>
  <div>
    <label v-if="label" class="block text-[13px] font-semibold text-base-300 mb-1.5 tracking-tight">{{ label }}</label>
    <div class="relative">
      <select
        :value="modelValue"
        @change="$emit('update:modelValue', ($event.target as HTMLSelectElement).value as T)"
        class="w-full bg-white/[0.03] border border-white/[0.06] rounded-xl px-4 py-2.5 text-sm text-white/90 focus:outline-none focus:border-accent-500/30 focus:ring-2 focus:ring-accent-500/20 transition-all appearance-none cursor-pointer pr-10"
      >
        <option v-for="opt in options" :key="opt.value" :value="opt.value" class="bg-base-100 text-white/90">
          {{ opt.label }}
        </option>
      </select>
      <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none">
        <svg class="w-4 h-4 text-base-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <path d="M6 9l6 6 6-6"/>
        </svg>
      </div>
    </div>
  </div>
</template>
