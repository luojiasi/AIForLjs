<script setup lang="ts">
import { ref } from 'vue'
import BaseInput from '@/components/common/BaseInput.vue'
import BaseButton from '@/components/common/BaseButton.vue'

const emit = defineEmits<{ create: [data: { name: string }] }>()

const name = ref('')
const loading = ref(false)
const error = ref('')

async function handleCreate() {
  if (!name.value.trim()) { error.value = '请输入密钥名称'; return }
  error.value = ''; loading.value = true
  try {
    emit('create', { name: name.value.trim() })
    name.value = ''
  } finally { loading.value = false }
}
</script>

<template>
  <div class="flex flex-col sm:flex-row items-start sm:items-end gap-3">
    <div class="flex-1 w-full sm:w-auto">
      <BaseInput v-model="name" label="密钥名称" placeholder="例如：生产环境密钥" :error="error" />
    </div>
    <BaseButton :loading="loading" @click="handleCreate" class="flex-shrink-0">
      <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
      创建密钥
    </BaseButton>
  </div>
</template>
