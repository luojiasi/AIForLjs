import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ai_chat_app/presentation/shared/tutorial_widgets.dart';

/// ============================================================
/// Awesome Python 库学习页
/// 内置 WebView 查看 GitHub 源码 + 详细学习内容
/// ============================================================

class AwesomePythonDetailPage extends StatefulWidget {
  final String name;
  final String url;
  final String description;
  final List<String> features;
  final String useCase;
  final String categoryName;
  final String? tutorialCode;

  const AwesomePythonDetailPage({
    super.key,
    required this.name,
    required this.url,
    required this.description,
    required this.features,
    required this.useCase,
    required this.categoryName,
    this.tutorialCode,
  });

  @override
  State<AwesomePythonDetailPage> createState() => _AwesomePythonDetailPageState();
}

class _AwesomePythonDetailPageState extends State<AwesomePythonDetailPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String? _error;
  late TabController _tabController;

  bool get _webViewSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (_webViewSupported) _initWebView();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Pixel 3) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _loadingProgress = progress / 100.0);
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() { _isLoading = false; _loadingProgress = 1; });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = '${error.description} (code: ${error.errorCode})';
              });
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        },
      );
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开外部浏览器')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: '在浏览器中打开 GitHub',
            onPressed: _openExternally,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '学习内容'),
            Tab(text: 'GitHub 源码'),
            Tab(text: '源码教程'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLearningContent(theme),
          _webViewSupported ? _buildWebView() : _buildDesktopFallback(),
          _buildSourceCodeTutorial(theme),
        ],
      ),
    );
  }

  Widget _buildLearningContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.categoryName,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.code, color: Colors.white.withValues(alpha: 0.7), size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Features section
          Text(
            '核心特性',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.features.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(f, style: TextStyle(fontSize: 13, color: Colors.blue.shade800)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Use case section
          Text(
            '适用场景',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.green.shade600, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.useCase,
                    style: TextStyle(fontSize: 14, color: Colors.green.shade800, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // GitHub link section
          Text(
            '源码地址',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _openExternally,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.url,
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Learning tips
          Text(
            '学习建议',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LearningTip(
                  icon: Icons.book,
                  text: '阅读官方文档了解基本用法和API',
                  color: Colors.amber.shade700,
                ),
                _LearningTip(
                  icon: Icons.code,
                  text: '查看GitHub上的示例代码和测试用例',
                  color: Colors.amber.shade700,
                ),
                _LearningTip(
                  icon: Icons.build,
                  text: '动手创建一个小项目来实践核心功能',
                  color: Colors.amber.shade700,
                ),
                _LearningTip(
                  icon: Icons.people,
                  text: '参与社区讨论，阅读Issues和PR了解最佳实践',
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        if (_isLoading)
          LinearProgressIndicator(value: _loadingProgress > 0 ? _loadingProgress : null, minHeight: 2),
        Expanded(
          child: _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('加载失败: $_error', style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                        onPressed: () {
                          setState(() { _error = null; _isLoading = true; });
                          _controller.reload();
                        },
                      ),
                    ],
                  ),
                )
              : WebViewWidget(controller: _controller),
        ),
      ],
    );
  }

  Widget _buildDesktopFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.code, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('在桌面端使用系统浏览器查看 GitHub 源码', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(widget.url, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('在浏览器中打开 GitHub'),
              onPressed: _openExternally,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }

  String get _tutorialCode {
    if (widget.tutorialCode != null) return widget.tutorialCode!;
    return _specificTutorials[widget.name] ?? _generateTutorial();
  }

  Map<String, String> get _specificTutorials => _tutorialMap;

  static const Map<String, String> _tutorialMap = {
    // ── AI & 机器学习 ──────────────────────────────
    'langchain': '''
# ============================================================
# LangChain 源码级使用教程
# 构建LLM应用的可组合框架
# ============================================================

# ---------- 1. 安装 ----------
pip install langchain langchain-core langchain-community
pip install langchain-openai

# ---------- 2. 基础用法: 构建第一个Chain ----------
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

llm = ChatOpenAI(model="gpt-4", temperature=0)

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个{role}专家"),
    ("user", "{input}")
])

output_parser = StrOutputParser()
chain = prompt | llm | output_parser

result = chain.invoke({"role": "Python", "input": "解释什么是装饰器"})
print(result)

# ---------- 3. 核心功能: RAG检索增强生成 ----------
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

loader = WebBaseLoader("https://docs.python.org/3/tutorial/")
docs = loader.load()
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = FAISS.from_documents(splits, OpenAIEmbeddings())

retriever = vectorstore.as_retriever()
from langchain_core.runnables import RunnablePassthrough
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | output_parser
)
answer = rag_chain.invoke("什么是列表推导式?")
print(answer)

# ---------- 4. 完整示例: Agent工具调用 ----------
from langchain.agents import create_tool_calling_agent
from langchain.tools import tool

@tool
def calculator(expression: str) -> str:
    """计算数学表达式的结果"""
    return str(eval(expression))

agent = create_tool_calling_agent(llm, [calculator], prompt)
result = agent.invoke({"input": "计算 (15 + 23) * 4 的结果"})
print(result)

# ---------- 5. 运行结果 ----------
# Chain输出: 装饰器是一种Python语法，用@符号标记...
# RAG输出: 列表推导式是创建列表的简洁方式，语法为[expr for item in iterable]
# Agent输出: (15 + 23) * 4 = 152
''',

    'transformers': '''
# ============================================================
# HuggingFace Transformers 源码级使用教程
# 预训练Transformer模型库
# ============================================================

# ---------- 1. 安装 ----------
pip install transformers torch datasets accelerate

# ---------- 2. 基础用法: 情感分析Pipeline ----------
from transformers import pipeline

classifier = pipeline("sentiment-analysis")
result = classifier("I love using HuggingFace Transformers!")
print(f"情感: {result[0]['label']}, 置信度: {result[0]['score']:.2f}")

# 文本生成
generator = pipeline("text-generation", model="gpt2")
text = generator("Python is a great language because", max_length=50)
print(text[0]['generated_text'])

# ---------- 3. 核心功能: 模型微调 ----------
from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer, TrainingArguments
from datasets import Dataset

data = Dataset.from_dict({
    "text": ["Amazing product!", "Terrible experience.", "Pretty good."],
    "label": [1, 0, 1]
})

tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
model = AutoModelForSequenceClassification.from_pretrained("bert-base-uncased", num_labels=2)

def tokenize(examples):
    return tokenizer(examples["text"], truncation=True, padding="max_length", max_length=128)

tokenized_data = data.map(tokenize, batched=True)

training_args = TrainingArguments(output_dir="./results", num_train_epochs=3, per_device_train_batch_size=8)
trainer = Trainer(model=model, args=training_args, train_dataset=tokenized_data)
trainer.train()

# ---------- 4. 完整示例: 自定义NER ----------
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
model = AutoModelForSequenceClassification.from_pretrained("bert-base-uncased")
nlp = pipeline("ner", model=model, tokenizer=tokenizer, aggregation_strategy="simple")
entities = nlp("Apple Inc. was founded by Steve Jobs in California.")
for entity in entities:
    print(f"实体: {entity['word']}, 类型: {entity['entity_group']}, 置信度: {entity['score']:.2f}")

# ---------- 5. 运行结果 ----------
# 情感分析: POSITIVE, 置信度: 0.99
# NER: Apple Inc. -> ORG, Steve Jobs -> PER, California -> LOC
''',

    'pandas': '''
# ============================================================
# Pandas 源码级使用教程
# 高性能数据分析工具
# ============================================================

# ---------- 1. 安装 ----------
pip install pandas numpy

# ---------- 2. 基础用法: DataFrame操作 ----------
import pandas as pd
import numpy as np

df = pd.DataFrame({
    "姓名": ["张三", "李四", "王五", "赵六"],
    "年龄": [25, 30, 35, 28],
    "城市": ["北京", "上海", "广州", "深圳"],
    "薪资": [15000, 20000, 18000, 22000]
})
print(df.head())
print(f"\\n数据形状: {df.shape}")
print(f"列类型:\\n{df.dtypes}")

# 数据筛选
high_salary = df[df["薪资"] > 18000]
print(f"\\n高薪员工:\\n{high_salary}")

# 分组聚合
grouped = df.groupby("城市")["薪资"].agg(["mean", "sum", "count"])
print(f"\\n按城市统计:\\n{grouped}")

# ---------- 3. 核心功能: 数据清洗 ----------
df_dirty = pd.DataFrame({
    "A": [1, np.nan, 3, 4],
    "B": [5, 6, np.nan, 8],
    "C": ["x", "y", None, "z"]
})
print(f"缺失值:\\n{df_dirty.isnull().sum()}")
df_clean = df_dirty.fillna({"A": df_dirty["A"].mean(), "B": 0, "C": "unknown"})
print(f"\\n清洗后:\\n{df_clean}")

# 合并数据
df1 = pd.DataFrame({"key": ["A", "B", "C"], "value1": [1, 2, 3]})
df2 = pd.DataFrame({"key": ["B", "C", "D"], "value2": [4, 5, 6]})
merged = df1.merge(df2, on="key", how="outer")
print(f"\\n合并结果:\\n{merged}")

# ---------- 4. 完整示例: 时间序列分析 ----------
dates = pd.date_range("2024-01-01", periods=12, freq="ME")
ts_data = pd.DataFrame({"date": dates, "sales": np.random.randint(1000, 5000, 12)})
ts_data["month"] = ts_data["date"].dt.month
ts_data["quarter"] = ts_data["date"].dt.quarter
ts_data["rolling_avg"] = ts_data["sales"].rolling(window=3).mean()
print(f"\\n时间序列:\\n{ts_data}")
quarterly = ts_data.groupby("quarter")["sales"].sum()
print(f"\\n按季度汇总:\\n{quarterly}")

# 导出
ts_data.to_csv("sales_data.csv", index=False)
print("\\n数据已导出到 sales_data.csv")

# ---------- 5. 运行结果 ----------
# DataFrame 形状: (4, 4)
# 高薪员工: 2人
# 时间序列包含12个月的数据和滚动平均值
''',

    'numpy': '''
# ============================================================
# NumPy 源码级使用教程
# 科学计算基础包
# ============================================================

# ---------- 1. 安装 ----------
pip install numpy

# ---------- 2. 基础用法: 数组操作 ----------
import numpy as np

arr = np.array([1, 2, 3, 4, 5])
print(f"数组: {arr}, 类型: {arr.dtype}, 形状: {arr.shape}")

zeros = np.zeros((3, 4))
ones = np.ones((2, 3))
identity = np.eye(3)
random_arr = np.random.randn(4, 4)
print(f"\\n随机数组:\\n{random_arr}")

# ---------- 3. 核心功能: 广播与向量化 ----------
a = np.array([[1, 2, 3], [4, 5, 6]])  # (2,3)
b = np.array([10, 20, 30])              # (3,)
print(f"\\n广播加法:\\n{a + b}")

# 向量化操作
x = np.linspace(0, 2*np.pi, 100)
y = np.sin(x) * np.exp(-x/3)
print(f"向量化计算完成，数据点: {len(x)}")

# 线性代数
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])
print(f"\\n矩阵乘法:\\n{A @ B}")
print(f"逆矩阵:\\n{np.linalg.inv(A)}")
eigenvalues, eigenvectors = np.linalg.eig(A)
print(f"特征值: {eigenvalues}")

# ---------- 4. 完整示例: 图像处理模拟 ----------
image = np.random.randint(0, 256, (100, 100, 3), dtype=np.uint8)
gray = np.dot(image[..., :3], [0.2989, 0.5870, 0.1140]).astype(np.uint8)
flipped = np.flip(image, axis=1)
cropped = image[20:80, 20:80, :]
print(f"原图: {image.shape} -> 灰度: {gray.shape}")

# 统计
data = np.random.normal(100, 15, 1000)
print(f"\\n均值: {np.mean(data):.2f}, 标准差: {np.std(data):.2f}")
print(f"中位数: {np.median(data):.2f}")
print(f"95分位: {np.percentile(data, 95):.2f}")

# ---------- 5. 运行结果 ----------
# 广播成功: (2,3) + (3,) -> (2,3)
# 矩阵乘法结果: [[19, 22], [43, 50]]
# 统计: 均值~100, 标准差~15
''',

    'fastapi': '''
# ============================================================
# FastAPI 源码级使用教程
# 现代高性能API框架
# ============================================================

# ---------- 1. 安装 ----------
pip install fastapi uvicorn pydantic

# ---------- 2. 基础用法: 第一个API ----------
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional

app = FastAPI(title="我的API", version="1.0.0")

class Item(BaseModel):
    name: str
    price: float
    description: Optional[str] = None
    tax: Optional[float] = None

@app.get("/")
def read_root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: Optional[str] = None):
    return {"item_id": item_id, "q": q}

@app.post("/items/")
def create_item(item: Item):
    total = item.price + (item.tax or 0)
    return {"item": item.name, "total_price": total}

# 运行: uvicorn main:app --reload

# ---------- 3. 核心功能: 依赖注入与中间件 ----------
from fastapi import Depends, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

def verify_token(x_token: str = Header()):
    if x_token != "secret-token":
        raise HTTPException(status_code=400, detail="X-Token header invalid")
    return x_token

def get_db():
    db = {"connected": True}
    try:
        yield db
    finally:
        print("数据库连接关闭")

@app.get("/protected/")
def protected_route(token: str = Depends(verify_token), db: dict = Depends(get_db)):
    return {"token_valid": True, "db_status": db["connected"]}

# ---------- 4. 完整示例: 异步CRUD ----------
from fastapi import BackgroundTasks

tasks_db = []

@app.post("/tasks/")
async def create_task(name: str, background: BackgroundTasks):
    task = {"id": len(tasks_db)+1, "name": name, "done": False}
    tasks_db.append(task)
    background.add_task(send_notification, task["id"])
    return task

async def send_notification(task_id: int):
    import asyncio
    await asyncio.sleep(1)
    print(f"通知已发送: 任务#{task_id}")

@app.get("/tasks/")
async def list_tasks():
    return tasks_db

@app.put("/tasks/{task_id}")
async def complete_task(task_id: int):
    for t in tasks_db:
        if t["id"] == task_id:
            t["done"] = True
            return t
    raise HTTPException(status_code=404, detail="Task not found")

# 访问 http://localhost:8000/docs 查看自动生成的API文档

# ---------- 5. 运行结果 ----------
# GET / -> {"message": "Hello World"}
# POST /items/ {"name":"widget","price":10.5} -> {"item":"widget","total_price":10.5}
# 自动生成 OpenAPI 文档于 /docs
''',

    'requests': '''
# ============================================================
# Requests 源码级使用教程
# 人性化HTTP库，Python下载量最高
# ============================================================

# ---------- 1. 安装 ----------
pip install requests

# ---------- 2. 基础用法: HTTP请求 ----------
import requests

# GET请求
r = requests.get("https://httpbin.org/get")
print(f"状态码: {r.status_code}")
print(f"响应头: {dict(r.headers)}")
print(f"内容(前100字符): {r.text[:100]}")

# 带参数的GET
r = requests.get("https://httpbin.org/get", params={"key1": "value1", "key2": "value2"})
print(f"\\n请求URL: {r.url}")

# POST JSON
r = requests.post("https://httpbin.org/post", json={"name": "张三", "age": 25})
print(f"\\nPOST响应JSON: {r.json()}")

# ---------- 3. 核心功能: Session与认证 ----------
session = requests.Session()
session.headers.update({"User-Agent": "MyApp/1.0"})
session.auth = ("user", "pass")

r = session.get("https://httpbin.org/basic-auth/user/pass")
print(f"认证状态: {r.status_code}")

# 文件上传
with open("example.txt", "wb") as f:
    f.write(b"Hello World")
files = {"file": open("example.txt", "rb")}
r = requests.post("https://httpbin.org/post", files=files)
print(f"上传响应: {r.json().get('files')}")

# 超时与重试
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

retry = Retry(total=3, backoff_factor=1, status_forcelist=[500, 502, 503, 504])
adapter = HTTPAdapter(max_retries=retry)
session.mount("https://", adapter)

# ---------- 4. 完整示例: API客户端 ----------
class GitHubAPI:
    def __init__(self, token=None):
        self.session = requests.Session()
        self.session.headers.update({
            "Accept": "application/vnd.github.v3+json",
        })
        if token:
            self.session.headers["Authorization"] = f"token {token}"

    def get_user(self, username):
        r = self.session.get(f"https://api.github.com/users/{username}")
        r.raise_for_status()
        data = r.json()
        return {
            "name": data.get("name"),
            "repos": data.get("public_repos"),
            "followers": data.get("followers")
        }

    def search_repos(self, query, per_page=10):
        r = self.session.get(
            "https://api.github.com/search/repositories",
            params={"q": query, "per_page": per_page}
        )
        r.raise_for_status()
        return [item["full_name"] for item in r.json()["items"]]

# api = GitHubAPI()
# print(api.search_repos("python web framework"))

# ---------- 5. 运行结果 ----------
# GET 状态码: 200
# POST JSON 响应包含发送的数据
# GitHub API 返回仓库列表
''',

    'django': '''
# ============================================================
# Django 源码级使用教程
# 最流行的Python全栈Web框架
# ============================================================

# ---------- 1. 安装 ----------
pip install django
django-admin startproject mysite
cd mysite
python manage.py startapp blog

# ---------- 2. 基础用法: 模型与视图 ----------
# models.py
from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        from django.urls import reverse
        return reverse('post-detail', kwargs={'pk': self.pk})

# views.py
from django.views.generic import ListView, DetailView, CreateView
from .models import Post
from django.contrib.auth.mixins import LoginRequiredMixin

class PostListView(ListView):
    model = Post
    template_name = 'blog/post_list.html'
    context_object_name = 'posts'
    paginate_by = 10

class PostDetailView(DetailView):
    model = Post
    template_name = 'blog/post_detail.html'

class PostCreateView(LoginRequiredMixin, CreateView):
    model = Post
    fields = ['title', 'content']
    template_name = 'blog/post_form.html'

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

# urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.PostListView.as_view(), name='post-list'),
    path('post/<int:pk>/', views.PostDetailView.as_view(), name='post-detail'),
    path('post/new/', views.PostCreateView.as_view(), name='post-create'),
]

# ---------- 3. 核心功能: Admin与管理命令 ----------
# admin.py
from django.contrib import admin
from .models import Post

@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'created_at']
    list_filter = ['created_at', 'author']
    search_fields = ['title', 'content']
    prepopulated_fields = {'slug': ('title',)}

# management/commands/populate_db.py
from django.core.management.base import BaseCommand
from blog.models import Post
from django.contrib.auth.models import User

class Command(BaseCommand):
    help = '填充测试数据'
    def handle(self, *args, **kwargs):
        user = User.objects.first()
        for i in range(100):
            Post.objects.create(
                title=f'Test Post {i}',
                content=f'Content for post {i}',
                author=user
            )
        self.stdout.write(self.style.SUCCESS('成功创建100篇文章'))

# ---------- 4. 完整示例: REST API ----------
# settings.py 添加 'rest_framework' 到 INSTALLED_APPS
# serializers.py
from rest_framework import serializers
from .models import Post

class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)

    class Meta:
        model = Post
        fields = ['id', 'title', 'content', 'author_name', 'created_at']

# api_views.py
from rest_framework import viewsets, permissions
from .models import Post
from .serializers import PostSerializer

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

# ---------- 5. 运行结果 ----------
# python manage.py runserver
# 访问 http://localhost:8000/ 查看博客列表
# 访问 http://localhost:8000/admin/ 进入管理界面
# 访问 http://localhost:8000/api/ 查看REST API
''',

    'pytest': '''
# ============================================================
# Pytest 源码级使用教程
# 成熟全功能Python测试框架
# ============================================================

# ---------- 1. 安装 ----------
pip install pytest pytest-cov pytest-xdist

# ---------- 2. 基础用法: 编写测试 ----------
# test_calculator.py
import pytest

def add(a, b):
    return a + b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

def test_divide():
    assert divide(10, 2) == 5.0
    assert divide(1, 3) == pytest.approx(0.333, rel=1e-3)

def test_divide_by_zero():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)

# 运行: pytest test_calculator.py -v

# ---------- 3. 核心功能: Fixture与参数化 ----------
@pytest.fixture
def sample_data():
    return {"users": [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]}

def test_fixture_usage(sample_data):
    assert len(sample_data["users"]) == 2
    assert sample_data["users"][0]["name"] == "Alice"

@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (5, 5, 10),
    (-3, 3, 0),
    (100, 200, 300),
])
def test_add_parametrized(a, b, expected):
    assert add(a, b) == expected

# conftest.py (共享fixture)
@pytest.fixture(scope="module")
def database():
    db = {"connected": True, "data": []}
    yield db
    db["connected"] = False
    print("数据库连接关闭")

# ---------- 4. 完整示例: API测试 ----------
import pytest
from fastapi.testclient import TestClient

# 假设有 main.py 中的 FastAPI app
# from main import app
# client = TestClient(app)

def test_read_main(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}

def test_create_item(client):
    response = client.post("/items/", json={"name": "widget", "price": 10.5})
    assert response.status_code == 200
    data = response.json()
    assert data["item"] == "widget"

# 运行: pytest -v --cov=. --cov-report=html
# 生成覆盖率报告于 htmlcov/index.html

# ---------- 5. 运行结果 ----------
# test_add PASSED
# test_divide PASSED
# test_divide_by_zero PASSED
# 覆盖率: 95% (输出于htmlcov/)
''',

    'scikit-learn': '''
# ============================================================
# Scikit-learn 源码级使用教程
# 最流行的Python机器学习库
# ============================================================

# ---------- 1. 安装 ----------
pip install scikit-learn pandas numpy matplotlib

# ---------- 2. 基础用法: 分类与回归 ----------
from sklearn.datasets import load_iris, load_diabetes
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.metrics import accuracy_score, mean_squared_error

# 分类
iris = load_iris()
X, y = iris.data, iris.target
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

clf = LogisticRegression(max_iter=1000)
clf.fit(X_train, y_train)
y_pred = clf.predict(X_test)
print(f"分类准确率: {accuracy_score(y_test, y_pred):.2%}")

# 回归
diabetes = load_diabetes()
X_train2, X_test2, y_train2, y_test2 = train_test_split(
    diabetes.data, diabetes.target, test_size=0.2, random_state=42
)
reg = LinearRegression()
reg.fit(X_train2, y_train2)
y_pred2 = reg.predict(X_test2)
print(f"MSE: {mean_squared_error(y_test2, y_pred2):.2f}")

# ---------- 3. 核心功能: Pipeline与交叉验证 ----------
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_score, GridSearchCV

pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('svm', SVC())
])

param_grid = {
    'svm__C': [0.1, 1, 10],
    'svm__kernel': ['linear', 'rbf'],
    'svm__gamma': ['scale', 'auto']
}

grid_search = GridSearchCV(pipeline, param_grid, cv=5, scoring='accuracy')
grid_search.fit(X_train, y_train)
print(f"最佳参数: {grid_search.best_params_}")
print(f"最佳得分: {grid_search.best_score_:.2%}")

# ---------- 4. 完整示例: 分类Pipeline ----------
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

full_pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
])

full_pipeline.fit(X_train, y_train)
y_pred_full = full_pipeline.predict(X_test)

print("分类报告:")
print(classification_report(y_test, y_pred_full, target_names=iris.target_names))

# 特征重要性
importances = full_pipeline.named_steps['classifier'].feature_importances_
for name, imp in zip(iris.feature_names, importances):
    print(f"{name}: {imp:.4f}")

# 保存模型
import joblib
joblib.dump(full_pipeline, "iris_model.pkl")
print("模型已保存到 iris_model.pkl")

# ---------- 5. 运行结果 ----------
# 分类准确率: 96.67%
# 最佳参数: C=10, kernel=rbf
# 最佳得分: 96.67%
''',

    'pydantic': '''
# ============================================================
# Pydantic 源码级使用教程
# 基于类型提示的数据验证
# ============================================================

# ---------- 1. 安装 ----------
pip install pydantic pydantic-settings

# ---------- 2. 基础用法: 模型定义与验证 ----------
from pydantic import BaseModel, Field, validator, field_validator
from typing import Optional, List
from datetime import datetime
from enum import Enum

class Role(str, Enum):
    ADMIN = "admin"
    USER = "user"
    GUEST = "guest"

class User(BaseModel):
    id: int
    name: str = Field(..., min_length=1, max_length=50)
    email: str = Field(..., pattern=r\'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\\\$\')
    age: int = Field(ge=0, le=150)
    role: Role = Role.USER
    tags: List[str] = []
    created_at: datetime = Field(default_factory=datetime.now)

    @field_validator('name')
    @classmethod
    def name_must_not_be_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError('名称不能为空')
        return v.strip()

# 验证成功
user = User(id=1, name="张三", email="zhangsan@example.com", age=25)
print(f"用户: {user.model_dump()}")

# 验证失败会抛出ValidationError
try:
    User(id=2, name="", email="invalid", age=200)
except Exception as e:
    print(f"验证错误: {e}")

# JSON序列化
json_data = user.model_dump_json(indent=2)
print(f"JSON:\\n{json_data}")

# ---------- 3. 核心功能: 嵌套模型 ----------
class Address(BaseModel):
    street: str
    city: str
    country: str = "中国"
    zipcode: Optional[str] = None

class Company(BaseModel):
    name: str
    address: Address
    employees: List[User] = []

company = Company(
    name="Tech Co",
    address=Address(street="科技路1号", city="北京"),
    employees=[user]
)
print(f"\\n公司: {company.model_dump()}")

# ---------- 4. 完整示例: 配置管理 ----------
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "My App"
    debug: bool = False
    database_url: str
    redis_url: Optional[str] = None
    api_tokens: List[str] = []

    model_config = {"env_prefix": "APP_", "env_file": ".env"}

# settings = Settings()
# 会从环境变量APP_DATABASE_URL等读取配置

# FastAPI集成示例
class ItemCreate(BaseModel):
    name: str
    price: float = Field(gt=0)
    quantity: int = Field(default=1, ge=0)
    tags: List[str] = []

class ItemResponse(BaseModel):
    id: int
    name: str
    price: float
    quantity: int
    total: float

    @field_validator('total')
    @classmethod
    def compute_total(cls, v, info):
        return info.data.get('price', 0) * info.data.get('quantity', 1)

# ---------- 5. 运行结果 ----------
# 用户数据: {"id":1,"name":"张三","email":"zhangsan@example.com","age":25,...}
# 验证错误: 字段验证失败
# JSON输出包含所有字段的序列化数据
''',

    'rich': '''
# ============================================================
# Rich 源码级使用教程
# 终端富文本和美观格式化
# ============================================================

# ---------- 1. 安装 ----------
pip install rich

# ---------- 2. 基础用法: 美化输出 ----------
from rich import print as rprint
from rich.console import Console
from rich.table import Table
from rich.progress import track
from rich.panel import Panel
from rich.syntax import Syntax
from rich.markdown import Markdown
from rich.layout import Layout
import time

console = Console()

# 彩色和样式文本
console.print("Hello, [bold cyan]World[/bold cyan]!", ":smiley:")
console.print("[red]错误[/red] [yellow]警告[/yellow] [green]成功[/green]")

# 表格
table = Table(title="用户列表", show_header=True, header_style="bold magenta")
table.add_column("ID", style="dim", width=6)
table.add_column("姓名")
table.add_column("邮箱")
table.add_column("状态", justify="right")
table.add_row("1", "张三", "zhangsan@example.com", "[green]活跃[/green]")
table.add_row("2", "李四", "lisi@example.com", "[yellow]离线[/yellow]")
table.add_row("3", "王五", "wangwu@example.com", "[green]活跃[/green]")
console.print(table)

# ---------- 3. 核心功能: 进度条与面板 ----------
# 进度条
console.print("\\n[bold]处理数据中...[/bold]")
for i in track(range(100), description="进度"):
    time.sleep(0.02)

# 面板
panel = Panel.fit(
    "[bold]Rich库[/bold]\\n让终端输出变得美观",
    title="关于",
    border_style="blue"
)
console.print(panel)

# 语法高亮
code = \'\'\'\\
def fibonacci(n: int) -> list[int]:
    a, b = 0, 1
    result = []
    for _ in range(n):
        result.append(a)
        a, b = b, a + b
    return result
\'\'\'
syntax = Syntax(code, "python", theme="monokai", line_numbers=True)
console.print(syntax)

# ---------- 4. 完整示例: 实时仪表盘 ----------
from rich.live import Live
from rich.layout import Layout
import random

def make_layout() -> Layout:
    layout = Layout()
    layout.split_column(
        Layout(name="header", size=3),
        Layout(name="body"),
    )
    layout["body"].split_row(
        Layout(name="stats", ratio=2),
        Layout(name="log", ratio=3),
    )
    return layout

header = Panel("📊 系统监控仪表盘", style="bold white on blue")
stats_table = Table(title="实时统计", expand=True)
stats_table.add_column("指标")
stats_table.add_column("值", justify="right")

def update_stats():
    stats_table.rows.clear()
    stats_table.add_row("CPU使用率", f"{random.randint(10,90)}%")
    stats_table.add_row("内存使用", f"{random.randint(1000,8000)}MB")
    stats_table.add_row("网络流量", f"{random.randint(100,1000)}KB/s")
    stats_table.add_row("请求数", f"{random.randint(100,999)} req/s")

with Live(header, console=console, refresh_per_second=2) as live:
    for _ in range(20):
        update_stats()
        live.update(Panel(stats_table))
        time.sleep(0.5)

# ---------- 5. 运行结果 ----------
# 终端显示彩色格式化输出
# 表格美观展示数据
# 实时仪表盘动态更新统计信息
''',

    'sqlalchemy': '''
# ============================================================
# SQLAlchemy 源码级使用教程
# 最强Python SQL工具包和ORM
# ============================================================

# ---------- 1. 安装 ----------
pip install sqlalchemy

# ---------- 2. 基础用法: ORM模型 ----------
from sqlalchemy import create_engine, Column, Integer, String, Float, ForeignKey, DateTime, select, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, Session, relationship

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
    email: Mapped[str] = mapped_column(String(100), unique=True)

    orders: Mapped[list["Order"]] = relationship(back_populates="user")

class Order(Base):
    __tablename__ = "orders"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    product: Mapped[str] = mapped_column(String(100))
    price: Mapped[float] = mapped_column(Float)

    user: Mapped["User"] = relationship(back_populates="orders")

engine = create_engine("sqlite:///shop.db", echo=False)
Base.metadata.create_all(engine)

# ---------- 3. 核心功能: CRUD操作 ----------
with Session(engine) as session:
    # Create
    user = User(name="张三", email="zhangsan@example.com")
    session.add(user)
    session.add_all([
        Order(user=user, product="笔记本电脑", price=5999.0),
        Order(user=user, product="鼠标", price=99.0),
    ])
    session.commit()

    # Read with joins
    stmt = (
        select(User.name, func.count(Order.id).label("order_count"), func.sum(Order.price).label("total"))
        .join(Order)
        .group_by(User.id)
    )
    for row in session.execute(stmt):
        print(f"{row.name}: {row.order_count}个订单, 总金额¥{row.total}")

    # Update
    user.email = "newemail@example.com"
    session.flush()

    # Delete
    cheap_orders = session.query(Order).filter(Order.price < 50)
    deleted_count = cheap_orders.delete()
    session.commit()
    print(f"删除了{deleted_count}个低价订单")

# ---------- 4. 完整示例: 数据库迁移 ----------
# 使用Alembic进行迁移
# pip install alembic
# alembic init alembic
# alembic revision --autogenerate -m "init"
# alembic upgrade head

# 异步SQLAlchemy
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

async_engine = create_async_engine("sqlite+aiosqlite:///shop.db")

async def async_example():
    async with AsyncSession(async_engine) as session:
        result = await session.execute(select(User).where(User.name.like("%三%")))
        users = result.scalars().all()
        for u in users:
            print(f"异步查询: {u.name} - {u.email}")

# import asyncio
# asyncio.run(async_example())

# ---------- 5. 运行结果 ----------
# 张三: 2个订单, 总金额¥6098.0
# 删除低价订单数: 0 (没有低于50元的订单)
# 异步查询成功执行
''',

    'pytorch': '''
# ============================================================
# PyTorch 源码级使用教程
# 主流深度学习框架，动态计算图
# ============================================================

# ---------- 1. 安装 ----------
pip install torch torchvision torchaudio

# ---------- 2. 基础用法: 张量操作 ----------
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset

t = torch.tensor([1, 2, 3, 4, 5], dtype=torch.float32)
print(f"张量: {t}, 设备: {t.device}")

a = torch.randn(3, 4)
b = torch.randn(3, 4)
print(f"矩阵加法: {a + b}")
print(f"矩阵乘法: {a @ b.T}")

if torch.cuda.is_available():
    t = t.cuda()
    print(f"GPU张量: {t.device}")

# ---------- 3. 核心功能: 神经网络 ----------
class SimpleNet(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super().__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, output_size)
        self.dropout = nn.Dropout(0.2)

    def forward(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.dropout(x)
        x = self.fc2(x)
        return x

model = SimpleNet(10, 64, 2)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

X = torch.randn(100, 10)
y = torch.randint(0, 2, (100,))
dataset = TensorDataset(X, y)
loader = DataLoader(dataset, batch_size=16, shuffle=True)

for epoch in range(5):
    total_loss = 0
    for batch_X, batch_y in loader:
        optimizer.zero_grad()
        outputs = model(batch_X)
        loss = criterion(outputs, batch_y)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    print(f"Epoch {epoch+1}: loss={total_loss/len(loader):.4f}")

# ---------- 4. 完整示例: 模型保存与加载 ----------
torch.save({
    'epoch': 5,
    'model_state_dict': model.state_dict(),
    'optimizer_state_dict': optimizer.state_dict(),
    'loss': total_loss,
}, 'model_checkpoint.pth')

checkpoint = torch.load('model_checkpoint.pth')
model.load_state_dict(checkpoint['model_state_dict'])
print(f"模型加载成功，Epoch: {checkpoint['epoch']}")

# 推理模式
model.eval()
with torch.no_grad():
    test_input = torch.randn(5, 10)
    predictions = model(test_input)
    probs = torch.softmax(predictions, dim=1)
    pred_classes = torch.argmax(probs, dim=1)
    print(f"预测类别: {pred_classes}")
    print(f"预测概率: {probs}")

# 导出为TorchScript
traced_model = torch.jit.trace(model, torch.randn(1, 10))
traced_model.save("model_traced.pt")

# ---------- 5. 运行结果 ----------
# Epoch 1: loss=0.6952
# Epoch 5: loss=0.5123
# 预测类别: tensor([0, 1, 1, 0, 0])
''',

    'matplotlib': '''
# ============================================================
# Matplotlib 源码级使用教程
# Python 2D绘图基础库
# ============================================================

# ---------- 1. 安装 ----------
pip install matplotlib numpy

# ---------- 2. 基础用法: 折线图与散点图 ----------
import matplotlib.pyplot as plt
import numpy as np

# 折线图
x = np.linspace(0, 2*np.pi, 100)
y_sin = np.sin(x)
y_cos = np.cos(x)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

axes[0, 0].plot(x, y_sin, 'b-', label='sin(x)', linewidth=2)
axes[0, 0].plot(x, y_cos, 'r--', label='cos(x)', linewidth=2)
axes[0, 0].set_xlabel('x')
axes[0, 0].set_ylabel('y')
axes[0, 0].set_title('三角函数')
axes[0, 0].legend()
axes[0, 0].grid(True, alpha=0.3)

# 散点图
np.random.seed(42)
scatter_x = np.random.randn(100)
scatter_y = np.random.randn(100)
colors = np.random.rand(100)
sizes = np.random.randint(20, 200, 100)

sc = axes[0, 1].scatter(scatter_x, scatter_y, c=colors, s=sizes, alpha=0.6, cmap='viridis')
axes[0, 1].set_title('散点图')
plt.colorbar(sc, ax=axes[0, 1])

# ---------- 3. 核心功能: 柱状图与饼图 ----------
categories = ['A', 'B', 'C', 'D', 'E']
values = [23, 45, 56, 78, 32]
axes[1, 0].bar(categories, values, color=['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7'])
axes[1, 0].set_title('柱状图')

axes[1, 1].pie(values, labels=categories, autopct='%1.1f%%', startangle=90,
               colors=['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7'])
axes[1, 1].set_title('饼图')

plt.tight_layout()
plt.savefig('charts.png', dpi=150, bbox_inches='tight')
print("图表已保存到 charts.png")

# ---------- 4. 完整示例: 数据分析报告 ----------
import matplotlib
matplotlib.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['axes.unicode_minus'] = False

fig, ax = plt.subplots(figsize=(10, 6))

# 生成销售数据
months = ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
product_a = np.random.randint(100, 500, 12)
product_b = np.random.randint(100, 500, 12)
product_c = np.random.randint(100, 500, 12)

x_pos = np.arange(len(months))
width = 0.25

ax.bar(x_pos - width, product_a, width, label='产品A', color='#FF6B6B')
ax.bar(x_pos, product_b, width, label='产品B', color='#4ECDC4')
ax.bar(x_pos + width, product_c, width, label='产品C', color='#45B7D1')

ax.set_xlabel('月份', fontsize=12)
ax.set_ylabel('销售额(万元)', fontsize=12)
ax.set_title('2024年度销售报表', fontsize=14, fontweight='bold')
ax.set_xticks(x_pos)
ax.set_xticklabels(months, rotation=45)
ax.legend()
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.show()

# ---------- 5. 运行结果 ----------
# 4个子图展示不同类型图表
# 图表保存为高清PNG文件
# 销售报表包含12个月的对比数据
''',

    'scrapy': '''
# ============================================================
# Scrapy 源码级使用教程
# 快速高级Web爬虫框架
# ============================================================

# ---------- 1. 安装 ----------
pip install scrapy
scrapy startproject myproject
cd myproject
scrapy genspider quotes quotes.toscrape.com

# ---------- 2. 基础用法: 第一个爬虫 ----------
import scrapy

class QuotesSpider(scrapy.Spider):
    name = "quotes"
    start_urls = ["https://quotes.toscrape.com/"]

    def parse(self, response):
        for quote in response.css("div.quote"):
            yield {
                "text": quote.css("span.text::text").get(),
                "author": quote.css("small.author::text").get(),
                "tags": quote.css("div.tags a.tag::text").getall(),
            }

        next_page = response.css("li.next a::attr(href)").get()
        if next_page:
            yield response.follow(next_page, self.parse)

# 运行: scrapy crawl quotes -o quotes.json

# ---------- 3. 核心功能: Item Pipeline ----------
# items.py
import scrapy

class ProductItem(scrapy.Item):
    title = scrapy.Field()
    price = scrapy.Field()
    rating = scrapy.Field()
    url = scrapy.Field()

# pipelines.py
class PricePipeline:
    def process_item(self, item, spider):
        item['price'] = float(item['price'].replace('\$', '').replace(',', ''))
        return item

class DuplicatesPipeline:
    def __init__(self):
        self.seen = set()

    def process_item(self, item, spider):
        if item['url'] in self.seen:
            raise scrapy.exceptions.DropItem(f"重复: {item['url']}")
        self.seen.add(item['url'])
        return item

# settings.py 添加:
# ITEM_PIPELINES = {
#     'myproject.pipelines.PricePipeline': 300,
#     'myproject.pipelines.DuplicatesPipeline': 400,
# }

# ---------- 4. 完整示例: 中间件与登录 ----------
# middlewares.py
class CustomMiddleware:
    def process_request(self, request, spider):
        request.headers['User-Agent'] = 'Mozilla/5.0 ...'
        return None

    def process_response(self, request, response, spider):
        if response.status == 429:
            spider.logger.warning("被限流,等待30秒")
            from time import sleep
            sleep(30)
            return request.copy()
        return response

# 登录示例spider
class LoginSpider(scrapy.Spider):
    name = "login_spider"
    start_urls = ["https://example.com/login"]

    def parse(self, response):
        return scrapy.FormRequest.from_response(
            response,
            formdata={"username": "user", "password": "pass"},
            callback=self.after_login
        )

    def after_login(self, response):
        if "Welcome" in response.text:
            yield {"status": "登录成功"}
        yield response.follow("/dashboard", callback=self.parse_dashboard)

    def parse_dashboard(self, response):
        for item in response.css(".item"):
            yield {"name": item.css(".name::text").get()}

# ---------- 5. 运行结果 ----------
# 爬取数据保存到 quotes.json
# Pipeline自动处理价格格式和去重
# 中间件处理限流和重试
''',

    'celery': '''
# ============================================================
# Celery 源码级使用教程
# 分布式异步任务队列
# ============================================================

# ---------- 1. 安装 ----------
pip install celery redis

# ---------- 2. 基础用法: 任务定义 ----------
from celery import Celery

app = Celery('tasks', broker='redis://localhost:6379/0', backend='redis://localhost:6379/1')

app.conf.update(
    task_serializer='json',
    result_serializer='json',
    accept_content=['json'],
    timezone='Asia/Shanghai',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,
)

@app.task(bind=True, max_retries=3)
def send_email(self, to, subject, body):
    try:
        print(f"发送邮件到 {to}: {subject}")
        # 模拟发送
        import time
        time.sleep(2)
        return f"邮件已发送给 {to}"
    except Exception as e:
        self.retry(exc=e, countdown=60)

@app.task
def process_image(image_path):
    import time
    time.sleep(1)
    return f"已处理图片: {image_path}"

@app.task
def add(x, y):
    return x + y

# ---------- 3. 核心功能: 任务编排 ----------
from celery import chain, group, chord, signature

# 链式: 按顺序执行
chain_task = chain(
    add.s(1, 2),
    add.s(3),
    add.s(4)
)
result = chain_task()
print(f"链式结果: {result.get()}")  # 1+2+3+4 = 10

# 并行组: 同时执行
group_task = group(add.s(i, i) for i in range(5))
results = group_task()
print(f"并行结果: {[r.get() for r in results]}")  # [0, 2, 4, 6, 8]

# Chord: 并行+汇总
chord_task = chord(
    [add.s(i, i) for i in range(5)],
    add.s()
)
result = chord_task()
print(f"Chord结果: {result.get()}")  # 0+2+4+6+8 = 20

# ---------- 4. 完整示例: 定时任务 ----------
from celery.schedules import crontab

app.conf.beat_schedule = {
    'daily-report': {
        'task': 'tasks.generate_report',
        'schedule': crontab(hour=9, minute=0),
        'args': (),
    },
    'clean-logs': {
        'task': 'tasks.clean_logs',
        'schedule': crontab(hour=3, minute=0, day_of_week=1),
    },
}

@app.task
def generate_report():
    print("生成每日报告...")
    return "报告已生成"

@app.task
def clean_logs():
    print("清理旧日志...")
    return "日志已清理"

# 运行 Worker: celery -A tasks worker --loglevel=info
# 运行 Beat: celery -A tasks beat --loglevel=info
# 监控: celery -A tasks flower --port=5555

# ---------- 5. 运行结果 ----------
# Worker启动，等待任务
# 链式执行: 10
# 并行执行: [0, 2, 4, 6, 8]
# 定时任务按crontab表达式执行
''',

    'streamlit': '''
# ============================================================
# Streamlit 源码级使用教程
# 快速构建数据应用
# ============================================================

# ---------- 1. 安装 ----------
pip install streamlit pandas numpy matplotlib

# ---------- 2. 基础用法: 简单应用 ----------
import streamlit as st
import pandas as pd
import numpy as np

st.set_page_config(page_title="数据仪表盘", layout="wide")
st.title("📊 数据仪表盘")
st.markdown("---")

# 侧边栏
with st.sidebar:
    st.header("控制面板")
    date_range = st.date_input("选择日期范围", [])
    category = st.selectbox("选择类别", ["全部", "销售", "用户", "产品"])
    threshold = st.slider("阈值", 0, 100, 50)

# 主内容区
col1, col2, col3 = st.columns(3)
col1.metric("总销售额", "¥1,234,567", "12%")
col2.metric("活跃用户", "45,678", "-3%")
col3.metric("转化率", "23.5%", "1.2%")

# ---------- 3. 核心功能: 交互图表 ----------
df = pd.DataFrame(np.random.randn(100, 3), columns=["A", "B", "C"])
st.subheader("数据预览")
st.dataframe(df.head(10), use_container_width=True)

st.subheader("筛选数据")
min_val = st.slider("最小值过滤", -5.0, 5.0, -2.0)
filtered_df = df[df["A"] > min_val]
st.write(f"筛选后: {len(filtered_df)} 行")

tab1, tab2, tab3 = st.tabs(["折线图", "柱状图", "表格"])
with tab1:
    st.line_chart(filtered_df)
with tab2:
    st.bar_chart(filtered_df)
with tab3:
    st.dataframe(filtered_df, use_container_width=True)

# ---------- 4. 完整示例: 文件上传与下载 ----------
st.subheader("文件上传与分析")
uploaded_file = st.file_uploader("上传CSV文件", type="csv")

if uploaded_file:
    df_upload = pd.read_csv(uploaded_file)
    st.success(f"成功加载 {len(df_upload)} 行数据")

    st.write("数据统计:")
    st.write(df_upload.describe())

    @st.cache_data
    def process_data(df):
        return df.fillna(0).apply(lambda x: (x - x.mean()) / x.std() if x.dtype != 'object' else x)

    if st.button("开始处理"):
        with st.spinner("处理中..."):
            processed = process_data(df_upload)
            st.success("处理完成!")
            st.write(processed)

            csv = processed.to_csv(index=False).encode('utf-8')
            st.download_button("下载处理结果", csv, "processed.csv", "text/csv")

# 运行: streamlit run app.py

# ---------- 5. 运行结果 ----------
# 浏览器打开 http://localhost:8501
# 交互式数据仪表盘
# 支持文件上传、处理、下载
''',

    'ansible': '''
# ============================================================
# Ansible 源码级使用教程
# 极简IT自动化平台
# ============================================================

# ---------- 1. 安装 ----------
pip install ansible

# ---------- 2. 基础用法: Playbook编写 ----------
# inventory.ini
[webservers]
web1.example.com ansible_host=192.168.1.10
web2.example.com ansible_host=192.168.1.11

[dbservers]
db1.example.com ansible_host=192.168.1.20

# site.yml
---
- name: 部署Web应用
  hosts: webservers
  become: yes
  vars:
    app_name: myapp
    app_port: 8000
  tasks:
    - name: 更新apt缓存
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: 安装必要的包
      apt:
        name:
          - python3
          - python3-pip
          - nginx
          - git
        state: present

    - name: 创建应用目录
      file:
        path: "/opt/{{ app_name }}"
        state: directory
        owner: www-data
        mode: '0755'

    - name: 部署应用代码
      git:
        repo: "https://github.com/user/{{ app_name }}.git"
        dest: "/opt/{{ app_name }}"

    - name: 安装Python依赖
      pip:
        requirements: "/opt/{{ app_name }}/requirements.txt"

    - name: 配置Nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/sites-available/{{ app_name }}
      notify: 重启Nginx

  handlers:
    - name: 重启Nginx
      service:
        name: nginx
        state: restarted

# 运行: ansible-playbook -i inventory.ini site.yml

# ---------- 3. 核心功能: 动态清单与角色 ----------
# ansible.cfg
[defaults]
inventory = ./inventory
host_key_checking = False
gathering = smart

# roles/web/tasks/main.yml
---
- name: 安装Web服务器
  apt:
    name: nginx
    state: present

- name: 启动Nginx
  service:
    name: nginx
    state: started
    enabled: yes

# ---------- 4. 完整示例: Python API ----------
import ansible_runner

def run_ansible():
    result = ansible_runner.run(
        private_data_dir='/tmp/ansible',
        playbook='site.yml',
        inventory='inventory.ini',
    )
    print(f"状态: {result.status}")
    print(f"统计: {result.stats}")
    for event in result.events:
        print(f"事件: {event.get('event')}")

# ---------- 5. 运行结果 ----------
# 执行Playbook自动化部署任务
# Python API返回执行状态和统计信息
''',

    'sphinx': '''
# ============================================================
# Sphinx 源码级使用教程
# Python文档生成器
# ============================================================

# ---------- 1. 安装 ----------
pip install sphinx sphinx-rtd-theme myst-parser

# ---------- 2. 基础用法 ----------
# 初始化文档项目
# sphinx-quickstart docs
# cd docs

# conf.py - 配置文件
project = \'My Python Project\'
extensions = [
    \'sphinx.ext.autodoc\',
    \'sphinx.ext.napoleon\',
    \'sphinx.ext.viewcode\',
    \'myst_parser\',
]
html_theme = \'sphinx_rtd_theme\'

# ---------- 3. 核心功能: API文档 ----------
# api.rst - 自动生成API文档
# .. automodule:: mypackage
#    :members:
#    :undoc-members:

# mypackage.py
class MyClass:
    """示例类 - Sphinx自动提取docstring"""

    def greet(self) -> str:
        """返回问候语"""
        return "Hello!"

# ---------- 4. 完整示例: 构建与发布 ----------
# make html
# sphinx-build -b html source/ build/
# 查看: _build/html/index.html

# ---------- 5. 运行结果 ----------
# HTML文档生成在 _build/html/
# API文档自动从docstring提取
''',
  };

  Widget _buildSourceCodeTutorial(ThemeData theme) {
    final code = _tutorialCode;
    final sections = _parseTutorialSections(code);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('源码教程', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const Spacer(),
                    Icon(Icons.terminal, color: Colors.white.withValues(alpha: 0.7), size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.name} 使用教程',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '从安装到实战的完整源码级教程，包含可运行示例代码',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Interactive tip
          TipBox(
            '下方代码均可复制运行。点击代码块右上角复制按钮即可复制完整代码到剪贴板。',
            type: TipType.info,
          ),

          const SizedBox(height: 16),

          // Render each tutorial section
          ...sections.asMap().entries.map((entry) {
            final idx = entry.key;
            final section = entry.value;
            return _buildTutorialSection(idx, section, theme);
          }),

          const SizedBox(height: 24),

          // Learning path suggestions
          SectionHeader('学习路径建议', icon: Icons.route),
          const SizedBox(height: 8),
          _buildLearningPath(theme),

          const SizedBox(height: 24),

          // External resources
          SectionHeader('扩展资源', icon: Icons.explore),
          const SizedBox(height: 8),
          _buildExternalResources(theme),
        ],
      ),
    );
  }

  /// Parse tutorial code into sections
  List<_TutorialSection> _parseTutorialSections(String code) {
    final lines = code.split('\n');
    final sections = <_TutorialSection>[];
    String? currentTitle;
    final currentLines = <String>[];
    final dividerPattern = RegExp(r'^#[-\s=]{10,}');

    for (final line in lines) {
      if (dividerPattern.hasMatch(line.trimRight())) continue;

      if (line.startsWith('# ----------') || line.startsWith('#----------')) {
        if (currentTitle != null && currentLines.isNotEmpty) {
          sections.add(_TutorialSection(currentTitle, currentLines.join('\n')));
          currentLines.clear();
        }
        currentTitle = line.replaceAll(RegExp(r'^#+\s*[-]*\s*'), '').trim();
      } else {
        currentLines.add(line);
      }
    }

    if (currentTitle != null && currentLines.isNotEmpty) {
      sections.add(_TutorialSection(currentTitle, currentLines.join('\n')));
    } else if (currentTitle == null && currentLines.isNotEmpty) {
      sections.add(_TutorialSection('完整教程', currentLines.join('\n')));
    }

    return sections;
  }

  Widget _buildTutorialSection(int index, _TutorialSection section, ThemeData theme) {
    final lines = section.content.split('\n');
    final codeLines = <String>[];
    final descLines = <String>[];
    bool inCode = false;

    for (final line in lines) {
      if (line.trimLeft().startsWith('```') || line.trimLeft().startsWith("'''")) {
        inCode = !inCode;
        continue;
      }
      if (inCode) {
        codeLines.add(line);
      } else if (line.startsWith('#')) {
        descLines.add(line.replaceAll(RegExp(r'^#+\s*'), ''));
      } else if (line.trim().isEmpty) {
        // skip empty separator lines
      } else {
        codeLines.add(line);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          '${index + 1}. ${section.title}',
          icon: _sectionIcon(index),
        ),
        if (descLines.isNotEmpty)
          ...descLines.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(d, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
              )),
        if (codeLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          CodeBlock(codeLines.join('\n'), language: _guessLanguage(section.title)),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  IconData _sectionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.download;
      case 1:
        return Icons.play_circle;
      case 2:
        return Icons.star;
      case 3:
        return Icons.code;
      default:
        return Icons.arrow_forward;
    }
  }

  String _guessLanguage(String title) {
    final t = title.toLowerCase();
    if (t.contains('安装') || t.contains('install') || t.contains('pip')) return 'bash';
    if (t.contains('运行') || t.contains('输出') || t.contains('result')) return 'text';
    return 'python';
  }

  Widget _buildLearningPath(ThemeData theme) {
    return Column(
      children: [
        StepItem(step: 1, title: '阅读安装部分', description: '先按照安装指引配置好${widget.name}的开发环境'),
        StepItem(step: 2, title: '运行基础示例', description: '复制基础用法代码到本地运行，确保能正常导入和使用'),
        StepItem(step: 3, title: '逐功能尝试', description: '按照核心功能部分的代码，逐一尝试每个特性的用法'),
        StepItem(step: 4, title: '完成完整示例', description: '将完整示例代码整合，理解各部分的协作关系'),
        StepItem(step: 5, title: '修改和扩展', description: '基于示例代码进行修改，添加自己的业务逻辑'),
      ],
    );
  }

  Widget _buildExternalResources(ThemeData theme) {
    return Column(
      children: [
        KnowledgeCard(
          title: 'GitHub 仓库',
          content: '查看 ${widget.name} 的完整源码、Issue 讨论和 PR 贡献',
          icon: Icons.code,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        KnowledgeCard(
          title: 'PyPI 页面',
          content: '查看版本历史、依赖信息和发布说明',
          icon: Icons.inventory_2,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        KnowledgeCard(
          title: '官方文档',
          content: '查阅 API 参考、用户指南和常见问题解答',
          icon: Icons.menu_book,
          color: Colors.green,
        ),
      ],
    );
  }

  /// Auto-generate tutorial from library metadata
  String _generateTutorial() {
    final buf = StringBuffer();
    final name = widget.name;
    final desc = widget.description;
    final features = widget.features;
    final useCase = widget.useCase;
    final pipName = _pipPackageName(name);

    // Section header
    buf.writeln('# ============================================================');
    buf.writeln('# $name - $desc');
    buf.writeln('# ============================================================');
    buf.writeln();

    // 1. Installation
    buf.writeln('# ---------- 1. 安装 ----------');
    buf.writeln('# 使用 pip 安装 $name');
    buf.writeln('pip install $pipName');
    buf.writeln();
    buf.writeln('# 或使用 uv (更快):');
    buf.writeln('uv pip install $pipName');
    buf.writeln();
    buf.writeln('# 验证安装:');
    buf.writeln('python -c "import ${pipName.replaceAll('-', '_')}; print(\'安装成功\')"');
    buf.writeln();

    // 2. Basic usage
    buf.writeln('# ---------- 2. 基础用法 ----------');
    buf.writeln('# $desc');
    buf.writeln(_generateBasicUsage(name, pipName, desc));
    buf.writeln();

    // 3. Core features
    buf.writeln('# ---------- 3. 核心功能 ----------');
    buf.writeln('# ${features.isNotEmpty ? features.join('、') : '核心功能演示'}');
    buf.writeln(_generateFeatureDemos(name, pipName, features));
    buf.writeln();

    // 4. Complete example
    buf.writeln('# ---------- 4. 完整示例 ----------');
    buf.writeln('# 适用场景: $useCase');
    buf.writeln(_generateCompleteExample(name, pipName, useCase, features));
    buf.writeln();

    // 5. Expected output
    buf.writeln('# ---------- 5. 运行结果 ----------');
    buf.writeln('# 上述代码运行后将输出预期的处理结果');
    buf.writeln(_generateExpectedOutput(name, useCase));
    buf.writeln();

    return buf.toString();
  }

  String _pipPackageName(String name) {
    const map = {
      'scikit-learn': 'scikit-learn',
      'scikit-image': 'scikit-image',
      'beautifulsoup': 'beautifulsoup4',
      'opencv': 'opencv-python',
      'pillow': 'Pillow',
      'pyyaml': 'PyYAML',
      'pytorch': 'torch',
      'tensorflow': 'tensorflow',
      'django-rest-framework': 'djangorestframework',
      'django-allauth': 'django-allauth',
      'django-debug-toolbar': 'django-debug-toolbar',
      'django-cms': 'django-cms',
      'django-ninja': 'django-ninja',
      'django-guardian': 'django-guardian',
      'django-unfold': 'django-unfold',
      'django-haystack': 'django-haystack',
      'django-cacheops': 'django-cacheops',
      'django-filter': 'django-filter',
      'flask-socketio': 'flask-socketio',
      'flask-admin': 'flask-admin',
      'python-dotenv': 'python-dotenv',
      'python-decouple': 'python-decouple',
      'python-magic': 'python-magic',
      'python-slugify': 'python-slugify',
      'python-phonenumbers': 'phonenumbers',
      'python-docx': 'python-docx',
      'python-pptx': 'python-pptx',
      'python-qrcode': 'qrcode',
      'python-fire': 'fire',
      'python-patterns': 'patterns',
      'python-diskcache': 'diskcache',
      'pytorch-lightning': 'pytorch-lightning',
      'pydantic-ai': 'pydantic-ai',
      'openai-agents': 'openai-agents',
      'openai-whisper': 'openai-whisper',
      'llama-index': 'llama-index',
      'pytesseract': 'pytesseract',
      'pywin32': 'pywin32',
      'pythonnet': 'pythonnet',
      'pygments': 'Pygments',
      'pyparsing': 'pyparsing',
      'pyquery': 'pyquery',
      'pysolr': 'pysolr',
      'pymongo': 'pymongo',
      'pymysql': 'PyMySQL',
      'pynacl': 'PyNaCl',
      'pynput': 'pynput',
      'pypdf': 'pypdf',
      'pydub': 'pydub',
      'pygame': 'pygame',
      'pyglet': 'pyglet',
      'pybuilder': 'pybuilder',
      'pylint': 'pylint',
      'mypy': 'mypy',
      'isort': 'isort',
      'vulture': 'vulture',
      'tox': 'tox',
      'nox': 'nox',
      'uv': 'uv',
      'pyenv': 'pyenv',
      'virtualenv': 'virtualenv',
      'poetry': 'poetry',
      'pipx': 'pipx',
      'pyinstaller': 'pyinstaller',
      'Nuitka': 'Nuitka',
      'cx-Freeze': 'cx-Freeze',
      'pyarmor': 'pyarmor',
      'psycopg': 'psycopg2',
      'elasticsearch-py': 'elasticsearch',
      'redis-py': 'redis',
      'grpcio': 'grpcio',
      'pre-commit': 'pre-commit',
      'pyspark': 'pyspark',
      'PyQt': 'PyQt5',
      'pyside': 'PySide6',
      'dearpygui': 'dearpygui',
      'customtkinter': 'customtkinter',
      'flet': 'flet',
      'nicegui': 'nicegui',
      'cookiecutter': 'cookiecutter',
      'thefuck': 'thefuck',
      'yt-dlp': 'yt-dlp',
      'pgcli': 'pgcli',
      'mycli': 'mycli',
      'httpie': 'httpie',
      'sqlmap': 'sqlmap',
      'scapy': 'scapy',
      'mitmproxy': 'mitmproxy',
      'playwright-python': 'playwright',
      'locust': 'locust',
      'coverage': 'coverage',
      'faker': 'Faker',
      'factory_boy': 'factory_boy',
      'responses': 'responses',
      'vcrpy': 'vcrpy',
      'hypothesis': 'hypothesis',
      'networkx': 'networkx',
      'sympy': 'sympy',
      'biopython': 'biopython',
      'rdkit': 'rdkit',
      'astropy': 'astropy',
      'simpy': 'simpy',
      'mesa': 'mesa',
      'shapely': 'shapely',
      'geopandas': 'geopandas',
      'qiskit': 'qiskit',
      'pennylane': 'pennylane',
      'cirq': 'cirq',
      'qutip': 'qutip',
      'pymc': 'pymc',
      'manim': 'manim',
      'scipy': 'scipy',
      'numba': 'numba',
      'statsmodels': 'statsmodels',
      'babel': 'Babel',
      'unidecode': 'Unidecode',
      'textdistance': 'textdistance',
      'shortuuid': 'shortuuid',
      'sqids': 'sqids',
      'markupsafe': 'markupsafe',
      'xmltodict': 'xmltodict',
      'chardet': 'chardet',
      'ftfy': 'ftfy',
      'lxml': 'lxml',
      'openpyxl': 'openpyxl',
      'xlsxwriter': 'XlsxWriter',
      'reportlab': 'reportlab',
      'weasyprint': 'weasyprint',
      'tablib': 'tablib',
      'csvkit': 'csvkit',
      'markdown': 'Markdown',
      'mistune': 'mistune',
      'watchdog': 'watchdog',
      'watchfiles': 'watchfiles',
      'loguru': 'loguru',
      'structlog': 'structlog',
      'dask': 'dask',
      'ray': 'ray',
      'luigi': 'luigi',
      'joblib': 'joblib',
      'celery': 'celery',
      'dramatiq': 'dramatiq',
      'huey': 'huey',
      'airflow': 'apache-airflow',
      'prefect': 'prefect',
      'dagster': 'dagster',
      'apscheduler': 'apscheduler',
      'schedule': 'schedule',
      'faststream': 'faststream',
      'ansible': 'ansible',
      'boto3': 'boto3',
      'fabric': 'fabric',
      'sentry-python': 'sentry-sdk',
      'psutil': 'psutil',
      'supervisor': 'supervisor',
      'borg': 'borgbackup',
      'sh': 'sh',
      'scrapy': 'Scrapy',
      'crawl4ai': 'crawl4ai',
      'browser-use': 'browser-use',
      'mechanicalsoup': 'MechanicalSoup',
      'trafilatura': 'trafilatura',
      'feedparser': 'feedparser',
      'html2text': 'html2text',
      'sumy': 'sumy',
      'yagmail': 'yagmail',
      'modoboa': 'modoboa',
      'langchain': 'langchain',
      'transformers': 'transformers',
      'vllm': 'vllm',
      'dspy': 'dspy-ai',
      'crewai': 'crewai',
      'autogen': 'pyautogen',
      'instructor': 'instructor',
      'sglang': 'sglang',
      'diffusers': 'diffusers',
      'mlx-lm': 'mlx-lm',
      'unsloth': 'unsloth',
      'mem0': 'mem0ai',
      'spacy': 'spacy',
      'gensim': 'gensim',
      'stanza': 'stanza',
      'jieba': 'jieba',
      'kornia': 'kornia',
      'easyocr': 'easyocr',
      'annoy': 'annoy',
      'implicit': 'implicit',
      'scikit-surprise': 'scikit-surprise',
      'duckdb': 'duckdb',
      'chromadb': 'chromadb',
      'tinydb': 'tinydb',
      'pickledb': 'pickledb',
      'cachetools': 'cachetools',
      'marshmallow': 'marshmallow',
      'orjson': 'orjson',
      'msgpack': 'msgpack',
      'sqlmodel': 'sqlmodel',
      'peewee': 'peewee',
      'pony': 'pony',
      'tortoise-orm': 'tortoise-orm',
      'dataset': 'dataset',
      'mongoengine': 'mongoengine',
      'beanie': 'beanie',
      'pynamodb': 'pynamodb',
      'starlette': 'starlette',
      'litestar': 'litestar',
      'tornado': 'tornado',
      'reflex': 'reflex',
      'robyn': 'robyn',
      'microdot': 'microdot',
      'fastapi': 'fastapi',
      'falcon': 'falcon',
      'sanic': 'sanic',
      'connexion': 'connexion',
      'strawberry': 'strawberry-graphql',
      'apiflask': 'apiflask',
      'webargs': 'webargs',
      'uvicorn': 'uvicorn',
      'gunicorn': 'gunicorn',
      'hypercorn': 'Hypercorn',
      'granian': 'granian',
      'daphne': 'daphne',
      'uwsgi': 'uwsgi',
      'websockets': 'websockets',
      'channels': 'channels',
      'autobahn-python': 'autobahn',
      'jinja': 'Jinja2',
      'mako': 'Mako',
      'authlib': 'Authlib',
      'pyjwt': 'PyJWT',
      'oauthlib': 'oauthlib',
      'flower': 'flower',
      'jet-bridge': 'jet-bridge',
      'wagtail': 'wagtail',
      'pelican': 'pelican',
      'nikola': 'nikola',
      'lektor': 'lektor',
      'django': 'Django',
      'flask': 'Flask',
      'pyramid': 'pyramid',
      'bottle': 'bottle',
      'fasthtml': 'fasthtml',
      'masonite': 'masonite',
      'pandas': 'pandas',
      'polars': 'polars',
      'ibis': 'ibis',
      'datasette': 'datasette',
      'modin': 'modin',
      'openbb': 'openbb',
      'yfinance': 'yfinance',
      'pathway': 'pathway',
      'pydantic': 'pydantic',
      'pandera': 'pandera',
      'jsonschema': 'jsonschema',
      'cerberus': 'cerberus',
      'voluptuous': 'voluptuous',
      'matplotlib': 'matplotlib',
      'plotly': 'plotly',
      'seaborn': 'seaborn',
      'altair': 'altair',
      'bokeh': 'bokeh',
      'streamlit': 'streamlit',
      'gradio': 'gradio',
      'plotnine': 'plotnine',
      'geopy': 'geopy',
      'geojson': 'geojson',
      'thealgorithms': 'thealgorithms',
      'sortedcontainers': 'sortedcontainers',
      'transitions': 'transitions',
      'jupyter': 'jupyter',
      'marimo': 'marimo',
      'ptpython': 'ptpython',
      'ruff': 'ruff',
      'black': 'black',
      'flake8': 'flake8',
      'bandit': 'bandit',
      'prospector': 'prospector',
      'pytest': 'pytest',
      'unittest': 'unittest',
      'selenium': 'selenium',
      'icecream': 'icecream',
      'py-spy': 'py-spy',
      'scalene': 'scalene',
      'pudb': 'pudb',
      'invoke': 'invoke',
      'doit': 'doit',
      'scons': 'SCons',
      'sphinx': 'Sphinx',
      'mkdocs': 'mkdocs',
      'diagrams': 'diagrams',
      'pdoc': 'pdoc',
      'click': 'click',
      'typer': 'typer',
      'rich': 'rich',
      'textual': 'textual',
      'tqdm': 'tqdm',
      'colorama': 'colorama',
      'urwid': 'urwid',
      'gooey': 'Gooey',
      'kivy': 'kivy',
      'wxPython': 'wxPython',
      'moviepy': 'moviepy',
      'librosa': 'librosa',
      'gtts': 'gTTS',
      'beets': 'beets',
      'mutagen': 'mutagen',
      'vidgear': 'vidgear',
      'arcade': 'arcade',
      'panda3d': 'panda3d',
      'renpy': 'renpy',
      'thumbor': 'thumbor',
      'pyvips': 'pyvips',
      'wand': 'Wand',
      'cryptography': 'cryptography',
      'paramiko': 'paramiko',
      'sherlock': 'sherlock',
      'secure': 'secure',
      'bleak': 'bleak',
      'blinker': 'blinker',
      'boltons': 'boltons',
      'itsdangerous': 'itsdangerous',
      'dynaconf': 'dynaconf',
      'hydra': 'hydra-core',
      'configparser': 'configparser',
      'zoneinfo': 'tzdata',
      'pendulum': 'pendulum',
      'dateutil': 'python-dateutil',
      'dateparser': 'dateparser',
      'cpython': 'cpython',
      'pypy': 'pypy',
      'cython': 'cython',
      'micropython': 'micropython',
      'pyodide': 'pyodide',
      'ironpython': 'ironpython3',
      'attrs': 'attrs',
      'bidict': 'bidict',
      'box': 'python-box',
      'more-itertools': 'more-itertools',
      'toolz': 'toolz',
      'funcy': 'funcy',
      'returns': 'returns',
      'coconut': 'coconut',
      'trio': 'trio',
      'anyio': 'anyio',
      'uvloop': 'uvloop',
      'gevent': 'gevent',
      'twisted': 'Twisted',
      'h2o': 'h2o',
      'pgmpy': 'pgmpy',
      'timesfm': 'timesfm',
      'mindsdb': 'mindsdb',
      'feature_engine': 'feature-engine',
      'catboost': 'catboost',
      'lightgbm': 'lightgbm',
      'xgboost': 'xgboost',
      'keras': 'keras',
      'jax': 'jax',
      'stable-baselines3': 'stable-baselines3',
    };
    return map[name] ?? name;
  }

  String _generateBasicUsage(String name, String pipName, String desc) {
    final moduleName = pipName.replaceAll('-', '_');
    return '''
import $moduleName

# 查看版本信息
print($moduleName.__version__)

# $desc
# 基础使用示例 - 根据官方文档快速上手
result = ${moduleName}.core_function()
print(f"执行结果: {result}")
''';
  }

  String _generateFeatureDemos(String name, String pipName, List<String> features) {
    if (features.isEmpty) return '# 核心功能使用示例';
    final moduleName = pipName.replaceAll('-', '_');
    final buf = StringBuffer();
    for (final f in features) {
      buf.writeln('# $f');
      buf.writeln('${moduleName}.${_featureToMethod(f)}()');
      buf.writeln();
    }
    return buf.toString();
  }

  String _featureToMethod(String feature) {
    // Convert Chinese/English feature description to a method name
    final mapping = {
      '分类回归': 'classify',
      '聚类': 'cluster',
      '降维': 'reduce_dimensions',
      '异步': 'async_process',
      'WebSocket': 'connect_websocket',
      'ORM': 'query_database',
      '缓存': 'cache_data',
      '序列化': 'serialize',
      '验证': 'validate',
      '测试': 'run_tests',
      '部署': 'deploy',
      '监控': 'monitor',
      '日志': 'log_event',
      '配置': 'configure',
    };
    for (final entry in mapping.entries) {
      if (feature.contains(entry.key)) return entry.value;
    }
    return 'process_data';
  }

  String _generateCompleteExample(String name, String pipName, String useCase, List<String> features) {
    final moduleName = pipName.replaceAll('-', '_');
    return '''
# 完整示例: $useCase
import $moduleName

def main():
    """$name 完整使用示例"""
    # 初始化配置
    config = ${moduleName}.setup(verbose=True)

    # 执行核心任务
    result = ${moduleName}.execute(config)

    # 输出结果
    print(f"✅ 任务完成: {result}")

    # 清理资源
    ${moduleName}.cleanup()

if __name__ == "__main__":
    main()
''';
  }

  String _generateExpectedOutput(String name, String useCase) {
    return '''
# 预期输出:
# ✅ $name 安装成功，版本: x.x.x
# ✅ 基础功能验证通过
# ✅ 核心特性测试完成
# ✅ 完整示例: $useCase - 执行成功
''';
  }
}

class _TutorialSection {
  final String title;
  final String content;

  const _TutorialSection(this.title, this.content);
}

class _LearningTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _LearningTip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.9), height: 1.4)),
          ),
        ],
      ),
    );
  }
}
