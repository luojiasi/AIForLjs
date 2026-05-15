<script setup lang="ts">
</script>

<template>
  <div class="min-h-screen flex items-center justify-center relative overflow-hidden px-4 py-8 lg:py-12 safe-top safe-bottom">
    <!-- Animated gradient background -->
    <div class="absolute inset-0 animate-gradient bg-gradient-to-br from-base-0 via-accent-950/30 to-base-0" />
    <div class="absolute top-1/4 left-1/4 w-[600px] h-[600px] bg-accent-500/10 rounded-full blur-[120px] animate-float" />
    <div class="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] bg-accent-600/8 rounded-full blur-[100px] animate-float" style="animation-delay: 1s;" />

    <!-- Grid pattern -->
    <div class="absolute inset-0 opacity-[0.03]"
      style="background-image: radial-gradient(circle, rgba(255,255,255,0.3) 1px, transparent 1px); background-size: 40px 40px;" />

    <div class="relative w-full max-w-md">
      <!-- Brand -->
      <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-accent-500 to-accent-600 shadow-xl shadow-accent-500/25 mb-5">
          <svg class="w-8 h-8 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
          </svg>
        </div>
        <h1 class="text-2xl font-extrabold text-white tracking-tight">TokenRelay</h1>
        <p class="text-sm text-base-500 mt-1.5 font-medium">AI API Token 中转平台</p>
      </div>

      <!-- Card -->
      <div class="relative">
        <div class="absolute inset-0 bg-gradient-to-br from-accent-500/5 to-transparent rounded-2xl" />
        <div class="relative bg-base-100/80 backdrop-blur-xl border border-white/[0.06] rounded-2xl shadow-2xl shadow-black/20 p-6">
          <router-view />
        </div>
      </div>

      <!-- Footer -->
      <p class="text-center text-xs text-base-600 mt-6">
        安全加密传输 · 多厂商统一接入
      </p>
    </div>
  </div>
</template>
