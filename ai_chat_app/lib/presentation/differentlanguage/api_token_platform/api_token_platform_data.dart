import 'package:flutter/material.dart';

class ApiTokenPlatformTopic {
  final String id;
  final String name;
  final String englishName;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String overview;
  final String coreConcept;
  final String keyPoints;
  final String detailedContent;
  final String practicalTips;
  final String relatedTech;
  final List<String> tags;
  final String difficulty;

  const ApiTokenPlatformTopic({
    required this.id,
    required this.name,
    required this.englishName,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.overview,
    required this.coreConcept,
    required this.keyPoints,
    required this.detailedContent,
    required this.practicalTips,
    required this.relatedTech,
    required this.tags,
    required this.difficulty,
  });
}

const List<ApiTokenPlatformTopic> apiTokenPlatformTopics = [
  // 1. 平台概述
  ApiTokenPlatformTopic(
    id: 'overview',
    name: '平台概述',
    englishName: 'Platform Overview',
    subtitle: '理解API Token中转平台的核心价值与运作机制',
    icon: Icons.hub,
    color: Color(0xFF0D47A1),
    overview: 'API Token中转平台是一个统一的AI服务网关，它作为一个中间层，'
        '接收客户端请求后，根据请求内容将请求转发到对应的AI厂商（如OpenAI、Anthropic），'
        '并将厂商的响应返回给客户端。\n\n'
        '这种架构的核心价值在于：\n'
        '• 统一入口：用户只需管理一个平台API Key即可访问多个AI服务\n'
        '• Token安全：厂商密钥存储在服务端加密保管，不会泄露给客户端\n'
        '• 成本管控：统一记录每次调用的Token消耗和费用，便于审计和成本控制\n'
        '• 灵活路由：可根据模型名称自动选择目标厂商，无需客户端关心后端细节\n\n'
        '该平台适用于企业内部AI服务统一管理、AI SaaS产品开发、个人AI工具聚合等场景。',
    coreConcept: 'API Gateway模式是微服务架构中的经典模式。在AI领域，由于不同厂商提供了'
        '互不兼容的API格式（OpenAI格式 vs Anthropic格式），一个统一的中转层可以通过'
        '适配器模式将不同厂商的API标准化为统一格式，从而让上游应用无需关心底层厂商差异。\n\n'
        '平台的工作流程可以概括为：\n'
        '1. 用户注册并获取平台API Key\n'
        '2. 管理员配置各厂商的API密钥（加密存储）\n'
        '3. 用户通过平台API Key调用统一的中继端点\n'
        '4. 平台验证Key → 识别目标厂商 → 解密厂商密钥 → 适配请求 → 转发 → 标准化响应 → 记录日志',
    keyPoints: '• API Gateway 统一入口模式\n'
        '• 适配器模式屏蔽厂商差异\n'
        '• 厂商密钥加密存储，安全隔离\n'
        '• 审计日志 + 用量追踪\n'
        '• 可扩展架构，新增厂商只需添加适配器',
    detailedContent: '一个完整的API Token中转平台由以下核心组件构成：\n\n'
        '1. 认证层（Auth Layer）：负责用户注册、登录、API Key的创建和验证。'
        '平台API Key使用 bcrypt 哈希存储，验证时通过哈希比对确认身份。\n\n'
        '2. 路由层（Routing Layer）：根据请求中的 model 字段或 vendor 字段，'
        '使用适配器工厂找到对应的厂商适配器，并调用其方法。\n\n'
        '3. 适配器层（Adapter Layer）：每个厂商有一个独立的适配器，'
        '负责将统一请求格式转换为厂商专用格式，并在响应返回后标准化。\n\n'
        '4. 密钥管理层（Key Management）：厂商API密钥使用Fernet对称加密存储，'
        '只有在实际调用时才会解密。平台自身的密钥永不出现在日志中。\n\n'
        '5. 限流层（Rate Limiting）：令牌桶算法对每个用户的请求频率进行限制，'
        '同时对月Token消耗量设置配额上限，防止滥用。\n\n'
        '6. 日志层（Logging Layer）：每次API调用都记录详细的审计日志，'
        '包括请求方、目标厂商、消耗Token数、延迟、费用等。\n\n'
        '本平台的后端实现位于 differentlanguage/api_token_platform_backend/，'
        '使用 Python FastAPI 框架构建，完整代码可直接运行。',
    practicalTips: '• 生产环境建议使用PostgreSQL替代SQLite，并配置Redis做分布式限流\n'
        '• 厂商密钥应通过环境变量或密钥管理服务（如Vault）注入，不要硬编码\n'
        '• 建议在Nginx层配置HTTPS和额外的IP限流\n'
        '• 日志应发送到集中式日志系统（如ELK），便于审计和分析\n'
        '• Key的创建和管理应该有独立的管理后台，不要直接在代码中操作',
    relatedTech: 'FastAPI · SQLAlchemy · bcrypt · Fernet加密 · 令牌桶算法 · JWT · Docker · Nginx',
    tags: ['入门', '概述', '核心概念', '架构'],
    difficulty: '基础',
  ),

  // 2. 架构设计
  ApiTokenPlatformTopic(
    id: 'architecture',
    name: '架构设计',
    englishName: 'Architecture Design',
    subtitle: '深入理解API网关架构的设计原则与技术选型',
    icon: Icons.architecture,
    color: Color(0xFF1565C0),
    overview: 'API Token中转平台的架构设计决定了系统的可扩展性、性能和安全性。'
        '核心架构采用分层设计，从外到内依次为：接入层 → 认证层 → 限流层 → 路由层 → 适配器层 → 厂商层。\n\n'
        '每一层都有明确的职责边界，层与层之间通过接口约定进行通信，使得任一层的变更不会影响到其他层。\n\n'
        '关键技术决策包括：\n'
        '• Web框架选择：FastAPI（高性能异步、自动Swagger文档、类型安全）\n'
        '• 数据库选择：SQLite（开发/演示）→ PostgreSQL（生产）\n'
        '• 认证方案：平台API Key（bcrypt哈希）+ JWT（用户登录态）\n'
        '• 加密方案：Fernet（AES-128-CBC + HMAC签名）保护厂商密钥\n'
        '• 限流方案：令牌桶（内存实现，可选Redis分布式版本）',
    coreConcept: '分层架构是平台设计的核心思想。每一层只依赖于其下方的层，上层通过接口调用下层服务。\n\n'
        '1. 接入层（Nginx/负载均衡）：处理TLS终止、静态资源、基础限流\n'
        '2. 认证层（FastAPI Middleware）：验证API Key、解析JWT、注入用户上下文\n'
        '3. 限流层（Rate Limiter）：令牌桶算法按用户维度限流\n'
        '4. 路由层（Relay Service）：根据model字段识别目标厂商，选取适配器\n'
        '5. 适配器层（Vendor Adapter）：将统一请求转为厂商格式，标准化响应\n'
        '6. 厂商层（Vendor API）：实际调用 OpenAI / Anthropic 等外部API\n\n'
        '这种分层架构带来的好处是：新增厂商只需在适配器层添加一个文件，'
        '无需修改认证、限流、路由等任何上层代码。',
    keyPoints: '• 六层架构设计（接入→认证→限流→路由→适配器→厂商）\n'
        '• 每层职责单一，接口隔离\n'
        '• 适配器工厂模式实现厂商自动发现\n'
        '• 依赖注入（FastAPI Depends）管理数据库会话和认证\n'
        '• 技术栈选型：FastAPI + SQLAlchemy + SQLite/PostgreSQL + Redis\n'
        '• Docker多阶段构建，减小镜像体积',
    detailedContent: '架构的完整请求链路如下：\n\n'
        'Client → Nginx(:443) → Uvicorn(:8000) → FastAPI App\n'
        '  → Middleware (CORS / Logging)\n'
        '  → Dependencies (API Key验证 → 注入User对象)\n'
        '  → Router (/v1/chat/completions)\n'
        '  → RelayService (限流检查 → 配额检查 → 厂商选择)\n'
        '  → VendorAdapter (请求转换 → HTTP调用 → 响应标准化)\n'
        '  → Response (标准化格式返回)\n'
        '  → Audit Log (异步写入数据库)\n\n'
        '数据库模型设计：\n'
        '• users — 用户账户\n'
        '• platform_api_keys — 平台API Key（bcrypt哈希存储）\n'
        '• vendor_keys — 厂商密钥（Fernet加密存储）\n'
        '• request_logs — 请求审计日志\n'
        '• usage_quotas — 用户配额记录\n\n'
        '项目目录结构设计遵循FastAPI最佳实践，将路由(router)、服务(service)、'
        '模型(model)、模式(schema)分别放在独立目录中，保持代码职责清晰。',
    practicalTips: '• 使用 pydantic-settings 管理所有环境变量，区分开发/生产配置\n'
        '• 数据库URL等敏感配置永远从环境变量读取，不硬编码\n'
        '• 在路由层保持薄层（thin router），业务逻辑全部放在service层\n'
        '• 使用FastAPI的Depends机制做依赖注入，简化测试和代码复用\n'
        '• 日志使用structlog做结构化日志，方便后续ELK接入',
    relatedTech: 'FastAPI · Uvicorn · SQLAlchemy · Pydantic · Docker · Nginx · Redis',
    tags: ['架构', '设计模式', '分层', '技术选型'],
    difficulty: '中级',
  ),

  // 3. Token管理
  ApiTokenPlatformTopic(
    id: 'token_mgmt',
    name: 'Token管理',
    englishName: 'Token Management',
    subtitle: 'API Key的全生命周期管理与安全存储方案',
    icon: Icons.vpn_key,
    color: Color(0xFF2E7D32),
    overview: 'Token管理是API中转平台安全体系的核心。平台涉及两种Token：\n'
        '1. 平台API Key — 用户用来调用平台的凭证（atp_前缀）\n'
        '2. 厂商API Key — 平台用来调用下游AI服务的凭证\n\n'
        '平台API Key的管理策略：\n'
        '• 生成：使用 secrets.token_hex(32) 生成128位随机密钥，前缀 atp_\n'
        '• 存储：使用 bcrypt 对完整Key做单向哈希存储，只保留前12字符（atp_ + 8位）作为前缀用于索引\n'
        '• 返回：Key仅在其创建时完整返回一次给用户，之后无法再次获取\n'
        '• 验证：请求时提取前缀 → 查找匹配的候选Key → bcrypt验证哈希\n'
        '• 撤销：将 is_active 设为 False，不物理删除\n\n'
        '厂商API Key的管理策略：\n'
        '• 加密：使用 Fernet（基于AES-128-CBC + HMAC）对称加密\n'
        '• 密钥派生：Fernet密钥从平台SECRET_KEY通过SHA256派生\n'
        '• 存储：加密后的密文存入数据库，仅使用时解密\n'
        '• 注入：通过管理API设置，或从环境变量初始化',
    coreConcept: 'API Key的安全生命周期分为四个阶段：\n\n'
        '1. 生成阶段：使用密码学安全的随机数生成器（secrets模块），生成足够长的随机字符串。'
        '前缀 atp_ 不仅用于标识平台，也便于快速索引查找。\n\n'
        '2. 分发阶段：Key只在创建时完整返回一次。这是用户唯一能看到完整Key的时刻。'
        '平台应提示用户立即保存。\n\n'
        '3. 存储阶段：服务端只存储 bcrypt 哈希值。bcrypt 包含随机盐(salt)和成本因子，'
        '即使数据库泄露，攻击者也无法从哈希恢复出原始Key。\n\n'
        '4. 使用阶段：每次API请求时，提取前缀快速缩小查找范围，然后逐条bcrypt验证。'
        'bcrypt的验证速度经过刻意设计较慢（0.2-0.5秒），这本身也是一种防暴力破解的机制。\n\n'
        '厂商密钥的加密采用Fernet方案：\n'
        '• Fernet = AES-128-CBC加密 + HMAC-SHA256签名\n'
        '• 保证加密数据的机密性和完整性\n'
        '• 时间戳嵌入，防止旧数据重放',
    keyPoints: '• 平台Key使用bcrypt单向哈希存储，不可逆\n'
        '• 厂商Key使用Fernet对称加密，支持解密使用\n'
        '• Key生成使用 secrets.token_hex() 密码学安全随机数\n'
        '• Key前缀机制实现O(1)缩小查找范围的索引\n'
        '• 完整Key仅创建时返回一次，之后只显示前缀\n'
        '• 撤销Key使用软删除（is_active=False），保留审计记录',
    detailedContent: 'Key格式设计：\n'
        '平台API Key格式: atp_<32位hex字符>\n'
        '例如: atp_a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6\n\n'
        '前缀 atp_ = API Token Platform 的缩写\n'
        '前缀 + 前8位hex = atp_a1b2c3d4 用于数据库索引\n\n'
        '数据库中的Key记录结构：\n'
        '- key_prefix: "atp_a1b2c3d4" （前缀，有索引）\n'
        '- key_hash: "\$2b\$12\$..." （bcrypt完整哈希）\n'
        '- name: "我的开发Key" （用户定义的别名）\n'
        '- is_active: true/false\n'
        '- created_at / last_used_at\n\n'
        '厂商密钥的管理API：\n'
        'POST /admin/vendors/{vendor_name}/key — 设置厂商密钥\n'
        'GET /admin/vendors — 查看各厂商密钥配置状态\n\n'
        '安全建议：\n'
        '• 定期轮转厂商API Key（如每90天）\n'
        '• 使用密钥管理服务（AWS KMS / HashiCorp Vault）替代Fernet\n'
        '• 在日志中完全屏蔽Key内容，即使是加密后的也不输出',
    practicalTips: '• 生产环境推荐使用AWS KMS或HashiCorp Vault管理主加密密钥\n'
        '• 对API Key的验证失败增加延迟响应（递增等待），防暴力破解\n'
        '• 监控API Key的使用频率，异常时自动告警\n'
        '• 为用户提供自助Key管理界面（创建、命名、撤销）\n'
        '• 记录每次Key的创建和撤销操作到不可变审计日志',
    relatedTech: 'bcrypt · Fernet · AES-128-CBC · HMAC-SHA256 · secrets模块 · JWT',
    tags: ['安全', '加密', '认证', 'Key管理'],
    difficulty: '基础',
  ),

  // 4. 多厂商适配器模式
  ApiTokenPlatformTopic(
    id: 'adapter_pattern',
    name: '多厂商适配器',
    englishName: 'Multi-Vendor Adapter',
    subtitle: '使用适配器模式统一接入不同AI厂商API',
    icon: Icons.extension,
    color: Color(0xFFE65100),
    overview: '不同AI厂商提供的API格式各不相同。以Chat Completions为例：\n\n'
        'OpenAI格式:\n'
        '  POST /v1/chat/completions\n'
        '  { "model": "gpt-4o", "messages": [{"role":"user","content":"Hi"}] }\n\n'
        'Anthropic格式:\n'
        '  POST /v1/messages\n'
        '  { "model": "claude-sonnet-4-6", "messages": [{"role":"user","content":"Hi"}], "max_tokens": 1024 }\n\n'
        '如果让上游应用直接处理这些差异，会导致代码高度耦合，新增厂商时改动巨大。\n\n'
        '适配器模式通过定义一个统一的抽象接口（BaseVendorAdapter），每个厂商实现自己的适配器，'
        '将厂商特定的API格式封装在适配器内部。上游应用只与抽象接口交互，完全不感知厂商差异。',
    coreConcept: 'BaseVendorAdapter 抽象基类定义了三个核心方法：\n\n'
        '1. chat_completion(request, api_key) → 调用厂商API，返回统一响应\n'
        '2. model_to_vendor(model) → 根据model名称判断是否属于本厂商\n'
        '3. estimate_cost(response) → 根据用量估算费用\n\n'
        '每个具体适配器（OpenAIAdapter、AnthropicAdapter）继承基类并实现这些方法。\n\n'
        '适配器工厂（AdapterFactory）维护一个注册表：vendor_name → adapter实例。\n'
        '路由层通过工厂的 detect_vendor() 方法根据model名称自动发现合适的适配器。\n\n'
        '新增厂商的步骤极为简单：\n'
        '1. 创建新适配器文件，继承BaseVendorAdapter\n'
        '2. 实现必要方法\n'
        '3. 在factory.py中调用 register_adapter() 注册\n'
        '无需修改任何路由、认证或限流代码。',
    keyPoints: '• 策略模式 + 适配器模式结合\n'
        '• BaseVendorAdapter 定义统一接口\n'
        '• 每个厂商独立实现，互不干扰\n'
        '• 工厂模式实现自动发现和注册\n'
        '• model_to_vendor() 实现模型名自动路由\n'
        '• 新增厂商零侵入（不需要改路由/认证/限流代码）\n'
        '• 费用估算接口可被统一计费系统调用',
    detailedContent: '适配器基类设计（base_adapter.py）：\n\n'
        'class BaseVendorAdapter(ABC):\n'
        '    @property\n'
        '    @abstractmethod\n'
        '    def vendor_name(self) -> str: ...\n\n'
        '    @property\n'
        '    @abstractmethod\n'
        '    def display_name(self) -> str: ...\n\n'
        '    @abstractmethod\n'
        '    async def chat_completion(\n'
        '        self, request: RelayRequest, api_key: str\n'
        '    ) -> RelayResponse: ...\n\n'
        '    def model_to_vendor(self, model: str) -> str | None: ...\n\n'
        '    def estimate_cost(self, response: RelayResponse) -> float: ...\n\n'
        'OpenAI适配器实现要点：\n'
        '• 使用 openai 官方Python SDK\n'
        '• model_to_vendor 匹配 gpt-/o1-/o3-/o4- 前缀\n'
        '• 内置GPT-4o/4o-mini/4-turbo/o1等模型的价格表\n'
        '• 费用 = prompt_tokens/1M * prompt_price + completion_tokens/1M * completion_price\n\n'
        'Anthropic适配器实现要点：\n'
        '• 使用 anthropic 官方Python SDK\n'
        '• 处理system消息的分离（Anthropic将system作为顶层参数）\n'
        '• model_to_vendor 匹配 claude- 前缀\n'
        '• 内置Claude Sonnet/Opus/Haiku模型价格表',
    practicalTips: '• 适配器的chat_completion方法应设置合理的超时时长（推荐120秒）\n'
        '• 每个适配器可以设置自己的base_url，便于对接代理或私有部署\n'
        '• 适配器应处理厂商特定的错误码，并转换为统一错误格式\n'
        '• 新增厂商时先确认其Python SDK的异步支持情况\n'
        '• 适配器的费用估算可以用作预算告警，超预算时自动停止服务',
    relatedTech: '适配器模式 · 策略模式 · 工厂模式 · OpenAI SDK · Anthropic SDK · httpx',
    tags: ['设计模式', '适配器', '多厂商', '扩展'],
    difficulty: '进阶',
  ),

  // 5. 限流与配额
  ApiTokenPlatformTopic(
    id: 'rate_limiting',
    name: '限流与配额',
    englishName: 'Rate Limiting & Quota',
    subtitle: '令牌桶算法实现API限流，配额管理控制成本',
    icon: Icons.speed,
    color: Color(0xFF6A1B9A),
    overview: '限流（Rate Limiting）和配额（Quota）是API平台保护自身和客户的关键机制：\n\n'
        '限流：控制请求频率，防止单个用户占用过多资源\n'
        '• 令牌桶算法：以固定速率向桶中放入令牌，请求到达时消耗令牌\n'
        '• 默认设置：每分钟60次请求\n'
        '• 桶容量 = 速率上限，允许短时突发\n\n'
        '配额：控制Token消耗总量，防止成本失控\n'
        '• 按月和按厂商设置Token使用上限\n'
        '• 默认：每月每厂商100万Token\n'
        '• 配额度自动按月重置\n'
        '• 超配额时拒绝请求，返回429状态码\n\n'
        '这两层防护确保了平台的稳定性和成本可预测性。',
    coreConcept: '令牌桶算法（Token Bucket）工作原理：\n\n'
        '1. 桶以固定速率 r（tokens/second）填充令牌\n'
        '2. 桶有最大容量 c（capacity），多余的令牌会被丢弃\n'
        '3. 每个请求需要消耗 1 个令牌\n'
        '4. 如果桶中有足够的令牌，请求被允许；否则被拒绝\n\n'
        '关键参数：\n'
        '- rate (r): 平均允许的请求速率\n'
        '- capacity (c): 允许的最大突发量\n'
        '- 例如：r=1 (60/min), c=60 表示平均每秒1个请求，最多可突发60个\n\n'
        '相比固定窗口算法，令牌桶的优势在于：\n'
        '• 允许合理的流量突发（burst）\n'
        '• 不会在窗口边界产生"双倍流量"问题\n'
        '• 实现简单，线程安全\n\n'
        '配额管理实现：\n'
        '• 每次请求前检查用户对该厂商的剩余配额\n'
        '• 请求成功后增量更新消耗量\n'
        '• 配额重置通过检查reset_at时间戳自动触发',
    keyPoints: '• 令牌桶算法实现请求频率限制\n'
        '• 桶容量支持短时流量突发\n'
        '• 配额按用户+厂商+周期维度管理\n'
        '• 月度配额自动重置\n'
        '• 内存限流器支持可选Redis升级\n'
        '• 超限返回标准HTTP 429状态码',
    detailedContent: '令牌桶实现的Python代码：\n\n'
        'class TokenBucket:\n'
        '    def __init__(self, rate, capacity=None):\n'
        '        self.rate = rate         # tokens/sec\n'
        '        self.capacity = capacity or rate\n'
        '        self.tokens = capacity\n'
        '        self.last_refill = time.monotonic()\n\n'
        '    def consume(self, tokens=1) -> bool:\n'
        '        with self.lock:\n'
        '            self._refill()\n'
        '            if self.tokens >= tokens:\n'
        '                self.tokens -= tokens\n'
        '                return True\n'
        '            return False\n\n'
        '    def _refill(self):\n'
        '        now = time.monotonic()\n'
        '        elapsed = now - self.last_refill\n'
        '        self.tokens = min(self.capacity,\n'
        '            self.tokens + elapsed * self.rate)\n'
        '        self.last_refill = now\n\n'
        'InMemoryRateLimiter 为每个用户维护独立的令牌桶，按user_id索引。\n\n'
        '生产环境升级路径：\n'
        '• 单机：内存限流器足够（默认）\n'
        '• 多机：配置 REDIS_URL 环境变量，切换到Redis后端（需额外实现）\n'
        '• 更复杂场景：使用专业的API网关（Kong、APISIX）处理限流',
    practicalTips: '• 限流参数应该可配置，不同用户等级可以有不同的限流值\n'
        '• 在响应头中返回 X-RateLimit-Remaining 和 X-RateLimit-Reset\n'
        '• 配额告警：当用量达到80%时发送通知\n'
        '• 使用Redis Lua脚本实现分布式令牌桶，保证原子性\n'
        '• 监控限流触发频率，如果大量用户被限流，考虑扩容',
    relatedTech: '令牌桶算法 · Redis · 分布式限流 · 滑动窗口 · 配额管理',
    tags: ['限流', '配额', '性能', '成本控制'],
    difficulty: '中级',
  ),

  // 6. 安全设计
  ApiTokenPlatformTopic(
    id: 'security',
    name: '安全设计',
    englishName: 'Security Design',
    subtitle: '从加密存储到审计日志的全方位安全防护',
    icon: Icons.security,
    color: Color(0xFFB71C1C),
    overview: 'API Token中转平台承载着敏感的API密钥和用户数据，安全设计必须是第一优先级。'
        '平台的安全体系分为四个层次：\n\n'
        '1. 传输安全：全链路HTTPS，TLS 1.2+，证书管理\n'
        '2. 存储安全：密钥加密存储，不同场景使用不同加密方案\n'
        '3. 访问安全：API Key认证 + 最小权限原则\n'
        '4. 审计安全：不可变日志 + 异常检测\n\n'
        '平台特有的安全挑战：\n'
        '• 厂商密钥是"密钥的密钥"——一旦泄露，所有用户的AI调用都会被劫持\n'
        '• 需要在"可解密使用"和"安全存储"之间取得平衡\n'
        '• 日志中绝对不能出现任何密钥原文',
    coreConcept: '密钥保护的分层策略：\n\n'
        '第一层 — 平台API Key（用户凭证）：\n'
        '• 使用 bcrypt 做单向哈希，即使数据库泄露也无法还原\n'
        '• bcrypt的成本因子默认为12（2^12次迭代），对抗暴力破解\n'
        '• 只存储"前缀"用于索引，完整Key永不可恢复\n\n'
        '第二层 — 厂商API Key（平台凭证）：\n'
        '• 使用 Fernet 对称加密，因为使用时需要解密\n'
        '• Fernet = AES-128-CBC + HMAC-SHA256，保证机密性和完整性\n'
        '• 加密密钥从SECRET_KEY派生，不直接存储\n'
        '• 解密后的Key只在内存中存在，用完立即丢弃\n\n'
        '第三层 — 主密钥（SECRET_KEY）：\n'
        '• 只存在于环境变量中，不写入任何文件\n'
        '• 长度至少32字节，使用 openssl rand -hex 32 生成\n'
        '• 定期轮转（注意：轮转会导致历史加密数据无法解密）\n\n'
        '防泄露机制：\n'
        '• 日志过滤器：在任何日志输出前移除Key相关内容\n'
        '• 错误响应：不返回内部错误细节给客户端\n'
        '• SQL注入防护：SQLAlchemy参数化查询\n'
        '• 输入校验：Pydantic自动验证所有请求参数',
    keyPoints: '• bcrypt单向哈希保护用户凭证\n'
        '• Fernet对称加密保护厂商密钥\n'
        '• 主密钥仅存环境变量，不入库不写文件\n'
        '• 日志全面屏蔽Key内容\n'
        '• SQLAlchemy参数化查询防注入\n'
        '• Pydantic自动输入校验\n'
        '• CORS白名单控制跨域访问\n'
        '• 审计日志不可变存储',
    detailedContent: '安全配置检查清单：\n\n'
        '环境安全：\n'
        '☐ SECRET_KEY 使用 openssl rand -hex 32 生成\n'
        '☐ .env 文件在 .gitignore 中\n'
        '☐ 生产环境使用密钥管理服务（KMS/Vault）\n'
        '☐ DEBUG=false 在生产环境\n\n'
        '传输安全：\n'
        '☐ 全站启用HTTPS（通过Nginx或Cloudflare）\n'
        '☐ TLS版本 ≥ 1.2\n'
        '☐ HSTS头已配置\n\n'
        '存储安全：\n'
        '☐ 数据库文件权限限制为600\n'
        '☐ 定期备份数据库并加密备份文件\n'
        '☐ 敏感字段在数据库中使用加密存储\n\n'
        '应用安全：\n'
        '☐ 所有输入使用Pydantic模型校验\n'
        '☐ API端点有适当的认证依赖\n'
        '☐ CORS配置为具体的允许域名而非"*"\n'
        '☐ 速率限制已启用\n\n'
        '监控安全：\n'
        '☐ 异常登录/API使用告警\n'
        '☐ 厂商密钥使用异常检测\n'
        '☐ 定期安全审计',
    practicalTips: '• 生产环境必须使用独立的、随机生成的SECRET_KEY\n'
        '• 厂商密钥建议使用KMS加密，Fernet作为开发环境的降级方案\n'
        '• 日志系统应有独立的保留策略，至少保存90天\n'
        '• 设置厂商密钥的使用告警：单日消耗超过阈值时通知管理员\n'
        '• 定期对数据库连接和执行计划做安全审查',
    relatedTech: 'bcrypt · Fernet · AES-256 · TLS · HMAC · OWASP · SQL注入防护 · KMS',
    tags: ['安全', '加密', '审计', '最佳实践'],
    difficulty: '进阶',
  ),

  // 7. 部署运维
  ApiTokenPlatformTopic(
    id: 'deployment',
    name: '部署运维',
    englishName: 'Deployment & Operations',
    subtitle: 'Docker容器化部署与生产环境运维实践',
    icon: Icons.cloud_done,
    color: Color(0xFF00695C),
    overview: '将API Token中转平台部署到生产环境需要综合考虑容器化、反向代理、监控和CI/CD。'
        '推荐的技术栈：\n\n'
        '容器化：Docker多阶段构建 + docker-compose（开发/小规模）→ Kubernetes（大规模）\n'
        '反向代理：Nginx（TLS终止、静态资源、额外安全层）\n'
        '数据库：开发用SQLite，生产用PostgreSQL（通过修改DATABASE_URL切换）\n'
        '缓存：开发用内存，生产用Redis（限流 + 缓存）\n'
        '监控：Prometheus + Grafana（指标采集和可视化）\n'
        '日志：structlog → ELK Stack（集中式日志分析）',
    coreConcept: 'Docker多阶段构建的核心思想是将构建时依赖和运行时依赖分离：\n\n'
        '第一阶段（builder）：\n'
        '• 基于 python:3.12-slim\n'
        '• 复制 requirements.txt\n'
        '• pip install 安装所有依赖\n\n'
        '第二阶段（runtime）：\n'
        '• 基于 python:3.12-slim（干净的基础镜像）\n'
        '• 从builder复制已安装的包\n'
        '• 创建非root用户运行应用\n'
        '• 最终镜像仅包含运行时所需，体积更小、攻击面更小\n\n'
        'Nginx反向代理配置要点：\n'
        '• 监听443端口，配置SSL证书\n'
        '• proxy_pass转发到FastAPI的8000端口\n'
        '• 设置 client_max_body_size 限制请求体大小\n'
        '• 添加 rate limiting zone 做IP级别限流\n'
        '• 配置 access_log 和 error_log',
    keyPoints: '• Docker多阶段构建减小镜像体积\n'
        '• 非root用户运行容器\n'
        '• Nginx做TLS终止和反向代理\n'
        '• SQLAlchemy抽象层方便切换数据库\n'
        '• 环境变量配置区分开发/生产环境\n'
        '• 健康检查端点 /health 供编排系统使用\n'
        '• docker-compose 一键启动完整服务栈',
    detailedContent: '生产部署步骤：\n\n'
        '1. 准备服务器\n'
        '   - 安装 Docker 和 docker-compose\n'
        '   - 配置防火墙（仅开放80/443端口）\n\n'
        '2. 配置环境变量\n'
        '   - 生成 SECRET_KEY\n'
        '   - 设置 DATABASE_URL（PostgreSQL格式）\n'
        '   - 配置 REDIS_URL\n'
        '   - 填入厂商API Key\n\n'
        '3. 拉取代码并构建镜像\n'
        '   docker-compose build\n\n'
        '4. 初始化数据库\n'
        '   docker-compose run app python -c "from app.database import init_db; init_db()"\n\n'
        '5. 启动服务\n'
        '   docker-compose up -d\n\n'
        '6. 配置Nginx反向代理\n'
        '   - 创建Nginx配置文件\n'
        '   - 配置SSL证书（Let\'s Encrypt免费证书）\n'
        '   - 重启Nginx\n\n'
        '7. 验证部署\n'
        '   curl https://your-domain.com/health',
    practicalTips: '• 使用 watchtower 或 renovate 自动更新Docker镜像\n'
        '• 数据库迁移使用 Alembic，配合 CI/CD 自动执行\n'
        '• 容器日志驱动使用 json-file 或直接输出到 syslog\n'
        '• 设置 Docker 的 restart policy 为 unless-stopped\n'
        '• 定期备份数据库（cron job + 远程存储）\n'
        '• 监控 /health 端点的可用性和响应时间',
    relatedTech: 'Docker · docker-compose · Nginx · PostgreSQL · Redis · Prometheus · ELK · CI/CD',
    tags: ['部署', 'Docker', '运维', '生产环境'],
    difficulty: '中级',
  ),

  // 8. API参考
  ApiTokenPlatformTopic(
    id: 'api_reference',
    name: 'API参考',
    englishName: 'API Reference',
    subtitle: '完整的中继平台API端点文档与调用示例',
    icon: Icons.api,
    color: Color(0xFF37474F),
    overview: 'API Token中转平台提供RESTful API，所有端点返回JSON格式数据。\n\n'
        'Base URL: http://localhost:8000\n'
        'Swagger UI: http://localhost:8000/docs\n'
        'ReDoc: http://localhost:8000/redoc\n\n'
        '认证方式有两种：\n'
        '1. JWT Token — 用于用户管理操作（注册、登录、创建API Key）\n'
        '   Header: Authorization: Bearer <jwt_token>\n'
        '2. 平台API Key — 用于实际的AI调用和用量查询\n'
        '   Header: Authorization: Bearer atp_xxxxxxxxxxxx\n\n'
        'API分为四个模块：\n'
        '• Auth — 用户认证和Key管理\n'
        '• Relay — AI调用的核心中继端点\n'
        '• Usage — 用量统计和配额查询\n'
        '• Admin — 厂商密钥管理',
    coreConcept: '核心中继端点 /v1/chat/completions 的请求格式设计为兼容OpenAI Chat Completions API，'
        '同时增加了 vendor 扩展字段用于手动指定厂商。\n\n'
        '请求体：\n'
        '{\n'
        '  "model": "gpt-4o",          // 必填，模型名称\n'
        '  "messages": [               // 必填，消息列表\n'
        '    {"role": "user", "content": "Hello"}\n'
        '  ],\n'
        '  "max_tokens": 1024,        // 可选，最大输出token数\n'
        '  "temperature": 0.7,        // 可选，温度参数\n'
        '  "top_p": 1.0,              // 可选，核采样参数\n'
        '  "stream": false,           // 可选，是否流式输出\n'
        '  "vendor": "openai"         // 可选，手动指定厂商\n'
        '}\n\n'
        '响应体（标准化格式）：\n'
        '{\n'
        '  "id": "chatcmpl-xxx",\n'
        '  "model": "gpt-4o",\n'
        '  "vendor": "openai",\n'
        '  "content": "Hello! How can I help?",\n'
        '  "role": "assistant",\n'
        '  "usage": {\n'
        '    "prompt_tokens": 10,\n'
        '    "completion_tokens": 5,\n'
        '    "total_tokens": 15\n'
        '  },\n'
        '  "finish_reason": "stop",\n'
        '  "latency_ms": 1234.5\n'
        '}',
    keyPoints: '• 兼容 OpenAI Chat Completions API 格式\n'
        '• 自动根据 model 名检测目标厂商\n'
        '• 手动指定 vendor 字段可覆盖自动检测\n'
        '• 标准化响应格式，统一所有厂商的返回\n'
        '• 响应中包含厂商信息、Token用量、延迟\n'
        '• Swagger UI 提供交互式API文档',
    detailedContent: '完整的API端点列表：\n\n'
        '认证模块 (/auth)：\n'
        '  POST /auth/register — 用户注册\n'
        '  POST /auth/login — 用户登录（返回JWT）\n'
        '  POST /auth/api-keys — 创建平台API Key（需JWT）\n'
        '  GET /auth/api-keys — 列出所有API Key\n'
        '  DELETE /auth/api-keys/{id} — 撤销API Key\n\n'
        '中继模块 (/v1)：\n'
        '  POST /v1/chat/completions — AI聊天补全（需API Key）\n\n'
        '用量模块 (/usage)：\n'
        '  GET /usage/stats?days=30 — 用量统计总览\n'
        '  GET /usage/quotas — 各厂商配额状态\n\n'
        '管理模块 (/admin)：\n'
        '  GET /admin/vendors — 厂商密钥配置状态\n'
        '  POST /admin/vendors/{name}/key — 设置厂商密钥\n'
        '  GET /admin/vendors/supported — 支持的厂商列表\n\n'
        '系统：\n'
        '  GET /health — 健康检查\n\n'
        '错误码说明：\n'
        '  200 — 成功\n'
        '  400 — 请求参数错误（不支持的厂商、无法识别模型）\n'
        '  401 — 未认证（缺少或无效的API Key）\n'
        '  429 — 请求过于频繁（触发限流）\n'
        '  502 — 厂商API调用失败（上游错误）',
    practicalTips: '• 使用 Swagger UI (/docs) 可以交互式测试所有API\n'
        '• 创建API Key后立即保存，完整Key不会再次显示\n'
        '• 建议为不同应用创建不同的API Key，便于独立管理和撤销\n'
        '• 查看用量统计时可以用 days 参数调整时间范围（1-365天）\n'
        '• 如果自动模型识别不准确，可以在请求中手动指定 vendor 字段',
    relatedTech: 'REST API · JSON · Swagger · OpenAPI · JWT · API Key · Bearer Token',
    tags: ['API', '参考', '端点', '集成'],
    difficulty: '基础',
  ),
];
