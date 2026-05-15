<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
auth.initFromStorage()
</script>

<template>
  <router-view />
</template>
