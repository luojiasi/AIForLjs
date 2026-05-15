# API Token Relay Platform — Frontend

现代化的 API Token 中转平台前端，提供 AI 对话、Key 管理、用量统计、厂商管理等完整功能。

## 功能特性

- **AI 对话**：类 OpenAI Playground 的对话界面，支持多模型切换和参数调节
- **API Keys**：创建、查看、撤销平台 API Key
- **用量统计**：Token 消耗、费用估算、配额状态、请求历史
- **厂商管理**：配置和管理各 AI 厂商的 API Key
- **认证系统**：用户注册/登录，JWT + API Key 双重认证

## 技术栈

- 原生 HTML5 / CSS3 / JavaScript（ES6+）
- 零依赖，无需构建工具
- 响应式设计，支持桌面和移动端
- Fetch API 对接后端 REST 接口

## 快速启动

### 1. 启动后端

```bash
cd ../api_token_platform_backend
pip install -r requirements.txt
cp .env.example .env
# 编辑 .env 填入厂商 API Key
uvicorn app.main:app --reload --port 8000
```

### 2. 打开前端

直接在浏览器中打开 `index.html`，或使用任意静态服务器：

```bash
# 方式一：直接打开
# 双击 index.html 在浏览器中打开

# 方式二：使用 Python 静态服务器
python -m http.server 3000
# 然后访问 http://localhost:3000

# 方式三：使用 npx serve
npx serve .
```

### 3. 使用流程

1. 注册账号（首次使用）
2. 在「API Keys」页面创建一个 Key（⚠️ 立即保存！）
3. 在「AI 对话」页面选择模型，发送消息
4. 在「用量统计」查看使用情况
5. 管理员在「厂商管理」配置各厂商 API Key

## 配置

后端地址默认为 `http://localhost:8000`，如需修改请编辑 `js/api.js` 中的 `BASE_URL`。
