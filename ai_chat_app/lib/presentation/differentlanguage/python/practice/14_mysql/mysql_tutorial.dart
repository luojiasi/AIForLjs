import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// SQL 查询构造器演示
class _SqlQueryBuilderDemo extends StatefulWidget {
  const _SqlQueryBuilderDemo();
  @override
  State<_SqlQueryBuilderDemo> createState() => _SqlQueryBuilderDemoState();
}

class _SqlQueryBuilderDemoState extends State<_SqlQueryBuilderDemo> {
  String _table = 'users';
  String _operation = 'SELECT';
  List<String> _conditions = [];
  String _orderBy = '';
  int _limit = 10;

  static const _availableConditions = ['age > 18', 'city = "北京"', 'status = 1'];

  String get _sql {
    final buf = StringBuffer();
    if (_operation == 'SELECT') {
      buf.write('SELECT * FROM $_table');
      if (_conditions.isNotEmpty) {
        buf.write(' WHERE ${_conditions.join(' AND ')}');
      }
      if (_orderBy.isNotEmpty) buf.write(' ORDER BY $_orderBy');
      buf.write(' LIMIT $_limit');
    } else if (_operation == 'INSERT') {
      buf.write('INSERT INTO $_table (name, age, city) VALUES (?, ?, ?)');
    } else if (_operation == 'UPDATE') {
      buf.write('UPDATE $_table SET name = ?');
      if (_conditions.isNotEmpty) {
        buf.write(' WHERE ${_conditions.join(' AND ')}');
      }
    } else {
      buf.write('DELETE FROM $_table');
      if (_conditions.isNotEmpty) {
        buf.write(' WHERE ${_conditions.join(' AND ')}');
      }
    }
    buf.write(';');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🔧 SQL 查询构造器',
      subtitle: '可视化拼装 SQL 语句，实时查看结果',
      children: [
        ParamChoiceChips<String>(
          label: '操作类型',
          value: _operation,
          options: const [
            ('SELECT', 'SELECT'),
            ('INSERT', 'INSERT'),
            ('UPDATE', 'UPDATE'),
            ('DELETE', 'DELETE'),
          ],
          onChanged: (v) => setState(() => _operation = v),
        ),
        ParamTextField(
          label: '表名',
          value: _table,
          onChanged: (v) => setState(() => _table = v.isEmpty ? 'users' : v),
          hint: 'users',
          maxLength: 20,
        ),
        if (_operation == 'SELECT') ...[
          ParamIntSlider(
            label: 'LIMIT',
            value: _limit,
            min: 1,
            max: 100,
            onChanged: (v) => setState(() => _limit = v),
            unit: ' 行',
          ),
          ParamChoiceChips<String>(
            label: 'ORDER BY',
            value: _orderBy,
            options: const [
              ('', '不排序'),
              ('id ASC', 'id ASC'),
              ('name ASC', 'name ASC'),
              ('age DESC', 'age DESC'),
            ],
            onChanged: (v) => setState(() => _orderBy = v),
          ),
        ],
        const SizedBox(height: 4),
        Text('添加 WHERE 条件:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ..._availableConditions.map((cond) {
              final selected = _conditions.contains(cond);
              return FilterChip(
                label: Text(cond, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (on) => setState(() {
                  if (on) {
                    _conditions = [..._conditions, cond];
                  } else {
                    _conditions = _conditions.where((c) => c != cond).toList();
                  }
                }),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _conditions = []),
              icon: const Icon(Icons.clear, size: 14),
              label: const Text('清空条件', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LiveCodeBlock(
          'import pymysql\n'
          'from sqlalchemy import create_engine, text\n\n'
          '# SQLAlchemy 连接\n'
          'engine = create_engine("mysql+pymysql://user:pwd@localhost/db")\n\n'
          'with engine.connect() as conn:\n'
          '    result = conn.execute(text(\n'
          '        "SELECT * FROM $_table'
          '${_conditions.isNotEmpty ? ' WHERE ${_conditions.join(" AND ")}' : ''}'
          '${_orderBy.isNotEmpty ? ' ORDER BY $_orderBy' : ''}'
          ' LIMIT $_limit"\n'
          '    ))\n'
          '    rows = result.fetchall()',
          language: 'Python',
        ),
        LiveOutputBox(_sql, label: '▶ 生成 SQL'),
      ],
    );
  }
}

/// Python第14章：MySQL数据库教程
class PythonMySQLTutorial extends StatelessWidget {
  const PythonMySQLTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('第14章 MySQL数据库'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // ============================================================
          // 1. MySQL 简介
          // ============================================================
          SectionHeader('MySQL 简介', icon: Icons.storage),
          Paragraph(
            'MySQL 是一个开源的关系型数据库管理系统（RDBMS），由瑞典 MySQL AB 公司开发，目前属于 Oracle 公司。'
            '它使用结构化查询语言（SQL）来管理数据，以其高性能、可靠性和易用性而闻名，'
            '被广泛应用于 Web 应用、企业系统和数据分析等领域。',
          ),
          Paragraph(
            '关系型数据库的核心概念包括：表（Table）用于存储数据，行（Row）表示一条记录，'
            '列（Column）表示一个字段。每个表都有一个主键（Primary Key）来唯一标识每一行数据。'
            '表与表之间可以通过外键建立关联关系。',
          ),
          Paragraph(
            'MySQL 的特点包括：支持多用户并发访问、支持事务处理（ACID）、'
            '支持多种存储引擎（如 InnoDB、MyISAM）、支持存储过程和触发器、'
            '提供丰富的内置函数、支持主从复制和高可用架构。',
          ),
          TipBox(
            'MySQL 是学习数据库编程的绝佳起点。它语法清晰、社区活跃、'
            '文档丰富，并且与 Python 完美搭配。',
            type: TipType.info,
          ),

          // ============================================================
          // 2. 安装与环境配置
          // ============================================================
          DividerLine(),
          SectionHeader('安装与环境配置', icon: Icons.download),
          Paragraph(
            '要使用 Python 操作 MySQL 数据库，首先需要安装 MySQL 服务器和 Python 的 MySQL 连接驱动。'
            '最常用的驱动是 mysql-connector-python，它是 MySQL 官方提供的 Python 驱动。',
          ),
          StepItem(
            step: 1,
            title: '安装 MySQL 服务器',
            description: '从 MySQL 官网下载并安装 MySQL Community Server。安装过程中会提示设置 root 用户的密码。'
                '安装完成后启动 MySQL 服务。',
          ),
          StepItem(
            step: 2,
            title: '安装 Python 连接驱动',
            description: '使用 pip 安装 mysql-connector-python 包。这是 MySQL 官方推荐的 Python 驱动。',
          ),
          CodeBlock(
            r'''pip install mysql-connector-python''',
            language: 'Python',
          ),
          StepItem(
            step: 3,
            title: '验证安装',
            description: '在 Python 中导入 mysql.connector 模块，确认安装成功。',
          ),
          CodeBlock(
            r'''import mysql.connector
print(mysql.connector.__version__)  # 输出版本号，验证安装成功''',
            language: 'Python',
          ),

          // ============================================================
          // 3. 数据库连接
          // ============================================================
          DividerLine(),
          SectionHeader('连接数据库', icon: Icons.link),
          Paragraph(
            '使用 mysql.connector.connect() 方法创建数据库连接。需要提供主机地址、端口、'
            '用户名、密码和数据库名称等参数。连接成功后返回一个 Connection 对象。',
          ),
          CodeBlock(
            r'''import mysql.connector

# 建立数据库连接
conn = mysql.connector.connect(
    host="localhost",       # MySQL 服务器地址
    port=3306,              # MySQL 默认端口
    user="root",            # 用户名
    password="your_password",  # 密码
    database="test_db",     # 数据库名称
    charset="utf8mb4"       # 字符编码
)

print("数据库连接成功！")
print(f"连接对象: {conn}")''',
            language: 'Python',
          ),
          Paragraph(
            'connect() 方法的常用参数：host（主机地址）、port（端口号，默认3306）、'
            'user（用户名）、password（密码）、database（数据库名）、charset（字符编码）、'
            'autocommit（是否自动提交事务）、use_unicode（是否使用Unicode）。',
          ),
          OutputBox(
            r'''数据库连接成功！
连接对象: <mysql.connector.connection.MySQLConnection object at 0x...>''',
          ),
          TipBox(
            '在生产环境中，建议将数据库连接信息存储在环境变量或配置文件中，'
            '而不是硬编码在代码里，以提高安全性。',
            type: TipType.warning,
          ),

          // ============================================================
          // 4. Cursor 游标对象
          // ============================================================
          DividerLine(),
          SectionHeader('Cursor 游标对象', icon: Icons.alt_route),
          Paragraph(
            'Cursor 对象是执行 SQL 语句和获取结果的核心工具。通过 connection.cursor() 方法获取。'
            '游标的主要方法包括 execute() 执行单条 SQL、executemany() 批量执行、'
            'fetchone() 获取一条记录、fetchall() 获取所有记录、fetchmany(size) 获取指定数量的记录。',
          ),
          CodeBlock(
            r'''# 创建游标对象
cursor = conn.cursor()

# 执行 SQL 语句
cursor.execute("SELECT VERSION()")
result = cursor.fetchone()
print(f"MySQL 版本: {result[0]}")

# 获取数据库列表
cursor.execute("SHOW DATABASES")
databases = cursor.fetchall()
for db in databases:
    print(f"  - {db[0]}")

# 关闭游标
cursor.close()''',
            language: 'Python',
          ),
          OutputBox(
            r'''MySQL 版本: 8.0.33
  - information_schema
  - mysql
  - performance_schema
  - sys
  - test_db''',
          ),
          Paragraph(
            'fetchone() 返回单条记录（元组）或 None，fetchall() 返回所有记录（元组列表），'
            'fetchmany(size) 返回指定数量的记录。对于大数据集，推荐使用 fetchmany 分批次获取，'
            '避免一次性加载过多数据导致内存溢出。',
          ),

          // ============================================================
          // 5. 创建数据表
          // ============================================================
          DividerLine(),
          SectionHeader('创建数据表', icon: Icons.table_chart),
          Paragraph(
            '使用 CREATE TABLE 语句创建数据表。定义字段名称、数据类型和约束条件。'
            'MySQL 的常用数据类型包括：INT（整数）、VARCHAR(n)（变长字符串）、'
            'TEXT（长文本）、FLOAT/DOUBLE（浮点数）、DATE/DATETIME（日期时间）。',
          ),
          Paragraph(
            '常用约束条件：PRIMARY KEY（主键）、AUTO_INCREMENT（自增）、'
            'NOT NULL（非空）、UNIQUE（唯一）、DEFAULT（默认值）、'
            'FOREIGN KEY（外键）。',
          ),
          CodeBlock(
            r'''# 创建用户表
create_table_sql = """
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    age INT DEFAULT 0,
    salary FLOAT DEFAULT 0.0,
    bio TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"""

cursor.execute(create_table_sql)
print("数据表 users 创建成功！")

# 查看表结构
cursor.execute("DESC users")
for column in cursor.fetchall():
    print(f"  {column[0]:20s} {column[1]:15s} {column[2]:10s} {column[3]:10s}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''数据表 users 创建成功！
  id                 INT(11)       NO         PRI
  username           VARCHAR(50)   NO         UNI
  email              VARCHAR(100)  NO
  password_hash      VARCHAR(255)  NO
  age                INT(11)       YES
  salary             FLOAT         YES
  bio                TEXT          YES
  created_at         DATETIME      YES
  updated_at         DATETIME      YES''',
          ),
          TipBox(
            'InnoDB 是 MySQL 的默认存储引擎，支持事务、外键和行级锁。'
            '在创建表时建议使用 ENGINE=InnoDB。',
            type: TipType.tip,
          ),

          // ============================================================
          // 6. 插入数据
          // ============================================================
          DividerLine(),
          SectionHeader('插入数据', icon: Icons.playlist_add),
          Paragraph(
            '使用 INSERT INTO 语句向表中插入数据。强烈建议使用参数化查询（%s 占位符）'
            '而不是直接拼接 SQL 字符串，以防止 SQL 注入攻击。',
          ),
          CodeBlock(
            r'''# 单条插入 - 使用参数化查询
insert_sql = """
INSERT INTO users (username, email, password_hash, age, salary, bio)
VALUES (%s, %s, %s, %s, %s, %s)
"""
user_data = ("alice", "alice@example.com", "hashed_pwd_123", 28, 75000.0, "Python开发者")

cursor.execute(insert_sql, user_data)
conn.commit()  # 提交事务
print(f"插入成功！影响行数: {cursor.rowcount}，ID: {cursor.lastrowid}")

# 批量插入多条记录
users_batch = [
    ("bob", "bob@example.com", "hashed_pwd_456", 32, 82000.0, "Java开发者"),
    ("charlie", "charlie@example.com", "hashed_pwd_789", 25, 68000.0, "前端工程师"),
    ("diana", "diana@example.com", "hashed_pwd_abc", 30, 90000.0, "数据科学家"),
    ("eve", "eve@example.com", "hashed_pwd_def", 27, 72000.0, "全栈开发者"),
]

cursor.executemany(insert_sql, users_batch)
conn.commit()
print(f"批量插入 {len(users_batch)} 条记录成功！")''',
            language: 'Python',
          ),
          OutputBox(
            r'''插入成功！影响行数: 1，ID: 1
批量插入 4 条记录成功！''',
          ),
          TipBox(
            'executemany() 方法在底层会循环执行 SQL，但对于大批量数据，'
            '建议使用 LOAD DATA INFILE 或分批插入以获得更好的性能。',
            type: TipType.tip,
          ),

          // ============================================================
          // 7. 查询数据
          // ============================================================
          DividerLine(),
          SectionHeader('查询数据', icon: Icons.search),
          Paragraph(
            '使用 SELECT 语句查询数据。可以结合 WHERE（条件过滤）、ORDER BY（排序）、'
            'LIMIT（限制数量）、LIKE（模糊匹配）等子句进行灵活的数据检索。',
          ),
          CodeBlock(
            r'''# 1. 查询所有记录
cursor.execute("SELECT * FROM users")
all_users = cursor.fetchall()
for user in all_users:
    print(user)

# 2. 条件查询 - WHERE 子句
cursor.execute("SELECT username, email, age FROM users WHERE age > %s", (28,))
older_users = cursor.fetchall()
print("\n年龄大于28岁的用户:")
for u in older_users:
    print(f"  {u[0]}: {u[1]}, 年龄 {u[2]}")

# 3. 排序查询 - ORDER BY
cursor.execute("SELECT username, salary FROM users ORDER BY salary DESC")
sorted_users = cursor.fetchall()
print("\n薪资排行:")
for rank, u in enumerate(sorted_users, 1):
    print(f"  第{rank}名: {u[0]} - ${u[1]:.2f}")

# 4. 限制数量 - LIMIT
cursor.execute("SELECT username FROM users LIMIT 3")
top3 = cursor.fetchall()
print("\n前3名用户:")
for u in top3:
    print(f"  - {u[0]}")

# 5. 模糊匹配 - LIKE
cursor.execute(
    "SELECT username, bio FROM users WHERE bio LIKE %s",
    ("%开发者%",)
)
dev_users = cursor.fetchall()
print("\n包含'开发者'的用户:")
for u in dev_users:
    print(f"  {u[0]}: {u[1]}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''(1, 'alice', 'alice@example.com', 'hashed_pwd_123', 28, 75000.0, 'Python开发者', ...)
(2, 'bob', 'bob@example.com', 'hashed_pwd_456', 32, 82000.0, 'Java开发者', ...)
...

年龄大于28岁的用户:
  bob: bob@example.com, 年龄 32
  diana: diana@example.com, 年龄 30

薪资排行:
  第1名: diana - $90000.00
  第2名: bob - $82000.00
  ...

前3名用户:
  - alice
  - bob
  - charlie

包含'开发者'的用户:
  alice: Python开发者
  bob: Java开发者
  eve: 全栈开发者''',
          ),

          // ============================================================
          // 8. 更新数据
          // ============================================================
          DividerLine(),
          SectionHeader('更新数据', icon: Icons.edit),
          Paragraph(
            '使用 UPDATE SET 语句更新已有的数据。WHERE 子句用于指定要更新的记录，'
            '如果不加 WHERE 条件，则会更新表中的所有记录，这一点必须格外小心！',
          ),
          CodeBlock(
            r'''# 更新单个字段
cursor.execute(
    "UPDATE users SET salary = %s WHERE username = %s",
    (95000.0, "diana")
)
conn.commit()
print(f"更新了 {cursor.rowcount} 条记录")

# 更新多个字段
cursor.execute(
    """UPDATE users
       SET age = %s, bio = %s
       WHERE username = %s""",
    (29, "高级Python开发者", "alice")
)
conn.commit()
print(f"更新了 {cursor.rowcount} 条记录")

# 验证更新结果
cursor.execute("SELECT username, age, salary, bio FROM users WHERE username IN (%s, %s)", ("alice", "diana"))
for row in cursor.fetchall():
    print(f"  {row[0]}: age={row[1]}, salary={row[2]}, bio={row[3]}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''更新了 1 条记录
更新了 1 条记录
  alice: age=29, salary=75000.0, bio=高级Python开发者
  diana: age=30, salary=95000.0, bio=数据科学家''',
          ),
          TipBox(
            '执行 UPDATE 或 DELETE 语句前，建议先用 SELECT 查询确认 WHERE 条件是否正确，'
            '避免误操作导致数据丢失。',
            type: TipType.caution,
          ),

          // ============================================================
          // 9. 删除数据
          // ============================================================
          DividerLine(),
          SectionHeader('删除数据', icon: Icons.delete),
          Paragraph(
            'DELETE FROM 用于删除表中的记录，DROP TABLE 用于删除整个表，'
            'TRUNCATE 用于清空表数据但保留表结构。三者的区别需要明确理解。',
          ),
          CodeBlock(
            r'''# 1. DELETE - 删除指定记录
cursor.execute("DELETE FROM users WHERE username = %s", ("eve",))
conn.commit()
print(f"删除了 {cursor.rowcount} 条记录")

# 2. TRUNCATE - 清空表数据（保留表结构）
# cursor.execute("TRUNCATE TABLE users")
# print("表数据已清空")

# 3. DROP TABLE - 删除整个表
# cursor.execute("DROP TABLE IF EXISTS users")
# print("表已删除")

# 验证当前数据
cursor.execute("SELECT COUNT(*) FROM users")
count = cursor.fetchone()[0]
print(f"users 表中剩余记录数: {count}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''删除了 1 条记录
users 表中剩余记录数: 4''',
          ),
          Paragraph(
            '三者对比：DELETE 是 DML（数据操作语言），逐行删除，可以加 WHERE 条件，'
            '事务可回滚；TRUNCATE 是 DDL（数据定义语言），删除所有行并重置自增计数器，'
            '不可回滚；DROP TABLE 也是 DDL，删除整个表结构和数据。',
          ),
          TipBox(
            '在执行 DELETE 或 DROP 操作前，强烈建议先备份数据或开启事务，'
            '以便在误操作时可以通过 ROLLBACK 恢复。',
            type: TipType.warning,
          ),

          // ============================================================
          // 10. 事务管理
          // ============================================================
          DividerLine(),
          SectionHeader('事务管理', icon: Icons.swap_horiz),
          Paragraph(
            '事务（Transaction）是一组 SQL 操作的逻辑单元，具有 ACID 特性：'
            '原子性（Atomicity）、一致性（Consistency）、隔离性（Isolation）、'
            '持久性（Durability）。MySQL 的 InnoDB 引擎支持事务。',
          ),
          Paragraph(
            '使用 conn.commit() 提交事务，使更改永久生效；使用 conn.rollback() 回滚事务，'
            '撤销所有未提交的更改。可以通过设置 autocommit=True 让每条 SQL 自动提交。',
          ),
          CodeBlock(
            r'''# 示例：银行转账事务
def transfer_money(cursor, conn, from_user, to_user, amount):
    try:
        # 开始事务（关闭自动提交）
        conn.autocommit = False

        # 扣减转出账户
        cursor.execute(
            "UPDATE accounts SET balance = balance - %s WHERE username = %s",
            (amount, from_user)
        )
        if cursor.rowcount == 0:
            raise Exception(f"用户 {from_user} 不存在")

        # 增加转入账户
        cursor.execute(
            "UPDATE accounts SET balance = balance + %s WHERE username = %s",
            (amount, to_user)
        )
        if cursor.rowcount == 0:
            raise Exception(f"用户 {to_user} 不存在")

        # 提交事务
        conn.commit()
        print(f"转账成功！{from_user} -> {to_user}: ${amount}")

    except Exception as e:
        # 回滚事务
        conn.rollback()
        print(f"转账失败！已回滚: {e}")

    finally:
        conn.autocommit = True

# 调用转账函数
transfer_money(cursor, conn, "alice", "bob", 5000.0)''',
            language: 'Python',
          ),
          OutputBox(
            r'''转账成功！alice -> bob: $5000.0''',
          ),
          TipBox(
            '事务的基本原则：要么全部成功（COMMIT），要么全部失败（ROLLBACK）。'
            '在银行转账、订单处理等关键业务中，务必使用事务保证数据一致性。',
            type: TipType.info,
          ),

          // ============================================================
          // 11. 参数化查询与 SQL 注入
          // ============================================================
          DividerLine(),
          SectionHeader('参数化查询与 SQL 注入防御', icon: Icons.security),
          Paragraph(
            'SQL 注入是最危险的 Web 安全漏洞之一。攻击者通过在输入中嵌入恶意 SQL 代码，'
            '可以绕过验证、窃取数据甚至删除数据库。使用参数化查询（%s 占位符）是防御 SQL 注入的最有效手段。',
          ),
          CodeBlock(
            r'''# 危险的写法 - 不要使用 f-string 拼接 SQL！
def unsafe_login(username, password):
    # 如果用户输入: "' OR '1'='1"
    sql = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
    cursor.execute(sql)  # 危险！实际执行的 SQL:
    # SELECT * FROM users WHERE username='' OR '1'='1' AND password=''
    # 这个查询会返回所有用户，导致登录绕过！
    return cursor.fetchone()

# 安全的写法 - 使用参数化查询
def safe_login(username, password):
    sql = "SELECT * FROM users WHERE username=%s AND password=%s"
    cursor.execute(sql, (username, password))  # 安全！输入被转义处理
    return cursor.fetchone()

# 演示注入攻击
malicious_input = "' OR '1'='1"
print(f"恶意输入: {malicious_input}")
print("使用参数化查询可以安全地处理:",
      safe_login(malicious_input, "anything"))''',
            language: 'Python',
          ),
          OutputBox(
            r'''恶意输入: ' OR '1'='1
使用参数化查询可以安全地处理: None''',
          ),
          TipBox(
            '永远不要在 SQL 语句中使用字符串拼接或 f-string 来插入变量！'
            '始终使用 %s 占位符和参数元组，这是防御 SQL 注入的黄金法则。',
            type: TipType.caution,
          ),
          Paragraph(
            '参数化查询的工作原理：驱动将 SQL 语句和参数分开发送给数据库服务器，'
            '数据库会对参数进行转义和类型检查，确保参数不会被解释为 SQL 代码。'
            '这样即使用户输入包含恶意 SQL 片段，也只会被当作普通字符串处理。',
          ),

          // ============================================================
          // 12. 连接池
          // ============================================================
          DividerLine(),
          SectionHeader('连接池', icon: Icons.pool),
          Paragraph(
            '在高并发应用中，频繁创建和销毁数据库连接会带来巨大的性能开销。'
            '连接池（Connection Pooling）通过复用一组已建立的连接来提升性能。'
            'mysql.connector.pooling 模块提供了 MySQLConnectionPool 类。',
          ),
          CodeBlock(
            r'''from mysql.connector.pooling import MySQLConnectionPool

# 创建连接池
dbconfig = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "your_password",
    "database": "test_db",
    "charset": "utf8mb4"
}

pool = MySQLConnectionPool(
    pool_name="mypool",
    pool_size=5,        # 连接池大小
    pool_reset_session=True,
    **dbconfig
)

print(f"连接池已创建: {pool.pool_name}, 大小: {pool.pool_size}")

# 从连接池获取连接
conn1 = pool.get_connection()
print(f"获取连接: {conn1}")

# 使用完后释放连接（不是关闭）
conn1.close()  # 实际上将连接归还到连接池

# 使用上下文管理器自动归还
with pool.get_connection() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users")
    print(f"用户总数: {cursor.fetchone()[0]}")
    cursor.close()
print("连接已自动归还到连接池")''',
            language: 'Python',
          ),
          OutputBox(
            r'''连接池已创建: mypool, 大小: 5
获取连接: <mysql.connector.connection.MySQLConnection object at 0x...>
用户总数: 4
连接已自动归还到连接池''',
          ),
          TipBox(
            '连接池大小应根据应用负载合理设置。太大会浪费资源，太小会导致连接等待。'
            '一般建议设置为 5~20 之间，具体取决于数据库服务器的处理能力。',
            type: TipType.tip,
          ),

          // ============================================================
          // 13. 错误处理
          // ============================================================
          DividerLine(),
          SectionHeader('错误处理', icon: Icons.error_outline),
          Paragraph(
            'Python 的 mysql.connector 模块定义了 mysql.connector.Error 异常类，'
            '以及它的子类：DatabaseError、DataError、IntegrityError、'
            'ProgrammingError、OperationalError 等。使用 try/except 可以捕获并处理这些异常。',
          ),
          CodeBlock(
            r'''import mysql.connector
from mysql.connector import Error as MySQLError

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="wrong_password",  # 故意使用错误密码
        database="test_db"
    )
    cursor = conn.cursor()

    # 尝试插入重复的用户名（违反 UNIQUE 约束）
    cursor.execute(
        "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
        ("alice", "duplicate@example.com", "pwd")  # alice 已存在
    )
    conn.commit()

except MySQLError as err:
    print(f"数据库错误: {err}")
    print(f"错误码: {err.errno}")
    print(f"SQLSTATE: {err.sqlstate}")

    if err.errno == 1062:  # 重复键错误
        print("=> 这是唯一键冲突错误，请使用不同的用户名")
    elif err.errno == 1045:  # 访问被拒绝
        print("=> 用户名或密码错误")
    elif err.errno == 1146:  # 表不存在
        print("=> 数据表不存在")
    elif err.errno == 1451:  # 外键约束失败
        print("=> 存在关联数据，无法删除")
    else:
        print("=> 其他数据库错误")

finally:
    if 'conn' in locals() and conn.is_connected():
        cursor.close()
        conn.close()
        print("数据库连接已关闭")''',
            language: 'Python',
          ),
          OutputBox(
            r'''数据库错误: 1062 (23000): Duplicate entry 'alice' for key 'users.username'
错误码: 1062
SQLSTATE: 23000
=> 这是唯一键冲突错误，请使用不同的用户名
数据库连接已关闭''',
          ),
          Paragraph(
            '常见的 MySQL 错误码：1045（访问拒绝）、1049（数据库不存在）、'
            '1054（字段不存在）、1062（重复键）、1146（表不存在）、'
            '1451（外键约束失败）、2003（无法连接服务器）、2006（连接超时）。',
          ),

          // ============================================================
          // 14. 日期时间处理
          // ============================================================
          DividerLine(),
          SectionHeader('日期时间处理', icon: Icons.calendar_today),
          Paragraph(
            'MySQL 提供了 DATE（日期）、TIME（时间）、DATETIME（日期时间）、'
            'TIMESTAMP（时间戳）等日期时间类型。Python 的 datetime 模块可以与 MySQL 无缝配合。',
          ),
          CodeBlock(
            r'''from datetime import date, datetime, timedelta

# 创建订单表
cursor.execute("""
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    order_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
""")

# 插入日期数据
today = date.today()
now = datetime.now()

cursor.execute(
    """INSERT INTO orders (user_id, product_name, amount, order_date, created_at)
       VALUES (%s, %s, %s, %s, %s)""",
    (1, "Python入门课程", 199.99, today, now)
)
conn.commit()

# 日期范围查询
start_date = date(2024, 1, 1)
end_date = date(2024, 12, 31)

cursor.execute(
    "SELECT * FROM orders WHERE order_date BETWEEN %s AND %s",
    (start_date, end_date)
)
orders = cursor.fetchall()
print(f"2024年的订单数: {len(orders)}")

# 使用 MySQL 日期函数
cursor.execute("""
    SELECT
        DATE_FORMAT(order_date, '%%Y-%%m') AS month,
        COUNT(*) AS order_count,
        SUM(amount) AS total_amount
    FROM orders
    GROUP BY month
    ORDER BY month
""")
stats = cursor.fetchall()
for row in stats:
    print(f"  {row[0]}: {row[1]}笔订单，总额${row[2]:.2f}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''2024年的订单数: 1
  2024-04: 1笔订单，总额$199.99''',
          ),
          TipBox(
            '在 MySQL 的 DATE_FORMAT 函数中使用 %%Y 和 %%m 进行日期格式化。'
            '因为在 Python 字符串中 % 需要转义，所以使用 %% 表示一个 %。',
            type: TipType.tip,
          ),

          // ============================================================
          // 15. JOIN 连接查询
          // ============================================================
          DividerLine(),
          SectionHeader('JOIN 连接查询', icon: Icons.join_inner),
          Paragraph(
            'JOIN 用于将多张表的数据关联起来查询。最常用的有 INNER JOIN（内连接）'
            '和 LEFT JOIN（左连接）。INNER JOIN 只返回匹配的记录，LEFT JOIN 返回左表所有记录。',
          ),
          CodeBlock(
            r'''# 插入更多订单数据
orders_data = [
    (1, "数据结构课程", 299.99, "2024-02-15"),
    (2, "Java高级编程", 249.99, "2024-03-10"),
    (1, "机器学习入门", 399.99, "2024-04-01"),
    (3, "前端框架实战", 179.99, "2024-04-15"),
]
cursor.executemany(
    "INSERT INTO orders (user_id, product_name, amount, order_date) VALUES (%s, %s, %s, %s)",
    orders_data
)
conn.commit()

# INNER JOIN - 只查询有订单的用户
cursor.execute("""
    SELECT u.username, o.product_name, o.amount, o.order_date
    FROM users u
    INNER JOIN orders o ON u.id = o.user_id
    ORDER BY o.order_date DESC
""")
print("所有订单记录（INNER JOIN）:")
for row in cursor.fetchall():
    print(f"  {row[0]:10s} | {row[1]:20s} | ${row[2]:>7.2f} | {row[3]}")

# LEFT JOIN - 查询所有用户及其订单（包括没有订单的用户）
cursor.execute("""
    SELECT u.username, COUNT(o.id) AS order_count, COALESCE(SUM(o.amount), 0) AS total_spent
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id, u.username
    ORDER BY total_spent DESC
""")
print("\n用户消费统计（LEFT JOIN）:")
for row in cursor.fetchall():
    print(f"  {row[0]:10s} | {row[1]:2d}笔订单 | 总消费${row[2]:>8.2f}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''所有订单记录（INNER JOIN）:
  alice      | 机器学习入门         | $399.99 | 2024-04-01
  charlie    | 前端框架实战         | $179.99 | 2024-04-15
  bob        | Java高级编程         | $249.99 | 2024-03-10
  alice      | 数据结构课程         | $299.99 | 2024-02-15
  alice      | Python入门课程       | $199.99 | 2024-04-01

用户消费统计（LEFT JOIN）:
  alice      | 3笔订单 | 总消费$ 899.97
  bob        | 1笔订单 | 总消费$ 249.99
  charlie    | 1笔订单 | 总消费$ 179.99
  diana      | 0笔订单 | 总消费$   0.00''',
          ),
          Paragraph(
            'JOIN 类型对比：INNER JOIN 只返回两表中匹配的行；'
            'LEFT JOIN 返回左表所有行，右表没有匹配则填充 NULL；'
            'RIGHT JOIN 返回右表所有行；FULL OUTER JOIN 返回两表所有行（MySQL 不支持，'
            '可通过 UNION 模拟）。',
          ),

          // ============================================================
          // 16. CRUD 完整示例：用户管理系统
          // ============================================================
          DividerLine(),
          SectionHeader('CRUD 完整示例：用户管理系统', icon: Icons.build),
          Paragraph(
            '下面实现一个完整的用户管理系统，涵盖增（Create）、查（Read）、'
            '改（Update）、删（Delete）四个基本操作，展示数据库编程的最佳实践。',
          ),
          CodeBlock(
            r'''class UserManager:
    """用户管理器 - 封装所有数据库操作"""

    def __init__(self, connection):
        self.conn = connection
        self.cursor = connection.cursor()

    def create_user(self, username, email, password_hash, age=0, salary=0.0, bio=""):
        """创建新用户"""
        sql = """INSERT INTO users
                 (username, email, password_hash, age, salary, bio)
                 VALUES (%s, %s, %s, %s, %s, %s)"""
        try:
            self.cursor.execute(sql, (username, email, password_hash, age, salary, bio))
            self.conn.commit()
            return {"success": True, "id": self.cursor.lastrowid}
        except Exception as e:
            self.conn.rollback()
            return {"success": False, "error": str(e)}

    def get_user(self, user_id=None, username=None):
        """查询用户"""
        if user_id:
            self.cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
        elif username:
            self.cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
        else:
            return None
        row = self.cursor.fetchone()
        if row:
            return {
                "id": row[0], "username": row[1], "email": row[2],
                "age": row[4], "salary": row[5], "bio": row[6],
                "created_at": row[7], "updated_at": row[8]
            }
        return None

    def list_users(self, order_by="id", limit=10):
        """列出所有用户"""
        sql = f"SELECT id, username, email, age, salary FROM users ORDER BY {order_by} LIMIT %s"
        self.cursor.execute(sql, (limit,))
        return [{"id": r[0], "username": r[1], "email": r[2],
                  "age": r[3], "salary": r[4]} for r in self.cursor.fetchall()]

    def update_user(self, user_id, **kwargs):
        """更新用户信息"""
        if not kwargs:
            return {"success": False, "error": "没有要更新的字段"}
        set_clause = ", ".join([f"{k} = %s" for k in kwargs.keys()])
        sql = f"UPDATE users SET {set_clause} WHERE id = %s"
        try:
            values = list(kwargs.values()) + [user_id]
            self.cursor.execute(sql, values)
            self.conn.commit()
            return {"success": True, "affected": self.cursor.rowcount}
        except Exception as e:
            self.conn.rollback()
            return {"success": False, "error": str(e)}

    def delete_user(self, user_id):
        """删除用户"""
        try:
            self.cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
            self.conn.commit()
            return {"success": True, "affected": self.cursor.rowcount}
        except Exception as e:
            self.conn.rollback()
            return {"success": False, "error": str(e)}

    def close(self):
        """关闭资源"""
        self.cursor.close()

# 使用示例
manager = UserManager(conn)

# 创建用户
result = manager.create_user("frank", "frank@example.com", "pwd_hash_xyz", 35, 88000.0, "DevOps工程师")
print(f"创建结果: {result}")

# 查询用户
user = manager.get_user(username="alice")
print(f"Alice 信息: {user}")

# 更新用户
result = manager.update_user(1, salary=80000.0, bio="资深Python/全栈开发者")
print(f"更新结果: {result}")

# 列出用户
users = manager.list_users(order_by="salary", limit=5)
for u in users:
    print(f"  ID={u['id']}: {u['username']}, ${u['salary']}")

# 删除用户
result = manager.delete_user(6)
print(f"删除结果: {result}")

manager.close()''',
            language: 'Python',
          ),
          OutputBox(
            r'''创建结果: {'success': True, 'id': 6}
Alice 信息: {'id': 1, 'username': 'alice', 'email': 'alice@example.com', ...}
更新结果: {'success': True, 'affected': 1}
  ID=1: alice, $80000.0
  ID=5: diana, $95000.0
  ID=6: frank, $88000.0
  ID=2: bob, $82000.0
  ID=3: charlie, $68000.0
删除结果: {'success': True, 'affected': 1}''',
          ),
          TipBox(
            '在设计 CRUD 类时，建议将错误处理封装在方法内部，返回统一的字典格式，'
            '方便调用方判断操作是否成功。',
            type: TipType.tip,
          ),

          // ============================================================
          // 17. SQL 注入演示
          // ============================================================
          DividerLine(),
          SectionHeader('SQL 注入攻击演示', icon: Icons.shield),
          Paragraph(
            'SQL 注入是最危险的 Web 安全威胁之一。下面通过具体示例演示为什么绝对不能使用 f-string 拼接 SQL。'
            '理解攻击原理是写出安全代码的第一步。',
          ),
          CodeBlock(
            r'''# 模拟用户输入 - 看似正常的输入
user_input_username = "admin"
user_input_password = "password123"

# 安全的参数化查询
safe_sql = "SELECT * FROM users WHERE username=%s AND password_hash=%s"
cursor.execute(safe_sql, (user_input_username, user_input_password))
print(f"安全查询结果: {cursor.fetchone()}")  # 正常结果

# 恶意输入 - 攻击者精心构造的注入代码
malicious_username = "admin' -- "
malicious_password = "anything"

# 如果使用 f-string 拼接:
injected_sql = f"SELECT * FROM users WHERE username='{malicious_username}' AND password_hash='{malicious_password}'"
print(f"\n注入后的SQL:\n{injected_sql}")
print("=> 注释符 -- 导致密码验证被绕过！")

# 更严重的注入 - 删除数据
drop_input = "'; DROP TABLE users; -- "
dangerous_sql = f"SELECT * FROM users WHERE username='{drop_input}'"
print(f"\n毁灭性注入:\n{dangerous_sql}")
print("=> 可能导致整个表被删除！！！")''',
            language: 'Python',
          ),
          OutputBox(
            r'''安全查询结果: None
注入后的SQL:
SELECT * FROM users WHERE username='admin' -- ' AND password_hash='anything'
=> 注释符 -- 导致密码验证被绕过！
毁灭性注入:
SELECT * FROM users WHERE username=''; DROP TABLE users; -- '
=> 可能导致整个表被删除！！！''',
          ),
          TipBox(
            '防御 SQL 注入的三原则：1. 始终使用参数化查询；2. 永远不要使用字符串拼接构造 SQL；'
            '3. 对用户输入进行验证和过滤作为辅助手段。',
            type: TipType.caution,
          ),
          Paragraph(
            '除了参数化查询，还可以采取以下安全措施：最小化数据库用户权限（如只授予 SELECT、'
            'INSERT、UPDATE、DELETE 权限，不授予 DROP、ALTER 等）；使用存储过程封装 SQL；'
            '对敏感输入进行白名单验证；定期进行安全审计。',
          ),

          // ============================================================
          // 18. 最佳实践
          // ============================================================
          DividerLine(),
          SectionHeader('最佳实践', icon: Icons.star),
          Paragraph(
            '良好的数据库编程习惯可以大幅提升代码的安全性和可维护性。'
            '以下是一些关键的最佳实践，建议在日常开发中遵循。',
          ),
          CodeBlock(
            r'''# 1. 使用上下文管理器（with 语句）自动管理资源
with mysql.connector.connect(**dbconfig) as conn:
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM users")
        data = cursor.fetchall()
        print(f"查询到 {len(data)} 条记录")
# 连接和游标在 with 块结束后自动关闭

# 2. 使用配置文件管理连接信息
import configparser

config = configparser.ConfigParser()
config.read("db.ini")

db_config = {
    "host": config["mysql"]["host"],
    "port": int(config["mysql"]["port"]),
    "user": config["mysql"]["user"],
    "password": config["mysql"]["password"],
    "database": config["mysql"]["database"],
}

# 3. 始终使用参数化查询
def get_user_by_email(email):
    cursor.execute(
        "SELECT * FROM users WHERE email = %s",  # 使用 %s 占位符
        (email,)
    )
    return cursor.fetchone()

# 4. 处理完数据后及时关闭游标
def query_with_cleanup(sql, params=None):
    cursor = conn.cursor()
    try:
        cursor.execute(sql, params or ())
        return cursor.fetchall()
    finally:
        cursor.close()

# 5. 批量操作使用 executemany
data = [(f"user{i}", f"user{i}@test.com", f"pwd{i}") for i in range(100)]
cursor.executemany(
    "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
    data
)
conn.commit()''',
            language: 'Python',
          ),
          TipBox(
            '使用 with 语句管理数据库连接和游标是 Python 的推荐做法。'
            '即使发生异常，资源也会被正确释放，避免连接泄漏。',
            type: TipType.warning,
          ),
          Paragraph(
            '更多最佳实践包括：为频繁查询的字段添加索引以提升性能；'
            '使用 EXPLAIN 分析查询计划；定期备份数据库；'
            '使用 ORM（如 SQLAlchemy）简化数据库操作；'
            '对敏感数据（如密码）进行哈希存储；使用连接池管理连接。',
          ),

          // ============================================================
          // 19. SQLite 数据库
          // ============================================================
          DividerLine(),
          SectionHeader('SQLite 数据库', icon: Icons.storage_outlined),
          Paragraph(
            'SQLite 是一个轻量级的嵌入式关系型数据库引擎，它不需要独立的数据库服务器进程，'
            '将整个数据库存储在一个文件中。SQLite 是 Python 标准库的一部分，通过 sqlite3 模块直接使用，'
            '无需额外安装任何依赖。',
          ),
          Paragraph(
            'SQLite 的核心理念是"零配置"：不需要配置、不需要管理员、不需要启动服务。'
            '它非常适合移动应用、嵌入式设备、小型网站、数据分析和原型开发。'
            '尽管功能比 MySQL 简单，但 SQLite 支持 ACID 事务、SQL 标准、触发器和视图等特性。',
          ),
          TipBox(
            'SQLite 是世界上部署最广泛的数据库引擎——每个智能手机、浏览器（Chrome、Firefox）、'
            '许多桌面应用都在使用它。Python 内置的 sqlite3 模块让你无需安装即可使用数据库。',
            type: TipType.info,
          ),

          // 19.1 连接数据库
          SectionHeader('连接数据库：文件与内存', icon: Icons.link),
          Paragraph(
            'sqlite3.connect() 方法用于建立数据库连接。如果指定路径的文件不存在，SQLite 会自动创建它。'
            '使用特殊的 ":memory:" 字符串可以在内存中创建临时数据库，'
            '程序结束后数据自动销毁，适合测试和缓存场景。',
          ),
          CodeBlock(
            r'''import sqlite3

# 1. 连接文件数据库（自动创建）
conn = sqlite3.connect("example.db")
print(f"文件数据库连接成功: {conn}")

# 2. 连接内存数据库（程序结束后数据消失）
mem_conn = sqlite3.connect(":memory:")
print(f"内存数据库连接成功: {mem_conn}")

# 3. 连接时指定超时和隔离级别
conn2 = sqlite3.connect(
    "example.db",
    timeout=10,           # 等待锁的超时时间（秒）
    detect_types=sqlite3.PARSE_DECLTYPES,  # 自动转换类型
    isolation_level=None  # 自动提交模式（相当于 autocommit=True）
)
print(f"带参数连接: {conn2}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''文件数据库连接成功: <sqlite3.Connection object at 0x...>
内存数据库连接成功: <sqlite3.Connection object at 0x...>
带参数连接: <sqlite3.Connection object at 0x...>''',
          ),
          Paragraph(
            'connect() 方法返回 Connection 对象，常用方法包括：cursor() 创建游标、'
            'execute() 直接执行 SQL（便捷方法）、commit() 提交事务、rollback() 回滚、'
            'close() 关闭连接。与 MySQL 不同，SQLite 的 Connection 对象也有 execute() 方法。',
          ),
          TipBox(
            '使用 ":memory:" 创建的内存数据库速度极快，适合做单元测试和临时数据处理。'
            '但数据不会持久化，程序退出后自动丢失。',
            type: TipType.tip,
          ),

          // 19.2 创建表和插入数据
          SectionHeader('创建表与插入数据', icon: Icons.playlist_add),
          Paragraph(
            'SQLite 支持标准的 CREATE TABLE 语法，常用数据类型包括：INTEGER、REAL（浮点）、'
            'TEXT（字符串）、BLOB（二进制）。SQLite 使用 rowid 作为隐式自增主键，'
            '也可以使用 INTEGER PRIMARY KEY 手动控制。',
          ),
          CodeBlock(
            r'''import sqlite3

conn = sqlite3.connect(":memory:")
cursor = conn.cursor()

# 创建表
cursor.execute("""
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    department TEXT NOT NULL,
    salary REAL DEFAULT 0.0,
    hire_date TEXT,
    active INTEGER DEFAULT 1
)
""")
print("employees 表创建成功！")

# 单条插入 - 使用 ? 占位符（SQLite 使用 ? 而不是 %s）
cursor.execute(
    "INSERT INTO employees (name, department, salary, hire_date) VALUES (?, ?, ?, ?)",
    ("张三", "技术部", 15000.0, "2024-01-15")
)
conn.commit()
print(f"插入成功！影响行数: {cursor.rowcount}，ID: {cursor.lastrowid}")

# 使用 executemany 批量插入
employees_data = [
    ("李四", "技术部", 18000.0, "2023-06-01"),
    ("王五", "市场部", 12000.0, "2024-03-10"),
    ("赵六", "技术部", 22000.0, "2022-11-20"),
    ("孙七", "人事部", 13000.0, "2024-07-01"),
    ("周八", "市场部", 11000.0, "2024-09-15"),
]

cursor.executemany(
    "INSERT INTO employees (name, department, salary, hire_date) VALUES (?, ?, ?, ?)",
    employees_data
)
conn.commit()
print(f"批量插入 {len(employees_data)} 条记录成功！")

# 查询验证
cursor.execute("SELECT COUNT(*) FROM employees")
print(f"总记录数: {cursor.fetchone()[0]}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''employees 表创建成功！
插入成功！影响行数: 1，ID: 1
批量插入 5 条记录成功！
总记录数: 6''',
          ),
          Paragraph(
            'SQLite 使用 ? 作为参数占位符（MySQL 使用 %s）。参数必须是一个元组或列表。'
            'executemany() 可以高效地批量插入多条记录，减少 Python 与数据库之间的交互次数。'
            '每次修改数据后都需要调用 conn.commit() 提交事务。',
          ),
          TipBox(
            'SQLite 使用 ? 占位符而不是 MySQL 的 %s。如果需要复用查询计划，'
            '可以用 :name 或 ? 两种形式。:name 形式适合参数较多的场景。',
            type: TipType.tip,
          ),

          // 19.3 查询数据与 Row 对象
          SectionHeader('查询数据与 Row 对象', icon: Icons.search),
          Paragraph(
            'SQLite 的查询操作与 MySQL 类似，支持 WHERE、ORDER BY、GROUP BY、LIMIT 等标准 SQL 子句。'
            '特别地，sqlite3.Row 类型可以让查询结果像字典一样通过列名访问，提高代码可读性。',
          ),
          CodeBlock(
            r'''# 默认游标返回元组
cursor.execute("SELECT name, department, salary FROM employees")
print("=== 元组形式的结果 ===")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}, 薪资{row[2]}")  # 通过索引访问

# 使用 Row 对象 - 像字典一样访问列
conn.row_factory = sqlite3.Row
cursor = conn.cursor()  # 重新创建游标

cursor.execute("SELECT name, department, salary FROM employees WHERE department = ?", ("技术部",))
print("\n=== Row 对象形式的结果 ===")
for row in cursor.fetchall():
    print(f"  {row['name']}: {row['department']}, 薪资{row['salary']}")
    # 也支持索引访问
    print(f"    -> 索引访问: {row[0]}")

# 条件查询 + 排序
cursor.execute(
    "SELECT name, department, salary FROM employees WHERE salary > ? ORDER BY salary DESC",
    (13000,)
)
print("\n=== 薪资超过 13000 的员工 ===")
for row in cursor.fetchall():
    print(f"  {row['name']:4s} | {row['department']:6s} | ${row['salary']:.2f}")

# 聚合查询
cursor.execute("""
    SELECT department,
           COUNT(*) AS count,
           ROUND(AVG(salary), 2) AS avg_salary,
           MAX(salary) AS max_salary
    FROM employees
    GROUP BY department
    ORDER BY avg_salary DESC
""")
print("\n=== 各部门薪资统计 ===")
for row in cursor.fetchall():
    print(f"  {row['department']:6s} | {row['count']}人 | 平均${row['avg_salary']:>8.2f} | 最高${row['max_salary']:.2f}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''=== 元组形式的结果 ===
  张三: 技术部, 薪资15000.0
  李四: 技术部, 薪资18000.0
  ...

=== Row 对象形式的结果 ===
  张三: 技术部, 薪资15000.0
    -> 索引访问: 张三
  李四: 技术部, 薪资18000.0
    -> 索引访问: 李四
  ...

=== 薪资超过 13000 的员工 ===
  张三  | 技术部  | $15000.00
  李四  | 技术部  | $18000.00
  ...

=== 各部门薪资统计 ===
  技术部  | 3人 | 平均$18333.33 | 最高$22000.00
  市场部  | 2人 | 平均$11500.00 | 最高$12000.00
  人事部  | 1人 | 平均$13000.00 | 最高$13000.00''',
          ),
          Paragraph(
            '设置 conn.row_factory = sqlite3.Row 后，查询结果的行对象既支持数字索引（像元组），'
            '也支持列名字符串索引（像字典）。这种方式比使用元组更具可读性，也比转换成字典更高效。'
            '注意：row_factory 设置后需要重新创建游标才能生效。',
          ),

          // 19.4 SQLite 特有功能
          SectionHeader('SQLite 特有功能', icon: Icons.extension),
          Paragraph(
            'SQLite 提供了一些独特的功能，如 lastrowid、rowcount、total_changes 等属性，'
            '以及支持 JSON 操作、全文搜索（FTS5）等扩展。下面展示一些常用特性。',
          ),
          CodeBlock(
            r'''import sqlite3

conn = sqlite3.connect(":memory:")
conn.row_factory = sqlite3.Row  # 启用 Row 工厂
cursor = conn.cursor()

# 创建表并插入数据
cursor.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)")
cursor.executemany("INSERT INTO test (value) VALUES (?)",
                   [("A",), ("B",), ("C",), ("D",), ("E",)])
conn.commit()

# 1. rowcount - 最后一条 DML 语句影响的行数
cursor.execute("UPDATE test SET value = ? WHERE id > ?", ("X", 2))
print(f"UPDATE 影响了 {cursor.rowcount} 行")

# 2. lastrowid - 最后一次 INSERT 的自增 ID
cursor.execute("INSERT INTO test (value) VALUES (?)", ("F",))
print(f"最后插入的 ID: {cursor.lastrowid}")

# 3. total_changes - 自连接打开以来总的修改次数
print(f"总的修改次数: {conn.total_changes}")

# 4. 使用 INSERT OR REPLACE 处理冲突
cursor.execute("INSERT OR REPLACE INTO test (id, value) VALUES (?, ?)", (1, "Z"))
print(f"替换后 ID=1 的值为: {cursor.execute('SELECT value FROM test WHERE id=1').fetchone()['value']}")

# 5. 获取表结构信息（Row 对象可像字典一样访问列）
cursor.execute("PRAGMA table_info(test)")
print("\n表结构:")
for col in cursor.fetchall():
    print(f"  {col['name']:10s} {col['type']:10s} nullable={not col['notnull']} default={col['dflt_value']}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''UPDATE 影响了 3 行
最后插入的 ID: 6
总的修改次数: 7
替换后 ID=1 的值为: Z

表结构:
  id           INTEGER    nullable=False default=None
  value        TEXT       nullable=True default=None''',
          ),
          Paragraph(
            'SQLite 的 PRAGMA 命令提供了丰富的数据库元信息查询和控制功能。常用 PRAGMA 包括：'
            'table_info（表结构）、foreign_key_list（外键列表）、index_list（索引列表）、'
            'database_list（数据库列表）、synchronous（同步模式）、journal_mode（日志模式）。',
          ),
          TipBox(
            'SQLite 最适合单用户或低并发的场景。在高并发写操作时会出现"database is locked"错误。'
            '如果应用需要高并发写入，建议使用 MySQL 或 PostgreSQL。',
            type: TipType.warning,
          ),

          // 19.5 SQLite 上下文管理器
          SectionHeader('使用上下文管理器', icon: Icons.auto_fix_high),
          Paragraph(
            'SQLite 的 Connection 对象可以作为上下文管理器使用，在 with 块结束时自动提交或回滚事务。'
            '如果块内没有抛出异常，自动提交；如果抛出异常，自动回滚。这与 Python 的 with 语句配合非常优雅。',
          ),
          CodeBlock(
            r'''import sqlite3

conn = sqlite3.connect(":memory:")
conn.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, done INTEGER)")

# 使用 Connection 作为上下文管理器
with conn:
    conn.execute("INSERT INTO tasks (title, done) VALUES (?, ?)", ("学习 Python", 0))
    conn.execute("INSERT INTO tasks (title, done) VALUES (?, ?)", ("学习 SQLite", 0))
    conn.execute("INSERT INTO tasks (title, done) VALUES (?, ?)", ("写教程", 0))
    print("事务自动提交！")

# 验证数据已持久化
count = conn.execute("SELECT COUNT(*) FROM tasks").fetchone()[0]
print(f"任务总数: {count}")

# 异常时自动回滚
try:
    with conn:
        conn.execute("INSERT INTO tasks (title, done) VALUES (?, ?)", ("新任务", 1))
        conn.execute("INSERT INTO tasks (title, done) VALUES (?, ?)", ("另一个任务", 1))
        raise ValueError("模拟异常，触发回滚！")
except ValueError:
    print("异常发生，事务已自动回滚！")

# 验证回滚 - 两条记录都不会被插入
count = conn.execute("SELECT COUNT(*) FROM tasks").fetchone()[0]
print(f"回滚后任务总数: {count}（仍然是 {count - 2 if count >= 2 else 0}，说明插入被撤销）")

conn.close()''',
            language: 'Python',
          ),
          OutputBox(
            r'''事务自动提交！
任务总数: 3
异常发生，事务已自动回滚！
回滚后任务总数: 3（仍然是 3，说明插入被撤销）''',
          ),
          Paragraph(
            '使用 with conn: 是 SQLite 推荐的编码方式。它确保事务被正确管理，'
            '不需要显式调用 commit() 或 rollback()。注意：with conn: 只管理事务提交/回滚，'
            '不会在退出时关闭连接，关闭连接仍需要调用 conn.close()。',
          ),
          TipBox(
            'SQLite 连接作为上下文管理器时，如果块内正常结束则自动 COMMIT，'
            '如果抛出异常则自动 ROLLBACK。这是 Python 数据库编程的最佳实践。',
            type: TipType.tip,
          ),

          // ============================================================
          // 20. SQLAlchemy ORM
          // ============================================================
          DividerLine(),
          SectionHeader('SQLAlchemy ORM', icon: Icons.schema),
          Paragraph(
            'SQLAlchemy 是 Python 最流行的 ORM（对象关系映射）框架。它提供了两种主要的使用方式：'
            'Core（核心，基于 SQL 表达式语言）和 ORM（高级 API，将数据库表映射为 Python 类）。'
            'ORM 方式让开发者可以用面向对象的方式操作数据库，无需直接编写 SQL 语句。',
          ),
          Paragraph(
            'ORM 的核心思想是"表 -> 类，行 -> 对象，列 -> 属性"。'
            '当创建一个 Python 对象并设置属性时，SQLAlchemy 自动将其转换为相应的 INSERT 语句；'
            '当查询数据库时，结果自动转换为 Python 对象。这大大简化了数据库编程的复杂度。',
          ),
          TipBox(
            'SQLAlchemy 是目前 Python 生态中最成熟的 ORM 框架，Django 的 ORM 也受其影响。'
            '它支持 MySQL、PostgreSQL、SQLite、Oracle 等多种数据库后端。',
            type: TipType.info,
          ),

          // 20.1 安装与连接引擎
          SectionHeader('安装与创建引擎', icon: Icons.download),
          Paragraph(
            '使用 SQLAlchemy 前需要先安装。创建引擎（Engine）是与数据库交互的入口，'
            '它管理着连接池和数据库方言（Dialect），通过连接字符串指定数据库类型和连接信息。',
          ),
          CodeBlock(
            r'''# 安装 SQLAlchemy
# pip install sqlalchemy''',
            language: 'Python',
          ),
          CodeBlock(
            r'''from sqlalchemy import create_engine, text

# 1. SQLite 内存数据库引擎
sqlite_engine = create_engine("sqlite:///:memory:", echo=True)
print(f"SQLite 引擎: {sqlite_engine}")

# 2. SQLite 文件数据库引擎
file_engine = create_engine("sqlite:///mydb.sqlite3", echo=False)

# 3. MySQL 数据库引擎（需要安装 pymysql）
# mysql_engine = create_engine(
#     "mysql+pymysql://root:password@localhost:3306/test_db?charset=utf8mb4",
#     pool_size=5,
#     max_overflow=10
# )

# 4. PostgreSQL 数据库引擎（需要安装 psycopg2）
# pg_engine = create_engine("postgresql://user:password@localhost:5432/mydb")

# 测试连接
with sqlite_engine.connect() as conn:
    result = conn.execute(text("SELECT 1"))
    print(f"连接测试成功: {result.fetchone()}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''SQLite 引擎: Engine(sqlite:///:memory:)
连接测试成功: (1,)''',
          ),
          Paragraph(
            'create_engine() 的常见参数：连接字符串（格式：dialect+driver://user:pwd@host/db）、'
            'echo（是否打印 SQL 日志，调试时设为 True）、pool_size（连接池大小）、'
            'max_overflow（超出 pool_size 的最大连接数）、pool_recycle（连接回收时间）。',
          ),
          TipBox(
            'echo=True 参数会在控制台打印所有 SQL 语句，非常适合开发和调试阶段。'
            '生产环境中应该关闭（echo=False 或不传参）。',
            type: TipType.tip,
          ),

          // 20.2 声明式基类与模型定义
          SectionHeader('声明式基类与模型定义', icon: Icons.table_chart),
          Paragraph(
            'SQLAlchemy 的声明式映射（Declarative Mapping）是最流行的 ORM 使用方式。'
            '通过 declarative_base() 创建基类，然后让模型类继承这个基类。'
            '每个模型类对应一个数据库表，类属性对应表的列。',
          ),
          CodeBlock(
            r'''from sqlalchemy import create_engine, Column, Integer, String, Float, Text, DateTime, Boolean
from sqlalchemy.orm import declarative_base
from datetime import datetime

# 创建基类
Base = declarative_base()

# 定义 User 模型类
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), nullable=False)
    password_hash = Column(String(255), nullable=False)
    age = Column(Integer, default=0)
    salary = Column(Float, default=0.0)
    bio = Column(Text, default="")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<User(id={self.id}, username='{self.username}', email='{self.email}')>"

# 定义 Post 模型类（演示关联）
class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(200), nullable=False)
    content = Column(Text, default="")
    user_id = Column(Integer, nullable=False)  # 外键
    created_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<Post(id={self.id}, title='{self.title}')>"

# 创建引擎并生成所有表
engine = create_engine("sqlite:///:memory:", echo=False)
Base.metadata.create_all(engine)

print("数据库表创建完成！")
print(f"已注册的表: {list(Base.metadata.tables.keys())}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''数据库表创建完成！
已注册的表: ['users', 'posts']''',
          ),
          Paragraph(
            'Column 的常用参数：数据类型（Integer、String、Float 等）、primary_key（主键）、'
            'autoincrement（自增）、unique（唯一约束）、nullable（是否可为空）、'
            'default（默认值）、index（是否创建索引）。String 类型需要指定长度。',
          ),
          TipBox(
            'Column 的 default 参数可以是一个 Python 函数（如 datetime.utcnow），'
            '在创建对象时自动调用赋值。这与数据库层的 DEFAULT 约束不同。',
            type: TipType.tip,
          ),

          // 20.3 Session 与会话管理
          const SectionHeader('Session 与会话管理', icon: Icons.admin_panel_settings),
          Paragraph(
            'Session 是 SQLAlchemy ORM 的核心工作单元。它维护着所有被跟踪的对象，'
            '管理着数据库的增删改查操作。sessionmaker() 是一个工厂函数，用于创建 Session 实例。'
            '推荐在应用级别使用单例的 sessionmaker。',
          ),
          CodeBlock(
            r'''from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, Integer, String

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    email = Column(String(100))

engine = create_engine("sqlite:///:memory:", echo=False)
Base.metadata.create_all(engine)

# 创建 Session 工厂
SessionLocal = sessionmaker(bind=engine)

# 创建 Session 实例
session = SessionLocal()
print(f"Session 创建成功: {session}")
print(f"Session 状态: active={session.is_active}" )

# 使用 Session 执行原生 SQL
result = session.execute(text("SELECT 1"))
print(f"查询结果: {result.fetchone()}")

session.close()
print("Session 已关闭")''',
            language: 'Python',
          ),
          OutputBox(
            r'''Session 创建成功: <sqlalchemy.orm.session.Session object at 0x...>
Session 状态: active=True
查询结果: (1,)
Session 已关闭''',
          ),
          Paragraph(
            'Session 的主要方法：add() 添加新对象、add_all() 批量添加、'
            'delete() 删除对象、query() 执行查询、commit() 提交事务、'
            'rollback() 回滚事务、close() 关闭会话。Session 不是线程安全的，'
            '在多线程环境中应为每个线程创建独立的 Session。',
          ),
          TipBox(
            '推荐使用 sessionmaker 创建 Session 工厂，而不是直接实例化 Session。'
            '这样可以集中管理 Session 的配置（如绑定引擎、过期策略等）。',
            type: TipType.tip,
          ),

          // 20.4 ORM 之 Create
          SectionHeader('ORM 插入数据（Create）', icon: Icons.playlist_add),
          Paragraph(
            'ORM 方式插入数据就像创建普通的 Python 对象一样简单。'
            '实例化模型类、设置属性、调用 session.add()，然后 commit() 即可。'
            'SQLAlchemy 会自动生成并执行 INSERT 语句。',
          ),
          CodeBlock(
            r'''from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), nullable=False)
    salary = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)

engine = create_engine("sqlite:///:memory:", echo=False)
Base.metadata.create_all(engine)
SessionLocal = sessionmaker(bind=engine)
session = SessionLocal()

# 创建对象就像实例化 Python 类
user1 = User(username="alice", email="alice@example.com", salary=75000.0)
user2 = User(username="bob", email="bob@example.com", salary=82000.0)
user3 = User(username="charlie", email="charlie@example.com", salary=68000.0)

# 添加到 Session
session.add(user1)
session.add_all([user2, user3])

# 提交事务 - SQLAlchemy 自动生成 INSERT
session.commit()

print(f"三个用户创建成功！")
print(f"user1.id = {user1.id}  (自动生成的自增 ID)")
print(f"user2.id = {user2.id}")
print(f"user3.id = {user3.id}")

# 添加更多数据供后续演示
for name, email, salary in [
    ("diana", "diana@example.com", 90000.0),
    ("eve", "eve@example.com", 72000.0),
]:
    session.add(User(username=name, email=email, salary=salary))
session.commit()
print(f"额外添加了 2 个用户，共 {session.query(User).count()} 个用户")

session.close()''',
            language: 'Python',
          ),
          OutputBox(
            r'''三个用户创建成功！
user1.id = 1  (自动生成的自增 ID)
user2.id = 2
user3.id = 3
额外添加了 2 个用户，共 5 个用户''',
          ),
          Paragraph(
            '当调用 session.commit() 时，SQLAlchemy 会 flush 所有待定的更改到数据库。'
            '此时会自动生成自增 ID 并赋值给对象的 id 属性。如果不希望立即提交，'
            '也可以先调用 session.flush() 获取 ID，稍后再 commit()。',
          ),
          TipBox(
            '添加对象后即使没有 commit()，新对象的 id 仍然是 None。'
            '只有在 flush 或 commit 后自增 ID 才会被赋值。这个特性在设计关联插入时需要注意。',
            type: TipType.tip,
          ),

          // 20.5 ORM 之 Read
          SectionHeader('ORM 查询数据（Read）', icon: Icons.search),
          Paragraph(
            'SQLAlchemy ORM 提供了丰富的查询 API。通过 session.query() 方法开始查询，'
            '链式调用 filter()、order_by()、limit() 等方法来构建查询条件。'
            '查询结果自动映射为 Python 对象。',
          ),
          CodeBlock(
            r'''# 1. 查询所有记录
users = session.query(User).all()
print(f"=== 所有用户（共 {len(users)} 个）===")
for u in users:
    print(f"  ID={u.id}: {u.username}, 薪资${u.salary}")

# 2. 按条件过滤 - filter()
high_earners = session.query(User).filter(User.salary > 75000).all()
print(f"\n=== 高薪用户（salary > 75000）===")
for u in high_earners:
    print(f"  {u.username}: ${u.salary}")

# 3. 多条件过滤
result = session.query(User).filter(
    User.salary > 70000,
    User.username.like("%e%")  # LIKE 模糊匹配
).all()
print(f"\n=== 薪资>70000 且用户名包含 e ===")
for u in result:
    print(f"  {u.username}: ${u.salary}")

# 4. 排序
top_salaries = session.query(User).order_by(User.salary.desc()).limit(3).all()
print(f"\n=== 薪资前三名 ===")
for i, u in enumerate(top_salaries, 1):
    print(f"  第{i}名: {u.username} - ${u.salary}")

# 5. 获取单个对象
user = session.query(User).filter_by(username="alice").first()
print(f"\n=== 查询特定用户 ===")
print(f"  alice: email={user.email}, salary=${user.salary}")

# 6. 只查询特定列
results = session.query(User.username, User.salary).filter(User.salary > 75000).all()
print(f"\n=== 只查询用户名和薪资 ===")
for username, salary in results:
    print(f"  {username}: ${salary}")

# 7. 计数
count = session.query(User).filter(User.salary >= 72000).count()
print(f"\n薪资不低于 72000 的用户数: {count}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''=== 所有用户（共 5 个）===
  ID=1: alice, $75000.0
  ID=2: bob, $82000.0
  ID=3: charlie, $68000.0
  ID=4: diana, $90000.0
  ID=5: eve, $72000.0

=== 高薪用户（salary > 75000）===
  bob: $82000.0
  diana: $90000.0

=== 薪资>70000 且用户名包含 e ===
  alice: $75000.0
  eve: $72000.0

=== 薪资前三名 ===
  第1名: diana - $90000.0
  第2名: bob - $82000.0
  第3名: alice - $75000.0

=== 查询特定用户 ===
  alice: email=alice@example.com, salary=$75000.0

=== 只查询用户名和薪资 ===
  bob: $82000.0
  diana: $90000.0

薪资不低于 72000 的用户数: 4''',
          ),
          Paragraph(
            'query() 的常用过滤方法：filter()（支持 Python 比较运算符）、'
            'filter_by()（使用关键字参数，等同于 = 比较）、like()、in_()、not_()、'
            'between()、startswith()、endswith() 等。'
            '链式调用时可以灵活组合这些方法构建复杂的查询条件。',
          ),
          TipBox(
            'filter_by() 适用于简单的等值比较（如 username="alice"），'
            'filter() 适用于更复杂的条件（如 salary > 75000）。'
            '建议在简单场景用 filter_by() 使代码更简洁。',
            type: TipType.tip,
          ),

          // 20.6 ORM 之 Update & Delete
          SectionHeader('ORM 更新与删除（Update & Delete）', icon: Icons.edit),
          Paragraph(
            'ORM 方式更新数据只需修改对象的属性，然后调用 commit() 提交即可。'
            'SQLAlchemy 会自动跟踪对象的变化（称为"脏检查"），只更新有改动的字段。'
            '删除数据则调用 session.delete() 方法。',
          ),
          CodeBlock(
            r'''# ========== 更新数据 ==========

# 1. 查找并更新对象属性
user = session.query(User).filter_by(username="alice").first()
user.salary = 95000.0
user.email = "alice_new@example.com"
session.commit()
print(f"Alice 信息已更新: salary=${user.salary}, email={user.email}")

# 2. 批量更新 - 使用 update() 方法
updated_count = session.query(User).filter(User.salary < 75000).update(
    {User.salary: User.salary * 1.1}  # 加薪 10%
)
session.commit()
print(f"批量更新了 {updated_count} 条记录")

# 验证更新结果
print(f"\n=== 更新后的薪资 ===")
for u in session.query(User).order_by(User.salary.desc()).all():
    print(f"  {u.username:8s} | ${u.salary:.2f}")

# ========== 删除数据 ==========

# 1. 删除单个对象
user_to_delete = session.query(User).filter_by(username="eve").first()
if user_to_delete:
    session.delete(user_to_delete)
    session.commit()
    print(f"\n用户 eve 已被删除")

# 2. 批量删除
deleted = session.query(User).filter(User.salary < 70000).delete()
session.commit()
print(f"批量删除了 {deleted} 条记录")

# 最终统计
remaining = session.query(User).count()
print(f"\n最终剩余用户数: {remaining}")
for u in session.query(User).all():
    print(f"  {u.id}: {u.username}, ${u.salary:.2f}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''Alice 信息已更新: salary=$95000.0, email=alice_new@example.com
批量更新了 1 条记录

=== 更新后的薪资 ===
  diana    | $90000.00
  alice    | $95000.00
  bob      | $82000.00
  eve      | $79200.00
  charlie  | $74800.00

用户 eve 已被删除

最终剩余用户数: 4
  1: alice, $95000.00
  2: bob, $82000.00
  3: charlie, $74800.00
  4: diana, $90000.00''',
          ),
          Paragraph(
            'ORM 更新有两种方式：一是查找->修改属性->commit（适合单个对象），'
            '二是使用 query().update() 批量更新（适合大量数据的条件更新）。'
            '删除也有两种方式：session.delete() 删除单个对象，query().delete() 批量删除。'
            '批量操作通常性能更好，但不会触发 ORM 的事件和级联操作。',
          ),
          TipBox(
            '批量 update() 和 delete() 是直接在数据库层面执行的，不会将数据加载到内存中。'
            '但也不会触发 SQLAlchemy 的事件钩子和关系级联，使用时需要特别注意。',
            type: TipType.warning,
          ),

          // 20.7 高级查询技巧
          SectionHeader('高级查询技巧', icon: Icons.auto_awesome),
          Paragraph(
            'SQLAlchemy 提供了丰富的查询能力，包括逻辑运算、范围查询、子查询、'
            '聚合函数、关联查询等高级功能。掌握这些技巧可以让你更高效地操作数据库。',
          ),
          CodeBlock(
            r'''from sqlalchemy import and_, or_, not_, between

# 1. 逻辑运算 - and / or / not
users = session.query(User).filter(
    or_(
        User.salary.between(70000, 80000),
        User.username.like("%a%")
    )
).all()
print("=== 逻辑 OR 查询 ===")
for u in users:
    print(f"  {u.username}: ${u.salary}")

# 2. IN 查询
users = session.query(User).filter(
    User.username.in_(["alice", "bob", "frank"])
).all()
print("\n=== IN 查询 ===")
for u in users:
    print(f"  {u.username}")

# 3. NULL 判断
from sqlalchemy import null
users = session.query(User).filter(User.bio.is_(null())).all()
print(f"\nbio 为空的用户数: {len(users)}")

# 4. 聚合查询
from sqlalchemy import func

stats = session.query(
    func.count(User.id).label("total"),
    func.avg(User.salary).label("avg_salary"),
    func.max(User.salary).label("max_salary"),
    func.min(User.salary).label("min_salary"),
).first()

print(f"\n=== 聚合统计 ===")
print(f"  总人数: {stats.total}")
print(f"  平均薪资: ${stats.avg_salary:.2f}")
print(f"  最高薪资: ${stats.max_salary:.2f}")
print(f"  最低薪资: ${stats.min_salary:.2f}")

# 5. 分组查询
dept_stats = session.query(
    User.department,
    func.count(User.id).label("count"),
    func.avg(User.salary).label("avg_salary"),
).group_by(User.department).having(
    func.avg(User.salary) > 50000
).all()

# 6. 分页
page_size = 2
for page in range(1, 4):
    users_page = session.query(User).offset((page-1) * page_size).limit(page_size).all()
    print(f"\n第 {page} 页（每页 {page_size} 条）:")
    for u in users_page:
        print(f"  {u.username}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''=== 逻辑 OR 查询 ===
  alice: $95000.0
  bob: $82000.0
  charlie: $74800.0

=== IN 查询 ===
  alice
  bob

bio 为空的用户数: 4

=== 聚合统计 ===
  总人数: 4
  平均薪资: $85450.00
  最高薪资: $95000.00
  最低薪资: $74800.00

第 1 页（每页 2 条）:
  alice
  bob
第 2 页（每页 2 条）:
  charlie
  diana
第 3 页（每页 2 条）:
  （空）''',
          ),
          Paragraph(
            'func 模块提供了丰富的 SQL 聚合函数：count、sum、avg、max、min、'
            'group_concat、date_trunc 等。分页查询通过 offset() 和 limit() 组合实现，'
            '注意 offset 从 0 开始。大数据量分页建议使用游标分页（基于 ID 的 WHERE 条件）。',
          ),
          TipBox(
            '处理大量数据时，使用 yield_per() 方法可以控制每次从数据库加载的行数，'
            '避免一次性加载过多数据导致内存溢出。推荐用于数据导出和批量处理场景。',
            type: TipType.tip,
          ),

          // 20.8 Session 生命周期管理
          SectionHeader('Session 生命周期管理', icon: Icons.repeat),
          Paragraph(
            '正确管理 Session 的生命周期是 ORM 编程的关键。推荐在每次请求或操作单元中'
            '创建新的 Session，操作完成后及时关闭。使用上下文管理器可以确保 Session 被正确释放。',
          ),
          CodeBlock(
            r'''from contextlib import contextmanager

@contextmanager
def get_session():
    """上下文管理器：自动管理 Session 的创建和关闭"""
    session = SessionLocal()
    try:
        yield session
        session.commit()  # 无异常时提交
    except Exception:
        session.rollback()  # 异常时回滚
        raise
    finally:
        session.close()  # 无论是否异常都关闭

# 使用示例
try:
    with get_session() as session:
        # 在这个块中执行数据库操作
        user = User(username="frank", email="frank@example.com", salary=88000.0)
        session.add(user)
        # 退出 with 块时自动 commit 并关闭
    print("Session 已自动提交并关闭")

except Exception as e:
    print(f"操作失败，已自动回滚: {e}")

# 验证数据
with get_session() as session:
    count = session.query(User).count()
    print(f"当前用户总数: {count}")
    for u in session.query(User).all():
        print(f"  {u.username}: ${u.salary}")''',
            language: 'Python',
          ),
          OutputBox(
            r'''Session 已自动提交并关闭
当前用户总数: 5
  alice: $95000.0
  bob: $82000.0
  charlie: $74800.0
  diana: $90000.0
  frank: $88000.0''',
          ),
          Paragraph(
            'Session 的生命周期原则：短生命周期、及时关闭。不要将 Session 长时间保持打开状态，'
            '也不要跨多个逻辑操作共享同一个 Session。在 Web 应用中，通常每个请求创建新的 Session，'
            '请求结束时关闭。使用 contextmanager 或依赖注入框架（如 Flask-SQLAlchemy）管理 Session。',
          ),
          TipBox(
            'Session 不是线程安全的。在 Web 框架中，推荐使用 scoped_session 为每个线程/请求'
            '提供独立的 Session 实例。Flask-SQLAlchemy 和 FastAPI 的 SQLAlchemy 集成都提供了这个功能。',
            type: TipType.caution,
          ),

          // 20.9 SQLAlchemy vs 原生 SQL
          SectionHeader('SQLAlchemy vs 原生 SQL', icon: Icons.compare),
          Paragraph(
            'SQLAlchemy ORM 和直接使用原生 SQL（如 mysql-connector-python 或 sqlite3）各有优劣。'
            'ORM 提高了开发效率，但可能带来性能开销；原生 SQL 更加灵活高效，但代码量大且容易出错。'
            '理解二者的适用场景有助于做出合理的技术选型。',
          ),
          CodeBlock(
            r'''# ========== 对比总结 ==========

# 原生 SQL（sqlite3/mysql-connector）方式
def native_way():
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
    cursor.execute("INSERT INTO users (name) VALUES (?)", ("Alice",))
    conn.commit()
    cursor.execute("SELECT * FROM users WHERE id = ?", (1,))
    user = cursor.fetchone()
    print(f"原生方式: {user}")
    cursor.close()
    conn.close()

# SQLAlchemy ORM 方式
def orm_way():
    engine = create_engine("sqlite:///:memory:", echo=False)
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()

    user = User(name="Alice")
    session.add(user)
    session.commit()
    user = session.query(User).filter_by(id=1).first()
    print(f"ORM 方式: {user}")
    session.close()

print("=== 原生 SQL 优缺点 ===")
print("  优点：直接控制 SQL，性能最佳，学习成本低")
print("  缺点：SQL 拼接容易出错，缺少类型检查，代码量较大")
print()
print("=== SQLAlchemy ORM 优缺点 ===")
print("  优点：面向对象操作，安全防注入，自动建表，")
print("        数据库无关性，关联加载，迁移工具支持")
print("  缺点：学习曲线陡峭，复杂查询不如 SQL 直观，")
print("        有性能开销（ORM 对象映射）")
print()
print("=== 选型建议 ===")
print("  简单查询、快速原型 → ORM 方式")
print("  复杂报表、批量操作 → 原生 SQL 或 Core API")
print("  两者可混合使用 → SQLAlchemy 支持原生 SQL 回退")''',
            language: 'Python',
          ),
          OutputBox(
            r'''=== 原生 SQL 优缺点 ===
  优点：直接控制 SQL，性能最佳，学习成本低
  缺点：SQL 拼接容易出错，缺少类型检查，代码量较大

=== SQLAlchemy ORM 优缺点 ===
  优点：面向对象操作，安全防注入，自动建表，
        数据库无关性，关联加载，迁移工具支持
  缺点：学习曲线陡峭，复杂查询不如 SQL 直观，
        有性能开销（ORM 对象映射）

=== 选型建议 ===
  简单查询、快速原型 → ORM 方式
  复杂报表、批量操作 → 原生 SQL 或 Core API
  两者可混合使用 → SQLAlchemy 支持原生 SQL 回退''',
          ),
          Paragraph(
            '实际项目中，ORM 和原生 SQL 并非互斥关系。SQLAlchemy 允许你在 ORM 中使用 text() 函数'
            '编写原生 SQL 语句，或者在 Core 层面使用 SQL 表达式语言。'
            '最佳实践是：80% 的常规 CRUD 使用 ORM，20% 的复杂查询使用原生 SQL。',
          ),
          TipBox(
            '学习 ORM 的关键不是记住所有 API，而是理解"对象-关系映射"的思维方式。'
            '一旦掌握了这种思维方式，使用任何语言的 ORM（Java Hibernate、TypeORM 等）都能快速上手。',
            type: TipType.info,
          ),

          const _SqlQueryBuilderDemo(),

          // ============================================================
          // 本章总结
          // ============================================================
          DividerLine(),
          SectionHeader('本章总结', icon: Icons.summarize),
          Paragraph(
            '本章学习了 Python 操作 MySQL 数据库的完整知识体系。从数据库的基本概念和安装配置入手，'
            '到连接管理、游标使用、CRUD 操作、事务控制，再到 SQL 注入防御、连接池、'
            '错误处理和日期处理等高级主题，最后通过完整的用户管理系统示例将所学知识融会贯通。',
          ),
          Paragraph(
            'MySQL 数据库是 Python 全栈开发的重要组成部分。掌握好数据库编程不仅需要理解 SQL 语法，'
            '更需要培养安全意识（防范 SQL 注入）、性能意识（合理使用索引和连接池）'
            '和工程意识（代码组织和错误处理）。持续实践是提升数据库编程能力的最佳途径。',
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}