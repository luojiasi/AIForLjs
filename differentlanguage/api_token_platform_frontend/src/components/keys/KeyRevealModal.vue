<script setup lang="ts">
import type { CreatedApiKey } from '@/types/auth'
import BaseModal from '@/components/common/BaseModal.vue'
import BaseButton from '@/components/common/BaseButton.vue'
import { ref } from 'vue'

defineProps<{ open: boolean; apiKey: CreatedApiKey | null }>()
defineEmits<{ close: [] }>()
const copied = ref(false)

async function copyKey(key: string) {
  try { await navigator.clipboard.writeText(key) } catch {
    const el = document.createElement('textarea')
    el.value = key; document.body.appendChild(el); el.select(); document.execCommand('copy'); document.body.removeChild(el)
  }
  copied.value = true; setTimeout(() => copied.value = false, 2000)
}
</script>

<template>
  <BaseModal :open="open" title="新密钥已创建" size="sm" @close="$emit('close')">
    <div v-if="apiKey" class="space-y-4">
      <div class="flex items-start gap-3 p-4 rounded-xl bg-amber-500/5 border border-amber-500/10">
        <svg class="w-5 h-5 text-amber-400 flex-shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
          <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><path d="M12 9v4M12 17h.01"/>
        </svg>
        <p class="text-sm text-amber-300/80 leading-relaxed">此密钥<strong class="text-amber-200">仅显示一次</strong>。关闭后无法再次查看完整密钥，请立即复制并安全保存。</p>
      </div>

      <div class="relative">
        <div class="p-4 bg-base-0 border border-white/[0.06] rounded-xl font-mono text-sm text-accent-300 break-all leading-relaxed tracking-tight">
          {{ apiKey.raw_key }}
        </div>
        <BaseButton size="sm" :variant="copied ? 'secondary' : 'primary'" class="absolute right-2 top-2" @click="copyKey(apiKey.raw_key)">
          <svg v-if="copied" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M20 6L9 17l-5-5"/></svg>
          <svg v-else class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
          {{ copied ? '已复制' : '复制' }}
        </BaseButton>
      </div>
    </div>
    <template #footer>
      <BaseButton @click="$emit('close')">我已安全保存</BaseButton>
    </template>
  </BaseModal>
</template>
