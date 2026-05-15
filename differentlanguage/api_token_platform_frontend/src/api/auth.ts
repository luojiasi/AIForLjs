import { post, get, del } from './client'
import { ENDPOINTS } from '@/constants/endpoints'
import type {
  AuthResponse,
  LoginRequest,
  RegisterRequest,
  ApiKey,
  CreatedApiKey,
  CreateApiKeyRequest,
} from '@/types/auth'

export function login(data: LoginRequest): Promise<AuthResponse> {
  return post<AuthResponse>(ENDPOINTS.LOGIN, data)
}

export function register(data: RegisterRequest): Promise<AuthResponse> {
  return post<AuthResponse>(ENDPOINTS.REGISTER, data)
}

export function fetchApiKeys(): Promise<ApiKey[]> {
  return get<ApiKey[]>(ENDPOINTS.API_KEYS)
}

export function createApiKey(data: CreateApiKeyRequest): Promise<CreatedApiKey> {
  return post<CreatedApiKey>(ENDPOINTS.CREATE_API_KEY, data)
}

export function deleteApiKey(id: number): Promise<void> {
  return del<void>(ENDPOINTS.DELETE_API_KEY(id))
}
