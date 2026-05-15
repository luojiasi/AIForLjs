<script setup lang="ts">
import type { ChatMessage } from '@/types/relay'
import { useMarkdown } from '@/composables/useMarkdown'
import { computed, ref } from 'vue'

const props = defineProps<{ message: ChatMessage; index: number }>()
const { render } = useMarkdown()
const isUser = computed(() => props.message.role === 'user')
const copied = ref(false)

const rendered = computed(() => {
  if (isUser.value) return ''
  return render(props.message.content)
})

async function copyText(text: string) {
  try {
    await navigator.clipboard.writeText(text)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch { /* fallback */ }
}
</script>

<template>
  <div class="flex gap-3 group" :class="isUser ? 'justify-end' : 'justify-start'">
    <!-- AI Avatar -->
    <div v-if="!isUser" class="w-8 h-8 rounded-xl bg-gradient-to-br from-accent-500 to-accent-600 flex items-center justify-center flex-shrink-0 mt-0.5 shadow-sm shadow-accent-500/20">
      <svg class="w-4 h-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
      </svg>
    </div>

    <!-- Bubble -->
    <div class="max-w-[82%] md:max-w-[75%] space-y-1">
      <!-- Role label -->
      <div class="text-[10px] font-semibold text-base-500 tracking-wide uppercase px-1" :class="isUser ? 'text-right' : ''">
        {{ isUser ? 'You' : 'Assistant' }}
      </div>

      <div
        class="rounded-2xl px-4 py-3 text-sm leading-relaxed"
        :class="isUser
          ? 'bg-gradient-to-br from-accent-500/15 to-accent-500/5 border border-accent-500/10 rounded-br-md text-white/90'
          : 'bg-base-100 border border-white/[0.05] rounded-bl-md text-white/90'"
      >
        <div v-if="isUser" class="whitespace-pre-wrap">{{ message.content }}</div>
        <div v-else class="markdown-body" v-html="rendered" />
      </div>

      <!-- Copy button (AI messages only) -->
      <div v-if="!isUser" class="px-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          @click="copyText(message.content)"
          class="text-[10px] text-base-600 hover:text-base-400 transition-colors flex items-center gap-1"
        >
          <svg v-if="copied" class="w-3 h-3 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M20 6L9 17l-5-5"/></svg>
          <svg v-else class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
          {{ copied ? '已复制' : '复制' }}
        </button>
      </div>
    </div>

    <!-- User Avatar -->
    <div v-if="isUser" class="w-8 h-8 rounded-xl bg-gradient-to-br from-base-300 to-base-400 flex items-center justify-center flex-shrink-0 mt-0.5">
      <svg class="w-4 h-4 text-base-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/>
      </svg>
    </div>
  </div>
</template>
