<script setup lang="ts">
import type { RequestLog } from '@/types/usage'
import BaseTable from '@/components/common/BaseTable.vue'
import BaseBadge from '@/components/common/BaseBadge.vue'

defineProps<{ requests: RequestLog[]; loading: boolean }>()

const cols = [
  { key: 'model', label: '模型' },
  { key: 'vendor', label: '厂商' },
  { key: 'total_tokens', label: 'Token 用量', align: 'right' as const },
  { key: 'cost', label: '费用', align: 'right' as const },
  { key: 'latency_ms', label: '延迟', align: 'right' as const },
  { key: 'status', label: '状态' },
  { key: 'created_at', label: '时间' },
]

function fmt(d: string): string {
  return new Date(d).toLocaleString('zh-CN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function latencyColor(ms: number): string {
  if (ms < 500) return 'text-emerald-400'
  if (ms < 1500) return 'text-amber-400'
  return 'text-rose-400'
}
</script>

<template>
  <BaseTable :columns="cols" :rows="(requests as any)" :loading="loading" emptyText="暂无请求记录">
    <template #cell-model="{ value }">
      <code class="text-xs font-mono bg-white/[0.03] px-2 py-0.5 rounded-lg text-base-300">{{ value }}</code>
    </template>
    <template #cell-vendor="{ value }">
      <span class="text-xs">{{ value }}</span>
    </template>
    <template #cell-total_tokens="{ value }">
      <span class="font-mono text-xs tabular-nums font-medium text-base-300">{{ (value as number).toLocaleString() }}</span>
    </template>
    <template #cell-cost="{ value }">
      <span class="font-mono text-xs font-semibold text-emerald-400 tabular-nums">${{ (value as number).toFixed(6) }}</span>
    </template>
    <template #cell-latency_ms="{ value }">
      <span class="font-mono text-xs font-medium tabular-nums" :class="latencyColor(value as number)">{{ value }}ms</span>
    </template>
    <template #cell-status="{ value }">
      <BaseBadge :variant="value === 'success' ? 'success' : 'danger'" :dot="true" size="sm">
        {{ value === 'success' ? '成功' : '失败' }}
      </BaseBadge>
    </template>
    <template #cell-created_at="{ value }">
      <span class="text-xs text-base-500">{{ fmt(value as string) }}</span>
    </template>
  </BaseTable>
</template>
