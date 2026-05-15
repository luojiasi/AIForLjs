<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { adminApi } from '@/api'
import type { PricingItem, RevenueStats } from '@/api/admin'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth'
import { VENDOR_NAMES } from '@/constants/models'
import type { SystemStats, VendorInfo, UserInfo } from '@/types/admin'
import type { VendorName } from '@/types/relay'
import BaseCard from '@/components/common/BaseCard.vue'
import BaseButton from '@/components/common/BaseButton.vue'
import BaseInput from '@/components/common/BaseInput.vue'
import BaseSelect from '@/components/common/BaseSelect.vue'
import BaseBadge from '@/components/common/BaseBadge.vue'
import StatCard from '@/components/common/StatCard.vue'

const auth = useAuthStore()
const { isSuperAdmin } = auth
const toast = useToast()

// ── Tabs ──
type Tab = 'vendors' | 'users' | 'pricing' | 'overview'
const activeTab = ref<Tab>('overview')

// ── System stats ──
const stats = ref<SystemStats | null>(null)
const statsLoading = ref(false)

// ── Vendors ──
const vendors = ref<VendorInfo[]>([])
const vendorsLoading = ref(false)
const showAddVendor = ref(false)
const newVendorName = ref<VendorName>('openai')
const newVendorKey = ref('')
const newVendorUrl = ref('')
const addingVendor = ref(false)

const vendorOpts = (Object.keys(VENDOR_NAMES) as VendorName[]).map(v => ({
  value: v,
  label: VENDOR_NAMES[v],
}))

// ── Users ──
const users = ref<UserInfo[]>([])
const usersTotal = ref(0)
const usersLoading = ref(false)
const showAddUser = ref(false)
const addUserForm = ref({ username: '', password: '', email: '', role: 'user', is_approved: false, quota_total: 1_000_000 })
const editingUserId = ref<number | null>(null)
const editUserForm = ref({ email: '', role: '', is_active: true, is_approved: false, quota_total: 1_000_000, password: '' })

// ── Pricing ──
const pricingItems = ref<PricingItem[]>([])
const pricingLoading = ref(false)
const pricingEditing = ref(false)
const revenue = ref<RevenueStats | null>(null)
const revenueLoading = ref(false)

// ── Load helpers ──

async function loadStats() {
  statsLoading.value = true
  try { stats.value = await adminApi.fetchSystemStats() }
  catch { toast.error('加载系统统计失败') }
  finally { statsLoading.value = false }
}

async function loadVendors() {
  vendorsLoading.value = true
  try { vendors.value = await adminApi.fetchVendors() }
  catch { toast.error('加载厂商列表失败') }
  finally { vendorsLoading.value = false }
}

async function loadUsers() {
  usersLoading.value = true
  try {
    const res = await adminApi.fetchUsers(1, 100)
    users.value = res.items
    usersTotal.value = res.total
  } catch { toast.error('加载用户列表失败') }
  finally { usersLoading.value = false }
}

// ── Vendor actions ──

async function handleAddVendor() {
  if (!newVendorKey.value.trim()) { toast.error('请输入 API 密钥'); return }
  addingVendor.value = true
  try {
    await adminApi.setVendorKey(newVendorName.value, {
      api_key: newVendorKey.value.trim(),
      base_url: newVendorUrl.value.trim() || undefined,
    })
    toast.success('厂商密钥已添加')
    newVendorKey.value = ''
    newVendorUrl.value = ''
    showAddVendor.value = false
    await loadVendors()
  } catch (e) {
    toast.error(e instanceof Error ? e.message : '添加失败')
  } finally { addingVendor.value = false }
}

async function handleToggleVendor(vendorName: string, currentActive: boolean) {
  try {
    await adminApi.updateVendor(vendorName, { is_active: !currentActive })
    toast.success(currentActive ? '已禁用' : '已启用')
    await loadVendors()
  } catch (e) { toast.error(e instanceof Error ? e.message : '操作失败') }
}

async function handleDeleteVendor(vendorName: string) {
  if (!confirm(`确定要删除厂商 "${vendorName}" 的密钥吗？`)) return
  try {
    await adminApi.deleteVendor(vendorName)
    toast.success('已删除')
    await loadVendors()
  } catch (e) { toast.error(e instanceof Error ? e.message : '删除失败') }
}

// ── User actions ──

async function handleAddUser() {
  const f = addUserForm.value
  if (!f.username || !f.password) { toast.error('请填写用户名和密码'); return }
  try {
    await adminApi.createUser({
      username: f.username,
      password: f.password,
      email: f.email || undefined,
      role: f.role,
      is_approved: f.is_approved,
      quota_total: f.quota_total,
    })
    toast.success('用户已创建')
    addUserForm.value = { username: '', password: '', email: '', role: 'user', is_approved: false, quota_total: 1_000_000 }
    showAddUser.value = false
    await loadUsers()
  } catch (e) { toast.error(e instanceof Error ? e.message : '创建失败') }
}

function startEdit(u: UserInfo) {
  editingUserId.value = u.id
  editUserForm.value = {
    email: u.email || '',
    role: u.role,
    is_active: u.is_active,
    is_approved: u.is_approved,
    quota_total: u.quota_total,
    password: '',
  }
}

async function handleEditUser(userId: number) {
  const f = editUserForm.value
  const data: any = {}
  if (f.email !== undefined) data.email = f.email || null
  if (f.role) data.role = f.role
  if (f.is_active !== undefined) data.is_active = f.is_active
  if (f.is_approved !== undefined) data.is_approved = f.is_approved
  if (f.quota_total) data.quota_total = f.quota_total
  if (f.password) data.password = f.password

  try {
    await adminApi.updateUser(userId, data)
    toast.success('用户已更新')
    editingUserId.value = null
    await loadUsers()
  } catch (e) { toast.error(e instanceof Error ? e.message : '更新失败') }
}

async function handleDeleteUser(userId: number, username: string) {
  if (!confirm(`确定要删除用户 "${username}" 吗？此操作不可恢复！`)) return
  try {
    await adminApi.deleteUser(userId)
    toast.success('用户已删除')
    await loadUsers()
  } catch (e) { toast.error(e instanceof Error ? e.message : '删除失败') }
}

// ── Pricing actions ──

async function loadPricing() {
  pricingLoading.value = true
  try { pricingItems.value = await adminApi.fetchPricing() }
  catch { toast.error('加载定价失败') }
  finally { pricingLoading.value = false }
}

async function loadRevenue() {
  revenueLoading.value = true
  try { revenue.value = await adminApi.fetchRevenue() }
  catch { /* non-critical */ }
  finally { revenueLoading.value = false }
}

async function savePricing() {
  try {
    await adminApi.updatePricing(pricingItems.value)
    toast.success('定价已保存')
    pricingEditing.value = false
  } catch (e) { toast.error(e instanceof Error ? e.message : '保存失败') }
}

onMounted(() => {
  loadStats()
  loadVendors()
  loadUsers()
  loadPricing()
  loadRevenue()
})
</script>

<template>
  <div v-if="auth.isAdmin" class="space-y-6 p-4 lg:p-6 max-w-6xl">
    <div>
      <h1 class="text-2xl font-extrabold text-white tracking-tight">管理后台</h1>
      <p class="text-sm text-base-500 mt-1">管理系统、厂商和用户</p>
    </div>

    <!-- System stats -->
    <div v-if="statsLoading" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
      <div v-for="i in 5" :key="i" class="skeleton h-28 rounded-2xl" />
    </div>
    <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
      <StatCard label="总用户" :value="stats?.total_users || 0" />
      <StatCard label="API Keys" :value="stats?.total_api_keys || 0" />
      <StatCard label="总请求" :value="(stats?.total_requests || 0).toLocaleString()" />
      <StatCard label="总Token" :value="stats ? (stats.total_tokens / 1_000_000).toFixed(1) : '0'" unit="M" />
      <StatCard label="总费用" :value="stats ? `$${stats.total_cost.toFixed(2)}` : '$0'" :accent="true" />
    </div>

    <div v-if="!statsLoading" class="grid grid-cols-2 sm:grid-cols-4 gap-4">
      <StatCard label="24h 活跃" :value="stats?.active_users_24h || 0" />
      <StatCard label="24h 请求" :value="(stats?.requests_24h || 0).toLocaleString()" />
      <StatCard label="24h 错误" :value="stats?.errors_24h || 0" :trend="(stats?.errors_24h || 0) > 0 ? 'down' : 'stable'" />
      <StatCard label="平均延迟" :value="stats?.avg_latency_ms || 0" unit="ms" />
    </div>

    <!-- Tabs -->
    <div class="flex gap-1 p-1 bg-white/[0.03] border border-white/[0.05] rounded-xl w-fit overflow-x-auto max-w-full">
      <button
        v-for="tab in (isSuperAdmin ? ['overview', 'vendors', 'users', 'pricing'] as const : ['overview', 'users'] as const)"
        :key="tab"
        @click="activeTab = tab"
        class="px-3 lg:px-4 py-2 rounded-lg text-xs lg:text-sm font-medium transition-all whitespace-nowrap flex-shrink-0"
        :class="activeTab === tab ? 'bg-accent-500/15 text-accent-300' : 'text-base-500 hover:text-base-300'"
      >
        {{ tab === 'overview' ? '概览' : tab === 'vendors' ? '厂商管理' : tab === 'users' ? '用户管理' : '定价策略' }}
      </button>
    </div>

    <!-- ── Vendor Management Tab ── -->
    <section v-if="activeTab === 'vendors'">
      <BaseCard>
        <div class="flex items-center justify-between mb-5">
          <h2 class="text-[13px] font-bold text-white tracking-tight">厂商密钥 · {{ vendors.length }}</h2>
          <BaseButton size="sm" @click="showAddVendor = !showAddVendor">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            {{ showAddVendor ? '取消' : '添加厂商' }}
          </BaseButton>
        </div>

        <!-- Add form -->
        <div v-if="showAddVendor" class="p-4 mb-4 bg-white/[0.02] border border-white/[0.05] rounded-xl">
          <div class="flex flex-col gap-3">
            <div class="flex flex-col sm:flex-row gap-3">
              <BaseSelect label="厂商" :modelValue="newVendorName" :options="vendorOpts" @update:modelValue="newVendorName = $event" />
              <div class="flex-1">
                <BaseInput v-model="newVendorKey" label="API 密钥" type="password" placeholder="sk-... 或 sk-ant-..." />
              </div>
            </div>
            <div class="flex flex-col sm:flex-row gap-3">
              <div class="flex-1">
                <BaseInput v-model="newVendorUrl" label="自定义 Base URL（可选）" placeholder="留空使用默认地址" />
              </div>
              <BaseButton :loading="addingVendor" @click="handleAddVendor" class="flex-shrink-0 self-end">添加密钥</BaseButton>
            </div>
          </div>
        </div>

        <!-- Vendor list -->
        <div class="space-y-3">
          <div v-if="vendorsLoading" v-for="i in 3" :key="i" class="skeleton h-20 rounded-2xl" />
          <div
            v-for="v in vendors"
            :key="v.vendor_name"
            class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-4 bg-white/[0.02] border border-white/[0.05] rounded-xl hover:border-white/[0.08] transition-colors"
          >
            <div class="flex items-center gap-3 lg:gap-4">
              <div class="w-2.5 h-2.5 rounded-full flex-shrink-0" :class="v.is_active ? 'bg-emerald-400 shadow-sm shadow-emerald-400/30' : 'bg-base-600'" />
              <div>
                <div class="text-sm font-semibold text-white/90">{{ v.display_name }}</div>
                <div class="text-xs text-base-500 font-mono">{{ v.vendor_name }}</div>
                <div v-if="v.base_url" class="text-[11px] text-base-600 mt-0.5 truncate max-w-[200px]">{{ v.base_url }}</div>
              </div>
            </div>
            <div class="flex items-center gap-2 flex-shrink-0">
              <BaseBadge :variant="v.has_key ? (v.is_active ? 'success' : 'warning') : 'default'" size="sm" :dot="true">
                {{ v.has_key ? (v.is_active ? '已配置' : '已禁用') : '未配置' }}
              </BaseBadge>
              <BaseButton v-if="v.has_key" variant="ghost" size="xs" @click="handleToggleVendor(v.vendor_name, v.is_active)">
                {{ v.is_active ? '禁用' : '启用' }}
              </BaseButton>
              <BaseButton v-if="v.has_key" variant="ghost" size="xs" class="!text-rose-400 hover:!bg-rose-500/5" @click="handleDeleteVendor(v.vendor_name)">
                删除
              </BaseButton>
            </div>
          </div>
          <p v-if="!vendorsLoading && vendors.length === 0" class="text-center py-12 text-base-500 text-sm">暂无配置的厂商密钥</p>
        </div>
      </BaseCard>
    </section>

    <!-- ── User Management Tab ── -->
    <section v-if="activeTab === 'users'">
      <BaseCard>
        <div class="flex items-center justify-between mb-5">
          <h2 class="text-[13px] font-bold text-white tracking-tight">用户管理 · {{ usersTotal }}</h2>
          <BaseButton size="sm" @click="showAddUser = !showAddUser">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            {{ showAddUser ? '取消' : '添加用户' }}
          </BaseButton>
        </div>

        <!-- Add user form -->
        <div v-if="showAddUser" class="p-4 mb-4 bg-white/[0.02] border border-white/[0.05] rounded-xl">
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-3">
            <BaseInput v-model="addUserForm.username" label="用户名" placeholder="请输入用户名" />
            <BaseInput v-model="addUserForm.password" label="密码" type="password" placeholder="至少6位" />
            <BaseInput v-model="addUserForm.email" label="邮箱（可选）" placeholder="user@example.com" />
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-3">
            <BaseSelect
              label="角色"
              :modelValue="addUserForm.role"
              :options="isSuperAdmin
                ? [{ value: 'user', label: '普通用户' }, { value: 'admin', label: '管理员' }, { value: 'super_admin', label: '超级管理员' }]
                : [{ value: 'user', label: '普通用户' }, { value: 'admin', label: '管理员' }]"
              @update:modelValue="addUserForm.role = $event"
            />
            <BaseSelect
              label="审批"
              :modelValue="addUserForm.is_approved ? 'approved' : 'pending'"
              :options="[{ value: 'approved', label: '已审批' }, { value: 'pending', label: '待审批' }]"
              @update:modelValue="addUserForm.is_approved = $event === 'approved'"
            />
            <BaseInput :modelValue="String(addUserForm.quota_total)" label="Token 配额" type="number" placeholder="1000000" @update:modelValue="addUserForm.quota_total = Number($event) || 0" />
          </div>
          <BaseButton @click="handleAddUser">创建用户</BaseButton>
        </div>

        <!-- User list -->
        <div class="space-y-3">
          <div v-if="usersLoading" v-for="i in 5" :key="i" class="skeleton h-16 rounded-xl" />
          <div
            v-for="u in users"
            :key="u.id"
            class="border border-white/[0.04] rounded-xl overflow-hidden"
          >
            <!-- User row -->
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 p-3 lg:p-4 bg-white/[0.01] hover:bg-white/[0.02] transition-colors cursor-pointer"
              @click="editingUserId === u.id ? (editingUserId = null) : startEdit(u)"
            >
              <div class="flex items-center gap-3 lg:gap-4 min-w-0">
                <div class="w-8 h-8 lg:w-9 lg:h-9 rounded-xl bg-gradient-to-br from-accent-500/20 to-accent-600/20 flex items-center justify-center text-accent-300 text-xs font-bold flex-shrink-0">
                  {{ u.username.charAt(0).toUpperCase() }}
                </div>
                <div class="min-w-0">
                  <div class="flex items-center gap-1.5 lg:gap-2 flex-wrap">
                    <span class="text-sm font-semibold text-white/90 truncate">{{ u.username }}</span>
                    <BaseBadge :variant="u.role === 'super_admin' ? 'danger' : u.role === 'admin' ? 'warning' : 'info'" size="sm">{{ u.role === 'super_admin' ? '超级管理员' : u.role === 'admin' ? '管理员' : '用户' }}</BaseBadge>
                    <BaseBadge :variant="u.is_active ? 'success' : 'danger'" size="sm" :dot="true">{{ u.is_active ? '启用' : '禁用' }}</BaseBadge>
                    <BaseBadge v-if="!u.is_approved" variant="warning" size="sm" :dot="true">待审批</BaseBadge>
                  </div>
                  <div class="text-xs text-base-500 mt-0.5 truncate">
                    {{ u.email || '无邮箱' }} · 配额 {{ ((u.quota_used || 0) / 1_000_000).toFixed(2) }}M / {{ (u.quota_total / 1_000_000).toFixed(1) }}M
                  </div>
                </div>
              </div>
              <div class="flex items-center gap-2 text-xs text-base-500 flex-shrink-0">
                {{ new Date(u.created_at).toLocaleDateString('zh-CN') }}
              </div>
            </div>

            <!-- Edit panel -->
            <div v-if="editingUserId === u.id" class="p-4 border-t border-white/[0.04] bg-white/[0.01]">
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3 mb-3">
                <BaseInput v-model="editUserForm.email" label="邮箱" placeholder="user@example.com" />
                <BaseSelect
                  label="角色"
                  :modelValue="editUserForm.role"
                  :options="isSuperAdmin
                    ? [{ value: 'user', label: '普通用户' }, { value: 'admin', label: '管理员' }, { value: 'super_admin', label: '超级管理员' }]
                    : [{ value: 'user', label: '普通用户' }, { value: 'admin', label: '管理员' }]"
                  @update:modelValue="editUserForm.role = $event"
                />
                <BaseSelect
                  label="账户状态"
                  :modelValue="editUserForm.is_active ? 'active' : 'inactive'"
                  :options="[{ value: 'active', label: '启用' }, { value: 'inactive', label: '禁用' }]"
                  @update:modelValue="editUserForm.is_active = $event === 'active'"
                />
                <BaseSelect
                  label="审批状态"
                  :modelValue="editUserForm.is_approved ? 'approved' : 'pending'"
                  :options="[{ value: 'approved', label: '已审批' }, { value: 'pending', label: '待审批' }]"
                  @update:modelValue="editUserForm.is_approved = $event === 'approved'"
                />
                <BaseInput :modelValue="String(editUserForm.quota_total)" label="Token 配额" type="number" @update:modelValue="editUserForm.quota_total = Number($event) || 0" />
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                <BaseInput v-model="editUserForm.password" label="新密码（留空不修改）" type="password" placeholder="留空则不修改密码" />
              </div>
              <div class="flex items-center justify-between">
                <BaseButton variant="ghost" class="!text-rose-400 hover:!bg-rose-500/5" @click="handleDeleteUser(u.id, u.username)">删除用户</BaseButton>
                <div class="flex gap-2">
                  <BaseButton variant="ghost" @click="editingUserId = null">取消</BaseButton>
                  <BaseButton @click="handleEditUser(u.id)">保存修改</BaseButton>
                </div>
              </div>
            </div>
          </div>
          <p v-if="!usersLoading && users.length === 0" class="text-center py-12 text-base-500 text-sm">暂无用户</p>
        </div>
      </BaseCard>
    </section>

    <!-- ── Pricing Tab ── -->
    <section v-if="activeTab === 'pricing'" class="space-y-6">
      <!-- Revenue summary -->
      <div v-if="revenue" class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard label="总成本" :value="`$${revenue.total_cost.toFixed(2)}`" />
        <StatCard label="总营收" :value="`$${revenue.total_revenue.toFixed(2)}`" :accent="true" />
        <StatCard label="总利润" :value="`$${revenue.total_profit.toFixed(2)}`" trend="up" />
        <StatCard label="利润率" :value="`${revenue.profit_margin}%`" :accent="revenue.profit_margin > 20" />
      </div>

      <BaseCard>
        <div class="flex items-center justify-between mb-5">
          <h2 class="text-[13px] font-bold text-white tracking-tight">模型定价配置</h2>
          <div class="flex gap-2">
            <BaseButton v-if="!pricingEditing" size="sm" variant="secondary" @click="pricingEditing = true; loadPricing()">编辑定价</BaseButton>
            <BaseButton v-if="pricingEditing" size="sm" @click="savePricing()">保存定价</BaseButton>
            <BaseButton v-if="pricingEditing" size="sm" variant="ghost" @click="pricingEditing = false; loadPricing()">取消</BaseButton>
          </div>
        </div>

        <div v-if="pricingLoading" class="space-y-3">
          <div v-for="i in 6" :key="i" class="skeleton h-10 rounded-lg" />
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead>
              <tr class="text-xs text-base-500 font-medium border-b border-white/[0.05]">
                <th class="text-left py-3 px-2">模型</th>
                <th class="text-left py-3 px-2">厂商</th>
                <th class="text-right py-3 px-2">成本输入价</th>
                <th class="text-right py-3 px-2">成本输出价</th>
                <th class="text-right py-3 px-2">售价输入</th>
                <th class="text-right py-3 px-2">售价输出</th>
                <th class="text-right py-3 px-2">利润率</th>
                <th class="text-center py-3 px-2">状态</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in pricingItems" :key="item.model_id" class="border-b border-white/[0.02] hover:bg-white/[0.01]">
                <td class="py-2.5 px-2">
                  <span class="text-white/90 font-medium">{{ item.model_name }}</span>
                  <div class="text-[11px] text-base-500 font-mono">{{ item.model_id }}</div>
                </td>
                <td class="py-2.5 px-2">
                  <BaseBadge size="sm" :variant="item.vendor === 'openai' ? 'info' : 'warning'">{{ item.vendor }}</BaseBadge>
                </td>
                <td class="py-2.5 px-2 text-right font-mono text-base-400" v-if="!pricingEditing">${{ item.cost_input_price.toFixed(2) }}</td>
                <td class="py-2.5 px-2 text-right font-mono text-base-400" v-if="!pricingEditing">${{ item.cost_output_price.toFixed(2) }}</td>
                <td class="py-2.5 px-2 text-right font-mono text-accent-300" v-if="!pricingEditing">${{ item.sell_input_price.toFixed(2) }}</td>
                <td class="py-2.5 px-2 text-right font-mono text-accent-300" v-if="!pricingEditing">${{ item.sell_output_price.toFixed(2) }}</td>
                <td class="py-2.5 px-2" v-if="pricingEditing"><input type="number" step="0.01" v-model.number="item.cost_input_price" class="w-20 bg-base-0 border border-white/[0.08] rounded-lg px-2 py-1 text-right text-xs font-mono text-base-300 focus:outline-none focus:border-accent-500/30" /></td>
                <td class="py-2.5 px-2" v-if="pricingEditing"><input type="number" step="0.01" v-model.number="item.cost_output_price" class="w-20 bg-base-0 border border-white/[0.08] rounded-lg px-2 py-1 text-right text-xs font-mono text-base-300 focus:outline-none focus:border-accent-500/30" /></td>
                <td class="py-2.5 px-2" v-if="pricingEditing"><input type="number" step="0.01" v-model.number="item.sell_input_price" class="w-20 bg-base-0 border border-white/[0.08] rounded-lg px-2 py-1 text-right text-xs font-mono text-accent-300 focus:outline-none focus:border-accent-500/30" /></td>
                <td class="py-2.5 px-2" v-if="pricingEditing"><input type="number" step="0.01" v-model.number="item.sell_output_price" class="w-20 bg-base-0 border border-white/[0.08] rounded-lg px-2 py-1 text-right text-xs font-mono text-accent-300 focus:outline-none focus:border-accent-500/30" /></td>
                <td class="py-2.5 px-2 text-right">
                  <span v-if="item.sell_input_price > 0" class="font-mono text-emerald-400 text-xs">{{ (((item.sell_input_price + item.sell_output_price) - (item.cost_input_price + item.cost_output_price)) / (item.sell_input_price + item.sell_output_price) * 100).toFixed(0) }}%</span>
                  <span v-else class="text-base-500 text-xs">-</span>
                </td>
                <td class="py-2.5 px-2 text-center">
                  <BaseBadge size="sm" :variant="item.is_active ? 'success' : 'danger'" :dot="true">{{ item.is_active ? '启用' : '禁用' }}</BaseBadge>
                </td>
              </tr>
            </tbody>
          </table>
          <p v-if="pricingItems.length === 0" class="text-center py-12 text-base-500 text-sm">暂无定价配置，系统将使用默认价格</p>
        </div>
      </BaseCard>
    </section>

    <!-- ── Overview Tab ── -->
    <section v-if="activeTab === 'overview'" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Revenue quick view (super admin only) -->
      <BaseCard v-if="isSuperAdmin && revenue">
        <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">营收概览</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <div class="text-xs text-base-500">总成本</div>
            <div class="text-lg font-bold text-white font-mono">${{ revenue.total_cost.toFixed(2) }}</div>
          </div>
          <div>
            <div class="text-xs text-base-500">总营收</div>
            <div class="text-lg font-bold text-accent-300 font-mono">${{ revenue.total_revenue.toFixed(2) }}</div>
          </div>
          <div>
            <div class="text-xs text-base-500">总利润</div>
            <div class="text-lg font-bold text-emerald-400 font-mono">${{ revenue.total_profit.toFixed(2) }}</div>
          </div>
          <div>
            <div class="text-xs text-base-500">利润率</div>
            <div class="text-lg font-bold text-white font-mono">{{ revenue.profit_margin }}%</div>
          </div>
        </div>
      </BaseCard>

      <BaseCard v-if="isSuperAdmin">
        <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">厂商状态</h2>
        <div class="space-y-3">
          <div v-if="vendorsLoading" v-for="i in 3" :key="i" class="skeleton h-8 rounded-lg" />
          <div v-else v-for="v in vendors" :key="v.vendor_name" class="flex items-center justify-between py-2 border-b border-white/[0.03] last:border-0">
            <div class="flex items-center gap-2.5">
              <div class="w-2 h-2 rounded-full" :class="v.is_active ? 'bg-emerald-400' : 'bg-base-600'" />
              <span class="text-sm text-white/90">{{ v.display_name }}</span>
            </div>
            <BaseBadge :variant="v.has_key ? (v.is_active ? 'success' : 'warning') : 'default'" size="sm">
              {{ v.has_key ? (v.is_active ? '在线' : '禁用') : '未配置' }}
            </BaseBadge>
          </div>
        </div>
      </BaseCard>

      <BaseCard>
        <h2 class="text-[13px] font-bold text-white tracking-tight mb-4">最近用户</h2>
        <div v-if="usersLoading" class="space-y-3">
          <div v-for="i in 5" :key="i" class="skeleton h-8 rounded-lg" />
        </div>
        <div v-else class="space-y-3">
          <div v-for="u in users.slice(0, 10)" :key="u.id" class="flex items-center justify-between py-2 border-b border-white/[0.03] last:border-0">
            <div class="flex items-center gap-2.5">
              <div class="w-7 h-7 rounded-lg bg-white/[0.04] flex items-center justify-center text-[11px] font-bold text-base-400">
                {{ u.username.charAt(0).toUpperCase() }}
              </div>
              <div>
                <div class="text-sm font-medium text-white/90">{{ u.username }}</div>
                <div class="text-[11px] text-base-500">{{ u.email || '-' }}</div>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <BaseBadge :variant="u.role === 'super_admin' ? 'danger' : u.role === 'admin' ? 'warning' : 'info'" size="sm">{{ u.role === 'super_admin' ? '超级管理员' : u.role === 'admin' ? '管理员' : '用户' }}</BaseBadge>
              <span class="text-xs text-base-500">{{ u.is_active ? '' : '(已禁用)' }}</span>
            </div>
          </div>
        </div>
      </BaseCard>
    </section>
  </div>
</template>
