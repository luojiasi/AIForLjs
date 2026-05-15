<script setup lang="ts" generic="T extends Record<string, unknown>">
defineProps<{
  columns: { key: string; label: string; align?: 'left' | 'right' | 'center'; width?: string }[]
  rows: T[]
  loading?: boolean
  emptyText?: string
}>()
</script>

<template>
  <div class="overflow-x-auto -mx-5 sm:mx-0">
    <table class="w-full text-sm">
      <thead>
        <tr class="border-b border-white/[0.04]">
          <th
            v-for="col in columns" :key="col.key"
            class="px-5 py-3 text-[11px] font-semibold text-base-500 uppercase tracking-widest first:pl-5 last:pr-5"
            :style="{ textAlign: col.align || 'left', width: col.width }"
          >
            {{ col.label }}
          </th>
        </tr>
      </thead>
      <tbody>
        <!-- Loading skeletons -->
        <tr v-if="loading" v-for="i in 5" :key="'sk-'+i" class="border-b border-white/[0.02]">
          <td v-for="col in columns" :key="col.key" class="px-5 py-3 first:pl-5 last:pr-5">
            <div class="skeleton h-4 w-full" />
          </td>
        </tr>
        <!-- Empty -->
        <tr v-else-if="rows.length === 0">
          <td :colspan="columns.length" class="px-5 py-16 text-center">
            <div class="flex flex-col items-center gap-2">
              <svg class="w-10 h-10 text-base-600 mb-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round">
                <path d="M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z"/><path d="M13 2v7h7"/>
              </svg>
              <span class="text-sm text-base-500">{{ emptyText || '暂无数据' }}</span>
            </div>
          </td>
        </tr>
        <!-- Rows -->
        <tr
          v-for="(row, idx) in rows" :key="idx"
          class="border-b border-white/[0.02] hover:bg-white/[0.015] transition-colors"
        >
          <td
            v-for="col in columns" :key="col.key"
            class="px-5 py-3 text-base-300 first:pl-5 last:pr-5 whitespace-nowrap"
            :style="{ textAlign: col.align || 'left' }"
          >
            <slot :name="'cell-' + col.key" :row="row" :value="row[col.key]" :index="idx">
              {{ row[col.key] }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
