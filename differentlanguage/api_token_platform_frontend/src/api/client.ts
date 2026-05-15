const TOKEN_KEY = 'tokenrelay_access_token'

export function getAccessToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function setAccessToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token)
}

export function removeAccessToken(): void {
  localStorage.removeItem(TOKEN_KEY)
}

export class ApiError extends Error {
  status: number
  detail: string

  constructor(status: number, detail: string) {
    super(detail)
    this.status = status
    this.detail = detail
    this.name = 'ApiError'
  }
}

async function request<T>(
  url: string,
  options: RequestInit = {},
): Promise<T> {
  const token = getAccessToken()
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  }
  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  const response = await fetch(url, { ...options, headers })

  if (response.status === 401) {
    removeAccessToken()
    window.location.href = '/auth/login'
    throw new ApiError(401, '登录已过期，请重新登录')
  }

  if (response.status === 204) {
    return undefined as T
  }

  let data: Record<string, any> | undefined
  try {
    data = await response.json()
  } catch {
    throw new ApiError(response.status, `服务器错误 (${response.status})`)
  }

  if (!response.ok) {
    throw new ApiError(
      response.status,
      data?.detail || `请求失败 (${response.status})`,
    )
  }

  return data as T
}

export function get<T>(url: string): Promise<T> {
  return request<T>(url, { method: 'GET' })
}

export function post<T>(url: string, body?: unknown): Promise<T> {
  return request<T>(url, {
    method: 'POST',
    body: body ? JSON.stringify(body) : undefined,
  })
}

export function put<T>(url: string, body?: unknown): Promise<T> {
  return request<T>(url, {
    method: 'PUT',
    body: body ? JSON.stringify(body) : undefined,
  })
}

export function del<T>(url: string): Promise<T> {
  return request<T>(url, { method: 'DELETE' })
}
