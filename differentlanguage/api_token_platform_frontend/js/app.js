/* ================================================================
   API Token Relay Platform — Application Logic
   页面路由、对话管理、数据渲染、UI 交互
   ================================================================ */

const App = (() => {
    // ===== DOM 引用 =====
    const $ = (sel) => document.querySelector(sel);
    const $$ = (sel) => document.querySelectorAll(sel);

    // ===== 状态 =====
    let currentPage = 'login';
    let chatMessages = [];           // { role, content }
    let isStreaming = false;

    // ===== 初始化 =====
    function init() {
        bindEvents();
        checkAuth();
        loadSettings();
    }

    // ===== 事件绑定 =====
    function bindEvents() {
        // 侧边栏导航
        $$('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                const page = item.dataset.page;
                if (page) navigateTo(page);
            });
        });
        $('#sidebarToggle').addEventListener('click', toggleSidebar);
        $('#logoutBtn').addEventListener('click', handleLogout);
        $('#userCard').addEventListener('click', () => navigateTo('keys'));

        // 登录/注册
        $('#loginForm').addEventListener('submit', handleAuthSubmit);
        $$('.auth-tab').forEach(tab => {
            tab.addEventListener('click', () => {
                $$('.auth-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');
                $('#loginForm').mode.value = tab.dataset.tab;
                const isLogin = tab.dataset.tab === 'login';
                $('#authSubmit').querySelector('.btn-text').textContent = isLogin ? '登录' : '注册';
            });
        });

        // API Keys
        $('#createKeyForm').addEventListener('submit', handleCreateKey);
        $('#copyKeyBtn').addEventListener('click', copyNewKey);
        $('#dismissReveal').addEventListener('click', () => $('#newKeyReveal').style.display = 'none');

        // 对话
        $('#btnSend').addEventListener('click', sendMessage);
        $('#chatInput').addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
        });
        $('#pgClearChat').addEventListener('click', clearChat);
        $$('.quick-prompt').forEach(btn => {
            btn.addEventListener('click', () => {
                $('#chatInput').value = btn.dataset.prompt;
                sendMessage();
            });
        });

        // 参数滑块
        ['pgTemperature', 'pgMaxTokens', 'pgTopP'].forEach(id => {
            const slider = $(`#${id}`);
            if (!slider) return;
            slider.addEventListener('input', () => {
                const map = {
                    pgTemperature: ['tempValue', v => (parseInt(v) / 100).toFixed(2)],
                    pgMaxTokens: ['maxTokensValue', v => v],
                    pgTopP: ['topPValue', v => (parseInt(v) / 100).toFixed(2)],
                };
                const [targetId, fn] = map[id];
                $(`#${targetId}`).textContent = fn(slider.value);
            });
        });

        // Modal
        $('#modalCancel').addEventListener('click', () => $('#modalOverlay').style.display = 'none');
    }

    // ===== 页面路由 =====
    function navigateTo(page) {
        if (!API.isLoggedIn() && page !== 'login') {
            navigateTo('login');
            return;
        }
        currentPage = page;
        $$('.page').forEach(p => p.style.display = 'none');
        $$('.nav-item').forEach(n => n.classList.remove('active'));

        const pageEl = $(`#page-${page}`);
        if (pageEl) pageEl.style.display = '';

        const navItem = document.querySelector(`.nav-item[data-page="${page}"]`);
        if (navItem) navItem.classList.add('active');

        // 页面加载逻辑
        switch (page) {
            case 'playground': loadPlayground(); break;
            case 'keys': loadApiKeys(); break;
            case 'usage': loadUsage(); break;
            case 'admin': loadAdmin(); break;
        }
    }

    // ===== 认证检查 =====
    function checkAuth() {
        if (API.isLoggedIn()) {
            const user = API.getUser();
            if (user) {
                $('#userName').textContent = user.username;
                $('#userAvatar').textContent = user.username[0].toUpperCase();
                $('#userName').parentElement.querySelector('.user-status').textContent = '在线';
                $('#logoutBtn').style.display = '';
            }
            navigateTo('playground');
        } else {
            $('#userName').textContent = '未登录';
            $('#userAvatar').textContent = '?';
            $('#logoutBtn').style.display = 'none';
            navigateTo('login');
        }
    }

    // ===== 侧边栏 =====
    function toggleSidebar() {
        $('#sidebar').classList.toggle('collapsed');
    }

    // ===== 设置持久化 =====
    function loadSettings() {
        const saved = JSON.parse(localStorage.getItem('tokenrelay_settings') || '{}');
        if (saved.model) $('#pgModel').value = saved.model;
        if (saved.vendor) $('#pgVendor').value = saved.vendor;
        if (saved.temperature !== undefined) {
            $('#pgTemperature').value = Math.round(saved.temperature * 100);
            $('#tempValue').textContent = saved.temperature.toFixed(2);
        }
        if (saved.maxTokens) {
            $('#pgMaxTokens').value = saved.maxTokens;
            $('#maxTokensValue').textContent = saved.maxTokens;
        }
        if (saved.systemPrompt) $('#pgSystemPrompt').value = saved.systemPrompt;
    }
    function saveSettings() {
        localStorage.setItem('tokenrelay_settings', JSON.stringify({
            model: $('#pgModel').value,
            vendor: $('#pgVendor').value,
            temperature: parseFloat($('#tempValue').textContent),
            maxTokens: parseInt($('#pgMaxTokens').value),
            systemPrompt: $('#pgSystemPrompt').value,
        }));
    }

    // ===== 认证处理 =====
    async function handleAuthSubmit(e) {
        e.preventDefault();
        const mode = $('#loginForm').mode.value;
        const username = $('#loginForm').username.value.trim();
        const password = $('#loginForm').password.value;

        const btn = $('#authSubmit');
        btn.disabled = true;
        btn.querySelector('.btn-text').style.display = 'none';
        btn.querySelector('.btn-spinner').style.display = '';
        $('#authError').style.display = 'none';

        try {
            if (mode === 'register') {
                await API.register(username, password);
                showToast('注册成功！欢迎使用 TokenRelay', 'success');
            } else {
                await API.login(username, password);
                showToast('登录成功', 'success');
            }
            checkAuth();
        } catch (err) {
            $('#authError').textContent = err.message || '操作失败，请重试';
            $('#authError').style.display = '';
        } finally {
            btn.disabled = false;
            btn.querySelector('.btn-text').style.display = '';
            btn.querySelector('.btn-spinner').style.display = 'none';
        }
    }

    function handleLogout() {
        showModal('确认退出', '退出后需要重新登录才能使用平台功能', async () => {
            API.logout();
            chatMessages = [];
            checkAuth();
            showToast('已退出登录', 'info');
        });
    }

    // ===== API Keys 管理 =====
    async function handleCreateKey(e) {
        e.preventDefault();
        const name = $('#createKeyForm').keyName.value.trim();
        if (!name) return;

        const btn = $('#createKeyForm').querySelector('button');
        btn.disabled = true;

        try {
            const result = await API.createApiKey(name);
            $('#newKeyText').textContent = result.raw_key;
            $('#newKeyReveal').style.display = '';
            $('#createKeyForm').keyName.value = '';
            showToast('API Key 创建成功！请立即保存', 'success');
            loadApiKeys();
            loadPlayground(); // 刷新 Key badge
        } catch (err) {
            showToast(err.message || '创建失败', 'error');
        } finally {
            btn.disabled = false;
        }
    }

    async function loadApiKeys() {
        try {
            const keys = await API.listApiKeys();
            const tbody = $('#keysTable tbody');
            tbody.innerHTML = '';

            if (keys.length === 0) {
                $('#keysListCard').style.display = 'none';
                return;
            }

            $('#keysListCard').style.display = '';
            $('#keysCount').textContent = keys.length;

            keys.forEach(key => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong style="color:var(--text-primary)">${esc(key.name)}</strong></td>
                    <td><span class="badge badge-prefix">${esc(key.key_prefix)}***</span></td>
                    <td>${key.is_active
                        ? '<span class="badge badge-active">活跃</span>'
                        : '<span class="badge badge-inactive">已撤销</span>'}</td>
                    <td>${formatDate(key.created_at)}</td>
                    <td>${key.last_used_at ? formatDate(key.last_used_at) : '—'}</td>
                    <td>${key.is_active
                        ? `<button class="btn-danger btn-sm revoke-key-btn" data-id="${key.id}">撤销</button>`
                        : '<span style="color:var(--text-muted);font-size:.8rem">已撤销</span>'}</td>
                `;
                tbody.appendChild(tr);
            });

            // 撤销按钮
            $$('.revoke-key-btn').forEach(btn => {
                btn.addEventListener('click', async () => {
                    const keyId = parseInt(btn.dataset.id);
                    showModal('确认撤销', '撤销后该 Key 将立即失效，不可恢复。', async () => {
                        try {
                            await API.revokeApiKey(keyId);
                            showToast('API Key 已撤销', 'success');
                            loadApiKeys();
                        } catch (err) {
                            showToast(err.message || '撤销失败', 'error');
                        }
                    });
                });
            });
        } catch (err) {
            if (err.status === 401) { logoutAndGoLogin(); return; }
            showToast(err.message || '加载失败', 'error');
        }
    }

    function copyNewKey() {
        const text = $('#newKeyText').textContent;
        navigator.clipboard.writeText(text).then(() => {
            showToast('已复制到剪贴板', 'success');
        }).catch(() => showToast('复制失败，请手动选择复制', 'error'));
    }

    // ===== AI 对话 =====
    function loadPlayground() {
        const apiKey = API.getApiKey();
        const badge = $('#apiKeyBadge');
        if (apiKey) {
            badge.textContent = `Key: ${apiKey.substring(0, 12)}***`;
            badge.className = 'badge badge-active';
            $('#chatStatusDot').className = 'status-dot connected';
            $('#chatStatusText').textContent = '就绪';
        } else {
            badge.textContent = '未配置 Key';
            badge.className = 'badge';
            $('#chatStatusDot').className = 'status-dot';
            $('#chatStatusText').textContent = '请先创建 API Key';
        }
    }

    async function sendMessage() {
        if (isStreaming) return;

        const input = $('#chatInput');
        const content = input.value.trim();
        if (!content) return;

        const apiKey = API.getApiKey();
        if (!apiKey) {
            showToast('请先在 API Keys 页面创建一个 Key', 'error');
            navigateTo('keys');
            return;
        }

        // 保存设置
        saveSettings();

        // 添加用户消息
        addMessage('user', content);
        input.value = '';
        input.style.height = 'auto';

        // 构建消息列表
        const systemPrompt = $('#pgSystemPrompt').value.trim();
        const messages = [];
        if (systemPrompt) messages.push({ role: 'system', content: systemPrompt });
        messages.push(...chatMessages);

        // 显示加载状态
        isStreaming = true;
        setSendEnabled(false);
        $('#chatStatusDot').className = 'status-dot loading';
        $('#chatStatusText').textContent = '生成中...';

        // 添加助手占位消息
        const assistantMsg = addMessage('assistant', '', true);

        try {
            const model = $('#pgModel').value;
            const vendor = $('#pgVendor').value || null;
            const temperature = parseFloat($('#tempValue').textContent);
            const maxTokens = parseInt($('#pgMaxTokens').value);
            const topP = parseFloat($('#topPValue').textContent);

            const response = await API.chatCompletion({
                model, messages, maxTokens, temperature, topP, vendor
            });

            // 更新助手消息
            assistantMsg.contentEl.innerHTML = renderMarkdown(response.content);
            assistantMsg.wrapper.classList.remove('msg-streaming');
            assistantMsg.metaEl.innerHTML = `
                <span>${response.model}</span>
                <span>${response.usage.total_tokens} tokens</span>
                <span>${response.latency_ms.toFixed(0)}ms</span>
                <span>${response.vendor}</span>
            `;
            chatMessages[chatMessages.length - 1] = { role: 'assistant', content: response.content };

            $('#chatStatusDot').className = 'status-dot connected';
            $('#chatStatusText').textContent = '就绪';

        } catch (err) {
            assistantMsg.contentEl.innerHTML = `<span style="color:var(--red)">❌ 错误: ${esc(err.message)}</span>`;
            assistantMsg.wrapper.classList.remove('msg-streaming');
            chatMessages.pop(); // 移除失败的占位消息
            $('#chatStatusDot').className = 'status-dot';
            $('#chatStatusText').textContent = '出错';
        } finally {
            isStreaming = false;
            setSendEnabled(true);
            scrollChatBottom();
        }
    }

    function addMessage(role, content, isStreaming = false) {
        chatMessages.push({ role, content });
        const wrapper = document.createElement('div');
        wrapper.className = `msg-bubble ${role}${isStreaming ? ' msg-streaming' : ''}`;

        const avatar = document.createElement('div');
        avatar.className = 'msg-avatar';
        avatar.textContent = role === 'user'
            ? (API.getUser()?.username?.[0]?.toUpperCase() || 'U')
            : 'AI';

        const contentDiv = document.createElement('div');
        const contentEl = document.createElement('div');
        contentEl.className = 'msg-content';
        if (role === 'assistant') {
            contentEl.innerHTML = isStreaming
                ? '<div class="typing-indicator"><span></span><span></span><span></span></div>'
                : renderMarkdown(content);
        } else {
            contentEl.textContent = content;
        }
        contentDiv.appendChild(contentEl);

        const metaEl = document.createElement('div');
        metaEl.className = 'msg-meta';
        if (!isStreaming && role === 'assistant') {
            metaEl.innerHTML = `<span></span>`;
        } else if (role === 'user') {
            metaEl.innerHTML = `<span>${API.getUser()?.username || 'You'}</span>`;
        }
        contentDiv.appendChild(metaEl);

        wrapper.appendChild(avatar);
        wrapper.appendChild(contentDiv);

        // 移除欢迎消息
        const welcome = $('#chatMessages').querySelector('.chat-welcome');
        if (welcome) welcome.remove();

        $('#chatMessages').appendChild(wrapper);
        scrollChatBottom();

        return { wrapper, contentEl, metaEl };
    }

    function clearChat() {
        chatMessages = [];
        $('#chatMessages').innerHTML = `
            <div class="chat-welcome">
                <div class="welcome-icon">
                    <svg viewBox="0 0 48 48" fill="none">
                        <rect width="48" height="48" rx="12" fill="url(#logo-grad3)"/>
                        <path d="M12 24h6v-6h6v12h6V18h6v-6H12v12z" fill="white" opacity="0.9"/>
                        <defs><linearGradient id="logo-grad3" x1="0" y1="0" x2="48" y2="48"><stop stop-color="#0D47A1"/><stop offset="1" stop-color="#42A5F5"/></linearGradient></defs>
                    </svg>
                </div>
                <h2>开始 AI 对话</h2>
                <p>在左侧选择模型并配置参数，然后在下方输入框中发送消息</p>
                <div class="quick-prompts">
                    <button class="quick-prompt" data-prompt="请用简单易懂的语言解释什么是 API 网关">什么是 API 网关？</button>
                    <button class="quick-prompt" data-prompt="用 Python 写一个快速排序算法，并解释其时间复杂度">写一个快速排序</button>
                    <button class="quick-prompt" data-prompt="对比 GPT-4o 和 Claude Sonnet 的优势和适用场景">对比 GPT-4o 和 Claude</button>
                </div>
            </div>`;
        // 重新绑定快捷提示
        $$('.quick-prompt').forEach(btn => {
            btn.addEventListener('click', () => {
                $('#chatInput').value = btn.dataset.prompt;
                sendMessage();
            });
        });
    }

    function setSendEnabled(enabled) {
        $('#btnSend').disabled = !enabled;
        $('#chatInput').disabled = !enabled;
    }

    function scrollChatBottom() {
        const container = $('#chatMessages');
        setTimeout(() => { container.scrollTop = container.scrollHeight; }, 50);
    }

    // ===== 用量统计 =====
    async function loadUsage() {
        try {
            const stats = await API.getUsageStats(30);
            $('#statRequests').textContent = stats.total_requests?.toLocaleString() || '0';
            $('#statTokens').textContent = stats.total_tokens?.toLocaleString() || '0';
            $('#statCost').textContent = '$' + (stats.total_cost_estimate || 0).toFixed(4);
            $('#statQuotas').textContent = stats.quotas?.length || 0;

            // 配额表格
            if (stats.quotas && stats.quotas.length > 0) {
                $('#quotasCard').style.display = '';
                const tbody = $('#quotasTableBody');
                tbody.innerHTML = '';
                stats.quotas.forEach(q => {
                    const pct = q.max_tokens > 0 ? (q.used_tokens / q.max_tokens * 100) : 0;
                    const level = pct > 80 ? 'high' : pct > 50 ? 'medium' : 'low';
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td><strong>${esc(q.vendor)}</strong></td>
                        <td>${esc(q.period)}</td>
                        <td>
                            ${q.used_tokens.toLocaleString()} / ${q.max_tokens.toLocaleString()}
                            <div class="quota-bar" style="margin-top:4px"><div class="quota-bar-fill ${level}" style="width:${Math.min(pct,100)}%"></div></div>
                        </td>
                        <td><span class="badge ${level === 'high' ? 'badge-inactive' : level === 'medium' ? '' : 'badge-active'}" style="font-size:.75rem">${pct.toFixed(1)}%</span></td>
                        <td>${q.remaining.toLocaleString()}</td>
                        <td style="font-size:.8rem">${formatDate(q.reset_at)}</td>
                    `;
                    tbody.appendChild(tr);
                });
            } else {
                $('#quotasCard').style.display = 'none';
            }

            // 最近请求
            if (stats.recent_requests && stats.recent_requests.length > 0) {
                $('#recentCard').style.display = '';
                const tbody = $('#recentTableBody');
                tbody.innerHTML = '';
                stats.recent_requests.forEach(r => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td><strong>${esc(r.vendor)}</strong></td>
                        <td>${esc(r.model || '—')}</td>
                        <td>${(r.tokens_used || 0).toLocaleString()}</td>
                        <td>${r.latency_ms ? r.latency_ms.toFixed(0) + 'ms' : '—'}</td>
                        <td>$${(r.cost || 0).toFixed(6)}</td>
                        <td>${r.status === 200 ? '<span class="badge badge-active">成功</span>' : '<span class="badge badge-inactive">失败</span>'}</td>
                        <td style="font-size:.8rem">${formatDate(r.created_at)}</td>
                    `;
                    tbody.appendChild(tr);
                });
            } else {
                $('#recentCard').style.display = 'none';
            }
        } catch (err) {
            if (err.status === 401) { logoutAndGoLogin(); return; }
            showToast(err.message || '加载失败', 'error');
        }
    }

    // ===== 厂商管理 =====
    async function loadAdmin() {
        try {
            const vendors = await API.listVendors();
            const grid = $('#vendorsGrid');
            grid.innerHTML = '';

            vendors.forEach(v => {
                const card = document.createElement('div');
                card.className = 'vendor-card';
                card.innerHTML = `
                    <div class="vendor-card-header">
                        <span class="vendor-card-name">${esc(v.display_name)}</span>
                        ${v.has_key
                            ? '<span class="badge badge-active">已配置</span>'
                            : '<span class="badge badge-inactive">未配置</span>'}
                    </div>
                    <div class="vendor-card-status">
                        <span style="font-size:.82rem;color:var(--text-muted)">厂商标识: </span>
                        <code style="font-size:.82rem;color:var(--blue-300)">${esc(v.vendor_name)}</code>
                        ${v.base_url ? `<br><span style="font-size:.8rem;color:var(--text-muted)">端点: ${esc(v.base_url)}</span>` : ''}
                    </div>
                    <form class="vendor-key-form" data-vendor="${esc(v.vendor_name)}">
                        <input type="password" class="form-input" placeholder="输入 API Key..." autocomplete="off">
                        <button type="submit" class="btn-primary btn-sm">保存</button>
                    </form>
                `;
                grid.appendChild(card);

                // 表单提交
                card.querySelector('form').addEventListener('submit', async (e) => {
                    e.preventDefault();
                    const input = e.target.querySelector('input');
                    const key = input.value.trim();
                    if (!key) return;

                    const btn = e.target.querySelector('button');
                    btn.disabled = true;
                    btn.textContent = '...';

                    try {
                        await API.setVendorKey(v.vendor_name, key);
                        showToast(`${v.display_name} Key 已更新`, 'success');
                        input.value = '';
                        loadAdmin();
                    } catch (err) {
                        showToast(err.message || '更新失败', 'error');
                    } finally {
                        btn.disabled = false;
                        btn.textContent = '保存';
                    }
                });
            });

            if (vendors.length === 0) {
                grid.innerHTML = '<div class="empty-state"><p>暂无已注册的厂商适配器</p></div>';
            }
        } catch (err) {
            if (err.status === 401) { logoutAndGoLogin(); return; }
            showToast(err.message || '加载失败', 'error');
        }
    }

    // ===== 工具函数 =====
    function showToast(message, type = 'info') {
        const container = $('#toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        container.appendChild(toast);
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transition = 'opacity .3s';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }

    function showModal(title, message, onConfirm) {
        $('#modalTitle').textContent = title;
        $('#modalMessage').textContent = message;
        $('#modalOverlay').style.display = '';
        $('#modalConfirm').onclick = async () => {
            $('#modalOverlay').style.display = 'none';
            if (onConfirm) await onConfirm();
        };
    }

    function formatDate(iso) {
        if (!iso) return '—';
        const d = new Date(iso);
        const now = new Date();
        const diff = now - d;
        if (diff < 60000) return '刚刚';
        if (diff < 3600000) return `${Math.floor(diff/60000)}分钟前`;
        if (diff < 86400000) return `${Math.floor(diff/3600000)}小时前`;
        return d.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    }

    function esc(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function renderMarkdown(text) {
        if (!text) return '';
        // 简易 Markdown 渲染
        let html = esc(text);
        // 代码块
        html = html.replace(/```(\w*)\n([\s\S]*?)```/g, '<pre><code>$2</code></pre>');
        // 行内代码
        html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
        // 粗体
        html = html.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
        // 斜体
        html = html.replace(/\*([^*]+)\*/g, '<em>$1</em>');
        // 换行
        html = html.replace(/\n/g, '<br>');
        return html;
    }

    function logoutAndGoLogin() {
        API.logout();
        chatMessages = [];
        checkAuth();
        showToast('登录已过期，请重新登录', 'info');
    }

    // ===== 启动 =====
    document.addEventListener('DOMContentLoaded', init);

    return { navigateTo, showToast };
})();
