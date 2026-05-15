<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usageApi } from '@/api'
import { useToast } from '@/composables/useToast'
import type { UsageStats, RequestLog } from '@/types/usage'
import BaseCard from '@/components/common/BaseCard.vue'
import StatCard from '@/components/common/StatCard.vue'
import QuotaGauge from '@/components/usage/QuotaGauge.vue'
import RecentRequests from '@/components/usage/RecentRequests.vue'

const toast = useToast()
const stats = ref<UsageStats | null>(null)
const requests = ref<RequestLog[]>([])
const statsLoading = ref(false)
const reqLoading = ref(false)

async function load() {
  statsLoading.value = true
  try { stats.value = await usageApi.fetchUsageStats() }
  catch { toast.error('加载用量统计失败') }
  finally { statsLoading.value = false }

  reqLoading.value = true
  try { requests.value = (await usageApi.fetchRequestLogs(1, 20)).items }
  catch { toast.error('加载请求记录失败') }
  finally { reqLoading.value = false }
}

onMounted(load)
</script>

<template>
  <div class="space-y-6 p-4 lg:p-6 max-w-6xl">
    <div>
      <h1 class="text-2xl font-extrabold text-white tracking-tight">用量统计</h1>
      <p class="text-sm text-base-500 mt-1">追踪 API 使用和配额消耗</p>
    </div>

    <!-- Stat cards -->
    <div v-if="statsLoading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div v-for="i in 4" :key="i" class="skeleton h-28 rounded-2xl" />
    </div>
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <StatCard label="今日 Token" :value="(stats?.today.tokens || 0).toLocaleString()" :trend="(stats?.today.tokens || 0) > 0 ? 'up' : 'stable'" :trend-value="stats ? `$${stats.today.cost.toFixed(4)}` : ''" />
      <StatCard label="今日请求" :value="stats?.today.requests || 0" unit="次" />
      <StatCard label="总 Token" :value="stats ? (stats.total.tokens / 1_000_000).toFixed(2) : '0'" unit="M" :trend-value="stats ? `$${stats.total.cost.toFixed(2)}` : ''" />
      <StatCard label="总请求" :value="(stats?.total.requests || 0).toLocaleString()" unit="次" />
    </div>

    <!-- Quota -->
    <BaseCard v-if="stats">
      <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">配额使用</h2>
      <QuotaGauge :used="stats.quota.used" :total="stats.quota.total" label="Token 配额" />
      <p class="text-xs text-base-500 mt-4">下次重置: {{ new Date(stats.quota.reset_at).toLocaleString('zh-CN', { month: 'long', day: 'numeric' }) }}</p>
    </BaseCard>

    <!-- Breakdown -->
    <div v-if="stats" class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <BaseCard>
        <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">按厂商统计</h2>
        <div class="space-y-3">
          <div v-for="v in stats.by_vendor" :key="v.vendor" class="flex items-center justify-between py-2.5 border-b border-white/[0.03] last:border-0">
            <span class="text-sm font-semibold text-white/90">{{ v.vendor }}</span>
            <div class="text-right">
              <div class="text-sm font-mono font-semibold text-base-300">{{ v.total_tokens.toLocaleString() }}</div>
              <div class="text-[11px] text-base-500">{{ v.requests }} 次 · ${{ v.cost.toFixed(4) }}</div>
            </div>
          </div>
        </div>
      </BaseCard>
      <BaseCard>
        <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">按模型统计</h2>
        <div class="space-y-3">
          <div v-for="m in stats.by_model" :key="m.model" class="flex items-center justify-between py-2.5 border-b border-white/[0.03] last:border-0">
            <div>
              <div class="text-sm font-semibold text-white/90">{{ m.model }}</div>
              <div class="text-[11px] text-base-500">{{ m.vendor }}</div>
            </div>
            <div class="text-right">
              <div class="text-sm font-mono font-semibold text-base-300">{{ m.total_tokens.toLocaleString() }}</div>
              <div class="text-[11px] text-base-500">{{ m.requests }} 次 · ${{ m.cost.toFixed(4) }}</div>
            </div>
          </div>
        </div>
      </BaseCard>
    </div>

    <!-- Recent requests -->
    <BaseCard :padding="false">
      <div class="px-5 py-4 border-b border-white/[0.05]">
        <h2 class="text-[13px] font-bold text-white tracking-tight">最近请求</h2>
      </div>
      <RecentRequests :requests="requests" :loading="reqLoading" />
    </BaseCard>
  </div>
</template>
