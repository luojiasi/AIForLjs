import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { ChatMessage, ChatCompletionResponse } from '@/types/relay'
import { relayApi } from '@/api'
import { DEFAULT_PLAYGROUND_SETTINGS } from '@/constants/settings'

export const useChatStore = defineStore('chat', () => {
  const messages = ref<ChatMessage[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  const lastResponse = ref<ChatCompletionResponse | null>(null)

  const settings = ref({ ...DEFAULT_PLAYGROUND_SETTINGS })

  function addMessage(role: ChatMessage['role'], content: string) {
    messages.value.push({ role, content })
  }

  function clearMessages() {
    messages.value = []
    lastResponse.value = null
    error.value = null
  }

  async function sendMessage(content: string) {
    addMessage('user', content)
    isLoading.value = true
    error.value = null

    const requestMessages: ChatMessage[] = []
    if (settings.value.systemPrompt) {
      requestMessages.push({ role: 'system', content: settings.value.systemPrompt })
    }
    requestMessages.push(...messages.value)

    try {
      const response = await relayApi.sendChatCompletion({
        model: settings.value.model,
        messages: requestMessages,
        max_tokens: settings.value.maxTokens,
        temperature: settings.value.temperature,
        top_p: settings.value.topP,
        stream: false,
      })
      lastResponse.value = response
      const choice = response.choices[0]
      if (choice) {
        addMessage('assistant', choice.message.content)
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : '发送失败'
      error.value = msg
      throw e
    } finally {
      isLoading.value = false
    }
  }

  function updateSetting<K extends keyof typeof DEFAULT_PLAYGROUND_SETTINGS>(
    key: K,
    value: (typeof DEFAULT_PLAYGROUND_SETTINGS)[K],
  ) {
    settings.value[key] = value
  }

  return {
    messages,
    isLoading,
    error,
    lastResponse,
    settings,
    addMessage,
    clearMessages,
    sendMessage,
    updateSetting,
  }
})
