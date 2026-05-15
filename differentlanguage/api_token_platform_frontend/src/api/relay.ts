import { post, get } from './client'
import { ENDPOINTS } from '@/constants/endpoints'
import type {
  ChatCompletionRequest,
  ChatCompletionResponse,
  VendorInfo,
} from '@/types/relay'

export function sendChatCompletion(
  data: ChatCompletionRequest,
): Promise<ChatCompletionResponse> {
  return post<ChatCompletionResponse>(ENDPOINTS.CHAT_COMPLETIONS, data)
}

export function fetchVendors(): Promise<VendorInfo[]> {
  return get<VendorInfo[]>(ENDPOINTS.VENDORS)
}
