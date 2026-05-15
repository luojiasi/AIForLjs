import type { ModelInfo, VendorName } from '@/types/relay'

export const VENDOR_NAMES: Record<VendorName, string> = {
  openai: 'OpenAI',
  anthropic: 'Anthropic Claude',
}

export const MODELS: ModelInfo[] = [
  {
    id: 'gpt-4o',
    name: 'GPT-4o',
    max_tokens: 128000,
    pricing: { prompt: 2.50, completion: 10.00 },
    supports_streaming: true,
    supports_vision: true,
  },
  {
    id: 'gpt-4o-mini',
    name: 'GPT-4o Mini',
    max_tokens: 128000,
    pricing: { prompt: 0.15, completion: 0.60 },
    supports_streaming: true,
    supports_vision: true,
  },
  {
    id: 'gpt-4-turbo',
    name: 'GPT-4 Turbo',
    max_tokens: 128000,
    pricing: { prompt: 10.00, completion: 30.00 },
    supports_streaming: true,
    supports_vision: true,
  },
  {
    id: 'claude-sonnet-4-6',
    name: 'Claude Sonnet 4.6',
    max_tokens: 200000,
    pricing: { prompt: 3.00, completion: 15.00 },
    supports_streaming: true,
    supports_vision: true,
  },
  {
    id: 'claude-opus-4-7',
    name: 'Claude Opus 4.7',
    max_tokens: 200000,
    pricing: { prompt: 15.00, completion: 75.00 },
    supports_streaming: true,
    supports_vision: true,
  },
  {
    id: 'claude-haiku-4-5',
    name: 'Claude Haiku 4.5',
    max_tokens: 200000,
    pricing: { prompt: 0.80, completion: 4.00 },
    supports_streaming: true,
    supports_vision: true,
  },
]

export const MODEL_BY_VENDOR: Record<VendorName, ModelInfo[]> = {
  openai: MODELS.filter((m) => m.id.startsWith('gpt')),
  anthropic: MODELS.filter((m) => m.id.startsWith('claude')),
}

export function getModelInfo(modelId: string): ModelInfo | undefined {
  return MODELS.find((m) => m.id === modelId)
}

export function getVendorForModel(modelId: string): VendorName | undefined {
  if (modelId.startsWith('gpt')) return 'openai'
  if (modelId.startsWith('claude')) return 'anthropic'
  return undefined
}

export const QUICK_PROMPTS = [
  { label: '代码审查', content: '请帮我审查以下代码，指出潜在问题、安全隐患和优化建议：' },
  { label: '翻译助手', content: '请将以下内容翻译成英文，保持专业语气：' },
  { label: '写作优化', content: '请润色以下文字，使其更流畅、更有说服力：' },
  { label: '概念解释', content: '请用通俗易懂的语言解释以下概念：' },
  { label: 'SQL 生成', content: '请根据以下需求生成对应的 SQL 查询语句：' },
  { label: 'API 设计', content: '请帮我为以下功能设计 RESTful API 接口：' },
]
