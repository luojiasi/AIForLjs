/* ================================================================
   API Token Relay Platform — API Client
   封装所有后端 API 调用，统一错误处理和 Token 管理
   ================================================================ */

const API = (() => {
    // 后端地址 — 根据部署环境修改
    const BASE_URL = 'http://localhost:8000';

    // 本地存储 key
    const STORAGE_KEY_JWT = 'tokenrelay_jwt';
    const STORAGE_KEY_USER = 'tokenrelay_user';
    const STORAGE_KEY_API_KEY = 'tokenrelay_active_api_key';

    // ===== Token 管理 =====
    function getJwt() { return localStorage.getItem(STORAGE_KEY_JWT); }
    function setJwt(token) { localStorage.setItem(STORAGE_KEY_JWT, token); }
    function clearJwt() { localStorage.removeItem(STORAGE_KEY_JWT); }

    function getUser() {
        const raw = localStorage.getItem(STORAGE_KEY_USER);
        return raw ? JSON.parse(raw) : null;
    }
    function setUser(user) { localStorage.setItem(STORAGE_KEY_USER, JSON.stringify(user)); }
    function clearUser() { localStorage.removeItem(STORAGE_KEY_USER); }

    function getApiKey() { return localStorage.getItem(STORAGE_KEY_API_KEY); }
    function setApiKey(key) { localStorage.setItem(STORAGE_KEY_API_KEY, key); }

    function isLoggedIn() { return !!getJwt(); }

    // ===== HTTP 请求封装 =====
    async function request(method, path, { body, auth = 'jwt', apiKey } = {}) {
        const url = `${BASE_URL}${path}`;
        const headers = { 'Content-Type': 'application/json' };

        if (auth === 'jwt') {
            const token = getJwt();
            if (token) headers['Authorization'] = `Bearer ${token}`;
        } else if (auth === 'apikey') {
            const key = apiKey || getApiKey();
            if (key) headers['Authorization'] = `Bearer ${key}`;
        }

        const opts = { method, headers };
        if (body && method !== 'GET') {
            opts.body = JSON.stringify(body);
        }

        // 登录接口特殊处理（form-urlencoded）
        if (path === '/auth/login' && body) {
            const formData = new URLSearchParams();
            formData.append('username', body.username);
            formData.append('password', body.password);
            opts.body = formData.toString();
            opts.headers['Content-Type'] = 'application/x-www-form-urlencoded';
        }

        const resp = await fetch(url, opts);
        let data;
        try { data = await resp.json(); } catch { data = null; }

        if (!resp.ok) {
            const err = new Error(data?.detail || `HTTP ${resp.status}`);
            err.status = resp.status;
            throw err;
        }

        return { data, status: resp.status };
    }

    // ===== Auth API =====
    async function register(username, password) {
        const { data } = await request('POST', '/auth/register', {
            body: { username, password }
        });
        setJwt(data.access_token);
        setUser({ username });
        return data;
    }

    async function login(username, password) {
        const { data } = await request('POST', '/auth/login', {
            body: { username, password }
        });
        setJwt(data.access_token);
        setUser({ username });
        return data;
    }

    function logout() {
        clearJwt();
        clearUser();
    }

    // ===== API Keys API =====
    async function createApiKey(name) {
        const { data } = await request('POST', '/auth/api-keys', {
            body: { name }, auth: 'jwt'
        });
        // 自动设置为活跃 Key
        if (data.raw_key) setApiKey(data.raw_key);
        return data;
    }

    async function listApiKeys() {
        const { data } = await request('GET', '/auth/api-keys', { auth: 'jwt' });
        return data;
    }

    async function revokeApiKey(keyId) {
        const { data } = await request('DELETE', `/auth/api-keys/${keyId}`, { auth: 'jwt' });
        return data;
    }

    // ===== Chat Relay API =====
    async function chatCompletion({ model, messages, maxTokens, temperature, topP, vendor }) {
        const body = {
            model,
            messages,
            max_tokens: maxTokens || 4096,
            temperature: temperature || 0.7,
            top_p: topP ?? 1.0,
        };
        if (vendor) body.vendor = vendor;

        const { data } = await request('POST', '/v1/chat/completions', {
            body, auth: 'apikey'
        });
        return data;
    }

    // ===== Usage API =====
    async function getUsageStats(days = 30) {
        const { data } = await request('GET', `/usage/stats?days=${days}`, { auth: 'jwt' });
        return data;
    }

    async function getQuotas() {
        const { data } = await request('GET', '/usage/quotas', { auth: 'jwt' });
        return data;
    }

    // ===== Admin API =====
    async function listVendors() {
        const { data } = await request('GET', '/admin/vendors', { auth: 'jwt' });
        return data;
    }

    async function setVendorKey(vendorName, apiKey, baseUrl) {
        const { data } = await request('POST', `/admin/vendors/${vendorName}/key?api_key=${encodeURIComponent(apiKey)}${baseUrl ? '&base_url=' + encodeURIComponent(baseUrl) : ''}`, { auth: 'jwt' });
        return data;
    }

    async function supportedVendors() {
        const { data } = await request('GET', '/admin/vendors/supported', { auth: 'jwt' });
        return data;
    }

    // ===== Health =====
    async function healthCheck() {
        try {
            const { data } = await request('GET', '/health', { auth: 'none' });
            return data;
        } catch { return null; }
    }

    return {
        BASE_URL,
        getJwt, setJwt, clearJwt,
        getUser, setUser, clearUser,
        getApiKey, setApiKey,
        isLoggedIn,
        register, login, logout,
        createApiKey, listApiKeys, revokeApiKey,
        chatCompletion,
        getUsageStats, getQuotas,
        listVendors, setVendorKey, supportedVendors,
        healthCheck,
    };
})();
