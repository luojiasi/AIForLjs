export type MessageRole = 'system' | 'user' | 'assistant'

export interface ChatMessage {
  role: MessageRole
  content: string
}

export interface ChatCompletionRequest {
  model: string
  messages: ChatMessage[]
  max_tokens?: number
  temperature?: number
  top_p?: number
  stream?: boolean
  vendor?: string
}

export interface TokenUsage {
  prompt_tokens: number
  completion_tokens: number
  total_tokens: number
}

export interface ChatChoice {
  index: number
  message: ChatMessage
  finish_reason: string | null
}

export interface ChatCompletionResponse {
  id: string
  object: string
  created: number
  model: string
  vendor: string
  choices: ChatChoice[]
  usage: TokenUsage
  cost: number
  latency_ms: number
}

export type VendorName = 'openai' | 'anthropic'

export interface VendorInfo {
  id: string
  name: string
  models: ModelInfo[]
  is_active: boolean
}

export interface ModelInfo {
  id: string
  name: string
  max_tokens: number
  pricing: {
    prompt: number
    completion: number
  }
  supports_streaming: boolean
  supports_vision: boolean
}

export interface PlaygroundSettings {
  model: string
  temperature: number
  maxTokens: number
  topP: number
  systemPrompt: string
}
