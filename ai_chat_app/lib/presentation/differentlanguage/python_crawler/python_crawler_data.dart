import 'package:flutter/material.dart';

class CrawlerProject {
  final String name;
  final String description;
  final String difficulty;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final String overview;
  final String whyLearn;
  final List<CrawlerTutorialSection> sections;

  const CrawlerProject({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.icon,
    required this.color,
    required this.tags,
    required this.overview,
    required this.whyLearn,
    required this.sections,
  });
}

class CrawlerTutorialSection {
  final String title;
  final String content;
  final IconData icon;

  const CrawlerTutorialSection({
    required this.title,
    required this.content,
    required this.icon,
  });
}

final List<CrawlerProject> crawlerProjects = [
  // ============================================================
  // 项目1: Requests + BeautifulSoup — 静态页面爬虫入门
  // ============================================================
  CrawlerProject(
    name: 'Requests + BeautifulSoup',
    description: '从零开始学习网页爬虫，使用最流行的HTTP库和HTML解析库，爬取静态网页数据',
    difficulty: '入门',
    icon: Icons.web,
    color: const Color(0xFF4CAF50),
    tags: ['入门', 'HTTP请求', 'HTML解析', '静态页面'],
    overview: '''
Requests 是 Python 下载量最高的 HTTP 库，BeautifulSoup 是最流行的 HTML 解析库。
两者结合是爬虫入门的最佳选择——简单、直观、功能强大。

本教程将从零开始，带你一步步学会：
- 发送 HTTP 请求获取网页内容
- 使用 CSS 选择器解析 HTML
- 处理编码、超时、重试等常见问题
- 爬取真实网站数据并保存为 CSV/JSON''',
    whyLearn: '''
1. Python 下载量最高的库组合，社区支持最强大
2. API 设计极其人性化，几行代码就能完成一个爬虫
3. 适合爬取新闻、博客、电商商品列表等静态页面
4. 学习曲线平缓，是爬虫入门的最佳起点''',
    sections: [
      CrawlerTutorialSection(
        title: '1. 环境准备与安装',
        icon: Icons.download,
        content: r'''
## 安装 Python

首先确认你的电脑已经安装了 Python 3.8 或更高版本：

```bash
python --version
# 应该输出类似: Python 3.11.0
```

**为什么需要 Python 3.8+？**
- Python 3.8 引入了 `f-string` 的 `=` 调试语法（如 `f"{x=}"`），调试更方便
- 3.10+ 引入了 `match-case` 模式匹配，写爬虫逻辑更清晰
- 大部分现代库已放弃对 3.7 以下版本的支持

## 安装所需库

打开终端，依次执行：

```bash
pip install requests beautifulsoup4 lxml pandas
```

各库的**职责分工**（这是爬虫架构的核心思想：**关注点分离**）：
- **requests** — 只负责"获取"：发送 HTTP 请求，拿到服务器返回的 HTML 字符串
- **beautifulsoup4** — 只负责"解析"：把 HTML 字符串变成可查询的树结构
- **lxml** — BeautifulSoup 的高性能"解析引擎"。BS4 支持多种解析器，
  lxml 是其中最快的（C 语言实现），比 Python 内置的 html.parser 快 5-10 倍
- **pandas** — 只负责"存储"：把爬到的数据整理成表格，导出 CSV/Excel

**优势对比：为什么选择这个组合？**

| 方案 | 获取 | 解析 | 适合场景 |
|------|------|------|---------|
| requests + BS4 | 简单稳定 | 功能全面 | 静态网页、入门学习 |
| urllib + BS4 | 标准库零依赖 | 功能全面 | 不能装第三方库的环境 |
| requests + 正则 | 简单稳定 | 极快 | 简单文本提取（不推荐维护） |
| httpx + BS4 | 支持异步+HTTP/2 | 功能全面 | 需要异步高并发 |

> **最佳实践：** 爬虫领域不追求"一个库搞定一切"，而是用每个库做它最擅长的事。
> requests 负责网络、BS4 负责解析、pandas 负责存储——这是经典的 Unix 哲学在爬虫中的体现。

## 验证安装

```python
# 验证所有依赖是否正确安装
# 每个 import 都会触发模块加载，如果库不存在会抛出 ImportError
import requests        # HTTP 请求库
import bs4             # BeautifulSoup 的主模块
import pandas as pd    # 数据分析库，as pd 是社区约定俗成的别名

# __version__ 是 Python 包的规范属性，用于声明版本号
# 生产环境中建议打印版本号，方便排查"在我机器上能跑"的问题
print("requests 版本:", requests.__version__)
print("BeautifulSoup 版本:", bs4.__version__)
print("pandas 版本:", pd.__version__)
print("所有库安装成功！")
```

**为什么用 `import pandas as pd`？**
这是 Python 数据科学社区的**约定俗成**。就像 `import numpy as np`，目的是减少打字量。
在团队协作中，使用约定的别名能让代码一眼就被理解。
''',
      ),
      CrawlerTutorialSection(
        title: '2. 第一个爬虫：获取网页标题',
        icon: Icons.play_circle,
        content: r'''
## 目标

爬取 http://quotes.toscrape.com 网站的页面标题和第一条名言。

> **选这个网站的原因：** quotes.toscrape.com 是专门为爬虫练习设计的"沙盒"网站。
> 它有清晰稳定的 HTML 结构、支持翻页、不会封 IP，是学习爬虫的完美起点。
> **永远先在"沙盒"上练习，再去爬真实网站。**

## 完整代码（逐行详解版）

```python
# ========================================
# 第一步：导入需要的库
# ========================================
import requests  # 发送 HTTP 请求（GET/POST），相当于"浏览器"
from bs4 import BeautifulSoup  # 解析 HTML，相当于"眼睛"

# ========================================
# 第二步：发送请求，获取网页内容
# ========================================
url = "http://quotes.toscrape.com/"
# 用变量存 URL 而非直接写死字符串——这是好习惯
# 好处1：后续改 URL 只需改一处
# 好处2：变量名本身就是文档（"这个 URL 是干什么的"）

response = requests.get(url)
# requests.get() 内部做了很多事：
#   1. DNS 解析（把域名变成 IP）
#   2. 建立 TCP 连接（三次握手）
#   3. 发送 HTTP GET 请求行 + 请求头
#   4. 接收服务器响应（状态行 + 响应头 + 响应体）
#
# 返回的 response 对象包含了所有响应信息

# ========================================
# 第三步：检查请求是否成功
# ========================================
# HTTP 状态码：
#   200 = 成功（OK）
#   301/302 = 重定向
#   403 = 禁止访问（反爬拦截）
#   404 = 页面不存在
#   429 = 请求太频繁（被限流）
#   500 = 服务器内部错误
print(f"状态码: {response.status_code}")

# 查看服务器返回的编码声明
# 如果 encoding 是 ISO-8859-1 但实际内容是 UTF-8，会出现乱码
print(f"编码: {response.encoding}")

# ========================================
# 第四步：检查请求是否真正成功
# ========================================
# 为什么不用 if response.status_code == 200？
# 因为 raise_for_status() 更安全——它会自动检查所有 4xx/5xx 错误
# 而且会抛出包含具体错误信息的异常，比手动判断更全面
response.raise_for_status()

# ========================================
# 第五步：用 BeautifulSoup 解析 HTML
# ========================================
# 第二个参数指定底层解析引擎：
#   'lxml'       — 最快（C语言实现），推荐生产环境使用
#   'html.parser' — Python 内置，不需要额外安装，但较慢
#   'html5lib'   — 最接近浏览器行为，但最慢
soup = BeautifulSoup(response.text, 'lxml')
# response.text vs response.content：
#   .text    → 按 encoding 解码后的字符串，用于 HTML 解析
#   .content → 原始字节，用于图片/PDF 等二进制内容

# ========================================
# 第六步：提取数据
# ========================================

# 方式A：find() — 返回第一个匹配的元素
# 参数：标签名 + 属性过滤条件
# class 是 Python 保留字，所以 BS4 用 class_ 代替
title = soup.find('title')
# title 是一个 Tag 对象，包含标签的所有信息
print(f"页面标题: {title.text}")  # .text 获取标签内的文本内容

# 方式B：find() + 类名过滤 — 精确查找
first_quote = soup.find('span', class_='text')
# 这里的逻辑：找"class 属性为 text 的 span 标签"
# BS4 会自动匹配 class 的一部分（多值 class 也能匹配）
first_author = soup.find('small', class_='author')

# 防御性编程：永远检查 find() 的结果是否为空
# 因为网页结构可能随时变化，不能假设元素一定存在
if first_quote and first_author:
    print(f"第一条名言: {first_quote.text}")
    print(f"作者: {first_author.text}")
else:
    print("未找到名言数据")

# ========================================
# 第七步：提取所有数据（find_all）
# ========================================
# find_all() 返回一个列表，包含所有匹配的元素
# 这是爬虫最常用的方法之一
all_quotes = soup.find_all('span', class_='text')
all_authors = soup.find_all('small', class_='author')

print(f"\n共找到 {len(all_quotes)} 条名言:")

# zip() 将两个列表"拉链式"配对
# enumerate() 同时获取索引和元素
for i, (quote, author) in enumerate(zip(all_quotes, all_authors), 1):
    print(f"{i}. \"{quote.text}\" — {author.text}")
```

## 为什么要这么写？设计思路分析

**思维模型：网络爬虫 = 浏览器 + 眼睛 + 手**

```
浏览器（requests）→ 输入网址，拿到 HTML
       ↓
眼睛（BeautifulSoup）→ 看懂 HTML 的结构
       ↓
手（代码逻辑）→ 取出需要的数据 → 保存
```

这个三层模型是理解所有爬虫的通用框架。无论爬虫多复杂，核心就是这三步。

**为什么用 `response.raise_for_status()` 而不是手动判断？**

```python
# 反模式：手动判断 —— 遗漏了重定向等特殊情况
if response.status_code == 200:
    print("成功")
else:
    print("失败")

# 推荐：raise_for_status() —— 自动覆盖所有非 2xx 状态码
response.raise_for_status()
# 403 → HTTPError: 403 Client Error: Forbidden
# 500 → HTTPError: 500 Server Error: Internal Server Error
# 301 → 不影响（requests 默认会自动跟随重定向）
```

**为什么用 `find()` 而不是正则表达式？**

```python
# 反模式：用正则解析 HTML
import re
# 正则无法处理嵌套标签、属性顺序变化、空格差异
pattern = r'<span class="text">(.+?)</span>'
# 这种正则在家class=""有多个值的时候就会失效

# 推荐：用 BeautifulSoup —— 它理解 HTML 的树结构
soup.find('span', class_='text')
# BS4 正确处理：嵌套标签、属性顺序、多值 class、HTML 实体转义
```

> **黄金法则：永远不要用正则表达式解析 HTML。**
> HTML 是上下文无关文法，正则只能处理正则文法——这是计算机科学的铁律。
> 你看到的所有"用正则爬网页"的教程，都是在埋未来的坑。
''',
      ),
      CrawlerTutorialSection(
        title: '3. 核心技能：CSS 选择器与数据提取',
        icon: Icons.code,
        content: r'''
## BeautifulSoup 的两种查找方式对比

BS4 提供两套 API：**find 系列**（方法调用风格）和 **select 系列**（CSS 选择器风格）。
两者功能等价，选择哪个取决于你的偏好和场景。

### 方式一：find / find_all 方法（适合简单场景）

```python
from bs4 import BeautifulSoup

# 模拟一段 HTML —— 电商商品卡片的结构
html = """
<div class="product">
    <h2 class="title">Python编程书</h2>
    <span class="price">¥59.00</span>
    <span class="rating">4.8分</span>
    <a href="/book/123">查看详情</a>
</div>
"""
soup = BeautifulSoup(html, 'lxml')

# -- find() —— 只返回第一个匹配的 Tag 对象 --
# 适合：确定页面中只有一个目标元素时
title = soup.find('h2', class_='title')
print(title.text)  # Python编程书

# -- find_all() —— 返回包含所有匹配 Tag 的列表 --
# 适合：提取列表数据时（如商品列表、新闻列表）
prices = soup.find_all('span', class_='price')
for price in prices:
    print(price.text)

# -- 获取属性值 —
link = soup.find('a')
print(link['href'])           # 直接用字典语法，但如果属性不存在会抛 KeyError
print(link.get('href'))       # 推荐用法！不存在返回 None 而不会崩溃
print(link.get('data-id', '0'))  # 还可以指定默认值

# -- 遍历子节点 --
product_div = soup.find('div', class_='product')
for child in product_div.children:
    # children 是生成器，惰性遍历，省内存
    print(f"子节点: {child.name if hasattr(child, 'name') else repr(child)}")
```

### 方式二：select / select_one 方法（CSS 选择器，推荐）

```python
# -- select_one() —— 返回第一个匹配（等价于 find） --
title = soup.select_one('h2.title')
# CSS 选择器语法：标签名.类名    （和写 CSS 一样）
print(title.text)

# -- select() —— 返回所有匹配的列表（等价于 find_all） --
items = soup.select('span.price')
for item in items:
    print(item.text)

# CSS 选择器完整语法速查表
soup.select('div')                  # 1. 标签选择器：所有 <div>
soup.select('#main')                # 2. ID选择器：id="main"
soup.select('.price')               # 3. 类选择器：class 含 "price"
soup.select('div.product')          # 4. 复合选择器：class="product" 的 div
soup.select('div > p')              # 5. 子元素选择器：div 的直接子元素 p
soup.select('div p')                # 6. 后代选择器：div 内任意层级的 p
soup.select('a[href]')              # 7. 属性选择器：有 href 属性的 a
soup.select('a[href$=".pdf"]')      # 8. 属性值结尾匹配：PDF 链接
soup.select('a[href*="book"]')      # 9. 属性值包含：链接含 "book"
soup.select('div.quote:nth-child(3)')  # 10. 伪类：第3个子元素
soup.select('span.text::text')      # 11. BS4扩展伪元素：直接提取文本
```

**为什么要用 CSS 选择器（select）而不是 find？**

| 维度 | find/find_all | select/select_one |
|------|-------------|-------------------|
| 语法习惯 | BS4 独有 API | 和前端 CSS 完全一致 |
| 表达能力 | 较有限 | 支持复杂嵌套条件 |
| 可迁移性 | 只有 BS4 支持 | 所有爬虫框架都支持 |
| 学习成本 | 较低（方法调用直观） | 需了解 CSS 选择器语法 |
| **推荐场景** | **简单的标签+类名查找** | **所有正式爬虫项目** |

> **最佳实践：优先使用 select/select_one。**
> 因为 CSS 选择器语法是跨工具的标准——BS4、Scrapy、Playwright、浏览器 DevTools 都用它。
> 学会一套语法，所有爬虫工具都能用。

## 常用提取方法汇总

```python
element.text              # 获取元素内所有文本（含子元素文本）
element.string            # 仅获取元素的直接文本（不含子元素）
element['属性名']          # 直接获取属性（不存在会报错）
element.get('属性名')       # 安全获取属性（不存在返回 None）
element.get('属性名', '默认') # 带默认值
element.attrs             # 返回所有属性的字典 {'href': '...', 'class': [...]}
element.name              # 返回标签名（如 'div', 'span'）
element.parent            # 父元素
element.find_next('div')  # 下一个 div 兄弟元素
```

## 实战：三种常见提取模式

```python
# 模式1："一对一"提取 —— 每个元素只取一个值
# 场景：文章标题、发布时间等单个信息
title = soup.select_one('h1.title')
author = soup.select_one('span.author')
print(f"{title.text} — {author.text}")

# 模式2："列表循环"提取 —— 一组相同结构的元素
# 场景：商品列表、新闻列表、搜索结果
for item in soup.select('div.search-result'):
    # 注意：这里用 item.select_one() 而不是 soup.select_one()
    # 这样才能限定在当前 item 的范围内查找
    title = item.select_one('h3.title').text
    link = item.select_one('a').get('href')
    print(f"标题: {title}, 链接: {link}")

# 模式3："条件筛选"提取 —— 按文本内容筛选
# 场景：找特定文字对应的链接（如"下一页"按钮）
next_link = soup.select_one('a:contains("下一页")')
# 但 CSS 的 :contains() 不是标准伪类，BS4 支持有限
# 更可靠的写法：
for a in soup.select('a'):
    if '下一页' in a.text:
        print(f"下一页链接: {a.get('href')}")
        break
```
''',
      ),
      CrawlerTutorialSection(
        title: '4. 实战：爬取书籍信息并保存为 CSV',
        icon: Icons.star,
        content: r'''
## 目标

爬取 http://books.toscrape.com 的所有书籍信息（书名、价格、评分、库存），
并保存为 CSV 文件。

> **选这个网站的原因：**
> 1. 纯静态 HTML（无 JS 渲染），适合入门
> 2. 有明确的分页结构（50页，每页20本书）
> 3. 数据格式规范，无需处理特殊编码
> 4. 专门为爬虫设计，不用担心法律风险

## 完整代码（带完整注释的生产级写法）

```python
# =====================================================
# 导入依赖
# =====================================================
import requests      # HTTP 客户端：发送请求
from bs4 import BeautifulSoup  # HTML 解析器：提取数据
import pandas as pd  # 数据分析：保存 CSV/Excel
import time          # 时间模块：实现礼貌延迟
from datetime import datetime  # 时间戳：记录爬取时间

# =====================================================
# 核心爬虫函数
# =====================================================
def scrape_books(base_url):
    """
    爬取 books.toscrape.com 的所有书籍

    参数:
        base_url: 网站根地址

    返回:
        list[dict]: 书籍信息列表，每个 dict 包含书名、价格、评分、库存

    设计思路:
        1. 用 while True 循环遍历所有分页
        2. 每页爬取后用 time.sleep() 添加礼貌延迟
        3. 遇到不存在的页（404）自动退出循环
        4. 返回结构化数据，调用者决定如何存储
    """
    all_books = []  # 存储所有书籍的容器
    page = 1        # 当前页码（从第1页开始）

    while True:
        # -- 构造分页 URL --
        # 网站的分页格式是 /catalogue/page-{page}.html
        # 为什么用 f-string 而不是 + 拼接？
        # f-string 更可读，且自动处理类型转换
        url = f"{base_url}/catalogue/page-{page}.html"
        print(f"正在爬取第 {page} 页: {url}")

        # -- 发送请求 --
        # timeout=10 表示最多等待10秒，防止无限等待
        # 这是一个防御性编程的好习惯
        response = requests.get(url, timeout=10)

        # -- 检查响应 --
        # 如果状态码不是 200（比如 404 表示没有更多页了）
        if response.status_code != 200:
            print(f"第 {page} 页不存在（状态码 {response.status_code}），爬取结束")
            break  # 退出 while 循环

        # -- 解析页面 --
        soup = BeautifulSoup(response.text, 'lxml')

        # -- 检查页面是否有数据 --
        books = soup.select('article.product_pod')
        # select() 返回列表，空列表在 Python 中视为 False
        if not books:
            print(f"第 {page} 页没有书籍数据，爬取结束")
            break

        # -- 遍历当前页的每本书 --
        for book in books:
            # ---- 提取书名 ----
            # 书名在 <h3><a title="书名"> 中
            # 为什么用 get('title') 而不是直接访问属性？
            # 因为 get() 在属性不存在时返回 None（可指定默认值）
            # 而直接访问会抛 KeyError 导致程序崩溃
            title_elem = book.select_one('h3 a')
            title = title_elem.get('title', 'N/A') if title_elem else 'N/A'

            # ---- 提取价格 ----
            # 价格如 "£51.77"，需要清理货币符号
            price_elem = book.select_one('p.price_color')
            # 用变量暂存而不是直接 .text 的好处：
            # 可以先检查是否存在再操作
            price_raw = price_elem.text if price_elem else '£0.00'
            # 清理货币符号（更健壮的方式见 Pipeline 部分）
            price = price_raw.replace('£', '').replace('Â', '')

            # ---- 提取评分（从 class 名解析） ----
            # 网站的评分不在文本中，而在 class 名中
            # 如: <p class="star-rating Three"> 表示 3 星
            # 这是常见的"隐性数据"提取场景
            rating_elem = book.select_one('p.star-rating')
            rating = 'N/A'
            if rating_elem:
                # get('class', []) 返回类名列表，如 ['star-rating', 'Three']
                rating_classes = rating_elem.get('class', [])
                # 定义英文数字 → 阿拉伯数字的映射
                rating_map = {
                    'One': 1, 'Two': 2, 'Three': 3,
                    'Four': 4, 'Five': 5
                }
                for cls in rating_classes:
                    if cls in rating_map:
                        rating = rating_map[cls]
                        break  # 找到即退出，提高效率

            # ---- 提取库存状态 ----
            stock_elem = book.select_one('p.instock.availability')
            # .strip() 去除前后空白字符（多余的空格和换行）
            stock = stock_elem.text.strip() if stock_elem else 'N/A'

            # ---- 组装数据 ----
            # 用 dict 存储每条记录，比用 list 更可读
            # key 用中文让 CSV 文件对人类友好
            all_books.append({
                '书名': title,
                '价格': price,
                '评分': rating,
                '库存': stock,
            })

        print(f"  第 {page} 页完成，本页 {len(books)} 本，累计 {len(all_books)} 本")
        page += 1  # 页码加1

        # -- 礼貌延迟 --
        # 为什么需要延迟？
        # 1. 不给对方服务器造成负担（这是爬虫道德规范）
        # 2. 降低被封 IP 的风险
        # 3. 0.5秒是经验值：既不太慢也不太激进
        time.sleep(0.5)

    return all_books

# =====================================================
# 运行爬虫
# =====================================================
if __name__ == '__main__':
    # ---- 爬取数据 ----
    base_url = "http://books.toscrape.com"
    print(f"开始爬取: {base_url}")
    start_time = time.time()

    books = scrape_books(base_url)

    elapsed = time.time() - start_time
    print(f"\n爬取完成！耗时 {elapsed:.1f} 秒，共 {len(books)} 本书")

    # ---- 保存为 CSV ----
    # DataFrame 是 pandas 的核心数据结构，相当于 Excel 表格
    df = pd.DataFrame(books)

    # index=False 不保存行号（否则 CSV 第一列是 0,1,2...）
    # encoding='utf-8-sig' 用 BOM 头的 UTF-8，确保 Excel 双击打开不乱码
    df.to_csv('books.csv', index=False, encoding='utf-8-sig')
    print(f"已保存 books.csv")

    # ---- 保存为 JSON ----
    # orient='records' 每条记录一个独立 JSON 对象
    # force_ascii=False 不把中文转成 \uXXXX 格式
    df.to_json('books.json', orient='records', force_ascii=False)
    print(f"已保存 books.json")

    # ---- 数据预览与统计 ----
    print(f"\n=== 数据概览 ===")
    print(f"总记录数: {len(df)}")
    print(f"列: {', '.join(df.columns)}")
    print(f"\n前5条数据:")
    print(df.head().to_string())

    print(f"\n评分分布:")
    print(df['评分'].value_counts().sort_index())

    print(f"\n价格统计:")
    # pd.to_numeric 把价格转成数字类型才能计算
    # errors='coerce' 把无法转换的值变成 NaN
    prices = pd.to_numeric(df['价格'], errors='coerce')
    print(f"  最低: £{prices.min():.2f}")
    print(f"  最高: £{prices.max():.2f}")
    print(f"  平均: £{prices.mean():.2f}")
```

## 代码设计中的核心决策

**为什么用 while True 而不是 for page in range(1, 100)？**

```python
# 反模式：猜测总页数
for page in range(1, 100):  # 如果只有50页，后面50次请求都是浪费
    ...

# 推荐：不知道总页数，边爬边判断
while True:
    response = requests.get(f"{url}/page-{page}")
    if response.status_code != 200:
        break  # 自然终止
    ...
```

**为什么每本书提取前都检查元素是否存在？**

网页结构会变化。今天 class="price_color"，明天可能改 class="product-price"。
防御性检查让爬虫在遇到变化时**优雅降级**而不是崩溃：

```python
# 脆弱写法：假设元素一定存在
price = book.select_one('p.price_color').text  # 改版后直接崩溃

# 健壮写法：先检查再操作
price_elem = book.select_one('p.price_color')
price = price_elem.text if price_elem else 'N/A'
```

**为什么用 dict 而不是 list 存储一条记录？**

```python
# 反模式：用 list —— 依赖位置，难以维护
row = ['Python编程', 59.00, 5]
# 三个月后：第2个数字是什么来着？是价格还是评分？

# 推荐：用 dict —— 语义明确，自文档化
row = {'书名': 'Python编程', '价格': 59.00, '评分': 5}
# 任何时间看都知道每个值的含义
```

> **最佳实践：让你的代码"自文档化"。** 变量名、函数名、数据结构本身的命名
> 应该让人一眼看懂意图，而不需要额外注释。
''',
      ),
      CrawlerTutorialSection(
        title: '5. 进阶技巧：请求头、会话、重试机制',
        icon: Icons.tune,
        content: r'''
这是爬虫从"玩具"升级到"工具"的关键章节。前几章你学会了爬，这章你学会**稳定地爬**。

## 一、设置请求头（伪装成浏览器）

**为什么需要设置 User-Agent？**

很多网站的服务器会检查 User-Agent 请求头来判断访问者是"人"还是"程序"。
Python requests 默认的 User-Agent 是 `python-requests/2.x.x`，
等于直接告诉对方"我是爬虫"。

```python
import requests

# -- 定义模拟浏览器的请求头 --
# 这些头和真实 Chrome 浏览器发送的完全一致
headers = {
    # User-Agent：告诉服务器"我是什么浏览器"
    # 为什么选这个值？这是 2024年 Chrome 120 在 Windows 10 上的标准 UA
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36'
    ),
    # Accept：告诉服务器"我能处理哪些格式"
    # 这个值来自浏览器默认的 Accept 头
    'Accept': (
        'text/html,application/xhtml+xml,'
        'application/xml;q=0.9,image/webp,*/*;q=0.8'
    ),
    # Accept-Language：告诉服务器"我偏好什么语言"
    # zh-CN 权重最高，zh 次之，en 兜底
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    # Accept-Encoding：告诉服务器"支持什么压缩格式"
    # gzip 可以大幅减少传输数据量（对爬虫有利）
    'Accept-Encoding': 'gzip, deflate, br',
}

# 对比：无请求头 vs 有请求头
# 这个网站会返回你发送的请求头，方便对比效果
response = requests.get('https://httpbin.org/headers', headers=headers)
print("服务器看到的请求头:")
print(response.json()['headers'])
# 可以看到 UA 已经伪装成了 Chrome
```

**优势对比：**

| 策略 | 效果 | 风险 |
|------|------|------|
| 不设 UA（默认） | 暴露爬虫身份 | 高——直接返回403 |
| 固定 UA | 基本伪装 | 中——高频请求仍可被识别 |
| 随机 UA 池 | 进阶伪装 | 低——模拟不同用户 |
| UA + 其他请求头 | 完整伪装 | 最低——接近真实浏览器 |

## 二、Session：保持登录状态

**为什么需要 Session？**

HTTP 是无状态协议——每次请求都是独立的。但网站需要记住你（登录状态、购物车等），
于是用了 Cookie 机制。Session 自动管理 Cookie：

```python
# -- 创建 Session 对象 --
# Session 和直接 requests.get() 的区别：
# Session 会自动保存和发送 Cookie，模拟浏览器的"会话"概念
session = requests.Session()

# -- 设置全局请求头 --
# 这些头会附加到 Session 发出的每个请求上
# 不需要每次请求都传 headers 参数了
session.headers.update({
    'User-Agent': 'Mozilla/5.0 ...',
    'Accept-Language': 'zh-CN,zh;q=0.9',
})

# -- 登录 --
# 登录请求会返回 Set-Cookie 响应头
# Session 自动存储这些 Cookie
login_data = {
    'username': 'myuser',
    'password': 'mypass',
    'csrf_token': '...'  # 实际场景中需要先从页面提取 CSRF token
}
login_response = session.post('https://example.com/login', data=login_data)

# -- 访问需要登录的页面 --
# Session 自动带上之前存储的 Cookie
# 服务器看到 Cookie 就知道"这个请求来自已登录的用户"
profile = session.get('https://example.com/profile')
print(profile.status_code)  # 200 → 登录成功，拿到了个人页面
```

**Session 的内部机制：**

```
第一次请求：
  客户端 ──POST /login──▶ 服务器
  客户端 ◀─Set-Cookie: session_id=abc123── 服务器
  [Session 自动保存 session_id=abc123]

第二次请求：
  客户端 ──GET /profile
          Cookie: session_id=abc123──▶ 服务器
  [Session 自动附加 Cookie]
  服务器识别 Cookie → 返回登录后的内容
```

## 三、重试机制：让爬虫更健壮

网络不稳定、服务器临时繁忙——这些都是常态，不是异常。
一个好的爬虫应该能**自动重试**，而不是遇到错误就放弃。

```python
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def create_robust_session():
    """
    创建一个"抗揍"的 Session —— 带智能重试机制

    设计思路：
    1. 不是所有错误都适合重试（400 Bad Request 重试100次也没用）
    2. 也不是所有请求都适合重试（POST 支付请求重试可能重复扣款）
    3. 只对"临时性错误"进行重试（网络超时、服务器繁忙等）
    """
    session = requests.Session()

    # -- 配置重试策略 --
    retry_strategy = Retry(
        total=3,
        # ↑ 最多重试3次
        # 原因：3次是经验平衡点——太多次浪费资源，太少不够

        backoff_factor=1,
        # ↑ 重试等待时间倍增系数：第1次等1s，第2次等2s，第3次等4s
        # 这是"指数退避"策略，给服务器恢复的时间

        status_forcelist=[429, 500, 502, 503, 504],
        # ↑ 只有这些状态码才触发重试
        # 429: Too Many Requests（被限流）→ 等一等可能就放行了
        # 5xx: 服务器错误          → 等一等服务器可能恢复了
        # 4xx（除了429）: 客户端错误 → 重试没意义，你请求本身就是错的

        allowed_methods=["GET", "POST"],
        # ↑ 哪些 HTTP 方法允许重试
        # GET 是幂等的（重复请求结果相同），重试安全
        # POST 不一定幂等，但通常也允许重试
        # 注意：DELETE/PUT 重试可能导致意外后果
    )

    # -- 将重试策略挂载到 Session --
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("https://", adapter)
    # mount() 的意思是："所有 https:// 开头的请求都用这个 adapter 处理"
    # 也可以分别给 http 和 https 设置不同的策略
    session.mount("http://", adapter)

    return session

# -- 使用 --
session = create_robust_session()

try:
    # timeout=(连接超时, 读取超时)
    # 连接超时5s：如果5秒内连不上就放弃
    # 读取超时30s：连上后最多等30秒接收数据
    response = session.get('https://example.com', timeout=(5, 30))
    print("请求成功")
except requests.Timeout:
    # 超时异常：可能网络差或服务器慢
    print("请求超时，已自动重试3次但仍失败")
except requests.ConnectionError:
    # 连接异常：DNS解析失败、网络不通等
    print("连接错误：请检查网络和DNS")
except requests.RequestException as e:
    # 所有 requests 异常的基类，兜底捕获
    print(f"请求异常: {e}")
```

**重试策略的核心取舍：**

| 维度 | 激进策略 | 保守策略 | 推荐策略 |
|------|---------|---------|---------|
| 重试次数 | 10+ | 0-1 | 3 |
| 退避因子 | 固定1s | 0.1s | 指数退避(1→2→4s) |
| 重试条件 | 所有4xx/5xx | 仅5xx | 429+5xx |
| POST重试 | 总是 | 从不 | 根据业务判断 |

> **关键原则：对临时性错误重试，对永久性错误快速失败。**
> 你请求一个不存在的 URL（404），重试100次也不会存在——这是浪费。
> 你被临时限流（429），等几秒再试可能就正常了——这才是重试的意义。
''',
      ),
      CrawlerTutorialSection(
        title: '6. 完整项目：新闻头条爬虫（面向对象设计）',
        icon: Icons.newspaper,
        content: r'''
## 目标

爬取 Hacker News 首页的热门新闻，面向对象设计，支持多页爬取和结果排序。

**为什么用面向对象（class）而不是函数式？**

- 函数式（前面几章的写法）：适合一次性小脚本
- 面向对象（这章的写法）：适合**需要维护和扩展**的项目
  - 状态管理更清晰（`self.news_list` 作为实例属性）
  - 职责分离（爬取、解析、保存各司其职）
  - 方便测试（每个方法可以独立 Mock）
  - 容易扩展（继承这个类添加新功能）

```python
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time
from datetime import datetime


class HackerNewsScraper:
    """
    Hacker News 新闻爬虫

    设计原则：
    1. 单一职责：只负责爬取 HN 的数据，不负责和其他新闻源
    2. 配置外部化：BASE_URL、headers 等作为类属性，方便修改
    3. 状态管理：news_list 作为实例属性，爬取过程中持续累积
    4. 容错设计：每个提取方法都有默认值保护
    """

    # ========== 类常量 ==========
    # 放在类属性而非方法内部的好处：
    # 1. 修改时只需改一处
    # 2. 子类可以覆盖实现不同网站
    BASE_URL = "https://news.ycombinator.com/"

    # ========== 初始化方法 ==========
    def __init__(self):
        """
        初始化爬虫实例

        为什么在 __init__ 中创建 Session？
        —— 保证每个爬虫实例有独立的 Cookie 和连接池
        —— 多次爬取之间共享 TCP 连接（HTTP Keep-Alive）
        """
        self.session = requests.Session()

        # 用一个礼貌的 UA，HN 对爬虫相对友好
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (compatible; HN-Scraper/1.0)'
        })

        # 存储所有爬取的新闻
        self.news_list = []

    # ========== 爬取单页 ==========
    def scrape_page(self, page=1):
        """
        爬取 HN 的某一页

        参数:
            page: 页码（1-based，和网站一致）

        返回:
            list[dict]: 当前页的新闻列表

        为什么返回 list 而不是直接加到 self.news_list？
        —— 这叫"纯函数"设计：输入决定输出，没有副作用
        —— 好处：方便单元测试（不需要 mock 实例状态）
        """
        url = f"{self.BASE_URL}?p={page}"
        print(f"爬取: {url}")

        # --- 发送请求 ---
        try:
            response = self.session.get(url, timeout=15)
            response.raise_for_status()
            # raise_for_status() 会在状态码非 2xx 时抛出异常
            # 比手动检查更全面（覆盖 301/302/304 等特殊情况）
        except requests.Timeout:
            print(f"  请求超时: {url}")
            return []  # 返回空列表而非崩溃
        except requests.RequestException as e:
            print(f"  请求失败: {e}")
            return []

        # --- 解析页面 ---
        soup = BeautifulSoup(response.text, 'lxml')

        # HN 的每条新闻在 <tr class="athing"> 中
        # 注意：这是网站特有的结构，换一个网站需要重新分析
        items = soup.select('tr.athing')

        page_news = []
        for item in items:
            # ---- 提取标题和链接 ----
            # HN 的标题结构是:
            # <td class="title">
            #   <span class="titleline">
            #     <a href="url">标题</a>
            #   </span>
            # </td>
            title_elem = item.select_one('td.title > span.titleline > a')
            if not title_elem:
                continue  # 跳过格式异常的条目

            title = title_elem.text
            link = title_elem.get('href', '')

            # ---- 提取分数和评论数 ----
            # 这两个信息在紧随其后的 <tr> 中，不在 <tr.athing> 内
            # BeautifulSoup 的 find_next_sibling() 正是为此场景设计的
            score_elem = item.find_next_sibling('tr')
            score = 0
            comments = 0

            if score_elem:
                # 分数：<span class="score">123 points</span>
                score_span = score_elem.select_one('span.score')
                if score_span:
                    try:
                        # "123 points" → 123
                        score = int(score_span.text.split()[0])
                    except (ValueError, IndexError):
                        pass
                        # 转换失败就用默认值 0
                        # 这是"优雅降级"哲学的体现

                # 评论数：在链接文本中，如 "45 comments"
                for cl in score_elem.select('a[href*="item?id="]'):
                    text = cl.text
                    if 'comment' in text.lower():
                        try:
                            comments = int(text.split()[0])
                        except (ValueError, IndexError):
                            pass

            # ---- 组装数据 ----
            page_news.append({
                'title': title,
                'link': link,
                'score': score,
                'comments': comments,
                'source': 'Hacker News',
                'crawled_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                # 记录爬取时间的好处：后续可以追踪数据的时效性
            })

        print(f"  第 {page} 页: 提取 {len(page_news)} 条新闻")
        return page_news

    # ========== 爬取多页 ==========
    def scrape_top_news(self, pages=5):
        """
        爬取多页热门新闻并排序

        参数:
            pages: 爬取页数（默认5页，约150条新闻）

        返回:
            list[dict]: 按分数降序排列的所有新闻
        """
        for page in range(1, pages + 1):
            page_news = self.scrape_page(page)

            # 如果某页返回空（网络错误等），跳过但继续下一页
            if page_news:
                self.news_list.extend(page_news)
                # extend() vs append():
                # extend(iterable) 展开添加，相当于逐个 append
                # append(list) 会把整个list当作一个元素——这不是我们想要的

            # 如果不是最后一页，加延迟
            if page < pages:
                time.sleep(1)  # HN 的 robots.txt 建议 Crawl-delay: 1

        # 按分数降序排列
        # sort(key=..., reverse=True) 是 Python 标准排序模式
        # lambda 作为 key 函数：从每个 dict 中提取用于比较的值
        self.news_list.sort(key=lambda x: x['score'], reverse=True)

        print(f"\n全部完成！共爬取 {len(self.news_list)} 条新闻")
        return self.news_list

    # ========== 保存结果 ==========
    def save_results(self, filename='hn_news.csv'):
        """
        保存结果到文件并打印统计

        为什么保存逻辑单独成一个方法？
        —— 关注点分离：爬取和存储是不同的关注点
        —— 方便替换存储方式（CSV → 数据库，只需改这个方法）
        """
        if not self.news_list:
            print("没有数据可保存")
            return

        df = pd.DataFrame(self.news_list)

        # 保存 CSV
        # encoding='utf-8-sig' 确保 Excel 打开时中文不乱码
        df.to_csv(filename, index=False, encoding='utf-8-sig')
        print(f"\n已保存 {len(df)} 条新闻到 {filename}")

        # 打印 Top 10
        print(f"\n=== 今日 Top 10 热门新闻 ===")
        for i, row in enumerate(df.head(10).itertuples(), 1):
            # .itertuples() 返回命名元组，比 .iterrows() 更快
            print(f"{i:2d}. [{row.score:4d}分 | {row.comments:3d}评] "
                  f"{row.title[:60]}{'...' if len(row.title) > 60 else ''}")
            print(f"     {row.link}")

        # 打印统计
        print(f"\n=== 统计信息 ===")
        print(f"总新闻数: {len(df)}")
        print(f"平均分数: {df['score'].mean():.0f}")
        print(f"平均评论: {df['comments'].mean():.0f}")
        print(f"100分以上: {(df['score'] >= 100).sum()} 条")


# ========== 程序入口 ==========
if __name__ == '__main__':
    # 实例化爬虫
    scraper = HackerNewsScraper()

    # 爬取前3页（约90条新闻）
    # 页数可以根据需要调整
    scraper.scrape_top_news(pages=3)

    # 保存结果
    scraper.save_results()
```

## 面向对象设计的优势分析

和函数式写法（前面章节）对比：

```python
# ---- 函数式写法 ----
# 优点：简单直接，适合一次性的小脚本
# 缺点：状态管理混乱（用全局变量或传参），不好复用
news_list = []
def scrape_page(page): ...
def save_results(): ...
scrape_page(1)
scrape_page(2)
save_results()

# ---- 面向对象写法 ----
# 优点：
#   1. 状态封装：news_list 属于 scraper 实例，不会和其他代码冲突
#   2. 职责清晰：每个方法只做一件事
#   3. 可复用：基于这个类轻松创建 HackerNewsScraper 的子类
#   4. 可测试：每个方法可以独立进行单元测试
scraper = HackerNewsScraper()
scraper.scrape_top_news(pages=3)
scraper.save_results()
```

> **何时用函数式、何时用面向对象？**
> — 脚本 < 50 行：函数式，快速搞定
> — 脚本 50-200 行：函数式 + 模块化
> — 脚本 > 200 行或需要复用：面向对象
> — 团队协作/开源项目：面向对象（接口清晰）
''',
      ),
    ],
  ),

  // ============================================================
  // 项目2: Scrapy — 框架化爬虫进阶
  // ============================================================
  CrawlerProject(
    name: 'Scrapy',
    description: '学习使用 Python 最强大的爬虫框架，构建高效、可扩展的数据采集系统',
    difficulty: '进阶',
    icon: Icons.bug_report,
    color: const Color(0xFFE65100),
    tags: ['进阶', '框架', '异步引擎', '大规模采集'],
    overview: '''
Scrapy 是 Python 生态中最强大、最成熟的爬虫框架（GitHub 57K+ Stars）。
它提供了完整的爬虫工程化方案——异步引擎、自动去重、Pipeline 数据处理、
中间件系统、命令行工具等一应俱全。

本教程将带你：
- 理解 Scrapy 的项目结构和工作原理
- 编写 Spider 爬取多页数据
- 使用 Item Pipeline 清洗和存储数据
- 配置中间件处理反爬
- 部署和运行生产级爬虫''',
    whyLearn: '''
1. GitHub 57K+ Stars，工业级爬虫框架的事实标准
2. 异步引擎并发性能远超 Requests+BS4 组合
3. 内置去重、重试、限速、Pipeline 等生产必备功能
4. 学习 Scrapy 就是学习规范的爬虫工程化方法''',
    sections: [
      CrawlerTutorialSection(
        title: '1. 安装与创建项目',
        icon: Icons.download,
        content: r'''
## 安装 Scrapy

```bash
pip install scrapy

# 验证安装
scrapy version
# 输出: Scrapy 2.11.x
```

## Scrapy 核心架构（理解这个才能用好 Scrapy）

在写代码之前，先理解 Scrapy 的执行流程。这是**数据流架构**：

```
[Spider]                   你写的代码在这里
   ↓ yield Request/Item
[Scrapy Engine]            核心调度器
   ↓ 发送 Request
[Scheduler]                请求队列（自动去重）
   ↓ 取出下一个 Request
[Downloader]               下载网页（异步并发）
   ↓ 返回 Response
[Spider Middleware]        处理 Response 前后的钩子
   ↓ 交给 Spider
[Spider parse()]           你的解析函数
   ↓ yield Item
[Item Pipeline]            清洗→验证→存储
```

**为什么用 Scrapy 而不是手写 Requests+BS4？**

| 能力 | 手写 Requests+BS4 | Scrapy |
|------|-------------------|--------|
| 异步并发 | 需自己实现 asyncio | 内置异步引擎 |
| 请求去重 | 需自己维护 set | 自动 SHA1 去重 |
| 自动限速 | 需手写 sleep | AUTOTHROTTLE 一行配置 |
| 失败重试 | 需手写逻辑 | RetryMiddleware 内置 |
| 数据管道 | 需自己组织代码 | Pipeline 机制解耦 |
| 命令行管理 | 无 | scrapy crawl/list/shell |
| 部署方案 | 需自己搭建 | Scrapyd/Scrapy Cloud |
| 学习成本 | 低 | 中 |

> **结论：小项目用手写够用，大项目用 Scrapy 更省心。** Scrapy 帮你处理了
> 80% 的通用问题，你只需要专注于 20% 的业务逻辑。

## 创建第一个 Scrapy 项目

```bash
# 创建项目
scrapy startproject myfirst
cd myfirst

# 项目的标准目录结构（Scrapy 的"约定大于配置"哲学）
myfirst/
├── scrapy.cfg          # 部署配置（告诉 scrapyd 项目在哪）
└── myfirst/            # Python 包（项目代码）
    ├── __init__.py
    ├── items.py        # 数据模型定义（Item = 你要采集的字段）
    ├── middlewares.py  # 中间件（在请求/响应过程中插入自定义逻辑）
    ├── pipelines.py    # 数据管道（清洗、验证、存储爬取结果）
    ├── settings.py     # 全局配置（并发数、延迟、Pipeline 优先级等）
    └── spiders/        # 爬虫目录（每个 Spider 负责一个网站的爬取逻辑）
        └── __init__.py
```

**为什么 Scrapy 要强制这种项目结构？**

这是 **"约定大于配置"（Convention over Configuration）** 的设计哲学。
每个文件的职责是固定的：
- `items.py` **只**定义数据字段
- `spiders/` **只**写爬取逻辑
- `pipelines.py` **只**处理数据清洗和存储

好处：
1. 新成员接手项目，看一眼目录就知道代码在哪
2. 不同关注点之间通过 Scrapy 引擎解耦，改 Pipeline 不影响 Spider
3. 团队可以并行开发：一个人写 Spider，一个人写 Pipeline

## 生成第一个 Spider

```bash
# 生成 quotes_spider.py（自动创建标准模板）
scrapy genspider quotes quotes.toscrape.com
```

这会在 `spiders/` 下创建：

```python
import scrapy

class QuotesSpider(scrapy.Spider):
    # name 是 Spider 的唯一标识符，用于命令行调用
    # 命名规范：全小写，用下划线分隔单词
    name = "quotes"

    # allowed_domains 限制爬虫只能访问这些域名
    # 这是一个"安全网"：防止爬虫不小心跳转到外部网站
    # 如果不用这个限制，爬虫可能从 quotes 爬到 google
    allowed_domains = ["quotes.toscrape.com"]

    # start_urls 是入口 URL 列表
    # 引擎会为每个 URL 创建一个 Request 并调用 parse()
    start_urls = ["https://quotes.toscrape.com/"]

    def parse(self, response):
        """
        默认的回调函数，处理 start_urls 的响应

        参数:
            response: Scrapy 下载好的网页，可以直接用 CSS/XPath 解析

        yield 的作用（重点理解！）：
            这是 Python 生成器语法。Scrapy 用生成器实现"流式处理"——
            解析出一条数据就交出去一条，不等全部解析完。
            好处：内存占用低，适合大数据量场景。
        """
        # ===== 解析名言列表 =====
        for quote in response.css('div.quote'):
            # 用 yield 生成一个 dict（或 Item）
            # Scrapy 引擎收到后会交给 Pipeline 处理
            yield {
                # ::text 是 CSS 伪元素选择器，提取标签内的文本
                # .get() 返回第一个匹配的字符串（或 None）
                'text': quote.css('span.text::text').get(),
                'author': quote.css('small.author::text').get(),
                # .getall() 返回所有匹配的字符串列表
                'tags': quote.css('div.tags a.tag::text').getall(),
            }

        # ===== 翻页逻辑 =====
        # 提取"下一页"链接
        next_page = response.css('li.next a::attr(href)').get()
        # ::attr(href) 提取 href 属性的值

        if next_page is not None:
            # response.follow() 构造完整的下一页 URL
            # 它会自动处理相对路径→绝对路径的转换
            # callback=self.parse 表示下一页也由这个函数处理（递归）
            yield response.follow(next_page, self.parse)
            # yield 一个 Request 对象，Scrapy 引擎会把它加入 Scheduler
```

## 运行爬虫

```bash
# 运行并将结果导出为 JSON
scrapy crawl quotes -o quotes.json

# 导出为 CSV（编码：UTF-8）
scrapy crawl quotes -o quotes.csv

# 导出为 JSON Lines（每行一个 JSON，适合超大文件）
scrapy crawl quotes -o quotes.jsonl
```

**为什么用 yield 而不是 return？**

```python
# 反模式：用 return —— 必须把所有数据存到 list 中再返回
def parse(self, response):
    results = []
    for quote in response.css('div.quote'):
        results.append({...})
    return results  # 全部解析完才能开始处理数据

# Scrapy 的方式：用 yield —— 边解析边处理，流水线作业
def parse(self, response):
    for quote in response.css('div.quote'):
        yield {...}  # 解析出第一条就能开始 Pipeline 处理
        # 这就是"流式处理"——内存中只需要当前这条数据
```

> **核心思想：生成器（yield）让 Scrapy 可以同时处理"下载-解析-存储"三个环节。**
> 就像工厂流水线：工人A装零件时，工人B不需要等A装完所有零件才开始工作。
''',
      ),
      CrawlerTutorialSection(
        title: '2. 核心概念：Item、Pipeline、Settings',
        icon: Icons.schema,
        content: r'''
Scrapy 的三大核心机制：**Item**（数据容器）、**Pipeline**（数据处理链）、**Settings**（配置中枢）。

## 一、Item：类型安全的数据容器

**为什么不用普通的 dict？**
Item 提供了：
1. 字段声明（IDE 自动补全 + 拼写错误检查）
2. 类型约束（Field 可以指定序列化器）
3. 元数据（每个 Field 可以附带说明信息）

```python
# items.py —— 数据模型定义文件
import scrapy

class BookItem(scrapy.Item):
    """
    书籍数据模型

    为什么要显式定义每个字段？
    1. 自我文档化：一看就知道会采集哪些字段
    2. IDE 支持：输入 item['tit'] 会提示补全
    3. 拼写保护：字段名拼错了 Scrapy 会警告
    4. 序列化控制：可以为每个字段指定 serializer
    """
    title = scrapy.Field()
    # ↑ 最简单的声明：字段名 = Field()

    price = scrapy.Field()
    # ↑ Scrapy Field 可以传入额外参数，如：
    # price = scrapy.Field(serializer=float)
    # 但通常在 Pipeline 中处理更灵活

    rating = scrapy.Field()
    availability = scrapy.Field()
    url = scrapy.Field()
    category = scrapy.Field()
```

**在 Spider 中使用 Item（比 dict 更好的写法）：**

```python
from myfirst.items import BookItem

class BooksSpider(scrapy.Spider):
    name = 'books'
    start_urls = ['http://books.toscrape.com/']

    def parse(self, response):
        for book in response.css('article.product_pod'):
            # 创建 Item 实例（而不是 dict）
            item = BookItem()

            # 逐字段赋值
            # 好处：如果写成了 item['titl']，Scrapy 会警告"未知字段"
            item['title'] = book.css('h3 a::attr(title)').get()
            item['price'] = book.css('p.price_color::text').get()
            item['url'] = book.css('h3 a::attr(href)').get()

            # 从 class 中提取评分（前面章节学过的技巧）
            rating_class = book.css('p.star-rating::attr(class)').get()
            item['rating'] = (
                rating_class.replace('star-rating ', '')
                if rating_class else None
            )

            yield item  # 交给 Pipeline 处理
```

## 二、Pipeline：数据处理流水线

**为什么需要 Pipeline？**

```
原始数据 ──▶ [价格清洗] ──▶ [评分转换] ──▶ [去重] ──▶ [存储]
                ↑               ↑              ↑          ↑
              Pipeline 1     Pipeline 2    Pipeline 3  Pipeline 4

每个 Pipeline 只做一件事，数据像流水线一样依次经过。
```

```python
# pipelines.py —— 数据处理管道

import json
from scrapy.exceptions import DropItem


class PriceCleanPipeline:
    """
    价格清洗 Pipeline

    职责：将 "£51.77" 这样的字符串转换为浮点数 51.77

    为什么单独一个 Pipeline？
    —— 单一职责原则：清洗和存储是不同关注点
    —— 方便测试：可以单独验证价格清洗逻辑
    """
    def process_item(self, item, spider):
        # process_item 是 Pipeline 的入口方法
        # 每个 Pipeline 都必须实现这个方法
        if item.get('price'):
            price_str = item['price']
            # 逐步清理：
            # 1. 移除货币符号（£、$、€ 等）
            # 2. 移除千位分隔符（如 1,234 → 1234）
            # 3. 转为浮点数
            clean = price_str.replace('£', '').replace(',', '').strip()
            try:
                item['price'] = float(clean)
            except ValueError:
                # 转换失败时设为 0，这是"优雅降级"
                item['price'] = 0.0
        return item
        # 必须返回 item，否则后续 Pipeline 收不到数据


class RatingCleanPipeline:
    """
    评分转换 Pipeline

    职责：将 'Three' 这样的英文评分转为数字 3
    """
    RATING_MAP = {
        'One': 1, 'Two': 2, 'Three': 3,
        'Four': 4, 'Five': 5
    }

    def process_item(self, item, spider):
        if item.get('rating') in self.RATING_MAP:
            item['rating'] = self.RATING_MAP[item['rating']]
        return item


class DuplicatesPipeline:
    """
    去重 Pipeline

    职责：过滤已经采集过的重复数据

    为什么需要独立的去重逻辑？
    —— Scrapy 内置的请求去重是"不重复请求同一 URL"
    —— 但不同 URL 可能返回相同内容，或同一商品出现在多个分类页
    —— 所以需要在数据层面再做一次去重
    """
    def __init__(self):
        # 用 set 而不是 list —— O(1) 的查找 vs O(n)
        self.urls_seen = set()

    def process_item(self, item, spider):
        if item.get('url') in self.urls_seen:
            # 抛出 DropItem 异常 = 告诉 Scrapy "这条数据不要了"
            # 这是 Scrapy 官方的丢弃数据方式
            raise DropItem(f"重复数据已丢弃: {item['url']}")

        self.urls_seen.add(item['url'])
        return item


class JsonExportPipeline:
    """
    JSON 导出 Pipeline

    职责：将所有爬取的数据写入一个 JSON 文件

    为什么要在 open_spider 和 close_spider 中操作文件？
    —— open_spider: 爬虫启动时打开文件（只开一次）
    —— close_spider: 爬虫结束时关闭文件（只关一次）
    —— process_item: 每收到一条数据就写入一行
    这样比每次打开/关闭文件效率高得多
    """
    def open_spider(self, spider):
        """爬虫启动时调用（只调用一次）"""
        self.file = open('books_output.json', 'w', encoding='utf-8')
        self.file.write('[\n')  # JSON 数组开头
        self.first_item = True  # 标记是否是第一条数据（处理逗号问题）

    def close_spider(self, spider):
        """爬虫结束时调用（只调用一次）"""
        self.file.write('\n]')  # JSON 数组结尾
        self.file.close()

    def process_item(self, item, spider):
        # dict(item) 将 Scrapy Item 转为普通 dict
        line = json.dumps(dict(item), ensure_ascii=False)
        # ensure_ascii=False 让中文正常显示而不是 \uXXXX

        if self.first_item:
            self.file.write(f'  {line}')
            self.first_item = False
        else:
            # 前一条数据后加逗号（JSON 数组元素分隔符）
            self.file.write(f',\n  {line}')
        return item
```

## 三、Settings：配置驱动的行为控制

```python
# settings.py —— 全局配置文件

# ---- Pipeline 配置 ----
# 数字越小，优先级越高（数据先经过优先级高的 Pipeline）
ITEM_PIPELINES = {
    'myfirst.pipelines.PriceCleanPipeline': 100,
    # ↑ 100: 价格清洗最先执行（原始数据需要先清理）
    'myfirst.pipelines.RatingCleanPipeline': 200,
    # ↑ 200: 评分转换第二
    'myfirst.pipelines.DuplicatesPipeline': 300,
    # ↑ 300: 去重第三（在存储之前过滤）
    'myfirst.pipelines.JsonExportPipeline': 400,
    # ↑ 400: 存储最后执行（数据已经清洗干净）
}

# ---- 并发与延迟 ----
CONCURRENT_REQUESTS = 16
# ↑ 同时发送16个请求
# 为什么是16？经验值——太多可能被封，太少浪费带宽
# 调节方法：从8开始，逐步增加直到遇到限流

DOWNLOAD_DELAY = 0.25
# ↑ 同一域名两次请求之间的间隔（秒）
# 为什么是0.25而不是0？给服务器喘息空间，降低被封风险

# ---- 自动限速（推荐开启） ----
AUTOTHROTTLE_ENABLED = True
# ↑ 自动根据服务器响应速度调整延迟
# 服务器快→延迟小，服务器慢→延迟大

AUTOTHROTTLE_START_DELAY = 1
# ↑ 初始延迟（会动态调整）

AUTOTHROTTLE_MAX_DELAY = 10
# ↑ 最大延迟（不会超过这个值）
# 为什么设上限？防止延迟无限增长导致爬虫卡住

# ---- 请求头 ----
DEFAULT_REQUEST_HEADERS = {
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36'
    ),
    'Accept-Language': 'zh-CN,zh;q=0.9',
}

# ---- 其他推荐配置 ----
ROBOTSTXT_OBEY = True
# ↑ 遵守网站的 robots.txt 规则
# 这是爬虫道德规范：尊重网站的爬取限制
```
''',
      ),
      CrawlerTutorialSection(
        title: '3. CSS 选择器与 XPath 详解',
        icon: Icons.search,
        content: r'''
## Scrapy 选择器体系

Scrapy 内置的选择器是基于 parsel 库（从 Scrapy 中独立出来的通用选择器库），
支持 CSS 和 XPath 两种语法，且可以链式调用。

```python
# 基础用法：response.css() 和 response.xpath()
# 两者返回的都是 SelectorList，可以继续调用 .css() 或 .xpath()
quotes = response.css('div.quote')       # CSS 选择器
quotes = response.xpath('//div[@class="quote"]')  # XPath 选择器（等价）

# 链式调用：先用 CSS 缩小范围，再用 XPath 精确提取
texts = response.css('div.quote').xpath('./span[@class="text"]/text()')
```

## CSS 选择器速查（Scrapy 扩展版）

Scrapy 对 CSS 选择器做了扩展，添加了几个非常实用的"伪元素"：

```python
# === 文本提取 ===
response.css('span.text::text').get()      # ::text   提取内部文本（第一个）
response.css('span.text::text').getall()   # ::text   提取内部文本（全部）
# 为什么用 ::text 而不是 .text？
# 因为 .text 是 Python 属性，::text 是选择器层面的操作
# ::text 可以和其他选择器组合使用，如: div.quote > span.text::text

# === 属性提取 ===
response.css('a::attr(href)').get()        # ::attr(name) 提取指定属性
response.css('img::attr(data-src)').get()  # 提取自定义属性（如延迟加载的图片）

# === 基本选择器 ===
response.css('div')                        # 标签选择器
response.css('div.quote')                  # 类选择器（等价于 div[class~="quote"]）
response.css('#main')                      # ID选择器

# === 属性选择器 ===
response.css('a[href]')                    # 有 href 属性的 a
response.css('a[href*="book"]')            # href 包含 "book"
response.css('a[href$=".pdf"]')            # href 以 .pdf 结尾
response.css('a[href^="https"]')           # href 以 https 开头
response.css('img[data-src]')              # 有 data-src 属性（懒加载图片）

# === 伪类选择器 ===
response.css('div.quote:first-child')      # 第一个
response.css('div.quote:nth-child(3)')     # 第3个
```

## XPath 选择器速查（终极武器）

XPath 比 CSS 更强大，可以按**文本内容**、**层级关系**、**属性包含**等条件筛选。

```python
# === 基本路径 ===
response.xpath('//div')                         # 所有 div
response.xpath('//div[@class="quote"]')          # class="quote" 的 div
response.xpath('//h1/text()').get()             # h1 的文本内容

# === 文本匹配（CSS 做不到的） ===
response.xpath('//a[text()="下一页"]/@href')             # 文本精确匹配
response.xpath('//a[contains(text(), "下")]/@href')      # 文本包含
response.xpath('//button[starts-with(text(), "提交")]')   # 文本开头

# === 条件筛选 ===
response.xpath('//div[@class="product" and @data-id="123"]')
response.xpath('//span[contains(@class, "price")]/text()')
response.xpath('//img[not(@src)]')              # 没有 src 的图片

# === 轴（Axes）—— XPath 最强大的特性 ===
# 可以沿着 DOM 树的任意方向导航
response.xpath('//h2/following-sibling::p')     # h2 后面的兄弟 p
response.xpath('//div/parent::section')          # div 的父级 section
response.xpath('//article/descendant::a/@href')  # article 内所有 a 的 href
```

## CSS vs XPath：如何选择？

| 场景 | 推荐 | 原因 |
|------|------|------|
| 简单选择 | CSS | 语法更简洁：`div.quote` vs `//div[@class="quote"]` |
| 按文本内容查找 | **XPath** | CSS 没有文本匹配选择器 |
| 复杂嵌套条件 | **XPath** | `and`/`or`/`not` 组合条件 |
| 按层级关系查找 | **XPath** | Axes 可以沿任意方向导航 |
| 团队经验 | CSS | 前端开发者更熟悉 CSS 语法 |
| 提取属性值 | 两者均可 | `::attr(href)` vs `/@href` |

> **最佳实践：默认用 CSS，遇到 CSS 做不到的再用 XPath。**
> 90% 的提取 CSS 就够了，但剩下 10% 只能靠 XPath。
''',
      ),
      CrawlerTutorialSection(
        title: '4. 中间件：拦截和修改请求/响应',
        icon: Icons.swap_horiz,
        content: r'''
## 中间件的定位

中间件在下载器和引擎之间，是 Scrapy 的"拦截器"机制。

```
请求方向：Engine → [Middleware] → Downloader → 网络
响应方向：网络 → Downloader → [Middleware] → Engine
```

## 自定义下载中间件

```python
# middlewares.py

import random
import time
from scrapy import signals


class CustomDownloaderMiddleware:
    """
    自定义下载中间件

    这个中间件实现了三个钩子方法：
    1. process_request: 在请求发送前拦截（修改请求头、代理等）
    2. process_response: 在响应返回后拦截（处理限流、验证码等）
    3. process_exception: 在网络异常时拦截（记录日志、重试决策等）
    """

    # 多个 UA 轮流使用，降低被识别为爬虫的概率
    # 为什么不用 random.choice 在每次请求时选？
    # 因为同一个 Session 频繁切换 UA 反而显得可疑
    # 更好的策略是每个 Spider 实例固定一个 UA
    USER_AGENTS = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
    ]

    @classmethod
    def from_crawler(cls, crawler):
        """Scrapy 的工厂方法模式：从 crawler 获取配置"""
        middleware = cls()
        crawler.signals.connect(middleware.spider_opened, signal=signals.spider_opened)
        return middleware

    def spider_opened(self, spider):
        spider.logger.info(f"中间件已启动: {spider.name}")

    def process_request(self, request, spider):
        """
        在请求发送前处理

        返回:
            None     — 让请求正常继续
            Request  — 替换当前请求（如重试时返回新请求）
            Response — 直接返回响应（短路下载，用于 Mock）
        """
        # 随机 User-Agent
        request.headers['User-Agent'] = random.choice(self.USER_AGENTS)

        # 添加 Referer（某些网站检查这个）
        # 没有 Referer 可能被识别为"直接访问"而非"正常浏览"
        if not request.headers.get('Referer'):
            request.headers['Referer'] = request.url

        return None  # 放行

    def process_response(self, request, response, spider):
        """
        在响应返回后处理

        返回:
            Response — 让这个响应正常进入 Spider
            Request  — 发起新的请求（如重试）
        """
        # 处理限流（429 Too Many Requests）
        if response.status == 429:
            spider.logger.warning(f"被限流！URL: {request.url}")
            # 等待 30 秒后重试
            # 30秒是经验值：大多数网站的限流窗口是1分钟
            time.sleep(30)
            return request.copy()  # 返回原请求的副本以重试

        # 检测验证码页面
        if 'captcha' in response.text.lower():
            spider.logger.error(f"遇到验证码！URL: {request.url}")
            # 遇到验证码时放弃该请求
            return None  # None = 丢弃

        return response  # 正常返回

    def process_exception(self, request, exception, spider):
        """
        处理下载异常
        """
        spider.logger.error(
            f"请求异常: {request.url} — {type(exception).__name__}: {exception}"
        )
        # 返回 None 让 Scrapy 的 RetryMiddleware 处理重试
        return None


# 在 settings.py 中启用中间件：
# DOWNLOADER_MIDDLEWARES = {
#     'myfirst.middlewares.CustomDownloaderMiddleware': 543,
# }
```

**中间件优先级的作用：**

Scrapy 内置中间件的优先级参考值：
- 100: RetryMiddleware（重试）
- 400: UserAgentMiddleware（UA设置）
- 543: **你的自定义中间件位置**（在UA之后、重定向之前）
- 600: RedirectMiddleware（重定向）
- 810: HttpCompressionMiddleware（解压）

你把自己的中间件放在 543 意味着：它会在 UA 设置之后、重定向之前执行。
如果你需要在 UA 设置之前修改请求头，就用小于 400 的优先级。
''',
      ),
      CrawlerTutorialSection(
        title: '5. 实战：电商商品爬虫（完整生产级代码）',
        icon: Icons.shopping_cart,
        content: r'''
## 完整的电商商品爬虫项目

下面是一个可以直接用于生产的完整 Scrapy 爬虫项目。

**items.py** — 数据模型
```python
import scrapy

class BookDetailItem(scrapy.Item):
    """书籍详细页的数据模型"""
    title = scrapy.Field()
    price = scrapy.Field()
    rating = scrapy.Field()
    availability = scrapy.Field()
    category = scrapy.Field()
    description = scrapy.Field()
    upc = scrapy.Field()           # 商品统一编码
    product_type = scrapy.Field()
    reviews = scrapy.Field()       # 评论数
    url = scrapy.Field()
```

**spiders/book_spider.py** — 核心爬取逻辑（重点注释）
```python
import scrapy
from myfirst.items import BookDetailItem


class BookDetailSpider(scrapy.Spider):
    """
    书籍详情爬虫
    流程：列表页 → 获取每本书的链接 → 进入详情页 → 提取完整信息
    """
    name = 'book_detail'
    start_urls = ['http://books.toscrape.com/']

    def parse(self, response):
        """
        解析列表页：提取每本书的链接，交给 parse_detail 处理

        为什么要分离 parse 和 parse_detail？
        —— 每个函数只处理一种页面结构
        —— 列表页和详情页的 HTML 结构完全不同
        —— 分开处理让代码更清晰、更好维护
        """
        for book in response.css('article.product_pod'):
            # 提取详情页链接
            detail_url = book.css('h3 a::attr(href)').get()
            if detail_url:
                # response.follow() 的特点：
                # 1. 自动补全相对路径
                # 2. 返回一个 Request 对象
                yield response.follow(
                    detail_url,
                    callback=self.parse_detail,   # 指定处理函数
                    meta={
                        # meta 在请求-响应间传递额外数据
                        # 这是 Scrapy 的"夹带私货"机制
                        # 注意：只能在列表页提取的信息用 meta 传递
                        'rating': book.css(
                            'p.star-rating::attr(class)'
                        ).get()
                    }
                )

        # 翻页逻辑
        next_page = response.css('li.next a::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)

    def parse_detail(self, response):
        """
        解析详情页：提取完整信息

        response.meta 中可以访问从列表页传递过来的数据
        这就是 Scrapy 的"上下文传递机制"
        """
        item = BookDetailItem()

        # ---- 基本信息提取 ----
        item['title'] = response.css('div.product_main h1::text').get()
        item['price'] = response.css('p.price_color::text').get()
        item['availability'] = response.css(
            'p.availability::text'
        ).get('').strip()
        item['url'] = response.url

        # ---- 评分（从列表页 meta 中提取） ----
        rating_class = response.meta.get('rating', '')
        rating_map = {
            'One': 1, 'Two': 2, 'Three': 3,
            'Four': 4, 'Five': 5
        }
        item['rating'] = rating_map.get(
            rating_class.replace('star-rating ', ''), 0
        )

        # ---- 产品信息表格（XPath 在此场景下更合适） ----
        for row in response.css('table.table-striped tr'):
            th = row.css('th::text').get('')
            td = row.css('td::text').get('')
            if 'UPC' in th:
                item['upc'] = td
            elif 'Product Type' in th:
                item['product_type'] = td
            elif 'Reviews' in th:
                item['reviews'] = td

        # ---- 描述（可能为空） ----
        desc = response.css('article.product_page p::text').get()
        item['description'] = desc.strip() if desc else ''

        # ---- 分类（面包屑导航中的第三级） ----
        item['category'] = response.css(
            'ul.breadcrumb li:nth-child(3) a::text'
        ).get('')

        yield item
        # yield 后，这个 item 会依次经过所有 Pipeline
```

**pipelines.py** — 数据处理
```python
import pandas as pd
import re
from scrapy.exceptions import DropItem


class BookDetailPipeline:
    """
    书籍数据处理管道

    设计思路：收集所有 item → 爬虫结束时统一处理
    为什么不全在 process_item 中处理？
    —— 有些操作需要看到全部数据才有意义（如排序、统计）
    """

    def __init__(self):
        self.items = []  # 缓存所有 item

    def process_item(self, item, spider):
        """处理每个 item"""
        # 清洗价格：移除货币符号
        if item.get('price'):
            clean = item['price'].replace('£', '').replace(',', '')
            item['price'] = float(clean)

        # 清洗库存：提取数字
        if item.get('availability'):
            match = re.search(r'\d+', item['availability'])
            item['stock'] = int(match.group()) if match else 0

        self.items.append(dict(item))
        return item

    def close_spider(self, spider):
        """爬虫结束时：保存数据并输出统计"""
        if not self.items:
            spider.logger.warning("没有采集到数据！")
            return

        df = pd.DataFrame(self.items)
        df.to_csv('books_detail.csv', index=False, encoding='utf-8-sig')
        df.to_json('books_detail.json', orient='records', force_ascii=False)

        spider.logger.info(f"=== 爬取完成 ===")
        spider.logger.info(f"总书籍数: {len(df)}")
        spider.logger.info(f"平均评分: {df['rating'].mean():.2f}")
        spider.logger.info(f"平均价格: £{df['price'].mean():.2f}")
```

## 运行

```bash
# 运行爬虫（输出日志，不导出文件，靠 Pipeline 存储）
scrapy crawl book_detail

# 如果要调试单个页面：
scrapy shell "http://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html"
# 在 shell 中测试选择器：
# >>> response.css('h1::text').get()
```
''',
      ),
    ],
  ),

  // ============================================================
  // 项目3: Playwright — 动态页面爬虫
  // ============================================================
  CrawlerProject(
    name: 'Playwright',
    description: '使用 Microsoft 的浏览器自动化工具，爬取 JavaScript 渲染的动态网页',
    difficulty: '中级',
    icon: Icons.smart_display,
    color: const Color(0xFF1976D2),
    tags: ['中级', '动态页面', '浏览器自动化', 'JS渲染'],
    overview: '''
Playwright 是 Microsoft 开源的浏览器自动化工具（GitHub 73K+ Stars），
支持 Chromium、Firefox、WebKit 三大浏览器引擎。

与 Requests+BS4 不同，Playwright 可以：
- 执行 JavaScript 代码，等待动态内容加载
- 模拟用户点击、输入、滚动等操作
- 截取页面截图和生成 PDF
- 拦截和修改网络请求
- 处理 SPA（单页应用）和 AJAX 加载的内容

本教程将教会你使用 Playwright 抓取传统方法无法获取的动态数据。''',
    whyLearn: '''
1. GitHub 73K+ Stars，浏览器自动化领域最活跃的项目
2. 完美处理 JavaScript 渲染的现代网站（React/Vue/Angular）
3. 自动等待机制，不需要手写 sleep()
4. 支持无头模式和有头模式，方便调试
5. 网络拦截功能可以截获 API 响应，比解析 DOM 更高效''',
    sections: [
      CrawlerTutorialSection(
        title: '1. Playwright 核心概念与安装',
        icon: Icons.download,
        content: r'''
## 安装

```bash
pip install playwright
playwright install chromium
```

## 为什么需要 Playwright？——传统爬虫的四大盲区

```
【盲区1】JS 动态渲染
  Requests 拿到的是：<div id="app"></div>   ← 空壳！
  浏览器实际显示的是：<div id="app">这里面有100条数据</div>
  原因：数据是 JavaScript 在浏览器中执行后才加载的
  Playwright 方案：启动真浏览器，等 JS 执行完再拿 HTML

【盲区2】SPA 单页应用（React/Vue/Angular）
  URL 不变，但页面内容通过 JS 动态切换
  Requests 做不到：点击按钮 → 等待新内容 → 解析
  Playwright 方案：真实点击 → 自动等待 → 获取更新后的 DOM

【盲区3】反爬检测
  网站检测 navigator.webdriver、缺少浏览器特征等
  Requests 无法通过：缺少完整的浏览器环境
  Playwright 方案：真浏览器环境，与普通用户无异

【盲区4】复杂交互逻辑
  需要：滚动到底部 → 点击"加载更多" → 等待 → 再滚动
  Requests 无法做到多步骤交互
  Playwright 方案：完整的自动化操作链
```

## 三大核心对象

```
Browser（浏览器实例）
  昂贵资源 —— 启动慢（~1s），内存占用大（~200MB）
  一个爬虫程序通常只开一个 Browser

  └── Context（浏览器上下文）
      类似隐身窗口 —— 独立的 Cookie、LocalStorage、Session
      创建快（~10ms），内存占用小
      可以为每个任务创建独立的 Context（多账号爬取）

      └── Page（页面标签）
          最小的操作单位 —— 导航、点击、提取数据
          每个 Page 对应一个标签页
```

**为什么 Context 如此重要？**
它允许你用一个 Browser 实例模拟多个完全隔离的"用户"（各自有独立的 Cookie）。
这在"多账号爬取"场景下至关重要。

## 同步 API vs 异步 API

```python
# 同步 API —— 简单直观，适合学习和小项目
# 代码从上到下顺序执行，容易理解
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('https://example.com')
    print(page.title())
    browser.close()


# 异步 API —— 高性能，适合生产环境
# 可以在"等待网络响应"的同时做其他事情
# 单线程可以管理成百上千个页面
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto('https://example.com')
        print(await page.title())
        await browser.close()

asyncio.run(main())
```

**何时用异步？**
- 同时爬取数十个页面 → 异步 API（一个事件循环管理所有页面）
- 爬取单个网站 → 同步 API（简单够用）
- 本教程使用同步 API（便于理解核心概念）
''',
      ),
      CrawlerTutorialSection(
        title: '2. Playwright 的自动等待机制（核心优势）',
        icon: Icons.hourglass_bottom,
        content: r'''
## Playwright 的核心创新：自动等待

这是 Playwright 和 Selenium 最大的区别，也是最重要的设计哲学。

**传统 Selenium 的做法（你不应该这样写）：**
```python
# 反模式：显式等待（Explicit Wait）
from selenium.webdriver.support.ui import WebDriverWait
# 每操作一个元素都要写等待条件，代码又臭又长
element = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.ID, "myElement"))
)

# 更糟的反模式：固定 sleep
import time
time.sleep(3)  # 页面可能 0.5 秒就加载好了，你白等了 2.5 秒
               # 也可能 5 秒还没加载好，你的代码就崩了
```

**Playwright 的做法（自动等待）：**
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('https://quotes.toscrape.com/js/')

    # 以下所有操作都会"自动等待"元素可用，不需要手动 sleep！
    page.click('li.next a')
    # ↑ 自动等待按钮：1.出现在DOM中 2.可见 3.可交互 4.不被遮挡
    # 这背后 Playwright 做了4层检查

    page.fill('input#search', 'hello')
    # ↑ 自动等待输入框可编辑

    page.text_content('span.text')
    # ↑ 自动等待元素渲染完成

    print("自动等完成了！没有写一行 sleep")
    browser.close()
```

**Playwright 自动等待检查的4个条件：**

```
1. Actionability checks（可操作性检查）
   ├── Attached（元素已挂载到 DOM 树）
   ├── Visible（元素可见，display ≠ none, visibility ≠ hidden）
   ├── Stable（元素位置稳定，动画已结束）
   ├── Receives Events（元素可接收事件，不被其他元素遮挡）
   └── Enabled（元素未 disabled）

2. 超时机制
   默认超时 30 秒，超时抛出 TimeoutError
   可通过 timeout 参数自定义
```

**手动等待（少数需要的情况）：**

```python
# 等待特定元素出现
page.wait_for_selector('div.quote', timeout=10000)

# 等待网络空闲（所有请求完成）
page.wait_for_load_state('networkidle')

# 等待自定义条件
page.wait_for_function('() => document.querySelectorAll(".item").length > 10')

# 唯一需要 sleep 的场景：等非DOM变化（如文件下载完成）
page.wait_for_timeout(2000)  # 2秒后继续，不推荐但有时必要
```
''',
      ),
      CrawlerTutorialSection(
        title: '3. 网络拦截：最高效的动态数据获取方式',
        icon: Icons.wifi,
        content: r'''
## 核心洞察：不解析 HTML，直接拿 JSON

现代网站的数据流是这样的：
```
用户访问 → HTML骨架（几乎空的）
          → JS执行 → 发起 XHR/Fetch 请求 → API返回 JSON
          → JS渲染数据到 DOM
```

**传统做法的低效路径：**
JS渲染完 → 解析 DOM → 提取数据（慢 + 容易出错）

**Playwright 网络拦截的高效路径：**
拦截 XHR/Fetch 响应 → 直接拿 JSON（快 + 数据结构化）

## 实战：拦截 API 响应

```python
from playwright.sync_api import sync_playwright
import json

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 收集拦截到的 API 数据
    api_responses = []

    def handle_response(response):
        """
        处理每个网络响应

        这个函数会在每个网络请求完成时被调用。
        response 包含：URL、状态码、响应头、响应体（JSON/HTML/...）

        为什么用回调函数而不是轮询？
        —— 事件驱动：数据一来就处理，不用等，效率最高
        —— Playwright 底层用 Node.js 的事件循环，回调是原生机制
        """
        # 过滤：只关注 API 请求
        if 'api' in response.url or response.request.resource_type == 'xhr':
            try:
                data = response.json()  # 直接拿 JSON，不用解析 HTML
                api_responses.append({
                    'url': response.url,
                    'status': response.status,
                    'data': data,
                })
            except Exception:
                # 非 JSON 响应（如 HTML），正常跳过
                pass

    # 注册响应监听器
    # 'response' 事件在每个 HTTP 响应到达时触发
    page.on('response', handle_response)

    # 访问页面（这个过程中，所有 API 响应会被自动拦截）
    page.goto('https://example.com/products')
    page.wait_for_load_state('networkidle')
    # networkidle: 500ms 内没有新的网络请求，视为加载完成

    print(f"拦截到 {len(api_responses)} 个 API 响应")

    for resp in api_responses:
        print(f"API: {resp['url'][:80]}...")
        print(f"数据: {json.dumps(resp['data'], ensure_ascii=False)[:100]}...\n")

    browser.close()
```

## 拦截并修改请求

```python
def modify_request(route, request):
    """
    在请求发送前拦截，可以修改或阻断

    使用场景：
    1. 阻断图片/CSS/字体加载 → 爬取速度提升 3-5 倍
    2. 修改请求头 → 添加认证 token
    """
    # 阻断不必要资源的加载（大幅加速爬取）
    if request.resource_type in ['image', 'stylesheet', 'font', 'media']:
        route.abort()  # 直接中止，不浪费带宽
        return

    # 对需要保留的请求继续发送
    route.continue_()


# route('**/*') 匹配所有 URL
# 这里的 '**/*' 是 glob 模式：
#   ** 匹配任意路径
#   * 匹配任意文件名
page.route('**/*', modify_request)
```

**为什么要阻断图片和 CSS？**

一个典型网页的资源分布：
- HTML 文档：~50KB（你需要的）
- CSS 文件：~200KB（不需要）
- 图片：~2MB（不需要）
- JS 文件：~500KB（部分需要）
- 字体：~100KB（不需要）

阻断不需要的资源后：**带宽节省 90%+，爬取速度提升 3-5 倍**。

> **最佳实践：先用网络拦截看看网站有哪些 API 请求。**
> 如果找到数据 API，直接调 API 比解析 DOM 高效 10 倍。
> 这是区分"入门爬虫"和"专业爬虫"的关键技能。
''',
      ),
      CrawlerTutorialSection(
        title: '4. 实战：动态加载页面 + 无限滚动处理',
        icon: Icons.swipe_vertical,
        content: r'''
## 实战代码：完整动态页面爬虫

```python
from playwright.sync_api import sync_playwright
import pandas as pd
from datetime import datetime


class DynamicPageScraper:
    """
    动态页面爬虫

    适用场景：
    - React/Vue/Angular 渲染的 SPA
    - 内容通过"加载更多"按钮加载
    - 无限滚动页面（如社交媒体 Feed）
    """

    def __init__(self, headless=True):
        """
        参数:
            headless: True=无头模式(生产), False=有头模式(调试)
            为什么分开两种模式？
            —— 调试时用有头模式可以看到浏览器的操作过程
            —— 生产时用无头模式更快且不占用屏幕空间
        """
        self.headless = headless
        self.all_data = []

    def scrape_paginated(self, url, max_pages=10):
        """
        爬取分页加载的网站（点击"下一页"翻页）

        流程：
        进入页面 → 等待内容加载 → 提取数据 → 点击下一页 → 重复
        """
        with sync_playwright() as p:
            # 启动浏览器
            browser = p.chromium.launch(headless=self.headless)

            # 创建 Context：类似打开一个隐身窗口
            # viewport 设置视窗大小（重要作用：影响响应式布局）
            context = browser.new_context(
                viewport={'width': 1920, 'height': 1080},
                user_agent='Mozilla/5.0 ...',
            )
            page = context.new_page()

            for page_num in range(1, max_pages + 1):
                print(f"正在爬取第 {page_num} 页...")

                # goto 的 wait_until 参数控制"何时视为加载完成"
                # 'networkidle': 所有网络请求完成后（最可靠但最慢）
                # 'domcontentloaded': DOM 解析完成（较快但可能缺内容）
                # 'load': onload 事件触发（默认，平衡）
                page.goto(f"{url}?page={page_num}", wait_until='networkidle')

                # 等待数据容器出现（超时 10 秒）
                try:
                    page.wait_for_selector('div.item', timeout=10000)
                except Exception:
                    print(f"  第 {page_num} 页无数据，结束")
                    break

                # 提取当前页数据
                items = page.query_selector_all('div.item')
                for item in items:
                    # text_content() 获取元素内的纯文本
                    # 比 .inner_text() 更快（不触发布局计算）
                    data = item.text_content()
                    self.all_data.append({
                        'text': data.strip(),
                        'page': page_num,
                    })

                print(f"  已采集 {len(self.all_data)} 条")

            browser.close()
        return self.all_data

    def scrape_infinite_scroll(self, url, item_selector, max_items=100):
        """
        爬取无限滚动页面

        原理：不断滚动到底部 → 等待新内容加载 → 重复
        """
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            page = browser.new_page()
            page.goto(url, wait_until='networkidle')

            last_count = 0
            no_change_count = 0
            MAX_NO_CHANGE = 3  # 连续3次无新内容则停止

            while len(self.all_data) < max_items and no_change_count < MAX_NO_CHANGE:
                # 滚动到底部
                # evaluate() 在浏览器中执行 JS 代码
                page.evaluate('window.scrollTo(0, document.body.scrollHeight)')

                # 等待新内容加载（给 AJAX 请求一点时间）
                page.wait_for_timeout(2000)

                # 检查当前加载了多少项目
                current_items = page.query_selector_all(item_selector)
                current_count = len(current_items)

                print(f"已加载 {current_count} 个项目...")

                if current_count == last_count:
                    no_change_count += 1
                else:
                    no_change_count = 0  # 有新内容，重置计数器

                last_count = current_count

            print(f"滚动结束，共加载 {last_count} 个项目")

            browser.close()
        return self.all_data

    def save_results(self):
        """保存结果并打印统计"""
        df = pd.DataFrame(self.all_data)
        df.to_csv('dynamic_data.csv', index=False, encoding='utf-8-sig')
        print(f"已保存 {len(df)} 条数据")


# 使用示例
if __name__ == '__main__':
    scraper = DynamicPageScraper(headless=True)
    scraper.scrape_paginated('https://example.com/products', max_pages=5)
    scraper.save_results()
```
''',
      ),
      CrawlerTutorialSection(
        title: '5. 反检测配置（Stealth 模式）',
        icon: Icons.shield,
        content: r'''
## 为什么需要反检测？

很多网站（尤其是商业化网站）会主动检测和拦截自动化工具。
检测手段包括：
- `navigator.webdriver` 属性（Playwright 默认会暴露）
- 缺少 `window.chrome` 对象
- `navigator.plugins` 为空
- Canvas/WebGL 指纹不一致
- 鼠标移动轨迹检测

## 完整的 Stealth 配置

```python
from playwright.sync_api import sync_playwright


def create_stealth_page(browser):
    """
    创建一个"隐形"的浏览器页面

    核心思路：
    1. 修改浏览器特征，让 navigator 系列属性看起来像普通浏览器
    2. 模拟真实用户环境（语言、时区、地理位置）
    3. 使用 add_init_script 在页面加载前注入修改代码
    """
    context = browser.new_context(
        # 视窗大小 —— 太小会被识别为爬虫
        viewport={'width': 1920, 'height': 1080},

        # User-Agent —— 使用主流浏览器的 UA
        user_agent=(
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/120.0.0.0 Safari/537.36'
        ),

        # 语言和时区 —— 保持一致，不一致会被识别
        locale='zh-CN',
        timezone_id='Asia/Shanghai',

        # 地理位置 —— 模拟北京
        geolocation={'latitude': 39.9042, 'longitude': 116.4074},
        permissions=['geolocation'],
    )

    page = context.new_page()

    # add_init_script 在页面加载前注入 JS
    # 这是最关键的一步：在所有网站脚本执行前就修改浏览器特征
    page.add_init_script("""
        // 1. 隐藏 webdriver 特征
        //    自动化工具的标志性属性，设为 undefined 伪装成普通浏览器
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined
        });

        // 2. 模拟 plugins 数组
        //    Chrome 有内置插件（PDF Viewer等），空数组会被识别
        Object.defineProperty(navigator, 'plugins', {
            get: () => [1, 2, 3, 4, 5]
        });

        // 3. 模拟 languages
        Object.defineProperty(navigator, 'languages', {
            get: () => ['zh-CN', 'zh', 'en-US', 'en']
        });

        // 4. 模拟 chrome 对象
        //    普通 Chrome 浏览器有 window.chrome 对象
        window.chrome = {
            runtime: {},
            loadTimes: function() {},
            csi: function() {},
            app: {}
        };

        // 5. 修改权限查询行为
        //    防止被 permissions API 检测出异常
        const originalQuery = window.navigator.permissions.query;
        window.navigator.permissions.query = (parameters) => (
            parameters.name === 'notifications' ?
            Promise.resolve({
                state: Notification.permission
            }) :
            originalQuery(parameters)
        );
    """)

    return page


# 使用
with sync_playwright() as p:
    # 启动时添加反检测参数
    browser = p.chromium.launch(
        headless=True,
        args=[
            '--disable-blink-features=AutomationControlled',
            # ↑ 禁用 Blink 引擎的自动化标记
            '--disable-features=IsolateOrigins,site-per-process',
            # ↑ 减少可被检测的特征
        ]
    )

    page = create_stealth_page(browser)
    page.goto('https://bot.sannysoft.com/')
    # 这个网站专门测试浏览器是否是机器人
    # 如果配置正确，所有检测项都会显示绿色

    page.screenshot(path='stealth_test.png')
    browser.close()
```

## 反检测的层级策略

| 层级 | 措施 | 效果 | 成本 |
|------|------|------|------|
| L1 | 设置 User-Agent | 绕过基础检查 | 极低 |
| L2 | add_init_script 隐藏特征 | 绕过 webdriver 检测 | 低 |
| L3 | 随机延迟+鼠标轨迹 | 绕过行为分析 | 中 |
| L4 | 住宅代理 IP | 绕过 IP 风控 | 高 |
| L5 | 指纹浏览器（AdsPower等） | 完整伪装 | 高 |

> **一线经验：90% 的网站只需要 L1+L2 就够了。**
> 不要一上来就搞全套反检测——过度设计会增加维护成本。
> 先试基础方案，被拦了再升级。
''',
      ),
    ],
  ),

  // ============================================================
  // 项目4: Crawl4AI — AI 智能爬虫
  // ============================================================
  CrawlerProject(
    name: 'Crawl4AI',
    description: '使用 AI 驱动的智能爬虫框架，自动提取结构化数据，对 LLM 友好',
    difficulty: '中级',
    icon: Icons.auto_awesome,
    color: const Color(0xFF7C4DFF),
    tags: ['中级', 'AI驱动', 'LLM友好', '智能提取'],
    overview: '''
Crawl4AI 是 2024 年崛起的 AI 友好型爬虫框架（GitHub 40K+ Stars），
专为 LLM 应用设计。它不仅能爬取网页，还能智能提取结构化内容。

核心亮点：
- LLM 友好输出：自动生成 Markdown 格式的干净内容
- 智能内容提取：自动识别正文、剔除广告和导航
- 结构化数据抽取：用自然语言描述即可提取数据
- 极速性能：比传统方案快 4-10 倍
- 支持多种输出策略：CSS 选择器、LLM 提取、正则匹配

本教程将带你体验 AI 时代爬虫的新范式。''',
    whyLearn: '''
1. GitHub 40K+ Stars，增长最快的新一代爬虫框架
2. LLM 友好设计，直接输出 AI 可用的格式化内容
3. 自然语言提取，不需要写复杂的解析规则
4. 速度极快，适合批量处理和大规模采集
5. 2025年爬虫领域最热门的技术方向''',
    sections: [
      CrawlerTutorialSection(
        title: '1. 安装与第一个爬虫（3行代码）',
        icon: Icons.download,
        content: r'''
## 安装

```bash
pip install crawl4ai

# 首次运行会自动下载必要的模型
crawl4ai-setup
```

## Crawl4AI 的设计理念

传统爬虫流程：
```
发请求 → 收到 HTML → 分析 DOM 结构 → 写选择器 → 提取数据 → 清洗格式
   ↑                           ↑                          ↑
 简单                     最费时间                   又费时间
```

Crawl4AI 流程：
```
发请求 → 收到 HTML → 自动提取 Markdown → 自动提取结构化数据
   ↑                           ↑
 简单                    AI 自动完成（秒级 vs 分钟级）
```

**Crawl4AI 的核心理念：让爬虫的焦点从"怎么提取"转移到"提取什么"。**

## 第一个爬虫（3行代码）

```python
import asyncio
from crawl4ai import AsyncWebCrawler

async def main():
    async with AsyncWebCrawler() as crawler:
        # 只需要一个 URL，其余全部自动处理
        result = await crawler.arun(
            url="https://quotes.toscrape.com/"
        )

        # 直接拿到干净的 Markdown 文本
        # 广告、导航栏、侧边栏等"噪音"已被自动剔除
        print(result.markdown[:500])
        # 输出就是干净的 Markdown，可以直接喂给 LLM！

asyncio.run(main())
```

**为什么 Crawl4AI 用异步 API？**
因为它内部集成了 Playwright 浏览器引擎，浏览器操作本质上都是异步的（I/O 密集型）。
使用 async/await 可以在"等待网页加载"的同时处理其他任务。

## 获取更多元数据

```python
async def main():
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(
            url="https://quotes.toscrape.com/"
        )

        # Markdown 正文（LLM 友好的格式）
        print("=== Markdown（可直接喂给 GPT） ===")
        print(result.markdown[:300])

        # 纯文本（无任何格式）
        print("\n=== 纯文本 ===")
        print(result.text[:200])

        # 元数据（标题、描述、关键词等 SEO 信息）
        print("\n=== Meta 信息 ===")
        print(f"标题: {result.metadata.get('title', 'N/A')}")
        print(f"描述: {result.metadata.get('description', 'N/A')}")

        # 页面内链接（自动分类为内部/外部）
        internal = result.links.get('internal', [])
        print(f"\n=== 内部链接: {len(internal)} 个 ===")
        for link in internal[:5]:
            print(f"  {link['href'][:60]} — {link['text'][:40]}")

asyncio.run(main())
```

## 传统方案 vs Crawl4AI 对比

```python
# 传统方案：解析一个博客页面
# 步骤1：发请求
# 步骤2：找正文容器（div.article-content? article.post? main?）
# 步骤3：写选择器提取每个段落
# 步骤4：处理嵌套格式（列表、引用、代码块）
# 步骤5：手动清理广告和无关元素
# 耗时：10-30 分钟 | 代码量：50-100 行

# Crawl4AI：同样的任务
result = await crawler.arun(url="https://example.com/blog/post")
print(result.markdown)  # 干净、格式化、LLM 就绪
# 耗时：10 秒 | 代码量：3 行
```
''',
      ),
      CrawlerTutorialSection(
        title: '2. CSS 选择器提取结构化数据',
        icon: Icons.account_tree,
        content: r'''
当你知道网页结构时，CSS 选择器是最快、最可靠的方式。

```python
import asyncio
from crawl4ai import AsyncWebCrawler
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

async def main():
    # 定义提取 Schema —— 类似 Scrapy Item
    # 这是"声明式提取"：你声明要什么，不用写怎么提取的逻辑
    schema = {
        "name": "Quotes Extraction",     # Schema 名称（用于日志）
        "baseSelector": "div.quote",     # 基础选择器：定位到每个数据项
        "fields": [                       # 字段定义列表
            {
                "name": "text",           # 字段名
                "selector": "span.text::text",  # CSS 选择器
                "type": "text",           # 类型：text/list/attribute
            },
            {
                "name": "author",
                "selector": "small.author::text",
                "type": "text",
            },
            {
                "name": "tags",
                "selector": "div.tags a.tag::text",
                "type": "list",           # 列表类型 → 自动收集所有匹配项
            },
        ],
    }

    extraction_strategy = JsonCssExtractionStrategy(schema, verbose=True)

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(
            url="https://quotes.toscrape.com/",
            extraction_strategy=extraction_strategy,
        )

        if result.extracted_content:
            import json
            data = json.loads(result.extracted_content)
            print(f"成功提取 {len(data)} 条:\n")
            for item in data[:3]:
                print(f'  "{item["text"]}"')
                print(f'  — {item["author"]}')
                print(f'  标签: {", ".join(item["tags"])}\n')

asyncio.run(main())
```

**Schema 字段类型说明：**

| type | 含义 | 示例 selector | 输出 |
|------|------|-------------|------|
| `"text"` | 单个文本 | `span.price::text` | `"£51.77"` |
| `"list"` | 文本列表 | `a.tag::text` | `["fiction", "classic"]` |
| `"attribute"` | 属性值 | `a::attr(href)` | `"/book/123"` |

**为什么用 Schema 而不是手写提取逻辑？**
1. 声明式 → 更好读：一眼看出在提取什么字段
2. 可复用 → 同一个 Schema 用在不同 URL 上
3. 易维护 → 网页改版只需改 Schema 的选择器
''',
      ),
      CrawlerTutorialSection(
        title: '3. LLM 智能提取：用自然语言描述数据',
        icon: Icons.psychology,
        content: r'''
## 核心创新：用自然语言代替选择器

这是 Crawl4AI 最强大的特性。你不需要知道 HTML 结构，
只需要用人话描述你要什么：

```python
import asyncio
from crawl4ai import AsyncWebCrawler
from crawl4ai.extraction_strategy import LLMExtractionStrategy

async def main():
    # 用自然语言告诉 AI 你要提取什么
    instruction = """
    从页面中提取所有名言信息。
    返回一个 JSON 数组，每个元素包含：
    - quote: 名言文本（完整原文）
    - author: 作者全名
    - tags: 标签列表
    - estimated_era: 根据作者生卒年推测的大致时期（如: "19世纪", "20世纪", "当代"）
    - sentiment: 这句名言的情感倾向（positive/neutral/philosophical/dark）
    """

    llm_strategy = LLMExtractionStrategy(
        provider="openai/gpt-4o-mini",
        # ↑ 推荐用 gpt-4o-mini：便宜（$0.15/M input）且足够聪明
        api_token="your-api-key-here",
        instruction=instruction,
        extraction_type="schema",
        chunk_token_threshold=1000,
        # ↑ 当 HTML 超过1000 token 时分块处理
    )

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(
            url="https://quotes.toscrape.com/",
            extraction_strategy=llm_strategy,
        )

        if result.extracted_content:
            import json
            data = json.loads(result.extracted_content)
            print("LLM 提取结果（注意 estimated_era 和 sentiment 是 LLM 推理出来的！）")
            print(json.dumps(data, ensure_ascii=False, indent=2))

asyncio.run(main())
```

**为什么 LLM 提取是革命性的？**

传统方式下，你只能提取"网页上明确写出来的信息"。
LLM 提取可以**推理出网页上没有直接写的信息**：
- 从作者的出生年份推断"所属时代"
- 从名言内容推断"情感倾向"
- 自动分类、摘要、翻译……

## 使用本地 LLM（免费）

```python
# 使用 Ollama 本地模型（完全免费，数据不出本机）
llm_strategy = LLMExtractionStrategy(
    provider="ollama/qwen2.5:7b",
    # ↑ Ollama 支持的模型都可以用
    # 推荐：qwen2.5:7b（中文好）、llama3.1:8b（英文好）
    instruction="提取所有书籍的标题、价格和评分...",
)
```

## CSS 选择器 vs LLM 提取：选择指南

| 维度 | CSS 选择器 | LLM 提取 |
|------|-----------|---------|
| 速度 | 毫秒级 | 秒级（调用 API） |
| 成本 | 免费 | API费用（~$0.001/页） |
| 准确性 | 100%（固定结构） | 90-99%（取决于LLM） |
| 结构变化适应 | 需要手动更新 | 自动适应 |
| 推理能力 | 无 | 可推理、分类、翻译 |
| **适合** | **稳定网站的大规模定期采集** | **探索性爬取、一次性任务、复杂提取** |

> **最佳实践：先用 LLM 探索（理解数据结构），再用 CSS 选择器固化（降低成本和延迟）。**
> 这是"探索-固化"模式：LLM 帮你搞清楚数据在哪，然后你写几条 CSS 选择器永久使用。
''',
      ),
      CrawlerTutorialSection(
        title: '4. 高级功能：批量爬取、缓存、截图',
        icon: Icons.rocket_launch,
        content: r'''
## 批量并发爬取多个 URL

```python
async def crawl_multiple():
    urls = [
        "https://quotes.toscrape.com/page/1/",
        "https://quotes.toscrape.com/page/2/",
        "https://quotes.toscrape.com/page/3/",
    ]

    async with AsyncWebCrawler() as crawler:
        # arun_many 内部使用 asyncio.gather 并发请求
        # 比逐个 arun 快 N 倍（N = URL 数量）
        results = await crawler.arun_many(urls=urls)

        for url, result in zip(urls, results):
            if result.success:
                print(f"✓ {url}: {len(result.markdown)} 字符")
            else:
                print(f"✗ {url}: 失败 — {result.error_message}")


asyncio.run(crawl_multiple())
```

## 缓存机制

```python
async with AsyncWebCrawler() as crawler:
    result = await crawler.arun(
        url="https://example.com",
        cache_mode="enabled",
        # 缓存模式：
        # "enabled"   — 优先用缓存，没缓存才抓取（推荐）
        # "disabled"  — 每次都抓取
        # "read_only" — 只用缓存，缓存未命中则失败
        # "write_only" — 只抓取+写入缓存，不读缓存
    )
```

**为什么缓存很重要？**
- 开发调试时：同一个页面可能被抓取几十次（测试选择器、检查结果）
- 有缓存后：第一次抓取 → 缓存，之后读取缓存（毫秒级，0网络开销）
- 对目标网站更友好（不会因为调试而重复请求）

## 处理需要登录的页面

```python
async with AsyncWebCrawler() as crawler:
    result = await crawler.arun(
        url="https://example.com/dashboard",
        cookies=[
            {"name": "sessionid", "value": "your-session-cookie"},
            {"name": "csrftoken", "value": "your-csrf-token"},
        ],
    )
```

## JavaScript 执行

```python
async with AsyncWebCrawler() as crawler:
    result = await crawler.arun(
        url="https://example.com",
        js_code="""
            // 在页面中执行自定义 JavaScript
            // 使用场景：点击"加载更多"、切换标签页、展开折叠内容
            const loadMoreBtn = document.querySelector('.load-more');
            if (loadMoreBtn) loadMoreBtn.click();
        """,
        wait_for="css:.content-loaded",
        # ↑ 执行 JS 后等待特定元素出现
    )
```
''',
      ),
      CrawlerTutorialSection(
        title: '5. 实战：智能新闻聚合器（多源+AI提取+统计分析）',
        icon: Icons.rss_feed,
        content: r'''
## 目标

构建一个智能新闻聚合器，自动爬取多个新闻源，提取标题、摘要、关键词。

这个示例展示了 Crawl4AI 在真实项目中的使用方式——**数据获取（异步）+ 数据处理（pandas）+ 展示（统计）** 的完整链路。

```python
import asyncio
from crawl4ai import AsyncWebCrawler
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy
import json
import pandas as pd
from datetime import datetime


class SmartNewsAggregator:
    """
    智能新闻聚合器

    架构设计：
    1. 数据源配置：每个新闻源是一个 dict（URL + schema）
    2. 并发爬取：asyncio.gather 同时爬取所有源
    3. 统一输出：所有源的数据合并到一个 DataFrame
    """

    def __init__(self):
        # 配置数据源 —— 添加新源只需加一个 dict
        self.news_sources = [
            {
                "name": "Hacker News",
                "url": "https://news.ycombinator.com/",
                "schema": {
                    "name": "HN Articles",
                    "baseSelector": "tr.athing",
                    "fields": [
                        {
                            "name": "title",
                            "selector": "td.title span.titleline a::text",
                            "type": "text",
                        },
                        {
                            "name": "link",
                            "selector": "td.title span.titleline a::attr(href)",
                            "type": "attribute",
                            "attribute": "href",
                        },
                    ],
                },
            },
        ]

    async def scrape_source(self, source):
        """
        爬取单个数据源

        为什么每个源独立一个方法？
        —— 便于单独测试（Mock 单个源）
        —— 便于错误隔离（一个源失败不影响其他源）
        """
        print(f"正在爬取: {source['name']}...")

        strategy = JsonCssExtractionStrategy(
            source['schema'],
            verbose=False,  # 生产环境关闭详细日志
        )

        try:
            async with AsyncWebCrawler() as crawler:
                result = await crawler.arun(
                    url=source['url'],
                    extraction_strategy=strategy,
                    cache_mode="enabled",
                )

                if result.extracted_content:
                    data = json.loads(result.extracted_content)
                    # 为每条数据标记来源和时间
                    for item in data:
                        item['source'] = source['name']
                        item['crawled_at'] = datetime.now().isoformat()
                    print(f"  {source['name']}: 获取 {len(data)} 条")
                    return data
                else:
                    print(f"  {source['name']}: 无数据")
                    return []

        except Exception as e:
            print(f"  {source['name']}: 错误 — {e}")
            return []  # 不崩溃，返回空列表（错误隔离）

    async def scrape_all(self):
        """
        并发爬取所有数据源

        asyncio.gather 的关键作用：
        —— 同时爬取所有数据源，总时间 = 最慢的那个的时间
        —— 而不是逐个等待（总时间 = 所有源的时间和）
        """
        tasks = [self.scrape_source(s) for s in self.news_sources]
        results = await asyncio.gather(*tasks)

        # 合并所有结果
        all_data = []
        for data in results:
            all_data.extend(data)

        return all_data

    def process_results(self, data):
        """处理和分析聚合结果"""
        df = pd.DataFrame(data)

        print(f"\n=== 聚合报告 ===")
        print(f"数据总量: {len(df)} 条")
        print(f"数据来源: {df['source'].nunique()} 个")
        print(f"爬取时间: {datetime.now().isoformat()}")

        # 按来源统计
        print(f"\n各来源数据量:")
        for source, count in df['source'].value_counts().items():
            print(f"  {source}: {count} 条")

        # 保存
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"news_aggregate_{timestamp}"
        df.to_csv(f"{filename}.csv", index=False, encoding='utf-8-sig')
        df.to_json(
            f"{filename}.json", orient='records', force_ascii=False
        )
        print(f"\n已保存: {filename}.csv / {filename}.json")

        return df


# 运行
async def main():
    aggregator = SmartNewsAggregator()
    data = await aggregator.scrape_all()
    aggregator.process_results(data)


asyncio.run(main())
```

## 四种爬虫方案最终选择指南

| 方案 | 最佳场景 | 速度 | 难度 | 典型用例 |
|------|---------|------|------|---------|
| **Requests+BS4** | 静态HTML,小规模 | ★★★★ | ★ | 博客列表、新闻标题、商品信息 |
| **Scrapy** | 大规模数据采集 | ★★★★★ | ★★★ | 电商全站、搜索引擎、数据集构建 |
| **Playwright** | JS渲染,SPA,交互 | ★★★ | ★★ | 社交媒体、地图数据、需要登录的网站 |
| **Crawl4AI** | AI应用,探索性爬取 | ★★★★ | ★★ | RAG数据源、LLM训练数据、内容聚合 |

**学习路径建议：**
1. 从 **Requests+BS4** 开始 → 理解 HTTP 和 HTML 的基本原理
2. 遇到 JS 渲染的网站 → 学习 **Playwright**
3. 需要大规模采集 → 学习 **Scrapy**（工程化能力）
4. 做 AI/RAG 项目 → 使用 **Crawl4AI**（效率最高）

> **核心原则：没有"最好"的工具，只有"最合适"的工具。**
> 根据任务特点选择，而不是根据工具热度选择。
> 一个成熟的爬虫工程师，四个工具都会用，且知道什么时候用什么。
''',
      ),
    ],
  ),
];
