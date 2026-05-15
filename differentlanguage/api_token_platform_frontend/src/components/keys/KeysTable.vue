<script setup lang="ts">
import type { ApiKey } from '@/types/auth'
import BaseTable from '@/components/common/BaseTable.vue'
import BaseBadge from '@/components/common/BaseBadge.vue'
import BaseButton from '@/components/common/BaseButton.vue'

defineProps<{ keys: ApiKey[]; loading: boolean }>()
defineEmits<{ delete: [id: number] }>()

const cols = [
  { key: 'name', label: '名称' },
  { key: 'key_prefix', label: '密钥前缀' },
  { key: 'is_active', label: '状态' },
  { key: 'last_used_at', label: '最后使用' },
  { key: 'created_at', label: '创建时间' },
  { key: 'actions', label: '操作', align: 'right' as const, width: '80px' },
]

function fmt(d: string | null): string {
  if (!d) return '从未使用'
  return new Date(d).toLocaleString('zh-CN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <BaseTable :columns="cols" :rows="(keys as any)" :loading="loading" emptyText="暂无 API 密钥，请创建一个开始使用">
    <template #cell-name="{ value }">
      <span class="font-semibold text-white/90 text-[13px]">{{ value }}</span>
    </template>
    <template #cell-key_prefix="{ value }">
      <code class="text-xs font-mono bg-white/[0.03] border border-white/[0.04] px-2.5 py-1 rounded-lg text-base-400">{{ value }}...</code>
    </template>
    <template #cell-is_active="{ value }">
      <BaseBadge :variant="value ? 'success' : 'danger'" :dot="true" size="sm">{{ value ? '启用' : '禁用' }}</BaseBadge>
    </template>
    <template #cell-last_used_at="{ value }">
      <span class="text-xs text-base-500">{{ fmt(value as string | null) }}</span>
    </template>
    <template #cell-created_at="{ value }">
      <span class="text-xs text-base-500">{{ fmt(value as string) }}</span>
    </template>
    <template #cell-actions="{ row }">
      <BaseButton variant="ghost" size="xs" @click="$emit('delete', (row as any).id)">删除</BaseButton>
    </template>
  </BaseTable>
</template>
