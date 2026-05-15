import { get, post, put, del } from './client'
import { ENDPOINTS } from '@/constants/endpoints'
import type { SystemStats, VendorInfo, UserInfo, UserListResponse } from '@/types/admin'

// Stats
export function fetchSystemStats(): Promise<SystemStats> {
  return get<SystemStats>(ENDPOINTS.ADMIN_STATS)
}

// Vendors
export function fetchVendors(): Promise<VendorInfo[]> {
  return get<VendorInfo[]>(ENDPOINTS.ADMIN_VENDORS)
}

export function setVendorKey(
  vendorName: string,
  data: { api_key: string; base_url?: string },
): Promise<{ message: string; vendor_name: string; id: number }> {
  return post(ENDPOINTS.ADMIN_VENDOR_KEY(vendorName), data)
}

export function updateVendor(
  vendorName: string,
  data: { api_key?: string; base_url?: string; is_active?: boolean },
): Promise<{ message: string }> {
  return put(ENDPOINTS.ADMIN_VENDOR(vendorName), data)
}

export function deleteVendor(vendorName: string): Promise<void> {
  return del<void>(ENDPOINTS.ADMIN_VENDOR(vendorName))
}

// Users
export function fetchUsers(page = 1, pageSize = 50): Promise<UserListResponse> {
  return get<UserListResponse>(`${ENDPOINTS.ADMIN_USERS}?page=${page}&page_size=${pageSize}`)
}

export function fetchUser(userId: number): Promise<UserInfo> {
  return get<UserInfo>(ENDPOINTS.ADMIN_USER(userId))
}

export function createUser(data: {
  username: string
  password: string
  email?: string
  role?: string
  is_approved?: boolean
  quota_total?: number
}): Promise<UserInfo> {
  return post<UserInfo>(ENDPOINTS.ADMIN_USERS, data)
}

export function updateUser(
  userId: number,
  data: {
    email?: string
    role?: string
    is_active?: boolean
    is_approved?: boolean
    quota_total?: number
    password?: string
  },
): Promise<UserInfo> {
  return put<UserInfo>(ENDPOINTS.ADMIN_USER(userId), data)
}

export function deleteUser(userId: number): Promise<void> {
  return del<void>(ENDPOINTS.ADMIN_USER(userId))
}

// Pricing
export interface PricingItem {
  id?: number
  model_id: string
  model_name: string
  vendor: string
  cost_input_price: number
  cost_output_price: number
  sell_input_price: number
  sell_output_price: number
  is_active: boolean
}

export function fetchPricing(): Promise<PricingItem[]> {
  return get<PricingItem[]>(ENDPOINTS.ADMIN_PRICING)
}

export function updatePricing(items: PricingItem[]): Promise<{ message: string }> {
  return put<{ message: string }>(ENDPOINTS.ADMIN_PRICING, { items })
}

// Revenue
export interface RevenueStats {
  total_cost: number
  total_revenue: number
  total_profit: number
  total_tokens: number
  profit_margin: number
}

export function fetchRevenue(): Promise<RevenueStats> {
  return get<RevenueStats>(ENDPOINTS.ADMIN_REVENUE)
}

// Global request logs (admin view)
export function fetchRequestLogs(
  page = 1,
  pageSize = 20,
  filters?: { user_id?: number; vendor?: string; status?: string },
) {
  let url = `${ENDPOINTS.ADMIN_REQUESTS}?page=${page}&page_size=${pageSize}`
  if (filters?.user_id) url += `&user_id=${filters.user_id}`
  if (filters?.vendor) url += `&vendor=${filters.vendor}`
  if (filters?.status) url += `&status=${filters.status}`
  return get<{
    items: any[]
    total: number
    page: number
    page_size: number
    total_pages: number
  }>(url)
}
