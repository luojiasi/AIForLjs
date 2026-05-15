import{_ as r}from"./BaseCard.vue_vue_type_script_setup_true_lang-aZdUs3tD.js";import{_ as f}from"./BaseButton.vue_vue_type_script_setup_true_lang-DOUUH2kG.js";import{d as h,c,a as t,f as a,w as n,o as m,b as s,F as g,l as v,n as _,t as x,r as u,i as w}from"./index-DqAP_nto.js";const A={class:"max-w-4xl space-y-6 lg:space-y-8 p-4 lg:p-6"},k={class:"text-xs text-base-500 mt-3"},P={class:"flex gap-1 mb-3"},I=["onClick"],C={class:"relative"},E={class:"p-4 bg-base-0 border border-white/[0.06] rounded-xl overflow-x-auto"},T={class:"text-xs font-mono text-base-300 leading-relaxed"},U=h({__name:"DocsView",setup(Y){const l=u("curl"),p=u(""),d={curl:`# 1. 获取 API Key（登录后在平台创建）
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
  }'`,python:`import requests

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
print("Cost: $" + str(data["cost"]))`,javascript:`const API_KEY = "atp_YOUR_API_KEY";
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

chat("Hello, how are you?");`};function b(i){navigator.clipboard.writeText(i),p.value=i,setTimeout(()=>{p.value=""},2e3)}return(i,e)=>{const y=w("router-link");return m(),c("div",A,[e[14]||(e[14]=t("div",null,[t("h1",{class:"text-2xl font-extrabold text-white tracking-tight"},"API 文档"),t("p",{class:"text-sm text-base-500 mt-1"},"快速开始使用 TokenRelay API")],-1)),a(r,null,{default:n(()=>[e[4]||(e[4]=t("h2",{class:"text-lg font-bold text-white mb-4"},"认证方式",-1)),e[5]||(e[5]=t("p",{class:"text-sm text-base-400 leading-relaxed mb-4"},[s("所有 API 请求需要在 Authorization 头中携带平台 API Key（以 "),t("code",{class:"bg-white/[0.04] px-1.5 py-0.5 rounded text-accent-300 text-xs font-mono"},"atp_"),s(" 开头）。")],-1)),e[6]||(e[6]=t("div",{class:"p-4 bg-base-0 border border-white/[0.06] rounded-xl font-mono text-sm text-base-300"},[s(" Authorization: Bearer "),t("span",{class:"text-accent-300"},"atp_YOUR_API_KEY")],-1)),t("p",k,[e[2]||(e[2]=s("登录后在 ",-1)),a(y,{to:"/api-keys",class:"text-accent-400 hover:text-accent-300"},{default:n(()=>[...e[1]||(e[1]=[s("API 密钥",-1)])]),_:1}),e[3]||(e[3]=s(" 页面创建和管理密钥。",-1))])]),_:1}),a(r,null,{default:n(()=>[e[7]||(e[7]=t("h2",{class:"text-lg font-bold text-white mb-4"},[t("span",{class:"px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 text-xs font-mono mr-2"},"POST"),s(" /v1/chat/completions ")],-1)),e[8]||(e[8]=t("p",{class:"text-sm text-base-400 mb-6"},"兼容 OpenAI Chat Completions API 格式，支持多厂商模型。",-1)),e[9]||(e[9]=t("h3",{class:"text-sm font-bold text-white mb-3"},"请求参数",-1)),e[10]||(e[10]=t("div",{class:"overflow-x-auto mb-6"},[t("table",{class:"w-full text-sm"},[t("thead",null,[t("tr",{class:"text-xs text-base-500 border-b border-white/[0.05]"},[t("th",{class:"text-left py-2 px-2"},"参数"),t("th",{class:"text-left py-2 px-2"},"类型"),t("th",{class:"text-left py-2 px-2"},"必填"),t("th",{class:"text-left py-2 px-2"},"说明")])]),t("tbody",{class:"text-base-400"},[t("tr",{class:"border-b border-white/[0.02]"},[t("td",{class:"py-2 px-2 font-mono text-accent-300"},"model"),t("td",{class:"py-2 px-2"},"string"),t("td",{class:"py-2 px-2 text-emerald-400"},"是"),t("td",{class:"py-2 px-2"},"模型 ID，如 gpt-4o, claude-sonnet-4-6")]),t("tr",{class:"border-b border-white/[0.02]"},[t("td",{class:"py-2 px-2 font-mono text-accent-300"},"messages"),t("td",{class:"py-2 px-2"},"array"),t("td",{class:"py-2 px-2 text-emerald-400"},"是"),t("td",{class:"py-2 px-2"},"消息列表 [{role, content}]")]),t("tr",{class:"border-b border-white/[0.02]"},[t("td",{class:"py-2 px-2 font-mono text-accent-300"},"max_tokens"),t("td",{class:"py-2 px-2"},"int"),t("td",{class:"py-2 px-2 text-base-500"},"否"),t("td",{class:"py-2 px-2"},"最大输出 Token，默认 1024")]),t("tr",{class:"border-b border-white/[0.02]"},[t("td",{class:"py-2 px-2 font-mono text-accent-300"},"temperature"),t("td",{class:"py-2 px-2"},"float"),t("td",{class:"py-2 px-2 text-base-500"},"否"),t("td",{class:"py-2 px-2"},"温度 0.0-2.0，默认 0.7")]),t("tr",null,[t("td",{class:"py-2 px-2 font-mono text-accent-300"},"vendor"),t("td",{class:"py-2 px-2"},"string"),t("td",{class:"py-2 px-2 text-base-500"},"否"),t("td",{class:"py-2 px-2"},"指定厂商，不填则自动识别")])])])],-1)),e[11]||(e[11]=t("h3",{class:"text-sm font-bold text-white mb-3"},"代码示例",-1)),t("div",P,[(m(),c(g,null,v(["curl","python","javascript"],o=>t("button",{key:o,onClick:B=>l.value=o,class:_(["px-3 py-1.5 rounded-lg text-xs font-medium transition-colors",l.value===o?"bg-white/[0.08] text-white":"text-base-500 hover:text-base-300"])},x(o==="curl"?"cURL":o==="python"?"Python":"JavaScript"),11,I)),64))]),t("div",C,[t("pre",E,[t("code",T,x(d[l.value]),1)]),a(f,{size:"xs",variant:"ghost",class:"absolute top-2 right-2",onClick:e[0]||(e[0]=o=>b(d[l.value]))},{default:n(()=>[s(x(p.value===d[l.value]?"已复制":"复制"),1)]),_:1})])]),_:1}),a(r,null,{default:n(()=>[...e[12]||(e[12]=[t("h2",{class:"text-lg font-bold text-white mb-4"},[t("span",{class:"px-2 py-0.5 rounded bg-sky-500/10 text-sky-400 text-xs font-mono mr-2"},"GET"),s(" /v1/models ")],-1),t("p",{class:"text-sm text-base-400 mb-4"},"获取所有可用模型列表和定价信息。",-1),t("div",{class:"relative"},[t("pre",{class:"p-4 bg-base-0 border border-white/[0.06] rounded-xl overflow-x-auto"},[t("code",{class:"text-xs font-mono text-base-300 leading-relaxed"},`curl https://your-domain.com/api/v1/models \\\\
  -H "Authorization: Bearer atp_YOUR_API_KEY"

# Response:
# {
#   "data": [
#     { "id": "gpt-4o", "vendor": "openai", "input_price": 2.50, ... },
#     { "id": "claude-sonnet-4-6", "vendor": "anthropic", ... }
#   ]
# }`)])],-1)])]),_:1}),a(r,null,{default:n(()=>[...e[13]||(e[13]=[t("h2",{class:"text-lg font-bold text-white mb-4"},"模型定价",-1),t("p",{class:"text-sm text-base-400 mb-4"},[s("查看 "),t("code",{class:"bg-white/[0.04] px-1.5 py-0.5 rounded text-xs font-mono"},"GET /v1/pricing"),s(" 获取最新定价。费用从钱包余额中扣除。")],-1)])]),_:1})])}}});export{U as default};
