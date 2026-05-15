<script setup lang="ts">
import { ref } from 'vue'
import BaseCard from '@/components/common/BaseCard.vue'
import BaseButton from '@/components/common/BaseButton.vue'

const activeTab = ref<'curl' | 'python' | 'javascript'>('curl')
const copied = ref('')

const codeSnippets = {
  curl: `# 1. 获取 API Key（登录后在平台创建）
# 2. 调用 Chat Completions API

curl https://your-domain.com/api/v1/chat/completions \\
  -H "Authorization: Bearer atp_YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ],
    "max_tokens": 1024,
    "temperature": 0.7
  }'`,

  python: `import requests

API_KEY = "atp_YOUR_API_KEY"
BASE_URL = "https://your-domain.com/api"

response = requests.post(
    f"{BASE_URL}/v1/chat/completions",
    headers={
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    },
    json={
        "model": "gpt-4o-mini",
        "messages": [
            {"role": "user", "content": "Hello, how are you?"}
        ],
        "max_tokens": 1024,
        "temperature": 0.7,
    },
)

data = response.json()
print(data["choices"][0]["message"]["content"])
print("Tokens:", data["usage"]["total_tokens"])
print("Cost: $" + str(data["cost"]))`,

  javascript: `const API_KEY = "atp_YOUR_API_KEY";
const BASE_URL = "https://your-domain.com/api";

async function chat(prompt) {
  const res = await fetch(BASE_URL + "/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": "Bearer " + API_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 1024,
      temperature: 0.7,
    }),
  });

  const data = await res.json();
  console.log(data.choices[0].message.content);
  console.log("Tokens:", data.usage.total_tokens);
  console.log("Cost: $" + data.cost.toFixed(6));
}

chat("Hello, how are you?");`,
}

function copyCode(code: string) {
  navigator.clipboard.writeText(code)
  copied.value = code
  setTimeout(() => { copied.value = '' }, 2000)
}
</script>

<template>
  <div class="max-w-4xl space-y-6 lg:space-y-8 p-4 lg:p-6">
    <div>
      <h1 class="text-2xl font-extrabold text-white tracking-tight">API 文档</h1>
      <p class="text-sm text-base-500 mt-1">快速开始使用 TokenRelay API</p>
    </div>

    <!-- Authentication -->
    <BaseCard>
      <h2 class="text-lg font-bold text-white mb-4">认证方式</h2>
      <p class="text-sm text-base-400 leading-relaxed mb-4">所有 API 请求需要在 Authorization 头中携带平台 API Key（以 <code class="bg-white/[0.04] px-1.5 py-0.5 rounded text-accent-300 text-xs font-mono">atp_</code> 开头）。</p>
      <div class="p-4 bg-base-0 border border-white/[0.06] rounded-xl font-mono text-sm text-base-300">
        Authorization: Bearer <span class="text-accent-300">atp_YOUR_API_KEY</span>
      </div>
      <p class="text-xs text-base-500 mt-3">登录后在 <router-link to="/api-keys" class="text-accent-400 hover:text-accent-300">API 密钥</router-link> 页面创建和管理密钥。</p>
    </BaseCard>

    <!-- Chat Completions -->
    <BaseCard>
      <h2 class="text-lg font-bold text-white mb-4">
        <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 text-xs font-mono mr-2">POST</span>
        /v1/chat/completions
      </h2>
      <p class="text-sm text-base-400 mb-6">兼容 OpenAI Chat Completions API 格式，支持多厂商模型。</p>

      <h3 class="text-sm font-bold text-white mb-3">请求参数</h3>
      <div class="overflow-x-auto mb-6">
        <table class="w-full text-sm">
          <thead>
            <tr class="text-xs text-base-500 border-b border-white/[0.05]">
              <th class="text-left py-2 px-2">参数</th>
              <th class="text-left py-2 px-2">类型</th>
              <th class="text-left py-2 px-2">必填</th>
              <th class="text-left py-2 px-2">说明</th>
            </tr>
          </thead>
          <tbody class="text-base-400">
            <tr class="border-b border-white/[0.02]"><td class="py-2 px-2 font-mono text-accent-300">model</td><td class="py-2 px-2">string</td><td class="py-2 px-2 text-emerald-400">是</td><td class="py-2 px-2">模型 ID，如 gpt-4o, claude-sonnet-4-6</td></tr>
            <tr class="border-b border-white/[0.02]"><td class="py-2 px-2 font-mono text-accent-300">messages</td><td class="py-2 px-2">array</td><td class="py-2 px-2 text-emerald-400">是</td><td class="py-2 px-2">消息列表 [{role, content}]</td></tr>
            <tr class="border-b border-white/[0.02]"><td class="py-2 px-2 font-mono text-accent-300">max_tokens</td><td class="py-2 px-2">int</td><td class="py-2 px-2 text-base-500">否</td><td class="py-2 px-2">最大输出 Token，默认 1024</td></tr>
            <tr class="border-b border-white/[0.02]"><td class="py-2 px-2 font-mono text-accent-300">temperature</td><td class="py-2 px-2">float</td><td class="py-2 px-2 text-base-500">否</td><td class="py-2 px-2">温度 0.0-2.0，默认 0.7</td></tr>
            <tr><td class="py-2 px-2 font-mono text-accent-300">vendor</td><td class="py-2 px-2">string</td><td class="py-2 px-2 text-base-500">否</td><td class="py-2 px-2">指定厂商，不填则自动识别</td></tr>
          </tbody>
        </table>
      </div>

      <h3 class="text-sm font-bold text-white mb-3">代码示例</h3>
      <div class="flex gap-1 mb-3">
        <button v-for="tab in (['curl', 'python', 'javascript'] as const)" :key="tab"
          @click="activeTab = tab"
          class="px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
          :class="activeTab === tab ? 'bg-white/[0.08] text-white' : 'text-base-500 hover:text-base-300'"
        >{{ tab === 'curl' ? 'cURL' : tab === 'python' ? 'Python' : 'JavaScript' }}</button>
      </div>
      <div class="relative">
        <pre class="p-4 bg-base-0 border border-white/[0.06] rounded-xl overflow-x-auto"><code class="text-xs font-mono text-base-300 leading-relaxed">{{ codeSnippets[activeTab] }}</code></pre>
        <BaseButton size="xs" variant="ghost" class="absolute top-2 right-2" @click="copyCode(codeSnippets[activeTab])">
          {{ copied === codeSnippets[activeTab] ? '已复制' : '复制' }}
        </BaseButton>
      </div>
    </BaseCard>

    <!-- Available Models -->
    <BaseCard>
      <h2 class="text-lg font-bold text-white mb-4">
        <span class="px-2 py-0.5 rounded bg-sky-500/10 text-sky-400 text-xs font-mono mr-2">GET</span>
        /v1/models
      </h2>
      <p class="text-sm text-base-400 mb-4">获取所有可用模型列表和定价信息。</p>
      <div class="relative">
        <pre class="p-4 bg-base-0 border border-white/[0.06] rounded-xl overflow-x-auto"><code class="text-xs font-mono text-base-300 leading-relaxed">curl https://your-domain.com/api/v1/models \\
  -H "Authorization: Bearer atp_YOUR_API_KEY"

# Response:
# {
#   "data": [
#     { "id": "gpt-4o", "vendor": "openai", "input_price": 2.50, ... },
#     { "id": "claude-sonnet-4-6", "vendor": "anthropic", ... }
#   ]
# }</code></pre>
      </div>
    </BaseCard>

    <!-- Pricing -->
    <BaseCard>
      <h2 class="text-lg font-bold text-white mb-4">模型定价</h2>
      <p class="text-sm text-base-400 mb-4">查看 <code class="bg-white/[0.04] px-1.5 py-0.5 rounded text-xs font-mono">GET /v1/pricing</code> 获取最新定价。费用从钱包余额中扣除。</p>
    </BaseCard>
  </div>
</template>
