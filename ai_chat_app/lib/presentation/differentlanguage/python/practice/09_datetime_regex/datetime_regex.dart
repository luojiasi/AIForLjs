import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// Demo 1: 日期时间运算
// ─────────────────────────────────────────────────────────────
class _DateTimeCalcDemo extends StatefulWidget {
  const _DateTimeCalcDemo();

  @override
  State<_DateTimeCalcDemo> createState() => _DateTimeCalcDemoState();
}

class _DateTimeCalcDemoState extends State<_DateTimeCalcDemo> {
  int _year = 2025;
  int _month = 1;
  int _day = 1;
  int _addDays = 30;

  @override
  Widget build(BuildContext context) {
    final baseDate = DateTime(_year, _month, _day);
    final mm = _month.toString().padLeft(2, '0');
    final dd = _day.toString().padLeft(2, '0');
    final baseDateStr = '$_year-$mm-$dd';
    final futureDate = baseDate.add(Duration(days: _addDays));
    final fmm = futureDate.month.toString().padLeft(2, '0');
    final fdd = futureDate.day.toString().padLeft(2, '0');
    final futureDateStr = '${futureDate.year}-$fmm-$fdd';
    final weekday = baseDate.weekday;
    const weekdayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final dayOfWeek = weekdayNames[weekday];
    final isWeekend = weekday >= 6;

    return InteractivePlayground(
      title: 'datetime 日期运算',
      children: [
        ParamIntSlider(
          label: '年份',
          value: _year,
          min: 2020,
          max: 2030,
          onChanged: (v) => setState(() => _year = v),
        ),
        ParamIntSlider(
          label: '月份',
          value: _month,
          min: 1,
          max: 12,
          onChanged: (v) => setState(() => _month = v),
        ),
        ParamIntSlider(
          label: '日期',
          value: _day,
          min: 1,
          max: 28,
          onChanged: (v) => setState(() => _day = v),
        ),
        ParamIntSlider(
          label: '加天数',
          value: _addDays,
          min: 1,
          max: 365,
          unit: '天',
          onChanged: (v) => setState(() => _addDays = v),
        ),
        LiveCodeBlock('''
from datetime import datetime, timedelta

dt = datetime($_year, $_month, $_day)
print(dt.strftime("%Y-%m-%d"))     # $baseDateStr
print(dt.strftime("%A"))           # $dayOfWeek

future = dt + timedelta(days=$_addDays)
print(future.strftime("%Y-%m-%d")) # $futureDateStr

# 判断是否为周末
is_weekend = dt.weekday() >= 5    # $isWeekend
'''),
        LiveOutputBox(
          '基准日期: $baseDateStr ($dayOfWeek)\n'
          '${isWeekend ? "周末" : "工作日"}\n'
          '+$_addDays天后: $futureDateStr',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Demo 2: 正则表达式匹配
// ─────────────────────────────────────────────────────────────
class _RegexMatchDemo extends StatefulWidget {
  const _RegexMatchDemo();

  @override
  State<_RegexMatchDemo> createState() => _RegexMatchDemoState();
}

class _RegexMatchDemoState extends State<_RegexMatchDemo> {
  String _pattern = r'\d+';
  String _text = 'abc123def456';
  String _mode = 'findall';

  static const _presetPatterns = [
    (label: r'\d+', desc: '数字'),
    (label: r'[a-z]+', desc: '小写字母'),
    (label: r'\w+', desc: '单词'),
    (label: r'[A-Z]', desc: '大写字母'),
  ];

  static const _modes = ['match', 'search', 'findall'];

  List<String> _computeMatches() {
    try {
      final re = RegExp(_pattern);
      if (_mode == 'match') {
        final m = re.matchAsPrefix(_text);
        return m != null ? [m.group(0)!] : [];
      } else if (_mode == 'search') {
        final m = re.firstMatch(_text);
        return m != null ? [m.group(0)!] : [];
      } else {
        return re.allMatches(_text).map((m) => m.group(0)!).toList();
      }
    } catch (_) {
      return [];
    }
  }

  List<TextSpan> _buildHighlightedSpans() {
    try {
      final re = RegExp(_pattern);
      final spans = <TextSpan>[];
      final matches = re.allMatches(_text).toList();
      if (matches.isEmpty) {
        return [TextSpan(text: _text)];
      }
      int cursor = 0;
      for (final m in matches) {
        if (m.start > cursor) {
          spans.add(TextSpan(text: _text.substring(cursor, m.start)));
        }
        spans.add(TextSpan(
          text: m.group(0),
          style: const TextStyle(
            backgroundColor: Color(0xFFFFE082),
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ));
        cursor = m.end;
      }
      if (cursor < _text.length) {
        spans.add(TextSpan(text: _text.substring(cursor)));
      }
      return spans;
    } catch (_) {
      return [TextSpan(text: _text)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = _computeMatches();
    final matchesList = matches.map((s) => "'$s'").join(', ');
    final firstMatch = matches.isNotEmpty ? matches.first : 'None';
    final modeDesc = {
      'match': '从字符串开头匹配',
      'search': '搜索第一个匹配',
      'findall': '查找所有匹配',
    }[_mode]!;
    final resultLine = _mode == 'findall'
        ? "print(result)  # [$matchesList]"
        : "print(result.group())  # $firstMatch";

    return InteractivePlayground(
      title: 're 正则表达式',
      children: [
        ParamChoiceChips<String>(
          label: '预设模式',
          value: _pattern,
          options: _presetPatterns.map((p) => (p.label, p.desc)).toList(),
          onChanged: (v) => setState(() => _pattern = v),
        ),
        ParamTextField(
          label: '正则模式',
          value: _pattern,
          maxLength: 40,
          onChanged: (v) => setState(() => _pattern = v),
        ),
        ParamTextField(
          label: '测试文本',
          value: _text,
          maxLength: 40,
          onChanged: (v) => setState(() => _text = v),
        ),
        ParamChoiceChips<String>(
          label: '匹配模式',
          value: _mode,
          options: _modes.map((m) => (m, m)).toList(),
          onChanged: (v) => setState(() => _mode = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('匹配高亮:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                    children: _buildHighlightedSpans(),
                  ),
                ),
              ),
            ],
          ),
        ),
        LiveCodeBlock('''
import re

pattern = r'$_pattern'
text = '$_text'

# $modeDesc
result = re.$_mode(pattern, text)
$resultLine
'''),
        LiveOutputBox(
          matches.isEmpty
              ? '无匹配结果'
              : '匹配到 ${matches.length} 个结果:\n${matches.map((s) => "  \"$s\"").join("\n")}',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
/// Python 第9章：日期时间与正则表达式（扩展版）
/// 涵盖 datetime/timedelta/timezone/strftime/strptime/calendar
/// zoneinfo/re 模块/re.compile/命名组/零宽断言/正则实战
class PythonDateTimeRegex extends StatelessWidget {
  const PythonDateTimeRegex({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第9章 日期与正则'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① datetime 模块\n'
            '② strftime/strptime 格式化\n'
            '③ timedelta 时间计算\n'
            '④ timezone 与时区\n'
            '⑤ calendar 日历模块\n'
            '⑥ 正则表达式入门\n'
            '⑦ re 函数详解\n'
            '⑧ re.compile 编译优化\n'
            '⑨ 命名组与零宽断言\n'
            '⑩ 正则实战：日志解析',
          ),
          const TipBox(
            '日期处理和正则匹配是 Python 最常用的功能之一。'
            '数据处理、日志分析、表单验证都离不开它们。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 1. datetime 基础 ──
          const SectionHeader('1. datetime —— 日期时间核心', icon: Icons.calendar_month),
          const Paragraph(
            'datetime 模块提供 date（日期）、time（时间）、datetime（日期+时间）三个核心类。'
            '此外还有 timedelta（时间差）和 timezone（时区）。',
          ),
          const CodeBlock(
            'from datetime import datetime, date, time\n\n'
            '# ===== 获取当前日期时间 =====\n'
            'now = datetime.now()\n'
            'print(now)  # 2025-01-15 14:30:25.123456\n\n'
            '# ===== 创建指定日期 =====\n'
            'd = date(2025, 1, 15)\n'
            'print(d)    # 2025-01-15\n\n'
            '# ===== 创建指定时间 =====\n'
            't = time(14, 30, 0, 123456)  # 时:分:秒:微秒\n'
            'print(t)    # 14:30:00.123456\n\n'
            '# ===== 获取日期各部分 =====\n'
            'print(now.year)    # 2025\n'
            'print(now.month)   # 1\n'
            'print(now.day)     # 15\n'
            'print(now.hour)    # 14\n'
            'print(now.minute)  # 30\n'
            'print(now.second)  # 25\n'
            'print(now.microsecond)  # 123456\n\n'
            '# ===== 星期几 =====\n'
            'print(now.weekday())     # 2（0=周一，6=周日）\n'
            'print(now.isoweekday())  # 3（1=周一，7=周日）\n\n'
            '# ===== 时间戳 =====\n'
            'print(now.timestamp())   # 秒级时间戳\n'
            'print(date.fromtimestamp(0))  # 1970-01-01\n\n'
            '# ===== 替换日期部分 =====\n'
            'tomorrow = now.replace(day=now.day+1)\n'
            'print(tomorrow)  # 2025-01-16 14:30:25.123456',
            language: 'Python',
          ),
          const OutputBox(
            '2025-01-15 14:30:25.123456\n'
            '2025-01-15\n14:30:00.123456\n'
            '2025\n1\n15\n14\n30\n25\n123456\n'
            '2\n3\n1736937025.123456\n1970-01-01\n'
            '2025-01-16 14:30:25.123456',
          ),

          // ── 2. strftime / strptime ──
          const DividerLine(),
          const SectionHeader('2. strftime / strptime —— 格式化', icon: Icons.format_align_left),
          const Paragraph(
            'strftime = datetime → 字符串（format）\n'
            'strptime = 字符串 → datetime（parse）\n\n'
            '记忆方法：str From Time（时间→字符串）\n'
            '         str Parse Time（字符串→时间）',
          ),
          const CodeBlock(
            'from datetime import datetime\n\n'
            'now = datetime.now()\n\n'
            '# ===== strftime 格式化速查 =====\n'
            'print(now.strftime("%Y-%m-%d"))              # 2025-01-15\n'
            'print(now.strftime("%Y年%m月%d日"))           # 2025年01月15日\n'
            'print(now.strftime("%H:%M:%S"))              # 14:30:25\n'
            'print(now.strftime("%I:%M %p"))              # 02:30 PM（12时制）\n'
            'print(now.strftime("%A"))                    # Wednesday（星期全称）\n'
            'print(now.strftime("%a"))                    # Wed（星期简称）\n'
            'print(now.strftime("%B"))                    # January（月份全称）\n'
            'print(now.strftime("%j"))                    # 015（年中第几天）\n'
            'print(now.strftime("%W"))                    # 02（年中第几周）\n\n'
            '# ===== strptime 解析 =====\n'
            'date_str = "2025-01-15 14:30:00"\n'
            'dt = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")\n'
            'print(dt)  # 2025-01-15 14:30:00\n\n'
            '# ===== 常见格式 =====\n'
            'fmt1 = "%Y-%m-%d"           # 2025-01-15\n'
            'fmt2 = "%Y/%m/%d"           # 2025/01/15\n'
            'fmt3 = "%d-%m-%Y"           # 15-01-2025\n'
            'fmt4 = "%Y-%m-%d %H:%M:%S"  # 2025-01-15 14:30:00\n\n'
            '# ===== 格式对照表 =====\n'
            '# %Y  - 4位年份     %y  - 2位年份\n'
            '# %m  - 月份(01-12)  %d  - 日期(01-31)\n'
            '# %H  - 24时制      %I  - 12时制\n'
            '# %M  - 分钟        %S  - 秒\n'
            '# %p  - AM/PM       %f  - 微秒(6位)\n'
            '# %A  - 星期全称    %a  - 星期简称\n'
            '# %B  - 月份全称    %b  - 月份简称\n'
            '# %j  - 年中第几天  %W  - 年中第几周',
            language: 'Python',
          ),
          const TipBox(
            'strptime 的格式必须和输入精确匹配！\n'
            '"2025-1-1" 和 "%Y-%m-%d" 会报错，因为月份需要两位数字。'
            '用 "%Y-%-m-%-d" 可以解析非补零的格式（仅 Unix）。',
            type: TipType.caution,
          ),
          const OutputBox(
            '2025-01-15\n2025年01月15日\n14:30:25\n02:30 PM\nWednesday\nWed\nJanuary\n015\n02\n2025-01-15 14:30:00',
          ),

          // ── 3. timedelta ──
          const DividerLine(),
          const SectionHeader('3. timedelta —— 时间计算', icon: Icons.timer),
          const Paragraph(
            'timedelta 表示时间差。支持加减运算、比较运算，'
            '可以精确到微秒。主要字段：days、seconds、microseconds。',
          ),
          const CodeBlock(r'''
from datetime import datetime, timedelta

now = datetime.now()

# ===== 创建时间差 =====
one_day = timedelta(days=1)
one_week = timedelta(weeks=1)
two_hours = timedelta(hours=2)
complex_td = timedelta(days=5, hours=3, minutes=30, seconds=15)

# ===== 日期加减 =====
print(now + one_day)      # 明天同一时间
print(now - one_week)     # 一周前
print(now + two_hours)    # 两小时后

# ===== 计算差值 =====
new_year = datetime(2026, 1, 1)
delta = new_year - now
print(f"距离2026年还有{delta.days}天")
print(f"总秒数: {delta.total_seconds()}")

# ===== timedelta 的属性 =====
print(complex_td)                  # 5 days, 3:30:15
print(complex_td.days)             # 5
print(complex_td.seconds)          # 12615 (3*3600+30*60+15)
print(complex_td.total_seconds())  # 454215.0

# ===== 时间比较 =====
print(one_day > two_hours)   # True
print(one_day == timedelta(hours=24))  # True

# ===== 批量生成日期 =====
start = date(2025, 1, 1)
for i in range(5):
    day = start + timedelta(days=i)
    print(day.strftime("%m-%d %A"), end="  ")
# 01-01 Wednesday  01-02 Thursday ...
		  '''),
          const OutputBox(
            '2025-01-16 14:30:25.123456\n'
            '2025-01-08 14:30:25.123456\n'
            '2025-01-15 16:30:25.123456\n'
            '距离2026年还有350天\n总秒数: 30240000.0\n'
            '5 days, 3:30:15\n5\n12615\n454215.0\nTrue\nTrue\n'
            '01-01 Wednesday  01-02 Thursday  01-03 Friday  01-04 Saturday  01-05 Sunday',
          ),

          // ── 4. timezone ──
          const DividerLine(),
          const SectionHeader('4. 时区处理', icon: Icons.public),
          const Paragraph(
            'Python 3.9+ 推荐使用 zoneinfo 模块处理时区。'
            '旧版本可以用 pytz（第三方库）。处理国际化应用时必须关注时区。',
          ),
          const CodeBlock(r'''
from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo  # Python 3.9+

# ===== 时区转换 =====
# 获取当前 UTC 时间
utc_now = datetime.now(timezone.utc)
print(f"UTC: {utc_now}")

# 转换为其他时区
beijing = utc_now.astimezone(ZoneInfo("Asia/Shanghai"))
tokyo = utc_now.astimezone(ZoneInfo("Asia/Tokyo"))
newyork = utc_now.astimezone(ZoneInfo("America/New_York"))

print(f"北京: {beijing}")    # UTC+8
print(f"东京: {tokyo}")      # UTC+9
print(f"纽约: {newyork}")    # UTC-5

# ===== 创建带时区的日期时间 =====
dt_utc8 = datetime(2025, 1, 15, 14, 30, tzinfo=ZoneInfo("Asia/Shanghai"))
print(dt_utc8)

# ===== 常见时区名称 =====
# Asia/Shanghai     中国标准时间 CST
# Asia/Tokyo        日本标准时间 JST
# America/New_York  美国东部时间 EST
# Europe/London     英国时间 GMT/BST
# UTC               协调世界时

# ===== 显示所有可用时区 =====
import zoneinfo
print(len(zoneinfo.available_timezones()))  # 约 600 个
		  '''),
          const OutputBox(
            'UTC: 2025-01-15 06:30:25+00:00\n'
            '北京: 2025-01-15 14:30:25+08:00\n'
            '东京: 2025-01-15 15:30:25+09:00\n'
            '纽约: 2025-01-15 01:30:25-05:00\n'
            '2025-01-15 14:30:00+08:00\n609',
          ),

          // ── 5. calendar ──
          const DividerLine(),
          const SectionHeader('5. calendar —— 日历模块', icon: Icons.calendar_view_month),
          const Paragraph(
            'calendar 模块提供日历相关功能：打印日历、判断闰年、'
            '计算月份天数等。适合做日期相关的工具。',
          ),
          const CodeBlock(r'''
import calendar

# ===== 打印日历 =====
cal = calendar.month(2025, 1)
print(cal)  # 打印 2025年1月的日历
#     January 2025
# Mo Tu We Th Fr Sa Su
#        1  2  3  4  5
#  6  7  8  9 10 11 12
# 13 14 15 16 17 18 19
# 20 21 22 23 24 25 26
# 27 28 29 30 31

# ===== 判断闰年 =====
print(calendar.isleap(2024))  # True
print(calendar.isleap(2025))  # False

# ===== 月份天数 =====
print(calendar.monthrange(2025, 2))  # (5, 28)
# 返回 (该月第一天是星期几, 该月天数)
# 2025年2月第一天是周六(5), 共28天

# ===== 生成日历数据 =====
weeks = calendar.monthcalendar(2025, 1)
print(weeks[0])  # 第一周: [0, 0, 1, 2, 3, 4, 5]
# 0 表示不属于该月的日期

# ===== 计算工作日 =====
import datetime
def count_workdays(year, month):
    """计算某月的工作日天数"""
    total_days = calendar.monthrange(year, month)[1]
    workdays = 0
    for day in range(1, total_days + 1):
        dt = datetime.date(year, month, day)
        if dt.weekday() < 5:  # 0-4 是周一到周五
            workdays += 1
    return workdays

print(count_workdays(2025, 1))  # 23
		  '''),
          const OutputBox(
            '    January 2025\nMo Tu We Th Fr Sa Su\n'
            '       1  2  3  4  5\n 6  7  8  9 10 11 12\n'
            '13 14 15 16 17 18 19\n20 21 22 23 24 25 26\n'
            '27 28 29 30 31\n\nTrue\nFalse\n(5, 28)\n[0, 0, 1, 2, 3, 4, 5]\n23',
          ),

          // ── 6. 正则入门 ──
          const DividerLine(),
          const SectionHeader('6. 正则表达式入门', icon: Icons.manage_search),
          const Paragraph(
            '正则表达式（Regular Expression）是用"模式"来匹配字符串的工具。'
            '核心概念：用一套特殊的语法描述"你想要什么样的字符串"。',
          ),
          const CodeBlock(r'''
import re

text = "我的邮箱是 alice@example.com，请发送邮件"

# ===== re.search：查找第一个匹配 =====
match = re.search(r"[\w.]+@[\w]+\.\w+", text)
if match:
    print(match.group())   # alice@example.com
    print(match.start())   # 匹配开始位置
    print(match.end())     # 匹配结束位置
    print(text[match.start():match.end()])  # 切片验证

# ===== re.findall：找到所有匹配 =====
text2 = "联系: bob@test.com, carol@demo.com"
emails = re.findall(r"[\w.]+@[\w]+\.\w+", text2)
print(emails)  # ['bob@test.com', 'carol@demo.com']

# ===== re.sub：替换匹配内容 =====
result = re.sub(r"\d{3}-\d{4}-\d{4}", "***-****-****",
                "电话: 138-1234-5678")
print(result)  # 电话: ***-****-****

# ===== re.split：按模式分割 =====
parts = re.split(r"[,\s;]+", "苹果, 香蕉; 橘子 西瓜")
print(parts)   # ['苹果', '香蕉', '橘子', '西瓜']
		  '''),
          const OutputBox(
            'alice@example.com\n7\n28\n'
            "alice@example.com\n['bob@test.com', 'carol@demo.com']\n"
            '电话: ***-****-****\n'
            "['苹果', '香蕉', '橘子', '西瓜']",
          ),

          // ── 7. 常用正则模式 ──
          const DividerLine(),
          const SectionHeader('7. 常用正则模式速查表', icon: Icons.table_chart),
          const Paragraph(
            '🔸 基础元字符：\n'
            '  .  匹配任意字符（除换行）  \\d 数字     \\w 字母/数字/下划线\n'
            '  \\s 空白字符              \\b 单词边界  ^ 行首    \$ 行尾\n\n'
            '🔸 数量词：\n'
            '  *  零次或多次    +  一次或多次    ?  零次或一次\n'
            '  {n} 恰好n次    {n,} 至少n次  {n,m} n到m次\n\n'
            '🔸 常用组合：\n'
            '  邮箱：r"[\\w.]+@[\\w]+\\.\\w+"\n'
            r'  手机号：r"^1[3-9]\d{9}$"' + '\n'
            '  网址：r"https?://[\\w./]+"\n'
            '  IP地址：r"\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}"\n'
            '  中文：r"[\\u4e00-\\u9fff]+"',
          ),
          const CodeBlock(r'''
import re

# ===== 元字符示例 =====
print(re.findall(r"\d+", "订单号: 12345, 价格: 99.9"))  # ['12345', '99', '9']
print(re.findall(r"\w+", "hello, 世界!"))               # ['hello', '世界']

# ===== 数量词示例 =====
print(re.findall(r"colou?r", "color colour"))          # ['color', 'colour']
print(re.findall(r"\d{3}-\d{4}", "010-8888 021-6666")) # ['010-8888', '021-6666']

# ===== 手机号验证 =====
def is_valid_phone(phone):
    """验证手机号：1开头的11位数字"""
    return bool(re.match(r"^1[3-9]\d{9}$", phone))

print(is_valid_phone("13812345678"))  # True
print(is_valid_phone("12345678901"))  # False

# ===== 贪婪 vs 非贪婪 =====
text = "<div>内容1</div><div>内容2</div>"
print(re.findall(r"<div>.*</div>", text))   # 贪婪：匹配整个
print(re.findall(r"<div>.*?</div>", text))  # 非贪婪：逐个匹配
		  '''),
          const OutputBox(
            "['12345', '99', '9']\n['hello', '世界']\n"
            "['color', 'colour']\n['010-8888', '021-6666']\n"
            "True\nFalse\n"
            "['<div>内容1</div><div>内容2</div>']\n"
            "['<div>内容1</div>', '<div>内容2</div>']",
          ),
          const TipBox(
            '贪婪 vs 非贪婪：* 和 + 默认是贪婪的（尽量多匹配）。'
            '加 ? 变成非贪婪（尽量少匹配）。处理 HTML 时非贪婪更安全。',
            type: TipType.tip,
          ),

          // ── 8. re.compile ──
          const DividerLine(),
          const SectionHeader('8. re.compile —— 正则编译优化', icon: Icons.speed),
          const Paragraph(
            '如果同一个正则要使用多次，用 re.compile() 预编译可以提高性能。'
            '编译后的 Pattern 对象比直接传字符串快 10-20 倍。',
          ),
          const CodeBlock(r'''
import re

# ===== 预编译正则 =====
email_pattern = re.compile(r"[\w.]+@[\w]+\.\w+")
phone_pattern = re.compile(r"1[3-9]\d{9}")

# ===== 使用编译后的正则 =====
text = "联系: alice@test.com, bob@test.com, 13812345678"
print(email_pattern.findall(text))   # ['alice@test.com', 'bob@test.com']
print(phone_pattern.search(text))    # <re.Match object>

# ===== 正则标志 Flags =====
# re.IGNORECASE / re.I  忽略大小写
# re.MULTILINE / re.M   多行模式（^$ 匹配每行）
# re.DOTALL / re.S      . 匹配换行符
# re.VERBOSE / re.X     允许正则中添加注释

pattern = re.compile(r"""
    \d{4}-\d{2}-\d{2}  # 日期
    \s+                 # 空格
    (INFO|ERROR|WARN)   # 级别
""", re.VERBOSE)

# ===== re.IGNORECASE 示例 =====
print(re.findall(r"python", "Python PYTHON python", re.I))
# ['Python', 'PYTHON', 'python']

# ===== re.MULTILINE 示例 =====
text = "第一行\n第二行\n第三行"
print(re.findall(r"^\w+", text))               # ['第一行']
print(re.findall(r"^\w+", text, re.MULTILINE))  # ['第一行', '第二行', '第三行']
		  '''),
          const TipBox(
            're.VERBOSE 允许在正则中添加空格和注释，对复杂正则非常有帮助。'
            '让正则变成"可读的代码"，而不是"天书"。',
            type: TipType.tip,
          ),
          const OutputBox(
            "['alice@test.com', 'bob@test.com']\n"
            '<re.Match object; span=(31, 42), match=\'13812345678\'>\n'
            "['Python', 'PYTHON', 'python']\n"
            "['第一行']\n['第一行', '第二行', '第三行']",
          ),

          // ── 9. 命名组与零宽断言 ──
          const DividerLine(),
          const SectionHeader('9. 命名组与零宽断言', icon: Icons.auto_fix_high),
          const Paragraph(
            '命名组让正则的匹配结果更有语义——用名字而不是数字索引。'
            '零宽断言匹配"位置"而不是"字符"——用于前后条件判断。',
          ),
          const CodeBlock(r'''
import re

# ===== 命名组 (?P<name>...) =====
text = "姓名: 张三, 年龄: 25, 城市: 北京"
pattern = r"姓名: (?P<name>\w+), 年龄: (?P<age>\d+)"

match = re.search(pattern, text)
if match:
    print(match.group("name"))   # 张三（按名字访问）
    print(match.group("age"))    # 25
    print(match.groupdict())     # {'name': '张三', 'age': '25'}

# ===== 零宽断言 =====
# 正向先行断言 (?=...)  后面跟着什么
# 负向先行断言 (?!)     后面不跟着什么
# 正向后发断言 (?<=...) 前面是什么
# 负向后发断言 (?<!)    前面不是什么

# 匹配后面跟"元"的数字
print(re.findall(r"\d+(?=元)", "价格: 100元, 数量: 50"))  # ['100']

# 匹配前面是"￥"的数字
print(re.findall(r"(?<=￥)\d+", "￥99 ￥199 美元50"))     # ['99', '199']

# 匹配不跟在"万"后面的数字
print(re.findall(r"\d+(?!万)", "3万 5 10万 20"))         # ['3', '5', '10', '20']

# ===== 实际应用：密码强度验证 =====
def validate_password(password):
    """至少8位，含大小写字母和数字"""

    has_upper = r"(?=.*[A-Z])"
    has_lower = r"(?=.*[a-z])"
    has_digit = r"(?=.*\d)"
    length = r".{8,}"

    pattern = has_upper + has_lower + has_digit + length
    return bool(re.match(pattern, password))

print(validate_password("Pass1234"))   # True
print(validate_password("pass1234"))   # False（无大写）
print(validate_password("Password"))   # False（无数字）
		  '''),
          const OutputBox(
            "张三\n25\n{'name': '张三', 'age': '25'}\n"
            "['100']\n['99', '199']\n"
            "['3', '5', '10', '20']\n"
            'True\nFalse\nFalse',
          ),

          // ── 10. 正则实战 ──
          const DividerLine(),
          const SectionHeader('10. 正则实战：日志解析', icon: Icons.terminal),
          const Paragraph(
            '下面的综合示例展示了如何用正则解析服务器日志。'
            '这是正则最经典的应用场景之一。',
          ),
          const CodeBlock(r'''
import re
from collections import Counter

# 模拟服务器日志
log = """
2025-01-15 10:30:25 INFO  用户 1001 登录成功
2025-01-15 10:31:10 ERROR 数据库连接超时
2025-01-15 10:32:00 WARN  磁盘使用率 85%
2025-01-15 10:33:15 INFO  用户 1002 退出登录
"""

# 1. 提取所有 ERROR 级别的日志
errors = re.findall(r"^.*ERROR.*$", log, re.MULTILINE)
for e in errors:
    print("错误:", e)

# 2. 解析日志中的时间、级别、消息（使用命名组）
pattern = re.compile(r"""
    (?P<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})  # 时间
    \s+(?P<level>INFO|ERROR|WARN)\s+                 # 级别
    (?P<message>.*)                                   # 消息
""", re.VERBOSE | re.MULTILINE)

for match in pattern.finditer(log):
    data = match.groupdict()
    print(f"[{data['level']}] {data['time']} → {data['message']}")

# 3. 提取所有用户 ID
user_ids = re.findall(r"用户 (\d+)", log)
print("在线用户:", user_ids)

# 4. 统计日志级别
levels = re.findall(r" (INFO|ERROR|WARN) ", log)
print(Counter(levels))
		  '''),
          const OutputBox(
            '错误: 2025-01-15 10:31:10 ERROR 数据库连接超时\n'
            '[INFO] 2025-01-15 10:30:25 → 用户 1001 登录成功\n'
            '[ERROR] 2025-01-15 10:31:10 → 数据库连接超时\n'
            '[WARN] 2025-01-15 10:32:00 → 磁盘使用率 85%\n'
            '[INFO] 2025-01-15 10:33:15 → 用户 1002 退出登录\n'
            "在线用户: ['1001', '1002']\n"
            "Counter({'INFO': 2, 'ERROR': 1, 'WARN': 1})",
          ),

          // ── 互动演示 ──
          const DividerLine(),
          const SectionHeader('🎮 互动演示', icon: Icons.play_circle_outline),
          const _DateTimeCalcDemo(),
          const _RegexMatchDemo(),

          // ── 小练习 ──
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const StepItem(
            step: 1,
            title: '日期格式转换',
            description: '用 strptime 解析 "2025-01-15" 再用 strftime 输出 "2025年01月15日 星期三"。',
          ),
          const StepItem(
            step: 2,
            title: '倒计时计算',
            description: '计算从今天到下一个元旦还有多少天、多少小时、多少分钟。',
          ),
          const StepItem(
            step: 3,
            title: 'URL 提取器',
            description: '用正则提取字符串中所有的 URL 链接（http/https 开头）。',
          ),
          const StepItem(
            step: 4,
            title: '身份证验证',
            description: '验证 18 位身份证号：前 17 位是数字，最后一位是数字或 X。',
          ),
          const StepItem(
            step: 5,
            title: 'HTML 标签清除',
            description: '用 re.sub 去除 HTML 标签 <...>，只保留纯文本内容。',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
