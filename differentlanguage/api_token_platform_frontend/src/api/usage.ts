import { get } from './client'
import { ENDPOINTS } from '@/constants/endpoints'
import type { UsageStats, DailyUsage, RequestLog, WalletInfo } from '@/types/usage'
import type { PaginatedResponse } from '@/types/common'

export function fetchUsageStats(): Promise<UsageStats> {
  return get<UsageStats>(ENDPOINTS.USAGE_STATS)
}

export function fetchDailyUsage(days?: number): Promise<DailyUsage[]> {
  const url = days
    ? `${ENDPOINTS.USAGE_DAILY}?days=${days}`
    : ENDPOINTS.USAGE_DAILY
  return get<DailyUsage[]>(url)
}

export function fetchRequestLogs(
  page = 1,
  pageSize = 20,
): Promise<PaginatedResponse<RequestLog>> {
  return get<PaginatedResponse<RequestLog>>(
    `${ENDPOINTS.USAGE_REQUESTS}?page=${page}&page_size=${pageSize}`,
  )
}

export function fetchWallet(): Promise<WalletInfo> {
  return get<WalletInfo>(ENDPOINTS.USAGE_WALLET)
}
