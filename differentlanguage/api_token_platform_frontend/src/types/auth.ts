export interface User {
  id: number
  username: string
  email: string | null
  role: 'user' | 'admin' | 'super_admin'
  is_active: boolean
  is_approved: boolean
  quota_total: number
  quota_used: number
  quota_reset_at: string | null
  created_at: string
}

export interface LoginRequest {
  username: string
  password: string
}

export interface RegisterRequest {
  username: string
  password: string
  email?: string
}

export interface AuthResponse {
  access_token: string
  token_type: string
  user: User
}

export interface ApiKey {
  id: number
  name: string
  key_prefix: string
  is_active: boolean
  created_at: string
  last_used_at: string | null
}

export interface CreatedApiKey {
  id: number
  name: string
  key_prefix: string
  raw_key: string
  is_active: boolean
  created_at: string
  last_used_at: string | null
}

export interface CreateApiKeyRequest {
  name: string
}
