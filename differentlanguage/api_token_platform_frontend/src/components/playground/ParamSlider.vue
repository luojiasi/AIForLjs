<script setup lang="ts">
defineProps<{
  label: string
  modelValue: number
  min: number
  max: number
  step: number
  unit?: string
}>()
const emit = defineEmits<{ 'update:modelValue': [value: number] }>()
</script>

<template>
  <div>
    <div class="flex justify-between items-center mb-2">
      <span class="text-[12px] font-medium text-base-400">{{ label }}</span>
      <span class="text-xs font-mono font-semibold text-white/90 tabular-nums">{{ modelValue }}{{ unit || '' }}</span>
    </div>
    <input
      type="range"
      :min="min" :max="max" :step="step"
      :value="modelValue"
      @input="emit('update:modelValue', parseFloat(($event.target as HTMLInputElement).value))"
      class="w-full h-1.5 rounded-full appearance-none cursor-pointer
        bg-gradient-to-r from-accent-500/20 to-accent-500/40
        [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:h-4
        [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-white
        [&::-webkit-slider-thumb]:shadow-lg [&::-webkit-slider-thumb]:shadow-black/30
        [&::-webkit-slider-thumb]:cursor-pointer [&::-webkit-slider-thumb]:border-2
        [&::-webkit-slider-thumb]:border-accent-500/30"
    />
  </div>
</template>
