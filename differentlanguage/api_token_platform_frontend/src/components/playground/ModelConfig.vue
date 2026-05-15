<script setup lang="ts">
import { useChatStore } from '@/stores/chat'
import { MODELS, MODEL_BY_VENDOR, VENDOR_NAMES } from '@/constants/models'
import type { VendorName } from '@/types/relay'

const chat = useChatStore()
const vendorKeys = Object.keys(MODEL_BY_VENDOR) as VendorName[]
const currentVendor: VendorName = chat.settings.model.startsWith('claude') ? 'anthropic' : 'openai'
const currentModel = MODELS.find(m => m.id === chat.settings.model)
</script>

<template>
  <div class="space-y-4">
    <!-- Vendor selector - Tabs -->
    <div>
      <div class="text-[12px] font-semibold text-base-500 tracking-wide uppercase mb-2">厂商</div>
      <div class="grid grid-cols-2 gap-2">
        <button
          v-for="v in vendorKeys" :key="v"
          @click="chat.updateSetting('model', MODEL_BY_VENDOR[v][0]?.id || chat.settings.model)"
          class="flex items-center gap-2 px-3 py-2.5 rounded-xl border text-sm font-medium transition-all duration-200"
          :class="currentVendor === v
            ? 'bg-accent-500/8 border-accent-500/20 text-accent-300'
            : 'border-white/[0.06] text-base-400 hover:border-white/[0.1] hover:text-base-300'"
        >
          <span class="w-5 h-5 rounded-md flex items-center justify-center text-xs font-bold"
            :class="currentVendor === v ? 'bg-accent-500/20 text-accent-300' : 'bg-white/[0.04] text-base-400'">
            {{ VENDOR_NAMES[v]?.charAt(0) }}
          </span>
          {{ VENDOR_NAMES[v]?.split(' ')[0] }}
        </button>
      </div>
    </div>

    <!-- Model selector -->
    <div>
      <div class="text-[12px] font-semibold text-base-500 tracking-wide uppercase mb-2">模型</div>
      <div class="space-y-1">
        <button
          v-for="m in MODEL_BY_VENDOR[currentVendor]" :key="m.id"
          @click="chat.updateSetting('model', m.id)"
          class="w-full text-left px-3 py-2.5 rounded-xl border transition-all duration-200"
          :class="chat.settings.model === m.id
            ? 'bg-accent-500/5 border-accent-500/15'
            : 'border-transparent hover:bg-white/[0.02]'"
        >
          <div class="flex items-center justify-between">
            <span class="text-[13px] font-semibold" :class="chat.settings.model === m.id ? 'text-accent-300' : 'text-white/90'">
              {{ m.name }}
            </span>
            <span v-if="chat.settings.model === m.id" class="w-2 h-2 rounded-full bg-accent-400" />
          </div>
          <div class="flex items-center gap-3 mt-1 text-[11px] text-base-500">
            <span class="font-mono">{{ (m.max_tokens / 1000).toFixed(0) }}K ctx</span>
            <span>${{ m.pricing.prompt }}/${{ m.pricing.completion }}</span>
          </div>
        </button>
      </div>
    </div>

    <!-- Pricing info -->
    <div v-if="currentModel" class="p-3 rounded-xl bg-white/[0.02] border border-white/[0.04] space-y-1.5">
      <div class="flex justify-between text-[11px]">
        <span class="text-base-500">输入价格</span>
        <span class="text-base-300 font-mono font-medium">${{ currentModel.pricing.prompt }}/1M tokens</span>
      </div>
      <div class="flex justify-between text-[11px]">
        <span class="text-base-500">输出价格</span>
        <span class="text-base-300 font-mono font-medium">${{ currentModel.pricing.completion }}/1M tokens</span>
      </div>
    </div>
  </div>
</template>
