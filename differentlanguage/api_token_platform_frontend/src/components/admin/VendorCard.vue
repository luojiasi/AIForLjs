<script setup lang="ts">
import type { VendorInfo } from '@/types/admin'
import BaseBadge from '@/components/common/BaseBadge.vue'
import BaseButton from '@/components/common/BaseButton.vue'
import { ref } from 'vue'
import { VENDOR_NAMES } from '@/constants/models'
import type { VendorName } from '@/types/relay'

const props = defineProps<{ vendor: VendorInfo }>()
const emit = defineEmits<{ toggle: [vendorName: string]; delete: [vendorName: string] }>()

const confirmDelete = ref(false)

function displayName(vendorName: string): string {
  return VENDOR_NAMES[vendorName as VendorName] || vendorName
}

function fmt(d: string | null): string {
  if (!d) return '未知'
  return new Date(d).toLocaleString('zh-CN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <div class="group rounded-2xl border border-white/[0.05] bg-base-100 hover:border-white/[0.08] transition-all duration-200 p-5">
    <div class="flex items-start justify-between">
      <div class="flex items-center gap-4">
        <div class="w-11 h-11 rounded-xl flex items-center justify-center text-lg font-extrabold"
          :class="vendor.is_active ? 'bg-accent-500/8 text-accent-400 border border-accent-500/15' : 'bg-white/[0.03] text-base-500 border border-white/[0.05]'"
        >
          {{ displayName(vendor.vendor_name).charAt(0) }}
        </div>
        <div>
          <div class="flex items-center gap-2.5">
            <h3 class="font-bold text-white/90 text-sm">{{ displayName(vendor.vendor_name) }}</h3>
            <BaseBadge :variant="vendor.is_active ? 'success' : 'danger'" :dot="true" size="sm">
              {{ vendor.is_active ? '已连接' : '已禁用' }}
            </BaseBadge>
          </div>
          <p class="text-xs text-base-500 mt-1 font-mono">{{ vendor.vendor_name }}</p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <BaseButton size="sm" :variant="vendor.is_active ? 'secondary' : 'primary'" @click="emit('toggle', vendor.vendor_name)">
          {{ vendor.is_active ? '禁用' : '启用' }}
        </BaseButton>
        <BaseButton v-if="!confirmDelete" size="sm" variant="ghost" @click="confirmDelete = true">删除</BaseButton>
        <BaseButton v-else size="sm" variant="danger" @click="emit('delete', vendor.vendor_name)">确认</BaseButton>
      </div>
    </div>
    <div class="mt-4 grid grid-cols-3 gap-3 text-xs text-base-500">
      <div>状态: <span class="text-base-300 font-semibold">{{ vendor.has_key ? (vendor.is_active ? '运行中' : '已禁用') : '未配置' }}</span></div>
      <div>Base URL: <span class="text-base-300">{{ vendor.base_url || '默认' }}</span></div>
      <div>更新于: <span class="text-base-300">{{ fmt(vendor.updated_at) }}</span></div>
    </div>
  </div>
</template>
