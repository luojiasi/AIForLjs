import type { VendorName } from './relay'

export interface VendorInfo {
  id: number
  vendor_name: string
  display_name: string
  has_key: boolean
  is_active: boolean
  base_url: string | null
  created_at: string | null
  updated_at: string | null
}

export interface SystemStats {
  total_users: number
  total_api_keys: number
  total_vendors: number
  total_requests: number
  total_tokens: number
  total_cost: number
  active_users_24h: number
  requests_24h: number
  errors_24h: number
  avg_latency_ms: number
}

export interface UserInfo {
  id: number
  username: string
  email: string | null
  role: string
  is_active: boolean
  is_approved: boolean
  quota_total: number
  quota_used: number
  created_at: string
}

export interface UserListResponse {
  items: UserInfo[]
  total: number
}
