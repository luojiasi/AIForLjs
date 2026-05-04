import 'package:flutter/material.dart';

class AwesomePythonLibrary {
  final String name;
  final String url;
  final String description;
  final List<String> features;
  final String useCase;
  final String? tutorialCode;
  const AwesomePythonLibrary(this.name, this.url, this.description, this.features, this.useCase, {this.tutorialCode});
}

class AwesomePythonSubCategory {
  final String name;
  final List<AwesomePythonLibrary> libraries;
  const AwesomePythonSubCategory(this.name, this.libraries);
}

class AwesomePythonCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<AwesomePythonSubCategory> subCategories;

  int get libraryCount =>
      subCategories.fold(0, (sum, sc) => sum + sc.libraries.length);

  const AwesomePythonCategory(
    this.name,
    this.icon,
    this.color,
    this.description,
    this.subCategories,
  );
}

final List<AwesomePythonCategory> awesomePythonCategories = [
  AwesomePythonCategory(
    'AI & 机器学习',
    Icons.psychology,
    Color(0xFF1565C0),
    '人工智能、深度学习、机器学习、自然语言处理、计算机视觉等领域的最佳 Python 库',
    [
      AwesomePythonSubCategory('AI 智能体与代理', [
        AwesomePythonLibrary('langchain', 'https://github.com/langchain-ai/langchain', '构建LLM应用的可组合框架', ['链式组合', '工具集成', '记忆管理'], '构建复杂的LLM应用'),
        AwesomePythonLibrary('transformers', 'https://github.com/huggingface/transformers', 'HuggingFace预训练Transformer模型库', ['预训练模型', '多模态', 'Pipelines'], '文本分类、NER、翻译'),
        AwesomePythonLibrary('vllm', 'https://github.com/vllm-project/vllm', '高吞吐量LLM推理和服务引擎', ['PagedAttention', '批处理', '多GPU'], '大规模LLM推理部署'),
        AwesomePythonLibrary('dspy', 'https://github.com/stanfordnlp/dspy', 'Stanford NLP编程式语言模型框架', ['声明式', '自动优化', '模块化'], '构建可优化的LLM管道'),
        AwesomePythonLibrary('pydantic-ai', 'https://github.com/pydantic/pydantic-ai', '基于Pydantic的AI Agent框架', ['类型安全', '结构化输出', '多模型'], '构建类型安全的AI Agent'),
        AwesomePythonLibrary('llama-index', 'https://github.com/run-llama/llama_index', 'LLM数据框架，连接数据源到LLM', ['数据连接器', '索引', '查询引擎'], 'RAG应用、知识库问答'),
        AwesomePythonLibrary('crewai', 'https://github.com/crewAIInc/crewAI', '多Agent协作框架', ['角色扮演', '任务委派', '协作'], '复杂多步骤任务自动化'),
        AwesomePythonLibrary('autogen', 'https://github.com/microsoft/autogen', 'Microsoft多Agent对话框架', ['多Agent', '代码生成', '人机协作'], '多Agent系统、工作流'),
        AwesomePythonLibrary('openai-agents', 'https://github.com/openai/openai-agents', 'OpenAI的Agent框架', ['Agent编排', '工具使用', '追踪'], '生产级AI Agent'),
        AwesomePythonLibrary('instructor', 'https://github.com/jxnl/instructor', '从LLM提取结构化数据', ['结构化提取', '类型验证', '重试'], 'LLM输出转结构化数据'),
        AwesomePythonLibrary('sglang', 'https://github.com/sglang-project/sglang', '高性能LLM和VL模型服务框架', ['RadixAttention', '结构化输出', '多模态'], '高效LLM推理'),
        AwesomePythonLibrary('diffusers', 'https://github.com/huggingface/diffusers', '预训练扩散模型库', ['扩散模型', 'Pipeline', '模型微调'], '图像、音频、视频生成'),
        AwesomePythonLibrary('mlx-lm', 'https://github.com/ml-explore/mlx-lm', 'Apple Silicon LLM运行和微调', ['Apple Silicon', '统一内存', 'LoRA'], 'Mac上高效运行LLM'),
        AwesomePythonLibrary('unsloth', 'https://github.com/unslothai/unsloth', '加速LLM微调和训练', ['内存优化', '训练加速', 'LoRA'], '低资源LLM微调'),
        AwesomePythonLibrary('openai-whisper', 'https://github.com/openai/whisper', '通用语音识别模型', ['多语言', '语音识别', '转录'], '语音转文字'),
        AwesomePythonLibrary('mem0', 'https://github.com/mem0ai/mem0', 'AI Agent智能记忆层', ['记忆管理', '个性化', '上下文'], '长期记忆AI应用'),
      ]),
      AwesomePythonSubCategory('深度学习', [
        AwesomePythonLibrary('pytorch', 'https://github.com/pytorch/pytorch', '主流深度学习框架，动态计算图', ['动态计算图', '自动微分', 'GPU加速'], 'CV、NLP、强化学习'),
        AwesomePythonLibrary('tensorflow', 'https://github.com/tensorflow/tensorflow', 'Google深度学习框架', ['Keras API', 'TF Serving', 'TPU'], '生产环境ML部署'),
        AwesomePythonLibrary('keras', 'https://github.com/keras-team/keras', '高级深度学习API，多后端支持', ['多后端', '高层API', '回调系统'], '快速原型和模型训练'),
        AwesomePythonLibrary('jax', 'https://github.com/jax-ml/jax', '高性能数值计算和自动微分', ['函数式', 'JIT编译', 'vmap/pmap'], '科学计算、研究级DL'),
        AwesomePythonLibrary('pytorch-lightning', 'https://github.com/Lightning-AI/pytorch-lightning', 'PyTorch训练标准化框架', ['训练循环', '多GPU', '16位精度'], '规范化DL项目开发'),
        AwesomePythonLibrary('stable-baselines3', 'https://github.com/DLR-RM/stable-baselines3', 'PyTorch强化学习算法集合', ['强化学习', '算法实现', 'VecEnv'], 'RL研究和应用'),
      ]),
      AwesomePythonSubCategory('机器学习', [
        AwesomePythonLibrary('scikit-learn', 'https://github.com/scikit-learn/scikit-learn', '最流行的Python机器学习库', ['分类回归', '聚类', '降维'], '通用ML任务、数据挖掘'),
        AwesomePythonLibrary('xgboost', 'https://github.com/dmlc/xgboost', '可扩展梯度提升库', ['GBDT', 'GPU加速', '特征重要性'], '结构化数据预测、竞赛'),
        AwesomePythonLibrary('lightgbm', 'https://github.com/microsoft/LightGBM', '高性能梯度提升框架', ['直方图算法', '并行', '类别特征'], '大规模数据快速训练'),
        AwesomePythonLibrary('catboost', 'https://github.com/catboost/catboost', '支持类别特征的高性能GBDT', ['类别特征', 'GPU', '过拟合检测'], '含大量类别特征的数据'),
        AwesomePythonLibrary('h2o', 'https://github.com/h2oai/h2o-3', '开源快速ML平台', ['AutoML', '分布式', '模型解释'], '自动化ML、企业级平台'),
        AwesomePythonLibrary('pgmpy', 'https://github.com/pgmpy/pgmpy', '概率图模型和贝叶斯网络', ['贝叶斯网络', '结构学习', '推断'], '概率建模、因果推断'),
        AwesomePythonLibrary('timesfm', 'https://github.com/google-research/timesfm', '预训练时间序列基础模型', ['预训练', '时间序列', '零样本'], '时间序列预测'),
        AwesomePythonLibrary('mindsdb', 'https://github.com/mindsdb/mindsdb', '数据库AI层，SQL接口ML', ['数据库集成', 'SQL', 'AutoML'], '数据库内ML训练部署'),
        AwesomePythonLibrary('feature_engine', 'https://github.com/feature-engine/feature_engine', '特征工程库，sklearn兼容', ['特征工程', '缺失值', '编码'], '系统化特征工程pipeline'),
      ]),
      AwesomePythonSubCategory('自然语言处理', [
        AwesomePythonLibrary('spacy', 'https://github.com/explosion/spaCy', '工业级NLP库', ['分词标注', 'NER', '依存分析'], '生产环境文本处理'),
        AwesomePythonLibrary('nltk', 'https://github.com/nltk/nltk', 'NLP研究和教学标准平台', ['语料库', '标注', '语法分析'], 'NLP教学、原型开发'),
        AwesomePythonLibrary('gensim', 'https://github.com/RaRe-Technologies/gensim', '主题建模和文档相似度', ['Word2Vec', 'LDA', 'Doc2Vec'], '主题建模、词嵌入'),
        AwesomePythonLibrary('stanza', 'https://github.com/stanfordnlp/stanza', 'Stanford NLP库，60+语言', ['多语言', '依存分析', 'NER'], '多语言文本分析'),
        AwesomePythonLibrary('jieba', 'https://github.com/fxsjy/jieba', '最流行的中文分词库', ['中文分词', '词性标注', '关键词'], '中文文本处理基础工具'),
      ]),
      AwesomePythonSubCategory('计算机视觉', [
        AwesomePythonLibrary('opencv', 'https://github.com/opencv/opencv', '开源计算机视觉库', ['图像处理', '对象检测', '视频分析'], '图像处理、AR应用'),
        AwesomePythonLibrary('kornia', 'https://github.com/kornia/kornia', 'PyTorch可微分CV库', ['可微分', '数据增强', '几何变换'], 'DL视觉任务数据处理'),
        AwesomePythonLibrary('easyocr', 'https://github.com/JaidedAI/EasyOCR', '即用型OCR，40+语言', ['多语言OCR', '文本检测', 'GPU'], '多语言文字识别'),
        AwesomePythonLibrary('pytesseract', 'https://github.com/madmaze/pytesseract', 'Google Tesseract OCR包装器', ['OCR', '多语言', '预处理'], '文档数字化'),
      ]),
      AwesomePythonSubCategory('推荐系统', [
        AwesomePythonLibrary('annoy', 'https://github.com/spotify/annoy', 'Spotify近似最近邻搜索', ['近似搜索', '内存优化', '多距离'], '大规模向量相似度搜索'),
        AwesomePythonLibrary('implicit', 'https://github.com/benfred/implicit', '隐式反馈协同过滤', ['协同过滤', 'ALS', 'GPU'], '隐式反馈推荐'),
        AwesomePythonLibrary('scikit-surprise', 'https://github.com/NicolasHug/Surprise', '推荐系统构建和分析', ['协同过滤', '矩阵分解', '评估'], '推荐系统研究和原型'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    'Web 开发',
    Icons.web,
    Color(0xFF2E7D32),
    'Python Web框架、API开发、服务器、WebSocket、模板引擎和认证等',
    [
      AwesomePythonSubCategory('Web 框架 — 同步', [
        AwesomePythonLibrary('django', 'https://github.com/django/django', '最流行的Python全栈Web框架', ['ORM', 'Admin', '中间件', '认证'], 'CMS、电商、社交平台'),
        AwesomePythonLibrary('flask', 'https://github.com/pallets/flask', '轻量级微框架，灵活扩展', ['路由', '模板', '扩展', '测试'], 'API服务、微服务'),
        AwesomePythonLibrary('pyramid', 'https://github.com/Pylons/pyramid', '灵活可扩展的Web框架', ['路由', '认证', '模板', '资源树'], '灵活架构的Web应用'),
        AwesomePythonLibrary('bottle', 'https://github.com/bottlepy/bottle', '单文件微框架，零依赖', ['单文件', '零依赖', '路由', '模板'], '嵌入式服务、原型'),
        AwesomePythonLibrary('fasthtml', 'https://github.com/AnswerDotAI/fasthtml', '最快创建HTML应用', ['快速', 'HTML生成', '组件化'], '快速HTML应用构建'),
        AwesomePythonLibrary('masonite', 'https://github.com/MasoniteFramework/masonite', '现代以开发者为中心的框架', ['IoC', 'ORM', '任务调度'], '现代Web应用'),
      ]),
      AwesomePythonSubCategory('Web 框架 — 异步', [
        AwesomePythonLibrary('starlette', 'https://github.com/encode/starlette', '轻量级ASGI框架', ['ASGI', 'WebSocket', '后台任务'], '高性能API服务'),
        AwesomePythonLibrary('litestar', 'https://github.com/litestar-org/litestar', '生产就绪ASGI Web框架', ['ASGI', '依赖注入', 'OpenAPI'], '企业级异步API'),
        AwesomePythonLibrary('tornado', 'https://github.com/tornadoweb/tornado', '异步网络库和Web框架', ['非阻塞I/O', 'WebSocket', '长轮询'], '实时Web服务'),
        AwesomePythonLibrary('reflex', 'https://github.com/reflex-dev/reflex', '纯Python构建响应式全栈应用', ['响应式', '组件化', '全栈'], '用Python构建SPA'),
        AwesomePythonLibrary('robyn', 'https://github.com/sparckles/Robyn', 'Rust运行时的异步Web框架', ['Rust核心', '高并发', '多线程'], '极致性能Web服务'),
        AwesomePythonLibrary('microdot', 'https://github.com/miguelgrinberg/microdot', '极小的Web框架，支持MicroPython', ['极小', 'MicroPython', 'WebSocket'], 'IoT嵌入式Web服务'),
      ]),
      AwesomePythonSubCategory('Web API', [
        AwesomePythonLibrary('fastapi', 'https://github.com/fastapi/fastapi', '现代高性能API框架', ['自动文档', '类型验证', '异步'], 'RESTful API首选'),
        AwesomePythonLibrary('django-rest-framework', 'https://github.com/encode/django-rest-framework', 'Django REST API工具集', ['序列化', '视图集', '认证'], 'Django REST API层'),
        AwesomePythonLibrary('django-ninja', 'https://github.com/vitalik/django-ninja', '基于类型提示的Django REST', ['类型提示', '自动文档', 'Pydantic'], 'Django现代API开发'),
        AwesomePythonLibrary('falcon', 'https://github.com/falconry/falcon', '高性能云API框架', ['极简', '高性能', 'RESTful'], '高性能微服务'),
        AwesomePythonLibrary('sanic', 'https://github.com/sanic-org/sanic', '高速异步Web服务器框架', ['异步', '速度优先', 'WebSocket'], '极致响应速度API'),
        AwesomePythonLibrary('connexion', 'https://github.com/spec-first/connexion', 'API优先，OpenAPI规范框架', ['API优先', 'OpenAPI', '自动路由'], 'API规范驱动开发'),
        AwesomePythonLibrary('strawberry', 'https://github.com/strawberry-graphql/strawberry', '基于类型注解的GraphQL库', ['GraphQL', '类型注解', '订阅'], '类型安全GraphQL API'),
        AwesomePythonLibrary('apiflask', 'https://github.com/apiflask/apiflask', 'Flask+Marshmallow API框架', ['Flask', '序列化', 'OpenAPI'], 'Flask项目API开发'),
        AwesomePythonLibrary('webargs', 'https://github.com/marshmallow-code/webargs', 'HTTP请求参数解析库', ['参数解析', '验证', '多框架'], '统一请求参数处理'),
      ]),
      AwesomePythonSubCategory('Web 服务器', [
        AwesomePythonLibrary('uvicorn', 'https://github.com/encode/uvicorn', '闪电ASGI服务器', ['ASGI', 'uvloop', '多进程'], 'ASGI应用生产服务器'),
        AwesomePythonLibrary('gunicorn', 'https://github.com/benoitc/gunicorn', '预分叉WSGI服务器', ['预分叉', '多Worker', '优雅重启'], 'WSGI应用生产服务器'),
        AwesomePythonLibrary('hypercorn', 'https://github.com/pgjones/hypercorn', 'ASGI/WSGI服务器，支持HTTP/2', ['ASGI', 'WSGI', 'HTTP/2'], 'HTTP/2 Python服务器'),
        AwesomePythonLibrary('granian', 'https://github.com/emmett-framework/granian', 'Rust HTTP服务器', ['Rust', '高性能', '多协议'], '高性能Python部署'),
        AwesomePythonLibrary('daphne', 'https://github.com/django/daphne', 'Django Channels的ASGI服务器', ['ASGI', 'HTTP/2', 'Django'], 'Django Channels服务'),
        AwesomePythonLibrary('uwsgi', 'https://github.com/unbit/uwsgi', 'C语言全栈托管服务', ['多协议', '进程管理', '缓存'], '复杂部署场景'),
        AwesomePythonLibrary('grpcio', 'https://github.com/grpc/grpc', 'Google HTTP/2 RPC框架Python绑定', ['gRPC', 'Protobuf', '流式'], '微服务高性能通信'),
      ]),
      AwesomePythonSubCategory('WebSocket', [
        AwesomePythonLibrary('websockets', 'https://github.com/python-websockets/websockets', 'WebSocket服务器和客户端库', ['asyncio', 'RFC6455', '双向'], '实时通信应用'),
        AwesomePythonLibrary('channels', 'https://github.com/django/channels', 'Django异步支持层', ['Django', 'WebSocket', '消费者'], 'Django实时功能扩展'),
        AwesomePythonLibrary('flask-socketio', 'https://github.com/miguelgrinberg/Flask-SocketIO', 'Flask的Socket.IO集成', ['Socket.IO', '房间', '事件'], 'Flask实时通信'),
        AwesomePythonLibrary('autobahn-python', 'https://github.com/crossbario/autobahn-python', 'WebSocket和WAMP协议实现', ['WAMP', 'WebSocket', 'RPC'], '分布式实时系统'),
      ]),
      AwesomePythonSubCategory('模板引擎', [
        AwesomePythonLibrary('jinja', 'https://github.com/pallets/jinja', '设计师友好的模板语言', ['沙箱', '继承', '宏'], 'HTML模板渲染'),
        AwesomePythonLibrary('mako', 'https://github.com/sqlalchemy/mako', '超快速Python模板引擎', ['内联Python', '缓存', '继承'], '高性能模板渲染'),
      ]),
      AwesomePythonSubCategory('认证', [
        AwesomePythonLibrary('authlib', 'https://github.com/lepture/authlib', 'OAuth/OpenID Connect实现', ['OAuth2', 'OIDC', 'JWT'], 'OAuth认证服务'),
        AwesomePythonLibrary('django-allauth', 'https://github.com/pennersr/django-allauth', 'Django集成认证应用', ['社交登录', '多因素', '邮箱'], 'Django项目认证'),
        AwesomePythonLibrary('pyjwt', 'https://github.com/jpadilla/pyjwt', 'Python JSON Web Token实现', ['JWT', '签名', '验证'], '无状态API认证'),
        AwesomePythonLibrary('django-guardian', 'https://github.com/django-guardian/django-guardian', 'Django对象级权限', ['对象权限', '行级权限', '继承'], '细粒度权限控制'),
        AwesomePythonLibrary('oauthlib', 'https://github.com/oauthlib/oauthlib', 'OAuth请求签名逻辑实现', ['OAuth1', 'OAuth2', '签名'], 'OAuth协议底层实现'),
      ]),
      AwesomePythonSubCategory('Admin 管理面板', [
        AwesomePythonLibrary('flower', 'https://github.com/mher/flower', 'Celery实时监控Web面板', ['任务监控', 'Worker管理', '图表'], 'Celery分布式任务监控'),
        AwesomePythonLibrary('django-unfold', 'https://github.com/unfoldadmin/django-unfold', '现代Django管理界面', ['现代化UI', '暗色模式', '可定制'], 'Django Admin现代化'),
        AwesomePythonLibrary('flask-admin', 'https://github.com/flask-admin/flask-admin', 'Flask可扩展管理界面', ['CRUD', '模型视图', '文件管理'], 'Flask管理后台'),
        AwesomePythonLibrary('jet-bridge', 'https://github.com/jet-admin/jet-bridge', '任意应用管理面板', ['零代码', '多数据库', '可视化'], '快速管理界面'),
      ]),
      AwesomePythonSubCategory('CMS 内容管理', [
        AwesomePythonLibrary('wagtail', 'https://github.com/wagtail/wagtail', 'Django内容管理系统', ['StreamField', '页面模型', '工作流'], '企业级内容管理'),
        AwesomePythonLibrary('django-cms', 'https://github.com/django-cms/django-cms', '企业级Django CMS', ['拖拽编辑', '插件', '多语言'], '大型企业网站'),
      ]),
      AwesomePythonSubCategory('静态网站生成器', [
        AwesomePythonLibrary('pelican', 'https://github.com/getpelican/pelican', '支持Markdown/reST的静态生成器', ['Markdown', 'reST', '主题'], '博客和技术文档'),
        AwesomePythonLibrary('nikola', 'https://github.com/getnikola/nikola', '静态网站和博客生成器', ['多格式', '主题', '部署'], '个人博客和文档站'),
        AwesomePythonLibrary('lektor', 'https://github.com/lektor/lektor', '易用静态CMS和博客引擎', ['管理界面', '模板', '部署'], '静态内容网站'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    'HTTP & 爬虫',
    Icons.http,
    Color(0xFFE65100),
    'HTTP客户端、网络爬虫、网页抓取和邮件处理工具',
    [
      AwesomePythonSubCategory('HTTP 客户端', [
        AwesomePythonLibrary('requests', 'https://github.com/psf/requests', '人性化HTTP库，Python下载量最高', ['简洁API', '会话管理', 'SSL', '编码'], 'API调用、文件下载'),
        AwesomePythonLibrary('httpx', 'https://github.com/encode/httpx', '下一代HTTP客户端，HTTP/2+异步', ['HTTP/2', '异步', '连接池'], '现代异步HTTP请求'),
        AwesomePythonLibrary('aiohttp', 'https://github.com/aio-libs/aiohttp', '异步HTTP客户端/服务器', ['异步', 'WebSocket', '中间件'], '高并发HTTP服务'),
        AwesomePythonLibrary('urllib3', 'https://github.com/urllib3/urllib3', '线程安全HTTP库，连接池', ['连接池', '线程安全', '重试'], '底层HTTP通信'),
        AwesomePythonLibrary('furl', 'https://github.com/gruns/furl', 'URL解析和操作库', ['URL解析', '查询参数', '编码'], 'URL构建和解析'),
      ]),
      AwesomePythonSubCategory('Web 爬虫', [
        AwesomePythonLibrary('scrapy', 'https://github.com/scrapy/scrapy', '快速高级Web爬虫框架', ['异步引擎', 'Pipeline', '去重'], '大规模数据采集'),
        AwesomePythonLibrary('crawl4ai', 'https://github.com/unclecode/crawl4ai', 'LLM友好的Web爬虫', ['LLM友好', '结构化提取', '快速'], 'AI应用网页数据提取'),
        AwesomePythonLibrary('browser-use', 'https://github.com/browser-use/browser-use', 'AI Agent浏览器自动化', ['AI友好', '浏览器控制', '多标签'], 'AI Agent智能网页交互'),
        AwesomePythonLibrary('mechanicalsoup', 'https://github.com/MechanicalSoup/MechanicalSoup', '网站交互自动化库', ['表单提交', 'Cookie', '重定向'], '自动化网页登录交互'),
        AwesomePythonLibrary('trafilatura', 'https://github.com/adbar/trafilatura', 'Web文本和元数据提取', ['内容提取', '过滤', '多语言'], '干净文本提取'),
        AwesomePythonLibrary('feedparser', 'https://github.com/kurtmckee/feedparser', '通用RSS/Atom Feed解析器', ['RSS', 'Atom', '多格式'], 'RSS订阅聚合'),
        AwesomePythonLibrary('html2text', 'https://github.com/Alir3z4/html2text', 'HTML转Markdown文本', ['HTML解析', 'Markdown', '格式化'], '网页转可读文本'),
        AwesomePythonLibrary('sumy', 'https://github.com/miso-belica/sumy', '自动文本摘要模块', ['文本摘要', '多算法', '多语言'], '文章自动摘要'),
      ]),
      AwesomePythonSubCategory('邮件', [
        AwesomePythonLibrary('modoboa', 'https://github.com/modoboa/modoboa', '邮件托管管理平台', ['邮件服务器', 'Web界面', '自托管'], '自建邮件系统'),
        AwesomePythonLibrary('yagmail', 'https://github.com/kootenpv/yagmail', '简化Gmail/SMTP发送', ['Gmail', '附件', 'HTML邮件'], '程序化邮件发送'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '数据库 & 存储',
    Icons.storage,
    Color(0xFF6A1B9A),
    'ORM、数据库驱动、缓存、搜索、序列化等数据存储相关库',
    [
      AwesomePythonSubCategory('ORM — 关系数据库', [
        AwesomePythonLibrary('sqlalchemy', 'https://github.com/sqlalchemy/sqlalchemy', '最强Python SQL工具包和ORM', ['ORM', 'Core API', '连接池'], '复杂数据库操作'),
        AwesomePythonLibrary('django.db.models', 'https://github.com/django/django', 'Django ORM', ['模型', '查询集', '迁移', '关联'], 'Django项目数据模型'),
        AwesomePythonLibrary('peewee', 'https://github.com/coleifer/peewee', '小巧表达力强的ORM', ['轻量', '表达式', '连接池'], '中小型项目数据层'),
        AwesomePythonLibrary('sqlmodel', 'https://github.com/fastapi/sqlmodel', '类型注解ORM，Pydantic+SQLAlchemy', ['类型安全', 'Pydantic', 'FastAPI'], 'FastAPI项目数据模型'),
        AwesomePythonLibrary('pony', 'https://github.com/ponyorm/pony', '生成器接口ORM', ['生成器查询', '可视化', '自动迁移'], 'Pythonic数据库操作'),
        AwesomePythonLibrary('tortoise-orm', 'https://github.com/tortoise/tortoise-orm', '异步ORM，受Django启发', ['异步', 'Django风格', 'Pydantic'], '异步Web应用数据层'),
        AwesomePythonLibrary('dataset', 'https://github.com/pudo/dataset', '字典存入数据库的简化工具', ['字典存储', '自动建表', '导出'], '快速原型数据存储'),
      ]),
      AwesomePythonSubCategory('ORM — NoSQL', [
        AwesomePythonLibrary('mongoengine', 'https://github.com/MongoEngine/mongoengine', 'MongoDB Python ODM', ['文档映射', '查询', 'GridFS'], 'MongoDB数据建模'),
        AwesomePythonLibrary('beanie', 'https://github.com/BeanieODM/beanie', '异步MongoDB ODM', ['异步', 'Pydantic', '索引'], 'FastAPI+MongoDB'),
        AwesomePythonLibrary('pynamodb', 'https://github.com/pynamodb/PynamoDB', 'Amazon DynamoDB Pythonic接口', ['DynamoDB', '模型', '查询'], 'AWS DynamoDB应用'),
      ]),
      AwesomePythonSubCategory('数据库驱动', [
        AwesomePythonLibrary('psycopg', 'https://github.com/psycopg/psycopg2', '最流行PostgreSQL适配器', ['连接池', '异步', '二进制'], 'PostgreSQL连接'),
        AwesomePythonLibrary('pymongo', 'https://github.com/mongodb/mongo-python-driver', 'MongoDB官方Python客户端', ['CRUD', '聚合', 'GridFS'], 'MongoDB操作'),
        AwesomePythonLibrary('redis-py', 'https://github.com/redis/redis-py', 'Redis Python客户端', ['所有命令', 'Pipeline', '发布订阅'], 'Redis缓存和队列'),
        AwesomePythonLibrary('pymysql', 'https://github.com/PyMySQL/PyMySQL', '纯Python MySQL驱动', ['兼容', '安全', '连接池'], 'MySQL连接'),
        AwesomePythonLibrary('mysqlclient', 'https://github.com/PyMySQL/mysqlclient', 'MySQL C扩展连接器', ['C扩展', '高性能', '兼容'], '高性能MySQL连接'),
        AwesomePythonLibrary('sqlite3', 'https://docs.python.org/3/library/sqlite3.html', '标准库SQLite接口', ['零配置', '嵌入式', '事务'], '嵌入式数据库'),
      ]),
      AwesomePythonSubCategory('Python实现的数据库', [
        AwesomePythonLibrary('duckdb', 'https://github.com/duckdb/duckdb', '进程内SQL OLAP数据库', ['列式存储', 'OLAP', '并行'], '数据分析、ETL'),
        AwesomePythonLibrary('chromadb', 'https://github.com/chroma-core/chroma', '开源嵌入数据库', ['向量存储', '相似搜索', '元数据'], 'AI应用向量存储'),
        AwesomePythonLibrary('tinydb', 'https://github.com/msiemens/tinydb', '轻量级面向文档数据库', ['JSON存储', '查询', '表'], '小项目持久化'),
        AwesomePythonLibrary('pickledb', 'https://github.com/patx/pickledb', '简单轻量级键值存储', ['键值存储', '持久化', '简单API'], '简单配置状态存储'),
      ]),
      AwesomePythonSubCategory('缓存', [
        AwesomePythonLibrary('python-diskcache', 'https://github.com/grantjenks/python-diskcache', '磁盘缓存，比memcached更快', ['磁盘缓存', 'Django集成', '过期'], '本地缓存'),
        AwesomePythonLibrary('cachetools', 'https://github.com/tkem/cachetools', '可扩展记忆化集合和装饰器', ['LRU', 'TTL', '装饰器'], '函数结果缓存'),
        AwesomePythonLibrary('django-cacheops', 'https://github.com/Suor/django-cacheops', 'Django ORM自动缓存', ['自动缓存', '查询集', '失效'], 'Django查询缓存'),
      ]),
      AwesomePythonSubCategory('搜索', [
        AwesomePythonLibrary('elasticsearch-py', 'https://github.com/elastic/elasticsearch-py', 'Elasticsearch官方Python客户端', ['全文搜索', '聚合', '索引'], '搜索引擎'),
        AwesomePythonLibrary('django-haystack', 'https://github.com/django-haystack/django-haystack', 'Django模块化搜索抽象', ['多后端', '统一API', '索引'], 'Django统一搜索'),
        AwesomePythonLibrary('pysolr', 'https://github.com/django-haystack/pysolr', 'Apache Solr轻量Python包装器', ['Solr', '查询', '索引'], 'Solr搜索引擎交互'),
      ]),
      AwesomePythonSubCategory('序列化', [
        AwesomePythonLibrary('marshmallow', 'https://github.com/marshmallow-code/marshmallow', '复杂对象与Python类型转换', ['序列化', '反序列化', '验证'], 'API数据验证转换'),
        AwesomePythonLibrary('orjson', 'https://github.com/ijl/orjson', '快速正确JSON库，Rust实现', ['极速', 'datetime', 'numpy'], '高性能JSON序列化'),
        AwesomePythonLibrary('msgpack', 'https://github.com/msgpack/msgpack-python', 'MessagePack序列化实现', ['二进制', '紧凑', '跨语言'], '高效二进制数据交换'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '数据 & 科学',
    Icons.bar_chart,
    Color(0xFF00838F),
    '数据分析、数据验证、可视化、地理信息、科学计算和量子计算',
    [
      AwesomePythonSubCategory('数据分析', [
        AwesomePythonLibrary('pandas', 'https://github.com/pandas-dev/pandas', '高性能数据分析工具', ['DataFrame', '数据清洗', '时间序列'], '数据分析标准工具'),
        AwesomePythonLibrary('polars', 'https://github.com/pola-rs/polars', 'Rust实现的快速DataFrame', ['极速', '惰性执行', '流式'], '大规模数据高效处理'),
        AwesomePythonLibrary('ibis', 'https://github.com/ibis-project/ibis', '便携式DataFrame库，20+后端', ['多后端', '统一API', 'SQL'], '跨平台统一数据分析'),
        AwesomePythonLibrary('datasette', 'https://github.com/simonw/datasette', '数据探索和发布多工具', ['SQLite', 'Web界面', 'API'], '数据发布和探索'),
        AwesomePythonLibrary('modin', 'https://github.com/modin-project/modin', 'pandas即插即用替代', ['分布式', '兼容Pandas', 'Ray'], '大数据集加速'),
        AwesomePythonLibrary('openbb', 'https://github.com/OpenBB-finance/OpenBB', '金融数据平台', ['金融数据', '分析工具', 'AI集成'], '金融分析投资研究'),
        AwesomePythonLibrary('yfinance', 'https://github.com/ranaroussi/yfinance', 'Yahoo Finance数据下载', ['股票数据', '历史行情', '分红'], '获取金融市场数据'),
        AwesomePythonLibrary('pathway', 'https://github.com/pathwaycom/pathway', '实时数据处理框架', ['实时处理', '增量更新', '流式'], '实时数据管道'),
      ]),
      AwesomePythonSubCategory('数据验证', [
        AwesomePythonLibrary('pydantic', 'https://github.com/pydantic/pydantic', '基于类型提示的数据验证', ['类型验证', 'JSON Schema', '序列化'], 'API数据模型验证'),
        AwesomePythonLibrary('pandera', 'https://github.com/unionai-oss/pandera', 'DataFrame数据验证', ['Schema', '类型检查', '多后端'], '数据管道质量保证'),
        AwesomePythonLibrary('jsonschema', 'https://github.com/python-jsonschema/jsonschema', 'JSON Schema验证实现', ['JSON Schema', '验证', '格式'], 'JSON数据格式验证'),
        AwesomePythonLibrary('cerberus', 'https://github.com/pyeve/cerberus', '轻量可扩展数据验证', ['Schema', '规则', '嵌套'], '配置表单数据验证'),
        AwesomePythonLibrary('voluptuous', 'https://github.com/alecthomas/voluptuous', '不可信数据源验证库', ['Schema', '验证', '转换'], '用户输入验证'),
      ]),
      AwesomePythonSubCategory('数据可视化', [
        AwesomePythonLibrary('matplotlib', 'https://github.com/matplotlib/matplotlib', 'Python 2D绘图基础库', ['2D绘图', '多后端', '自定义'], '科学出版图表'),
        AwesomePythonLibrary('plotly', 'https://github.com/plotly/plotly.py', '交互式图形库', ['交互式', '3D', 'Dash'], '交互式仪表板'),
        AwesomePythonLibrary('seaborn', 'https://github.com/mwaskom/seaborn', '基于Matplotlib的统计可视化', ['统计图', '调色板', '分布图'], '统计分析和探索'),
        AwesomePythonLibrary('altair', 'https://github.com/altair-viz/altair', '声明式统计可视化', ['声明式', 'Vega-Lite', '交互'], '快速优雅图表'),
        AwesomePythonLibrary('bokeh', 'https://github.com/bokeh/bokeh', '交互式Web绘图库', ['Web原生', '交互', '大数据'], 'Web交互可视化'),
        AwesomePythonLibrary('streamlit', 'https://github.com/streamlit/streamlit', '快速构建数据应用', ['极速开发', '组件', '缓存'], '数据科学应用'),
        AwesomePythonLibrary('gradio', 'https://github.com/gradio-app/gradio', '构建和分享ML应用界面', ['ML集成', 'HuggingFace', '分享'], 'ML模型演示'),
        AwesomePythonLibrary('plotnine', 'https://github.com/has2k1/plotnine', '基于ggplot2的图形语法', ['图形语法', '图层', '统计'], 'R用户迁移、统计图'),
      ]),
      AwesomePythonSubCategory('地理信息', [
        AwesomePythonLibrary('geopandas', 'https://github.com/geopandas/geopandas', '地理数据处理库，扩展pandas', ['GeoDataFrame', '空间操作', '投影'], '地理数据分析'),
        AwesomePythonLibrary('geopy', 'https://github.com/geopy/geopy', 'Python地理编码工具箱', ['地理编码', '逆编码', '多服务'], '地址坐标服务'),
        AwesomePythonLibrary('geodjango', 'https://github.com/django/django', 'Django地理Web框架', ['空间字段', '空间查询', 'GDAL'], 'Django地理信息应用'),
        AwesomePythonLibrary('geojson', 'https://github.com/jazzband/geojson', 'GeoJSON格式Python工具', ['GeoJSON', '几何', '特征'], 'GeoJSON数据处理'),
      ]),
      AwesomePythonSubCategory('科学计算', [
        AwesomePythonLibrary('numpy', 'https://github.com/numpy/numpy', '科学计算基础包', ['ndarray', '广播', '线性代数'], '数值计算基础'),
        AwesomePythonLibrary('scipy', 'https://github.com/scipy/scipy', '科学计算生态系统核心', ['优化', '积分', '信号处理'], '工程科学计算'),
        AwesomePythonLibrary('sympy', 'https://github.com/sympy/sympy', '符号数学库', ['符号计算', '方程求解', 'LaTeX'], '数学推导公式计算'),
        AwesomePythonLibrary('numba', 'https://github.com/numba/numba', 'Python JIT编译器', ['JIT', 'LLVM', 'CUDA'], '数值代码加速'),
        AwesomePythonLibrary('statsmodels', 'https://github.com/statsmodels/statsmodels', '统计建模和计量经济学', ['回归', '时间序列', 'GLM'], '统计推断计量分析'),
        AwesomePythonLibrary('networkx', 'https://github.com/networkx/networkx', '复杂网络分析库', ['图算法', '可视化', '网络度量'], '社交网络分析'),
        AwesomePythonLibrary('manim', 'https://github.com/3b1b/manim', '数学动画引擎(3Blue1Brown)', ['精确动画', 'LaTeX', '3D'], '数学科学教学视频'),
        AwesomePythonLibrary('biopython', 'https://github.com/biopython/biopython', '生物信息学工具集', ['序列分析', 'BLAST', '结构'], '生物数据处理'),
        AwesomePythonLibrary('rdkit', 'https://github.com/rdkit/rdkit', '化学信息学和ML软件', ['分子描述符', '指纹', '可视化'], '药物发现分子分析'),
        AwesomePythonLibrary('astropy', 'https://github.com/astropy/astropy', '天文学社区Python库', ['天体坐标', 'FITS', '宇宙学'], '天文数据处理'),
        AwesomePythonLibrary('pymc', 'https://github.com/pymc-devs/pymc', '概率编程和贝叶斯建模', ['贝叶斯', 'MCMC', '变分推断'], '贝叶斯统计建模'),
        AwesomePythonLibrary('simpy', 'https://github.com/simpy/simpy', '离散事件仿真框架', ['进程', '资源', '事件'], '排队系统流程仿真'),
        AwesomePythonLibrary('mesa', 'https://github.com/projectmesa/mesa', '基于Agent的建模框架', ['Agent', '空间', '可视化'], '复杂系统社会仿真'),
        AwesomePythonLibrary('shapely', 'https://github.com/shapely/shapely', '几何对象操作和分析', ['几何', '空间关系', '集合操作'], '空间数据几何计算'),
      ]),
      AwesomePythonSubCategory('量子计算', [
        AwesomePythonLibrary('qiskit', 'https://github.com/Qiskit/qiskit', 'IBM量子计算SDK', ['量子电路', '模拟器', '实机执行'], '量子硬件编程'),
        AwesomePythonLibrary('pennylane', 'https://github.com/PennyLaneAI/pennylane', '混合量子-经典ML库', ['自动微分', '量子ML', '混合'], '量子机器学习和优化'),
        AwesomePythonLibrary('cirq', 'https://github.com/quantumlib/Cirq', 'Google量子计算框架', ['量子电路', '噪声模型', 'NISQ'], 'NISQ量子算法设计'),
        AwesomePythonLibrary('qutip', 'https://github.com/qutip/qutip', 'Python量子工具箱', ['量子动力学', '稳态', '可视化'], '量子光学和开放系统'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '开发者工具',
    Icons.build,
    Color(0xFF37474F),
    '代码分析、测试、调试、构建工具、文档生成等开发者工具',
    [
      AwesomePythonSubCategory('算法与设计模式', [
        AwesomePythonLibrary('thealgorithms', 'https://github.com/TheAlgorithms/Python', '所有算法的Python实现', ['算法实现', '教学', '分类清晰'], '学习算法数据结构'),
        AwesomePythonLibrary('sortedcontainers', 'https://github.com/grantjenks/python-sortedcontainers', '快速纯Python排序集合', ['SortedList', 'SortedDict', 'SortedSet'], '高效排序数据结构'),
        AwesomePythonLibrary('python-patterns', 'https://github.com/faif/python-patterns', 'Python设计模式集合', ['创建型', '结构型', '行为型'], '学习设计模式'),
        AwesomePythonLibrary('transitions', 'https://github.com/pytransitions/transitions', '轻量面向对象状态机', ['状态机', '转换', '可视化'], '工作流引擎状态管理'),
      ]),
      AwesomePythonSubCategory('交互式解释器', [
        AwesomePythonLibrary('jupyter', 'https://github.com/jupyter/notebook', '交互式Python工具集', ['Notebook', 'Lab', 'Widget'], '数据探索教学原型'),
        AwesomePythonLibrary('marimo', 'https://github.com/marimo-team/marimo', 'Git友好的Python笔记本', ['Git友好', '响应式', '可复现'], '可版本控制交互开发'),
        AwesomePythonLibrary('ptpython', 'https://github.com/prompt-toolkit/ptpython', '高级Python REPL', ['语法高亮', '自动补全', '历史'], '增强Python交互体验'),
      ]),
      AwesomePythonSubCategory('代码分析', [
        AwesomePythonLibrary('ruff', 'https://github.com/astral-sh/ruff', '极速Python Linter和格式化', ['极速', 'Linter', '格式化'], 'Python代码质量'),
        AwesomePythonLibrary('black', 'https://github.com/psf/black', '不妥协的代码格式化工具', ['确定性', 'AST', '一致性'], '统一团队代码风格'),
        AwesomePythonLibrary('mypy', 'https://github.com/python/mypy', '静态类型检查器', ['类型检查', '渐进式', 'Stub'], '代码类型安全性'),
        AwesomePythonLibrary('pylint', 'https://github.com/pylint-dev/pylint', '完全可定制源代码分析器', ['代码分析', '错误检测', '评分'], '全面代码质量检查'),
        AwesomePythonLibrary('flake8', 'https://github.com/PyCQA/flake8', 'Python代码质量检查包装器', ['PEP8', 'pyflakes', 'mccabe'], '基础代码规范检查'),
        AwesomePythonLibrary('bandit', 'https://github.com/PyCQA/bandit', 'Python安全静态分析工具', ['安全扫描', '常见漏洞', 'AST'], '代码安全审计'),
        AwesomePythonLibrary('isort', 'https://github.com/PyCQA/isort', 'import排序工具', ['自动排序', '分组', '多行'], 'import语句组织'),
        AwesomePythonLibrary('vulture', 'https://github.com/jendrikseipp/vulture', '死代码查找和分析', ['死代码', '未使用', '检测'], '清理无用代码'),
        AwesomePythonLibrary('prospector', 'https://github.com/PyCQA/prospector', 'Python代码分析综合工具', ['多工具', '统一输出', '配置'], '全面代码质量分析'),
      ]),
      AwesomePythonSubCategory('测试', [
        AwesomePythonLibrary('pytest', 'https://github.com/pytest-dev/pytest', '成熟全功能Python测试框架', ['Fixture', '参数化', '插件'], 'Python测试首选'),
        AwesomePythonLibrary('hypothesis', 'https://github.com/HypothesisWorks/hypothesis', '属性基于测试库', ['生成测试', '缩小', '统计'], '边界情况自动发现'),
        AwesomePythonLibrary('unittest', 'https://docs.python.org/3/library/unittest.html', '标准库单元测试框架', ['TestCase', '断言', 'Mock'], '内置测试框架'),
        AwesomePythonLibrary('locust', 'https://github.com/locustio/locust', '可扩展用户负载测试', ['分布式', 'Web UI', '实时统计'], 'Web应用性能测试'),
        AwesomePythonLibrary('playwright-python', 'https://github.com/microsoft/playwright-python', 'Microsoft浏览器自动化测试', ['多浏览器', '自动等待', '拦截'], '端到端Web应用测试'),
        AwesomePythonLibrary('selenium', 'https://github.com/SeleniumHQ/selenium', '浏览器自动化测试标准', ['多浏览器', 'WebDriver', 'Grid'], 'Web应用功能测试'),
        AwesomePythonLibrary('coverage', 'https://github.com/nedbat/coveragepy', '代码覆盖率测量', ['行覆盖', '分支覆盖', '报告'], '测试覆盖率分析'),
        AwesomePythonLibrary('faker', 'https://github.com/joke2k/faker', '伪数据生成器', ['姓名', '地址', '多语言'], '测试数据生成'),
        AwesomePythonLibrary('factory_boy', 'https://github.com/FactoryBoy/factory_boy', '测试Fixture替代方案', ['工厂模式', 'ORM集成', '序列'], '测试对象创建'),
        AwesomePythonLibrary('responses', 'https://github.com/getsentry/responses', 'requests库Mock工具', ['HTTP Mock', 'URL匹配', '回调'], 'HTTP请求单元测试'),
        AwesomePythonLibrary('vcrpy', 'https://github.com/kevin1024/vcrpy', 'HTTP交互录制和回放', ['录制', '回放', 'Cassette'], '减少外部HTTP依赖'),
        AwesomePythonLibrary('tox', 'https://github.com/tox-dev/tox', '多Python版本自动化测试', ['多版本', '虚拟环境', '矩阵'], '跨版本兼容性测试'),
        AwesomePythonLibrary('nox', 'https://github.com/wntrblm/nox', '灵活测试自动化', ['会话', '参数化', '并行'], '复杂测试工作流'),
      ]),
      AwesomePythonSubCategory('调试工具', [
        AwesomePythonLibrary('icecream', 'https://github.com/gruns/icecream', '一个函数调用检查变量', ['简洁语法', '上下文', '多行'], '快速调试检查'),
        AwesomePythonLibrary('py-spy', 'https://github.com/benfred/py-spy', 'Python采样分析器(Rust)', ['采样', '火焰图', '实时'], '生产环境性能分析'),
        AwesomePythonLibrary('scalene', 'https://github.com/plasma-umass/scalene', 'CPU/GPU/内存分析器', ['CPU', 'GPU', '内存'], '全面性能分析'),
        AwesomePythonLibrary('pudb', 'https://github.com/inducer/pudb', '全屏控制台调试器', ['全屏', '可视化', '断点'], '终端可视化调试'),
        AwesomePythonLibrary('django-debug-toolbar', 'https://github.com/django-commons/django-debug-toolbar', 'Django调试信息面板', ['请求', 'SQL', '缓存'], 'Django开发调试'),
      ]),
      AwesomePythonSubCategory('构建工具', [
        AwesomePythonLibrary('invoke', 'https://github.com/pyinvoke/invoke', 'Shell子进程管理和任务组织', ['任务', 'Shell', '装饰器'], '自动化任务部署'),
        AwesomePythonLibrary('doit', 'https://github.com/pydoit/doit', '任务运行器和构建工具', ['任务依赖', '增量', '并行'], '数据处理管道构建'),
        AwesomePythonLibrary('pybuilder', 'https://github.com/pybuilder/pybuilder', '纯Python持续构建工具', ['生命周期', '插件', '测试'], 'Python项目构建'),
        AwesomePythonLibrary('scons', 'https://github.com/SCons/scons', '软件构建工具', ['依赖分析', '多语言', '配置'], 'C/C++项目构建'),
      ]),
      AwesomePythonSubCategory('文档', [
        AwesomePythonLibrary('sphinx', 'https://github.com/sphinx-doc/sphinx', 'Python文档生成器', ['reST', '自动生成', '扩展'], '项目文档和API文档'),
        AwesomePythonLibrary('mkdocs', 'https://github.com/mkdocs/mkdocs', 'Markdown友好文档生成器', ['Markdown', '主题', '部署'], '项目文档站点生成'),
        AwesomePythonLibrary('diagrams', 'https://github.com/mingrammer/diagrams', '代码即图表', ['云架构', '编程式', '多提供商'], '系统架构图设计'),
        AwesomePythonLibrary('pdoc', 'https://github.com/mitmproxy/pdoc', '自动API文档生成', ['自动生成', '类型注解', '美观'], 'Python库API文档'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    'DevOps',
    Icons.dns,
    Color(0xFF0277BD),
    'DevOps工具、分布式计算、任务队列、消息系统、调度和日志',
    [
      AwesomePythonSubCategory('DevOps 工具', [
        AwesomePythonLibrary('ansible', 'https://github.com/ansible/ansible', '极简IT自动化平台', ['无代理', 'YAML', '幂等'], '配置管理应用部署'),
        AwesomePythonLibrary('boto3', 'https://github.com/boto/boto3', 'AWS Python SDK', ['全部AWS服务', '资源API', '等待器'], 'AWS云服务自动化'),
        AwesomePythonLibrary('fabric', 'https://github.com/fabric/fabric', '远程执行和部署工具', ['SSH', '任务', '并行'], '远程服务器管理'),
        AwesomePythonLibrary('sentry-python', 'https://github.com/getsentry/sentry-python', 'Sentry错误追踪SDK', ['错误追踪', '性能', '上下文'], '应用错误监控'),
        AwesomePythonLibrary('psutil', 'https://github.com/giampaolo/psutil', '跨平台进程和系统工具', ['CPU', '内存', '磁盘'], '系统监控诊断'),
        AwesomePythonLibrary('supervisor', 'https://github.com/Supervisor/supervisor', 'UNIX进程控制系统', ['进程管理', '自动重启', 'Web'], '服务进程管理'),
        AwesomePythonLibrary('sh', 'https://github.com/amoffat/sh', '完整子进程替代方案', ['管道', '重定向', '超时'], 'Shell命令集成'),
        AwesomePythonLibrary('borg', 'https://github.com/borgbackup/borg', '去重归档备份工具', ['去重', '压缩', '加密'], '安全高效备份'),
        AwesomePythonLibrary('pre-commit', 'https://github.com/pre-commit/pre-commit', '多语言pre-commit钩子', ['Git钩子', '多语言', 'CI'], '代码提交前检查'),
      ]),
      AwesomePythonSubCategory('分布式计算', [
        AwesomePythonLibrary('dask', 'https://github.com/dask/dask', '灵活并行计算库', ['DataFrame', '延迟', '分布式'], '大数据集并行处理'),
        AwesomePythonLibrary('ray', 'https://github.com/ray-project/ray', '统一ML生态分布式系统', ['分布式', 'ML', '服务'], '分布式ML训练推理'),
        AwesomePythonLibrary('pyspark', 'https://github.com/apache/spark', 'Apache Spark Python API', ['RDD', 'DataFrame', 'MLlib'], '大规模数据处理'),
        AwesomePythonLibrary('luigi', 'https://github.com/spotify/luigi', 'Spotify批处理管道框架', ['管道', '依赖', 'Hadoop'], 'ETL批处理工作流'),
        AwesomePythonLibrary('joblib', 'https://github.com/joblib/joblib', '轻量管道和并行工具', ['缓存', '并行', '序列化'], 'scikit-learn计算加速'),
      ]),
      AwesomePythonSubCategory('任务队列', [
        AwesomePythonLibrary('celery', 'https://github.com/celery/celery', '分布式异步任务队列', ['分布式', '任务调度', '监控'], '后台任务定时任务'),
        AwesomePythonLibrary('rq', 'https://github.com/rq/rq', '简单Redis任务队列', ['Redis', '简单', '监控'], '轻量异步任务'),
        AwesomePythonLibrary('dramatiq', 'https://github.com/Bogdanp/dramatiq', '快速可靠后台任务处理', ['可靠', '中间件', '速率限制'], '生产级异步任务'),
        AwesomePythonLibrary('huey', 'https://github.com/coleifer/huey', '轻量多线程任务队列', ['轻量', '多线程', '调度'], '小型项目异步任务'),
      ]),
      AwesomePythonSubCategory('消息系统', [
        AwesomePythonLibrary('faststream', 'https://github.com/airtai/faststream', '异步消息服务框架', ['Kafka', 'RabbitMQ', 'NATS'], '事件驱动微服务'),
      ]),
      AwesomePythonSubCategory('任务调度', [
        AwesomePythonLibrary('airflow', 'https://github.com/apache/airflow', '编程式工作流编排平台', ['DAG', '调度', '传感器'], '数据管道ETL调度'),
        AwesomePythonLibrary('prefect', 'https://github.com/PrefectHQ/prefect', '数据管道编排框架', ['现代API', '重试', '缓存'], '数据工作流编排'),
        AwesomePythonLibrary('dagster', 'https://github.com/dagster-io/dagster', '数据资产开发观察平台', ['数据资产', '类型系统', '测试'], '数据管道开发运维'),
        AwesomePythonLibrary('apscheduler', 'https://github.com/agronholm/apscheduler', '轻量进程内任务调度', ['Cron', '间隔', '持久化'], '应用内定时任务'),
        AwesomePythonLibrary('schedule', 'https://github.com/dbader/schedule', '人性化Python任务调度', ['简洁API', '定时', '装饰器'], '简单定时任务'),
      ]),
      AwesomePythonSubCategory('日志', [
        AwesomePythonLibrary('loguru', 'https://github.com/Delgan/loguru', '愉快的Python日志库', ['简单API', '旋转', '彩色'], '替代标准库logging'),
        AwesomePythonLibrary('structlog', 'https://github.com/hynek/structlog', '结构化日志库', ['结构化', '键值对', '渲染'], '日志分析处理'),
        AwesomePythonLibrary('logging', 'https://docs.python.org/3/library/logging.html', '标准库日志工具', ['Handler', 'Formatter', 'Filter'], '标准日志记录'),
      ]),
      AwesomePythonSubCategory('网络虚拟化', [
        AwesomePythonLibrary('scapy', 'https://github.com/secdev/scapy', '强大数据包操作库', ['数据包', '嗅探', '构造'], '网络分析渗透测试'),
        AwesomePythonLibrary('mininet', 'https://github.com/mininet/mininet', '网络模拟器和API', ['网络拓扑', 'SDN', '虚拟化'], '网络研究教学'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    'CLI & GUI',
    Icons.terminal,
    Color(0xFF4E342E),
    '命令行界面、终端工具、桌面和Web GUI开发',
    [
      AwesomePythonSubCategory('CLI 开发', [
        AwesomePythonLibrary('click', 'https://github.com/pallets/click', '可组合命令行界面创建', ['装饰器', '组合', '彩色'], 'CLI工具命令开发'),
        AwesomePythonLibrary('typer', 'https://github.com/fastapi/typer', '基于类型提示的现代CLI框架', ['类型提示', '自动帮助', 'Shell补全'], '现代CLI应用开发'),
        AwesomePythonLibrary('python-fire', 'https://github.com/google/python-fire', '任意对象转CLI工具', ['零代码', '自动绑定', '嵌套'], '快速对象转CLI'),
        AwesomePythonLibrary('rich', 'https://github.com/Textualize/rich', '终端富文本和美观格式化', ['表格', '进度条', 'Markdown'], '终端输出美化'),
        AwesomePythonLibrary('textual', 'https://github.com/Textualize/textual', '终端和浏览器交互UI框架', ['组件', 'CSS布局', '异步'], '终端TUI仪表板'),
        AwesomePythonLibrary('tqdm', 'https://github.com/tqdm/tqdm', '快速可扩展进度条', ['进度条', '嵌套', '速度'], '循环处理进度显示'),
        AwesomePythonLibrary('colorama', 'https://github.com/tartley/colorama', '跨平台终端彩色输出', ['彩色', '跨平台', 'ANSI'], '终端彩色文本'),
        AwesomePythonLibrary('argparse', 'https://docs.python.org/3/library/argparse.html', '标准库命令行解析', ['位置参数', '选项', '子命令'], '内置CLI参数解析'),
      ]),
      AwesomePythonSubCategory('CLI 工具', [
        AwesomePythonLibrary('httpie', 'https://github.com/httpie/cli', '人性化cURL替代品', ['JSON', '彩色', '插件'], 'API调试HTTP测试'),
        AwesomePythonLibrary('cookiecutter', 'https://github.com/cookiecutter/cookiecutter', '项目模板生成工具', ['模板', '交互', '多语言'], '快速创建项目骨架'),
        AwesomePythonLibrary('thefuck', 'https://github.com/nvbn/thefuck', '纠正上条错误命令', ['自动纠正', '规则', '交互'], '命令行错误修复'),
        AwesomePythonLibrary('yt-dlp', 'https://github.com/yt-dlp/yt-dlp', 'YouTube视频下载工具', ['多站点', '格式选择', '字幕'], '视频下载'),
        AwesomePythonLibrary('pgcli', 'https://github.com/dbcli/pgcli', '智能PostgreSQL CLI', ['自动补全', '语法高亮', '历史'], 'PostgreSQL交互查询'),
        AwesomePythonLibrary('mycli', 'https://github.com/dbcli/mycli', '智能MySQL CLI', ['自动补全', '语法高亮', '提示'], 'MySQL交互查询'),
        AwesomePythonLibrary('xonsh', 'https://github.com/xonsh/xonsh', 'Python驱动的Shell', ['Python+Shell', '跨平台', '管道'], '高级Shell脚本'),
      ]),
      AwesomePythonSubCategory('GUI 开发 — 桌面', [
        AwesomePythonLibrary('kivy', 'https://github.com/kivy/kivy', '跨平台NUI应用框架', ['多点触控', '跨平台', 'GPU'], '移动和桌面应用'),
        AwesomePythonLibrary('tkinter', 'https://docs.python.org/3/library/tkinter.html', '标准库GUI工具包', ['内置', '跨平台', 'Canvas'], '简单桌面GUI'),
        AwesomePythonLibrary('PyQt', 'https://riverbankcomputing.com/software/pyqt/', 'Qt框架Python绑定', ['完整Qt', '信号槽', 'Designer'], '专业桌面应用'),
        AwesomePythonLibrary('pyside', 'https://github.com/qtproject/pyside-pyside-setup', 'Qt官方Python绑定', ['官方', 'LGPL', '完整Qt'], 'LGPL许可Qt应用'),
        AwesomePythonLibrary('wxPython', 'https://github.com/wxWidgets/Phoenix', 'wxWidgets的Python绑定', ['原生控件', '跨平台', '布局'], '原生外观桌面应用'),
        AwesomePythonLibrary('dearpygui', 'https://github.com/hoffstadt/DearPyGui', 'GPU加速Python GUI框架', ['GPU', '快速', '现代'], '实时数据可视化'),
        AwesomePythonLibrary('customtkinter', 'https://github.com/TomSchimansky/CustomTkinter', '现代化Tkinter增强库', ['现代UI', '主题', '暗色模式'], 'Tkinter应用现代化'),
      ]),
      AwesomePythonSubCategory('GUI 开发 — Web/终端', [
        AwesomePythonLibrary('flet', 'https://github.com/flet-dev/flet', '纯Python跨平台GUI', ['Flutter', '跨平台', 'Material'], 'Python构建Flutter应用'),
        AwesomePythonLibrary('nicegui', 'https://github.com/zauberzeug/nicegui', '浏览器Python UI框架', ['Web', '组件', '简单'], 'Web仪表板和工具'),
        AwesomePythonLibrary('urwid', 'https://github.com/urwid/urwid', '终端UI应用库', ['Widget', '事件', '布局'], '终端TUI应用'),
        AwesomePythonLibrary('gooey', 'https://github.com/chriskiehl/Gooey', '一行代码CLI转GUI', ['自动生成', '装饰器', '跨平台'], '命令行工具加GUI'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '文本 & 文档',
    Icons.article,
    Color(0xFF5D4037),
    '文本处理、HTML操作、文件格式处理和文件操作',
    [
      AwesomePythonSubCategory('文本处理', [
        AwesomePythonLibrary('chardet', 'https://github.com/chardet/chardet', '字符编码检测器', ['编码检测', '多语言', '高准确率'], '自动识别文件编码'),
        AwesomePythonLibrary('ftfy', 'https://github.com/rspeer/python-ftfy', '修复Unicode文本问题', ['自动修复', 'Unicode', 'Mojibake'], '乱码文本自动修复'),
        AwesomePythonLibrary('pygments', 'https://github.com/pygments/pygments', '通用语法高亮工具', ['500+语言', '主题', '过滤器'], '代码高亮彩色输出'),
        AwesomePythonLibrary('pyparsing', 'https://github.com/pyparsing/pyparsing', '通用解析器生成框架', ['PEG', '组合', '无正则'], '自定义DSL语言解析'),
        AwesomePythonLibrary('python-phonenumbers', 'https://github.com/daviddrysdale/python-phonenumbers', '国际电话号码处理', ['解析', '验证', '地理'], '电话号码验证处理'),
        AwesomePythonLibrary('babel', 'https://github.com/python-babel/babel', 'Python国际化库', ['翻译', '格式化', '时区'], '应用国际化本地化'),
        AwesomePythonLibrary('unidecode', 'https://github.com/avian2/unidecode', 'Unicode文本ASCII音译', ['音译', '多语言', 'ASCII'], 'URL生成ASCII转换'),
        AwesomePythonLibrary('textdistance', 'https://github.com/life4/textdistance', '序列距离计算30+算法', ['编辑距离', '相似度', '模糊匹配'], '文本相似度计算'),
        AwesomePythonLibrary('python-slugify', 'https://github.com/un33k/python-slugify', 'Unicode转ASCII slug', ['Slug', 'URL友好', '多语言'], 'URL文件名生成'),
        AwesomePythonLibrary('shortuuid', 'https://github.com/skorokithakis/shortuuid', '简洁URL安全UUID', ['短ID', 'URL安全', '去歧义'], '资源标识符生成'),
        AwesomePythonLibrary('sqids', 'https://github.com/sqids/sqids-python', '数字转短唯一ID', ['短ID', '可逆', '无脏话'], '用户可见短ID'),
      ]),
      AwesomePythonSubCategory('HTML 操作', [
        AwesomePythonLibrary('beautifulsoup', 'https://code.launchpad.net/beautifulsoup', 'Pythonic HTML/XML解析', ['遍历', '搜索', '修改'], '网页解析数据提取'),
        AwesomePythonLibrary('lxml', 'https://github.com/lxml/lxml', '快速HTML/XML处理库', ['极速', 'XPath', 'XSLT'], '高性能XML/HTML'),
        AwesomePythonLibrary('pyquery', 'https://github.com/gawel/pyquery', 'jQuery风格HTML解析', ['CSS选择器', '操作', 'Ajax'], '类jQuery HTML操作'),
        AwesomePythonLibrary('xmltodict', 'https://github.com/martinblech/xmltodict', 'XML与字典互转', ['双向转换', '属性', '命名空间'], 'XML和dict轻松转换'),
        AwesomePythonLibrary('markupsafe', 'https://github.com/pallets/markupsafe', 'XML/HTML安全字符串', ['转义', '安全', '高效'], '模板XSS防护'),
      ]),
      AwesomePythonSubCategory('文件格式处理', [
        AwesomePythonLibrary('openpyxl', 'https://foss.heptapod.net/openpyxl/openpyxl', 'Excel 2010+文件读写', ['xlsx', '公式', '图表'], 'Excel文件自动化'),
        AwesomePythonLibrary('python-docx', 'https://github.com/python-openxml/python-docx', 'Word文档读写操作', ['docx', '段落', '表格'], 'Word文档自动生成'),
        AwesomePythonLibrary('python-pptx', 'https://github.com/scanny/python-pptx', 'PowerPoint文件创建更新', ['pptx', '幻灯片', '形状'], 'PPT自动生成'),
        AwesomePythonLibrary('xlsxwriter', 'https://github.com/jmcnamara/XlsxWriter', 'Excel文件创建(写入)', ['xlsx', '图表', '公式'], '高性能Excel导出'),
        AwesomePythonLibrary('reportlab', 'https://bitbucket.org/rptlab/reportlab', '快速创建富PDF文档', ['PDF', '绘图', '条形码'], 'PDF报告生成'),
        AwesomePythonLibrary('pypdf', 'https://github.com/py-pdf/pypdf', 'PDF页面操作库', ['合并', '分割', '裁剪'], 'PDF文件操作处理'),
        AwesomePythonLibrary('weasyprint', 'https://github.com/Kozea/WeasyPrint', 'HTML/CSS渲染转PDF', ['HTML+CSS', '分页', '字体'], 'HTML报告转PDF'),
        AwesomePythonLibrary('tablib', 'https://github.com/jazzband/tablib', '表格数据集多格式处理', ['JSON', 'CSV', 'XLS'], '多格式数据导入导出'),
        AwesomePythonLibrary('csvkit', 'https://github.com/wireservice/csvkit', 'CSV转换和处理工具', ['CSV', '转换', '统计'], 'CSV数据处理转换'),
        AwesomePythonLibrary('markdown', 'https://github.com/Python-Markdown/markdown', 'Markdown的Python实现', ['Markdown', '扩展', 'HTML'], 'Markdown转HTML'),
        AwesomePythonLibrary('pyyaml', 'https://github.com/yaml/pyyaml', 'YAML解析和生成', ['YAML', '序列化', '配置'], '配置文件数据交换'),
        AwesomePythonLibrary('mistune', 'https://github.com/lepture/mistune', '最快纯Python Markdown解析', ['极速', '安全', '插件'], '高性能Markdown渲染'),
      ]),
      AwesomePythonSubCategory('文件操作', [
        AwesomePythonLibrary('pathlib', 'https://docs.python.org/3/library/pathlib.html', '标准库面向对象路径库', ['面向对象', '跨平台', '通配符'], '现代化文件路径操作'),
        AwesomePythonLibrary('watchdog', 'https://github.com/gorakhargosh/watchdog', '文件系统事件监控', ['监控', '事件', '递归'], '文件变化触发操作'),
        AwesomePythonLibrary('watchfiles', 'https://github.com/samuelcolvin/watchfiles', '简单现代快速文件监控', ['现代', '快速', 'asyncio'], '代码热重载文件监控'),
        AwesomePythonLibrary('python-magic', 'https://github.com/ahupp/python-magic', 'libmagic文件类型检测', ['文件类型', 'MIME', '魔术字节'], '文件类型自动识别'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '媒体处理',
    Icons.music_video,
    Color(0xFF880E4F),
    '图像处理、音视频处理、游戏开发等媒体相关库',
    [
      AwesomePythonSubCategory('图像处理', [
        AwesomePythonLibrary('pillow', 'https://github.com/python-pillow/Pillow', 'Python图像处理标准库(PIL)', ['格式转换', '滤镜', '缩略图'], '基础图像处理'),
        AwesomePythonLibrary('scikit-image', 'https://github.com/scikit-image/scikit-image', '科学图像处理库', ['分割', '变换', '滤波'], '科学医学图像分析'),
        AwesomePythonLibrary('thumbor', 'https://github.com/thumbor/thumbor', '智能图像处理服务', ['裁剪', '缩放', '水印'], '按需图像处理CDN'),
        AwesomePythonLibrary('python-qrcode', 'https://github.com/lincolnloop/python-qrcode', '纯Python二维码生成器', ['QR码', 'SVG', 'PNG'], '二维码生成'),
        AwesomePythonLibrary('pyvips', 'https://github.com/libvips/pyvips', '快速图像处理低内存', ['极速', '流式', '大图'], '大图处理批量转换'),
        AwesomePythonLibrary('wand', 'https://github.com/emcconville/wand', 'ImageMagick Python绑定', ['ImageMagick', '合成', '特效'], '高级图像处理'),
      ]),
      AwesomePythonSubCategory('音频与视频', [
        AwesomePythonLibrary('moviepy', 'https://github.com/Zulko/moviepy', '脚本化视频编辑库', ['剪辑', '合成', 'GIF'], '自动化视频编辑'),
        AwesomePythonLibrary('librosa', 'https://github.com/librosa/librosa', '音频和音乐分析库', ['频谱', '节拍', '音高'], '音乐信息检索'),
        AwesomePythonLibrary('pydub', 'https://github.com/jiaaro/pydub', '简单高级音频处理', ['格式转换', '切片', '淡入淡出'], '音频编辑转换'),
        AwesomePythonLibrary('gtts', 'https://github.com/pndurette/gTTS', 'Google TTS文本转语音', ['TTS', '多语言', 'MP3'], '文本朗读语音生成'),
        AwesomePythonLibrary('beets', 'https://github.com/beetbox/beets', '音乐库管理元数据标记', ['音乐库', '标签', 'MusicBrainz'], '音乐收藏管理'),
        AwesomePythonLibrary('mutagen', 'https://github.com/quodlibet/mutagen', '音频元数据处理', ['ID3', 'MP4', 'FLAC'], '音频文件标签'),
        AwesomePythonLibrary('vidgear', 'https://github.com/abhiTronix/vidgear', '多线程视频处理框架', ['多线程', '实时', '流媒体'], '高性能视频管道'),
      ]),
      AwesomePythonSubCategory('游戏开发', [
        AwesomePythonLibrary('pygame', 'https://github.com/pygame/pygame', 'Python游戏开发模块集', ['2D', '精灵', '碰撞'], '2D游戏开发学习'),
        AwesomePythonLibrary('arcade', 'https://github.com/pythonarcade/arcade', '现代Python游戏框架', ['现代OpenGL', '粒子', '物理'], '教学和现代2D游戏'),
        AwesomePythonLibrary('panda3d', 'https://github.com/panda3d/panda3d', 'Disney的3D游戏引擎', ['3D', '场景图', '着色器'], '3D游戏和仿真'),
        AwesomePythonLibrary('renpy', 'https://github.com/renpy/renpy', '视觉小说引擎', ['视觉小说', '对话', '存档'], '视觉小说叙事游戏'),
        AwesomePythonLibrary('pyglet', 'https://github.com/pyglet/pyglet', '跨平台窗口多媒体库', ['窗口', 'OpenGL', '音频'], '多媒体简单游戏'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    'Python 语言',
    Icons.language,
    Color(0xFF1565C0),
    'Python实现、内置类增强、函数式编程、异步编程和日期时间',
    [
      AwesomePythonSubCategory('Python 实现', [
        AwesomePythonLibrary('cpython', 'https://github.com/python/cpython', 'Python标准实现，C语言', ['参考实现', 'C扩展', 'GIL'], '标准Python开发'),
        AwesomePythonLibrary('pypy', 'https://github.com/pypy/pypy', '快速JIT Python实现', ['JIT', '快速', '兼容'], '性能敏感Python应用'),
        AwesomePythonLibrary('cython', 'https://github.com/cython/cython', 'Python到C优化编译器', ['C扩展', '类型注解', '性能'], 'Python代码编译为C'),
        AwesomePythonLibrary('micropython', 'https://github.com/micropython/micropython', '精简高效微控制器Python', ['嵌入式', '轻量', 'REPL'], '微控制器IoT开发'),
        AwesomePythonLibrary('pyodide', 'https://github.com/pyodide/pyodide', 'WebAssembly浏览器Python', ['浏览器', 'WebAssembly', 'NumPy'], '浏览器端Python'),
        AwesomePythonLibrary('ironpython', 'https://github.com/IronLanguages/ironpython3', 'C#实现的Python', ['.NET', 'C#互操作', 'CLR'], '.NET生态系统Python'),
      ]),
      AwesomePythonSubCategory('内置类增强', [
        AwesomePythonLibrary('attrs', 'https://github.com/python-attrs/attrs', '消除类样板代码', ['__init__', '__eq__', '__repr__'], '数据类定义验证'),
        AwesomePythonLibrary('bidict', 'https://github.com/jab/bidict', '高效Pythonic双向映射', ['双向映射', '反转', '有序'], '双向查找数据结构'),
        AwesomePythonLibrary('box', 'https://github.com/cdgriffith/Box', '高级点号访问字典', ['点号访问', '嵌套', '默认值'], '配置管理嵌套数据'),
      ]),
      AwesomePythonSubCategory('函数式编程', [
        AwesomePythonLibrary('functools', 'https://docs.python.org/3/library/functools.html', '标准库高阶函数工具', ['reduce', 'partial', 'cache'], '函数式编程基础'),
        AwesomePythonLibrary('more-itertools', 'https://github.com/more-itertools/more-itertools', 'itertools扩展例程', ['组合', '窗口', '分组'], '高级迭代器操作'),
        AwesomePythonLibrary('toolz', 'https://github.com/pytoolz/toolz', '函数式数据处理工具', ['柯里化', '组合', '管道'], '函数式数据处理'),
        AwesomePythonLibrary('funcy', 'https://github.com/Suor/funcy', '实用函数式编程工具', ['组合', '柯里化', '序列'], '函数式风格编程'),
        AwesomePythonLibrary('returns', 'https://github.com/dry-python/returns', '类型安全单子和组合', ['Maybe', 'Result', 'IO'], '类型安全错误处理'),
        AwesomePythonLibrary('coconut', 'https://github.com/evhub/coconut', 'Python函数式编程变体', ['模式匹配', '管道', '代数类型'], '纯函数式Python'),
      ]),
      AwesomePythonSubCategory('异步编程', [
        AwesomePythonLibrary('asyncio', 'https://docs.python.org/3/library/asyncio.html', '标准库异步I/O框架', ['事件循环', '协程', 'Future'], '标准异步编程'),
        AwesomePythonLibrary('trio', 'https://github.com/python-trio/trio', '友好的异步并发I/O库', ['结构化并发', '取消', '测试'], '现代异步应用'),
        AwesomePythonLibrary('anyio', 'https://github.com/agronholm/anyio', '高级异步并发框架', ['asyncio/trio', '任务组', '网络'], '跨异步后端兼容'),
        AwesomePythonLibrary('uvloop', 'https://github.com/MagicStack/uvloop', '超快asyncio事件循环', ['极速', 'libuv', '替换'], 'asyncio性能优化'),
        AwesomePythonLibrary('gevent', 'https://github.com/gevent/gevent', '基于greenlet的协程网络', ['协程', '猴子补丁', '高性能'], '高并发网络应用'),
        AwesomePythonLibrary('twisted', 'https://github.com/twisted/twisted', '事件驱动网络引擎', ['事件驱动', '协议', '反应器'], '复杂网络服务'),
        AwesomePythonLibrary('concurrent.futures', 'https://docs.python.org/3/library/concurrent.futures.html', '标准库异步可调用执行', ['线程池', '进程池', 'Future'], '简单并行任务'),
        AwesomePythonLibrary('multiprocessing', 'https://docs.python.org/3/library/multiprocessing.html', '标准库进程并行', ['进程', '队列', '共享内存'], '绕过GIL并行计算'),
      ]),
      AwesomePythonSubCategory('日期与时间', [
        AwesomePythonLibrary('pendulum', 'https://github.com/sdispater/pendulum', 'Python日期时间增强库', ['时区', '人性化', '周期'], '直观日期时间操作'),
        AwesomePythonLibrary('dateutil', 'https://github.com/dateutil/dateutil', 'datetime模块扩展', ['解析', '增量', '复发规则'], '日期计算解析'),
        AwesomePythonLibrary('dateparser', 'https://github.com/scrapinghub/dateparser', '多语言人类可读日期解析', ['多语言', '自然语言', '搜索'], '文本日期解析'),
        AwesomePythonLibrary('zoneinfo', 'https://docs.python.org/3/library/zoneinfo.html', '标准库IANA时区支持', ['IANA', '时区', '跨平台'], '标准时区处理'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    'Python 工具链',
    Icons.settings,
    Color(0xFFF57F17),
    '环境管理、包管理、分发、配置文件等Python开发工具链',
    [
      AwesomePythonSubCategory('环境管理', [
        AwesomePythonLibrary('uv', 'https://github.com/astral-sh/uv', '极速Python版本包项目管理(Rust)', ['极速', '版本管理', '包管理', '项目管理'], '现代Python项目一站式工具'),
        AwesomePythonLibrary('pyenv', 'https://github.com/pyenv/pyenv', '简单Python版本管理', ['版本切换', '虚拟环境', '插件'], '多版本Python共存'),
        AwesomePythonLibrary('virtualenv', 'https://github.com/pypa/virtualenv', '创建隔离Python环境', ['隔离', '可复制', '激活脚本'], '项目依赖隔离'),
        AwesomePythonLibrary('pyenv-win', 'https://github.com/pyenv-win/pyenv-win', 'Windows上的pyenv', ['版本管理', 'Windows', 'PowerShell'], 'Windows版本管理'),
      ]),
      AwesomePythonSubCategory('包管理', [
        AwesomePythonLibrary('pip', 'https://github.com/pypa/pip', 'Python包安装器', ['安装', '依赖解析', '轮子'], 'Python包安装标准'),
        AwesomePythonLibrary('conda', 'https://github.com/conda/conda', '跨平台二进制包管理器', ['环境', '二进制', '跨语言'], '科学计算数据分析环境'),
        AwesomePythonLibrary('poetry', 'https://github.com/python-poetry/poetry', 'Python依赖管理和打包', ['依赖解析', '锁定', '构建'], 'Python项目依赖打包'),
        AwesomePythonLibrary('pipx', 'https://github.com/pypa/pipx', '隔离环境安装Python应用', ['隔离', '全局CLI', '安全'], 'Python CLI工具隔离安装'),
      ]),
      AwesomePythonSubCategory('分发', [
        AwesomePythonLibrary('pyinstaller', 'https://github.com/pyinstaller/pyinstaller', 'Python程序转独立exe', ['单文件', '跨平台', '依赖打包'], 'Python应用分发'),
        AwesomePythonLibrary('Nuitka', 'https://github.com/Nuitka/Nuitka', 'Python编译为高性能exe', ['C编译', '高性能', '静态链接'], '高性能Python分发'),
        AwesomePythonLibrary('cx-Freeze', 'https://github.com/marcelotduarte/cx_Freeze', 'Python脚本转独立exe', ['跨平台', '安装包', '依赖'], 'Python应用打包'),
        AwesomePythonLibrary('pyarmor', 'https://github.com/dashingsoft/pyarmor', 'Python脚本混淆和绑定', ['混淆', '加密', '许可'], 'Python代码保护'),
      ]),
      AwesomePythonSubCategory('配置文件', [
        AwesomePythonLibrary('python-dotenv', 'https://github.com/theskumar/python-dotenv', '.env文件加载环境变量', ['.env', '12-Factor', 'Flask'], '多环境配置管理'),
        AwesomePythonLibrary('dynaconf', 'https://github.com/dynaconf/dynaconf', '多框架配置管理器', ['多格式', '分层', '动态'], '复杂配置需求'),
        AwesomePythonLibrary('hydra', 'https://github.com/facebookresearch/hydra', 'Facebook优雅配置框架', ['组合', '覆盖', '启动器'], '研究实验配置'),
        AwesomePythonLibrary('python-decouple', 'https://github.com/HBNetwork/python-decouple', '设置与代码严格分离', ['环境变量', '.env', '转换'], 'Django风格配置分离'),
        AwesomePythonLibrary('configparser', 'https://docs.python.org/3/library/configparser.html', '标准库INI文件解析器', ['INI', '节', '选项'], 'INI格式配置文件'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '安全',
    Icons.security,
    Color(0xFFB71C1C),
    '密码学、渗透测试和Web安全相关库',
    [
      AwesomePythonSubCategory('密码学', [
        AwesomePythonLibrary('cryptography', 'https://github.com/pyca/cryptography', '密码学原语和配方库', ['对称加密', '哈希', 'X.509'], '加密签名证书管理'),
        AwesomePythonLibrary('paramiko', 'https://github.com/paramiko/paramiko', 'Python SSHv2协议库', ['SSH', 'SFTP', '密钥'], 'SSH连接远程操作'),
        AwesomePythonLibrary('pynacl', 'https://github.com/pyca/pynacl', 'NaCl密码学Python绑定', ['加密', '签名', '哈希'], '现代安全密码学'),
      ]),
      AwesomePythonSubCategory('渗透测试', [
        AwesomePythonLibrary('mitmproxy', 'https://github.com/mitmproxy/mitmproxy', '交互式TLS拦截HTTP代理', ['TLS拦截', '流量分析', '脚本'], 'HTTP/HTTPS分析'),
        AwesomePythonLibrary('sqlmap', 'https://github.com/sqlmapproject/sqlmap', '自动SQL注入数据库接管', ['SQL注入', '自动检测', '接管'], 'SQL注入检测利用'),
        AwesomePythonLibrary('sherlock', 'https://github.com/sherlock-project/sherlock', '跨社交网络用户名搜索', ['用户名', '社交网络', 'OSINT'], '社交媒体调查'),
      ]),
      AwesomePythonSubCategory('Web 安全', [
        AwesomePythonLibrary('secure', 'https://github.com/TypeError/secure', 'HTTP安全头中间件', ['安全头', 'ASGI', 'WSGI'], 'Web应用安全头'),
      ]),
    ],
  ),

  AwesomePythonCategory(
    '其他实用工具',
    Icons.more_horiz,
    Color(0xFF546E7A),
    '硬件交互、Windows开发和其他实用工具',
    [
      AwesomePythonSubCategory('硬件', [
        AwesomePythonLibrary('pynput', 'https://github.com/moses-palmer/pynput', '控制和监控输入设备', ['键盘', '鼠标', '监听'], '输入设备自动化监控'),
        AwesomePythonLibrary('bleak', 'https://github.com/hbldh/bleak', '跨平台蓝牙低功耗客户端', ['BLE', '异步', 'GATT'], '蓝牙设备通信IoT'),
      ]),
      AwesomePythonSubCategory('Microsoft Windows', [
        AwesomePythonLibrary('pywin32', 'https://github.com/mhammond/pywin32', 'Python Windows扩展', ['COM', 'Win32', 'Office'], 'Windows系统管理'),
        AwesomePythonLibrary('pythonnet', 'https://github.com/pythonnet/pythonnet', '.NET CLR的Python集成', ['.NET', 'C#互操作', 'DLL'], '.NET和Python混合编程'),
        AwesomePythonLibrary('winpython', 'https://github.com/winpython/winpython', 'Windows便携Python环境', ['便携', '科学计算', '预装包'], 'Windows便携Python'),
      ]),
      AwesomePythonSubCategory('实用工具', [
        AwesomePythonLibrary('blinker', 'https://github.com/pallets-eco/blinker', '快速进程内信号分发', ['信号', '事件', '发布订阅'], '应用内事件驱动'),
        AwesomePythonLibrary('boltons', 'https://github.com/mahmoud/boltons', '纯Python实用工具集', ['集合工具', '文件工具', '统计'], '日常编程实用函数'),
        AwesomePythonLibrary('itsdangerous', 'https://github.com/pallets/itsdangerous', '向不可信环境传递可信数据', ['签名', '时间戳', '序列化'], 'Cookie签名令牌生成'),
      ]),
    ],
  ),
];
