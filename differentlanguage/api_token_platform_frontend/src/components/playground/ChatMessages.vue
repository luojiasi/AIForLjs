<script setup lang="ts">
import { ref, watch, nextTick } from 'vue'
import { useChatStore } from '@/stores/chat'
import MessageBubble from './MessageBubble.vue'

const chat = useChatStore()
const container = ref<HTMLElement>()

watch(
  () => chat.messages.length,
  async () => {
    await nextTick()
    container.value?.scrollTo({ top: container.value.scrollHeight, behavior: 'smooth' })
  },
)
</script>

<template>
  <div ref="container" class="flex-1 overflow-y-auto px-4 py-6 space-y-5">
    <!-- Empty state -->
    <div v-if="chat.messages.filter(m => m.role !== 'system').length === 0 && !chat.isLoading" class="h-full flex items-center justify-center">
      <div class="text-center max-w-sm">
        <div class="w-20 h-20 rounded-3xl bg-gradient-to-br from-accent-500/10 to-accent-600/5 border border-accent-500/10 flex items-center justify-center mx-auto mb-6 shadow-lg shadow-accent-500/5">
          <svg class="w-10 h-10 text-accent-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
            <path d="M8 9h.01M12 9h.01M16 9h.01" stroke-width="2.5"/>
          </svg>
        </div>
        <h3 class="text-lg font-bold text-white tracking-tight mb-1.5">开始对话</h3>
        <p class="text-sm text-base-500 leading-relaxed">在下方选择模型和输入提示词，<br>即可开始与 AI 对话。</p>
      </div>
    </div>

    <!-- Messages -->
    <template v-else>
      <MessageBubble
        v-for="(msg, idx) in chat.messages.filter(m => m.role !== 'system')"
        :key="idx" :message="msg" :index="idx"
      />

      <!-- Typing indicator -->
      <div v-if="chat.isLoading" class="flex gap-3">
        <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-accent-500 to-accent-600 flex items-center justify-center flex-shrink-0 shadow-sm shadow-accent-500/20">
          <svg class="w-4 h-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
          </svg>
        </div>
        <div class="bg-base-100 border border-white/[0.05] rounded-2xl rounded-bl-md px-4 py-3">
          <div class="flex gap-1.5">
            <span class="w-2 h-2 rounded-full bg-accent-400 animate-typing-dot" />
            <span class="w-2 h-2 rounded-full bg-accent-400 animate-typing-dot" style="animation-delay: 0.2s" />
            <span class="w-2 h-2 rounded-full bg-accent-400 animate-typing-dot" style="animation-delay: 0.4s" />
          </div>
        </div>
      </div>

      <!-- Error -->
      <div v-if="chat.error" class="flex gap-3">
        <div class="w-8 h-8 rounded-xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center flex-shrink-0">
          <svg class="w-4 h-4 text-rose-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
        </div>
        <div class="bg-rose-500/5 border border-rose-500/10 rounded-2xl rounded-bl-md px-4 py-3">
          <p class="text-sm text-rose-400">{{ chat.error }}</p>
        </div>
      </div>
    </template>
  </div>
</template>
