<script setup lang="ts">
withDefaults(
  defineProps<{
    open: boolean
    title?: string
    size?: 'sm' | 'md' | 'lg'
  }>(),
  { size: 'md' },
)
defineEmits<{ close: [] }>()
</script>

<template>
  <teleport to="body">
    <transition name="fade">
      <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <!-- Backdrop -->
        <div class="absolute inset-0 bg-black/70 backdrop-blur-md" @click="$emit('close')" />

        <!-- Panel -->
        <transition name="scale">
          <div v-if="open"
            class="relative glass bg-base-100/90 border border-white/[0.08] rounded-2xl shadow-2xl shadow-black/30 w-full max-h-[85vh] overflow-hidden flex flex-col"
            :class="{
              sm: 'max-w-sm',
              md: 'max-w-lg',
              lg: 'max-w-2xl',
            }[size]"
          >
            <!-- Header -->
            <div v-if="title || $slots.header" class="flex items-center justify-between px-6 py-4 border-b border-white/[0.05]">
              <h3 class="text-lg font-bold text-white tracking-tight">{{ title }}</h3>
              <slot name="header" />
              <button @click="$emit('close')" class="p-1.5 -mr-1.5 rounded-lg text-base-500 hover:text-base-300 hover:bg-white/[0.04] transition-colors">
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
              </button>
            </div>

            <!-- Body -->
            <div class="overflow-y-auto p-6">
              <slot />
            </div>

            <!-- Footer -->
            <div v-if="$slots.footer" class="px-6 py-4 border-t border-white/[0.05] flex justify-end gap-3 bg-white/[0.01]">
              <slot name="footer" />
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </teleport>
</template>
