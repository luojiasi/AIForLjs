<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { authApi } from '@/api'
import { useToast } from '@/composables/useToast'
import type { ApiKey, CreatedApiKey } from '@/types/auth'
import BaseCard from '@/components/common/BaseCard.vue'
import BaseButton from '@/components/common/BaseButton.vue'
import CreateKeyForm from '@/components/keys/CreateKeyForm.vue'
import KeysTable from '@/components/keys/KeysTable.vue'
import KeyRevealModal from '@/components/keys/KeyRevealModal.vue'

const toast = useToast()
const keys = ref<ApiKey[]>([])
const loading = ref(false)
const revealOpen = ref(false)
const newKey = ref<CreatedApiKey | null>(null)

async function loadKeys() {
  loading.value = true
  try { keys.value = await authApi.fetchApiKeys() }
  catch { toast.error('加载密钥列表失败') }
  finally { loading.value = false }
}

async function handleCreate(d: { name: string }) {
  try {
    newKey.value = await authApi.createApiKey(d)
    revealOpen.value = true
    toast.success('密钥创建成功')
    await loadKeys()
  } catch (e) { toast.error(e instanceof Error ? e.message : '创建失败') }
}

async function handleDelete(id: number) {
  try {
    await authApi.deleteApiKey(id)
    toast.success('密钥已删除')
    await loadKeys()
  } catch (e) { toast.error(e instanceof Error ? e.message : '删除失败') }
}

onMounted(loadKeys)
</script>

<template>
  <div class="max-w-5xl space-y-6 p-4 lg:p-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-extrabold text-white tracking-tight">API 密钥</h1>
        <p class="text-sm text-base-500 mt-1">管理平台 API 密钥，用于调用 AI 模型接口</p>
      </div>
    </div>

    <!-- Create form -->
    <BaseCard>
      <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">创建新密钥</h2>
      <CreateKeyForm @create="handleCreate" />
    </BaseCard>

    <!-- Keys list -->
    <BaseCard :padding="false">
      <div class="px-5 py-4 border-b border-white/[0.05]">
        <h2 class="text-[13px] font-bold text-white tracking-tight">我的密钥 · {{ keys.length }}</h2>
      </div>
      <KeysTable :keys="keys" :loading="loading" @delete="handleDelete" />
    </BaseCard>

    <!-- Empty state if no keys -->
    <div v-if="!loading && keys.length === 0" class="text-center py-16">
      <div class="w-16 h-16 rounded-2xl bg-white/[0.03] border border-white/[0.05] flex items-center justify-center mx-auto mb-4">
        <svg class="w-8 h-8 text-base-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/>
        </svg>
      </div>
      <h3 class="text-base font-bold text-white mb-1">开始使用 API</h3>
      <p class="text-sm text-base-500 max-w-sm mx-auto leading-relaxed">创建您的第一把 API 密钥，即可通过 TokenRelay 统一接入多家 AI 厂商的 API。</p>
    </div>

    <KeyRevealModal :open="revealOpen" :apiKey="newKey" @close="revealOpen = false; newKey = null" />
  </div>
</template>
