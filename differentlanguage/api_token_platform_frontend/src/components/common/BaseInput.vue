<script setup lang="ts">
import { ref } from 'vue'

withDefaults(
  defineProps<{
    modelValue: string
    label?: string
    type?: string
    placeholder?: string
    error?: string
    disabled?: boolean
    required?: boolean
    rows?: number
  }>(),
  { type: 'text', rows: 3 },
)

const emit = defineEmits<{ 'update:modelValue': [value: string] }>()

const focused = ref(false)

function onInput(e: Event) {
  emit('update:modelValue', (e.target as HTMLInputElement | HTMLTextAreaElement).value)
}
</script>

<template>
  <div>
    <label v-if="label" class="block text-[13px] font-semibold text-base-300 mb-1.5 tracking-tight">
      {{ label }}
      <span v-if="required" class="text-rose-400 ml-0.5">*</span>
    </label>

    <div
      class="relative rounded-xl transition-all duration-200"
      :class="[
        focused ? 'ring-2 ring-accent-500/30' : 'ring-0',
        error ? 'ring-2 ring-rose-500/30' : '',
      ]"
    >
      <textarea
        v-if="type === 'textarea'"
        :value="modelValue"
        @input="onInput"
        @focus="focused = true"
        @blur="focused = false"
        :rows="rows"
        :placeholder="placeholder"
        :disabled="disabled"
        class="w-full bg-white/[0.03] border rounded-xl px-4 py-2.5 text-sm text-white/90 placeholder-base-600 outline-none transition-all resize-none"
        :class="[
          error ? 'border-rose-500/30' : focused ? 'border-accent-500/30' : 'border-white/[0.06]',
          disabled ? 'opacity-40 cursor-not-allowed' : '',
        ]"
      />
      <input
        v-else
        :value="modelValue"
        @input="onInput"
        @focus="focused = true"
        @blur="focused = false"
        :type="type"
        :placeholder="placeholder"
        :disabled="disabled"
        class="w-full bg-white/[0.03] border rounded-xl px-4 py-2.5 text-sm text-white/90 placeholder-base-600 outline-none transition-all"
        :class="[
          error ? 'border-rose-500/30' : focused ? 'border-accent-500/30' : 'border-white/[0.06]',
          disabled ? 'opacity-40 cursor-not-allowed' : '',
        ]"
      />
    </div>

    <p v-if="error" class="text-xs text-rose-400 mt-1.5 flex items-center gap-1">
      <svg class="w-3 h-3 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
      {{ error }}
    </p>
  </div>
</template>
