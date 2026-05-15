<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usageApi } from '@/api'
import { useToast } from '@/composables/useToast'
import type { WalletInfo } from '@/types/usage'
import BaseCard from '@/components/common/BaseCard.vue'
import BaseButton from '@/components/common/BaseButton.vue'
import BaseBadge from '@/components/common/BaseBadge.vue'
import StatCard from '@/components/common/StatCard.vue'

const toast = useToast()
const wallet = ref<WalletInfo | null>(null)
const loading = ref(false)

async function loadWallet() {
  loading.value = true
  try { wallet.value = await usageApi.fetchWallet() }
  catch { toast.error('加载钱包信息失败') }
  finally { loading.value = false }
}

function formatAmount(amount: number): string {
  const sign = amount >= 0 ? '+' : ''
  return `${sign}$${amount.toFixed(2)}`
}

onMounted(loadWallet)
</script>

<template>
  <div class="max-w-4xl space-y-6 p-4 lg:p-6">
    <div>
      <h1 class="text-2xl font-extrabold text-white tracking-tight">我的钱包</h1>
      <p class="text-sm text-base-500 mt-1">管理账户余额，查看充值和使用记录</p>
    </div>

    <!-- Balance highlight -->
    <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div v-for="i in 3" :key="i" class="skeleton h-28 rounded-2xl" />
    </div>
    <div v-else-if="wallet" class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="col-span-1 sm:col-span-3 lg:col-span-1 p-5 rounded-2xl bg-gradient-to-br from-accent-500/10 to-accent-600/5 border border-accent-500/15 flex flex-col justify-center">
        <div class="text-xs text-base-500 font-medium mb-1">可用余额</div>
        <div class="text-3xl font-extrabold text-white font-mono tracking-tight">${{ wallet.balance.toFixed(2) }}</div>
        <div class="text-xs text-base-500 mt-2">余额用于 API 调用时自动扣费</div>
      </div>
      <StatCard label="累计充值" :value="`$${wallet.total_charged.toFixed(2)}`" :accent="true" />
      <StatCard label="累计消费" :value="`$${wallet.total_spent.toFixed(2)}`" />
    </div>

    <!-- No wallet yet -->
    <div v-if="!loading && !wallet" class="text-center py-16">
      <div class="w-16 h-16 rounded-2xl bg-white/[0.03] border border-white/[0.05] flex items-center justify-center mx-auto mb-4">
        <svg class="w-8 h-8 text-base-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/>
        </svg>
      </div>
      <h3 class="text-base font-bold text-white mb-1">暂无钱包信息</h3>
      <p class="text-sm text-base-500 max-w-sm mx-auto leading-relaxed">请联系管理员为您的账户充值</p>
    </div>

    <!-- Transactions -->
    <BaseCard :padding="false">
      <div class="px-5 py-4 border-b border-white/[0.05]">
        <h2 class="text-[13px] font-bold text-white tracking-tight">交易记录</h2>
      </div>
      <div v-if="wallet && wallet.transactions.length > 0" class="divide-y divide-white/[0.03]">
        <div
          v-for="t in wallet.transactions"
          :key="t.id"
          class="flex items-center justify-between px-5 py-3 hover:bg-white/[0.01] transition-colors"
        >
          <div class="flex items-center gap-3">
            <div
              class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
              :class="t.type === 'topup' ? 'bg-emerald-500/10 text-emerald-400' : 'bg-amber-500/10 text-amber-400'"
            >
              <svg v-if="t.type === 'topup'" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
              <svg v-else class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M5 12h14"/></svg>
            </div>
            <div>
              <div class="text-sm font-medium text-white/90">{{ t.description }}</div>
              <div class="text-[11px] text-base-500">{{ new Date(t.created_at).toLocaleString('zh-CN') }}</div>
            </div>
          </div>
          <div class="text-right">
            <div class="text-sm font-mono font-semibold" :class="t.amount >= 0 ? 'text-emerald-400' : 'text-amber-400'">
              {{ formatAmount(t.amount) }}
            </div>
            <div class="text-[11px] text-base-500 font-mono">余额 ${{ t.balance_after.toFixed(2) }}</div>
          </div>
        </div>
      </div>
      <div v-else class="px-5 py-12 text-center">
        <p class="text-sm text-base-500">暂无交易记录</p>
      </div>
    </BaseCard>

    <!-- Help text -->
    <div class="text-center">
      <p class="text-xs text-base-500">
        充值请联系管理员 · 余额将在 API 调用时自动扣减 ·
        <router-link to="/docs" class="text-accent-400 hover:text-accent-300 transition-colors">查看 API 文档</router-link>
      </p>
    </div>
  </div>
</template>
