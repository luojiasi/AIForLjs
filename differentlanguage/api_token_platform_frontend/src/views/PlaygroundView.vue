<script setup lang="ts">
import { ref } from 'vue'
import { useChatStore } from '@/stores/chat'
import { useToast } from '@/composables/useToast'
import BaseCard from '@/components/common/BaseCard.vue'
import BaseButton from '@/components/common/BaseButton.vue'
import ModelConfig from '@/components/playground/ModelConfig.vue'
import ParamSlider from '@/components/playground/ParamSlider.vue'
import ChatMessages from '@/components/playground/ChatMessages.vue'
import ChatInput from '@/components/playground/ChatInput.vue'
import QuickPrompts from '@/components/playground/QuickPrompts.vue'

const chat = useChatStore()
const toast = useToast()
const settingsOpen = ref(false)
const mobileSettingsOpen = ref(false)

async function handleSend(content: string) {
  try { await chat.sendMessage(content) }
  catch { toast.error(chat.error || '发送失败') }
}
</script>

<template>
  <div class="flex flex-col lg:flex-row gap-4 lg:gap-6 lg:h-[calc(100vh-7rem)] p-4 lg:p-0">
    <!-- Chat area -->
    <div class="flex-1 flex flex-col min-w-0 min-h-0">
      <div class="flex-1 flex flex-col rounded-2xl border border-white/[0.05] bg-base-100 overflow-hidden" style="min-height: 60vh;">
        <!-- Chat header -->
        <div class="flex items-center justify-between px-4 lg:px-5 py-2.5 lg:py-3 border-b border-white/[0.04]">
          <div class="flex items-center gap-2.5 lg:gap-3">
            <div class="w-2 h-2 rounded-full bg-emerald-400 shadow-sm shadow-emerald-400/30 flex-shrink-0" />
            <div class="min-w-0">
              <span class="text-[13px] font-semibold text-white/90 truncate">AI 对话</span>
              <span class="text-[11px] text-base-500 ml-2 hidden sm:inline">{{ chat.settings.model }}</span>
            </div>
          </div>
          <div class="flex items-center gap-1.5 lg:gap-2 flex-shrink-0">
            <BaseButton size="xs" variant="ghost" @click="chat.clearMessages()">
              <span class="hidden sm:inline">清空对话</span>
              <svg class="w-4 h-4 sm:hidden" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 6h18M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
            </BaseButton>
            <!-- Mobile settings toggle -->
            <BaseButton size="xs" variant="ghost" class="lg:hidden" @click="mobileSettingsOpen = !mobileSettingsOpen">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
            </BaseButton>
            <BaseButton size="xs" variant="ghost" class="hidden lg:inline-flex" @click="settingsOpen = !settingsOpen">
              {{ settingsOpen ? '隐藏面板' : '显示面板' }}
            </BaseButton>
          </div>
        </div>

        <!-- System prompt row -->
        <div class="px-4 lg:px-5 py-2.5 border-b border-white/[0.04] bg-white/[0.01]">
          <div class="flex items-center gap-2.5">
            <svg class="w-4 h-4 text-base-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
            <input
              :value="chat.settings.systemPrompt"
              @input="chat.updateSetting('systemPrompt', ($event.target as HTMLInputElement).value)"
              placeholder="系统提示词（可选）..."
              class="flex-1 bg-transparent text-xs text-base-400 placeholder-base-600 focus:outline-none"
            />
          </div>
        </div>

        <!-- Quick prompts -->
        <div class="px-4 lg:px-5 py-2 border-b border-white/[0.04]">
          <QuickPrompts @select="handleSend" />
        </div>

        <!-- Messages -->
        <ChatMessages />

        <!-- Input -->
        <ChatInput :loading="chat.isLoading" @send="handleSend" />
      </div>
    </div>

    <!-- Settings panel — Desktop: sidebar; Mobile: bottom sheet overlay -->
    <!-- Desktop settings -->
    <transition name="fade">
      <div v-if="settingsOpen" class="hidden lg:block w-72 flex-shrink-0 space-y-4 overflow-y-auto">
        <BaseCard>
          <h3 class="text-[13px] font-bold text-white tracking-tight mb-4 flex items-center gap-2">
            <svg class="w-4 h-4 text-base-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
            模型配置
          </h3>
          <ModelConfig />
        </BaseCard>

        <BaseCard>
          <h3 class="text-[13px] font-bold text-white tracking-tight mb-4">参数设置</h3>
          <div class="space-y-5">
            <ParamSlider label="Temperature" :modelValue="chat.settings.temperature" :min="0" :max="2" :step="0.05" @update:modelValue="chat.updateSetting('temperature', $event)" />
            <ParamSlider label="Max Tokens" :modelValue="chat.settings.maxTokens" :min="256" :max="32768" :step="256" @update:modelValue="chat.updateSetting('maxTokens', $event)" />
            <ParamSlider label="Top P" :modelValue="chat.settings.topP" :min="0" :max="1" :step="0.05" @update:modelValue="chat.updateSetting('topP', $event)" />
          </div>
        </BaseCard>

        <BaseCard v-if="chat.lastResponse">
          <h3 class="text-[13px] font-bold text-white tracking-tight mb-4">上次调用</h3>
          <div class="space-y-2.5">
            <div class="flex justify-between text-xs"><span class="text-base-500">模型</span><span class="text-base-300 font-mono">{{ chat.lastResponse.model }}</span></div>
            <div class="flex justify-between text-xs"><span class="text-base-500">输入</span><span class="text-base-300 font-mono">{{ chat.lastResponse.usage.prompt_tokens.toLocaleString() }}</span></div>
            <div class="flex justify-between text-xs"><span class="text-base-500">输出</span><span class="text-base-300 font-mono">{{ chat.lastResponse.usage.completion_tokens.toLocaleString() }}</span></div>
            <div class="border-t border-white/[0.04] pt-2.5 flex justify-between text-xs"><span class="text-base-500">费用</span><span class="text-emerald-400 font-mono font-semibold">${{ chat.lastResponse.cost.toFixed(6) }}</span></div>
            <div class="flex justify-between text-xs"><span class="text-base-500">延迟</span><span class="text-base-300 font-mono">{{ chat.lastResponse.latency_ms }}ms</span></div>
          </div>
        </BaseCard>
      </div>
    </transition>

    <!-- Mobile settings bottom sheet -->
    <transition name="sheet-slide">
      <div v-if="mobileSettingsOpen" class="lg:hidden fixed inset-0 z-50 flex flex-col justify-end">
        <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="mobileSettingsOpen = false" />
        <div class="relative bg-base-100 border border-white/[0.08] rounded-t-3xl shadow-2xl max-h-[80vh] overflow-y-auto p-5 space-y-4 safe-bottom">
          <!-- Handle bar -->
          <div class="flex justify-center -mt-2 mb-1">
            <div class="w-10 h-1 rounded-full bg-white/[0.1]" />
          </div>

          <div class="flex items-center justify-between">
            <h3 class="text-sm font-bold text-white">对话设置</h3>
            <button @click="mobileSettingsOpen = false" class="p-1.5 rounded-lg text-base-500 hover:text-white hover:bg-white/[0.04]">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
            </button>
          </div>

          <BaseCard>
            <h3 class="text-[13px] font-bold text-white tracking-tight mb-4 flex items-center gap-2">
              <svg class="w-4 h-4 text-base-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
              模型配置
            </h3>
            <ModelConfig />
          </BaseCard>

          <BaseCard>
            <h3 class="text-[13px] font-bold text-white tracking-tight mb-4">参数设置</h3>
            <div class="space-y-5">
              <ParamSlider label="Temperature" :modelValue="chat.settings.temperature" :min="0" :max="2" :step="0.05" @update:modelValue="chat.updateSetting('temperature', $event)" />
              <ParamSlider label="Max Tokens" :modelValue="chat.settings.maxTokens" :min="256" :max="32768" :step="256" @update:modelValue="chat.updateSetting('maxTokens', $event)" />
              <ParamSlider label="Top P" :modelValue="chat.settings.topP" :min="0" :max="1" :step="0.05" @update:modelValue="chat.updateSetting('topP', $event)" />
            </div>
          </BaseCard>

          <BaseCard v-if="chat.lastResponse">
            <h3 class="text-[13px] font-bold text-white tracking-tight mb-4">上次调用</h3>
            <div class="space-y-2.5">
              <div class="flex justify-between text-xs"><span class="text-base-500">模型</span><span class="text-base-300 font-mono">{{ chat.lastResponse.model }}</span></div>
              <div class="flex justify-between text-xs"><span class="text-base-500">输入</span><span class="text-base-300 font-mono">{{ chat.lastResponse.usage.prompt_tokens.toLocaleString() }}</span></div>
              <div class="flex justify-between text-xs"><span class="text-base-500">输出</span><span class="text-base-300 font-mono">{{ chat.lastResponse.usage.completion_tokens.toLocaleString() }}</span></div>
              <div class="border-t border-white/[0.04] pt-2.5 flex justify-between text-xs"><span class="text-base-500">费用</span><span class="text-emerald-400 font-mono font-semibold">${{ chat.lastResponse.cost.toFixed(6) }}</span></div>
              <div class="flex justify-between text-xs"><span class="text-base-500">延迟</span><span class="text-base-300 font-mono">{{ chat.lastResponse.latency_ms }}ms</span></div>
            </div>
          </BaseCard>

          <!-- Bottom spacer for close button area -->
          <div class="h-4" />
        </div>
      </div>
    </transition>
  </div>
</template>

<style scoped>
.sheet-slide-enter-active {
  transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}
.sheet-slide-leave-active {
  transition: all 0.25s cubic-bezier(0.4, 0, 1, 1);
}
.sheet-slide-enter-from .relative,
.sheet-slide-leave-to .relative {
  transform: translateY(100%);
}
.sheet-slide-enter-from .absolute,
.sheet-slide-leave-to .absolute {
  opacity: 0;
}
</style>