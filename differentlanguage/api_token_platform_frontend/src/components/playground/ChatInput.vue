<script setup lang="ts">
import { ref } from 'vue'

defineProps<{ loading?: boolean }>()
const emit = defineEmits<{ send: [content: string] }>()

const input = ref('')

function handleSend() {
  const text = input.value.trim()
  if (!text) return
  emit('send', text)
  input.value = ''
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    handleSend()
  }
}
</script>

<template>
  <div class="p-4 border-t border-white/[0.04]">
    <div class="flex items-end gap-3">
      <div class="flex-1 relative">
        <textarea
          v-model="input"
          @keydown="onKeydown"
          :disabled="loading"
          placeholder="输入消息，Enter 发送，Shift+Enter 换行..."
          rows="1"
          class="w-full bg-white/[0.03] border border-white/[0.06] rounded-2xl px-4 py-3 text-sm text-white/90 placeholder-base-600 outline-none transition-all duration-200 resize-none focus:border-accent-500/25 focus:ring-4 focus:ring-accent-500/5 disabled:opacity-50"
        />
        <!-- Shortcut hint -->
        <div class="absolute right-3 bottom-3 flex items-center gap-1.5 pointer-events-none">
          <kbd class="hidden sm:inline-flex items-center gap-0.5 text-[10px] text-base-600 font-medium bg-white/[0.03] border border-white/[0.05] rounded-md px-1.5 py-0.5">
            ↵
          </kbd>
        </div>
      </div>

      <button
        @click="handleSend"
        :disabled="loading || !input.trim()"
        class="flex-shrink-0 p-3 rounded-2xl bg-gradient-to-br from-accent-500 to-accent-600 text-white shadow-lg shadow-accent-500/20 hover:shadow-accent-500/30 hover:from-accent-400 hover:to-accent-500 disabled:opacity-30 disabled:shadow-none transition-all duration-200 active:scale-95"
      >
        <svg v-if="!loading" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
        </svg>
        <svg v-else class="w-5 h-5 animate-spin" viewBox="0 0 24 24" fill="none">
          <circle class="opacity-20" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3" />
          <path class="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
      </button>
    </div>
  </div>
</template>
