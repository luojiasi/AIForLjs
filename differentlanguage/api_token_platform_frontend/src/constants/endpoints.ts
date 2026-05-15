export const API_BASE = import.meta.env.VITE_API_BASE ?? '/api'

export const ENDPOINTS = {
  // Auth
  LOGIN: `${API_BASE}/auth/login`,
  REGISTER: `${API_BASE}/auth/register`,
  API_KEYS: `${API_BASE}/auth/api-keys`,
  CREATE_API_KEY: `${API_BASE}/auth/api-keys`,
  DELETE_API_KEY: (id: number) => `${API_BASE}/auth/api-keys/${id}`,

  // Relay
  CHAT_COMPLETIONS: `${API_BASE}/v1/chat/completions`,
  VENDORS: `${API_BASE}/v1/vendors`,
  MODELS: `${API_BASE}/v1/models`,

  // Usage
  USAGE_STATS: `${API_BASE}/usage/stats`,
  USAGE_DAILY: `${API_BASE}/usage/daily`,
  USAGE_REQUESTS: `${API_BASE}/usage/requests`,
  USAGE_WALLET: `${API_BASE}/usage/wallet`,

  // Admin - Stats
  ADMIN_STATS: `${API_BASE}/admin/stats`,

  // Admin - Vendors
  ADMIN_VENDORS: `${API_BASE}/admin/vendors`,
  ADMIN_VENDOR: (vendorName: string) => `${API_BASE}/admin/vendors/${vendorName}`,
  ADMIN_VENDOR_KEY: (vendorName: string) => `${API_BASE}/admin/vendors/${vendorName}/key`,

  // Admin - Users
  ADMIN_USERS: `${API_BASE}/admin/users`,
  ADMIN_USER: (userId: number) => `${API_BASE}/admin/users/${userId}`,

  // Admin - Request Logs
  ADMIN_REQUESTS: `${API_BASE}/admin/requests`,

  // Admin - Pricing
  ADMIN_PRICING: `${API_BASE}/admin/pricing`,
  ADMIN_REVENUE: `${API_BASE}/admin/revenue`,

  // Public
  PUBLIC_PRICING: `${API_BASE}/v1/pricing`,
} as const
