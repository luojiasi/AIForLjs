export const APP_NAME = 'TokenRelay'

export const DEFAULT_MODEL = 'gpt-4o-mini'

export const DEFAULT_PLAYGROUND_SETTINGS = {
  model: DEFAULT_MODEL,
  temperature: 0.7,
  maxTokens: 4096,
  topP: 1.0,
  systemPrompt: '你是一个智能助手，请用中文回答用户的问题。',
}

export const THEME = {
  brand: 'blue',
  sidebar: {
    width: 260,
    collapsedWidth: 72,
  },
}

export const PAGINATION = {
  defaultPageSize: 20,
  pageSizeOptions: [10, 20, 50, 100],
}
