export interface QuotaInfo {
  total: number
  used: number
  remaining: number
  reset_at: string
  usage_percent: number
}

export interface DailyUsage {
  date: string
  prompt_tokens: number
  completion_tokens: number
  total_tokens: number
  cost: number
  requests: number
}

export interface RequestLog {
  id: number
  model: string
  vendor: string
  prompt_tokens: number
  completion_tokens: number
  total_tokens: number
  cost: number
  latency_ms: number
  status: 'success' | 'error'
  created_at: string
}

export interface VendorUsage {
  vendor: string
  total_tokens: number
  cost: number
  requests: number
}

export interface ModelUsage {
  model: string
  vendor: string
  total_tokens: number
  cost: number
  requests: number
}

export interface UsageStats {
  quota: QuotaInfo
  today: {
    tokens: number
    cost: number
    requests: number
  }
  total: {
    tokens: number
    cost: number
    requests: number
  }
  by_vendor: VendorUsage[]
  by_model: ModelUsage[]
  daily: DailyUsage[]
}

export interface WalletTransaction {
  id: number
  amount: number
  type: 'topup' | 'consume'
  description: string
  balance_after: number
  created_at: string
}

export interface WalletInfo {
  balance: number
  total_charged: number
  total_spent: number
  transactions: WalletTransaction[]
}
