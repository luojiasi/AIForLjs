const String deploymentFullDetail = '''

# 部署运维

## Docker容器化
### 多阶段构建
```dockerfile
# 第一阶段：构建
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# 第二阶段：运行
FROM python:3.12-slim AS runtime
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:\$PATH
RUN useradd --create-home app && chown -R app:app /app
USER app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

多阶段构建的好处：
- **最终镜像体积小**：不包含pip缓存和编译工具链
- **安全性高**：攻击面更小，没有多余的开发工具
- **非root运行**：合规性和安全性要求

### Docker Compose

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ./data:/app/data    # SQLite数据持久化
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:                    # 可选：分布式限流
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    profiles:
      - with-redis          # 仅在指定profile时启用
volumes:
  redis_data:
```

## Nginx反向代理

### 生产级Nginx配置

```nginx
upstream api_backend {
    server 127.0.0.1:8000;
    keepalive 32;
}

# IP限流区域
limit_req_zone \$binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80;
    server_name api.your-domain.com;
    return 301 https://\$host\$request_uri;  # 强制HTTPS
}

server {
    listen 443 ssl http2;
    server_name api.your-domain.com;

    # SSL配置
    ssl_certificate     /etc/letsencrypt/live/api.your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.your-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;

    # 安全头
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;

    # 请求体大小限制
    client_max_body_size 10m;
    client_body_timeout 120s;

    location / {
        limit_req zone=api_limit burst=20 nodelay;
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;   # AI调用可能较慢
        proxy_send_timeout 120s;
    }

    # 禁止访问隐藏文件
    location ~ /\\. {
        deny all;
    }
}
```

## 部署流程

### 开发环境部署（5分钟）
```bash
# 1. 克隆项目
cd differentlanguage/api_token_platform_backend

# 2. 安装依赖
python -m venv venv
source venv/bin/activate  # Windows: venv\\Scripts\\activate
pip install -r requirements.txt

# 3. 配置
cp .env.example .env
nano .env  # 编辑配置

# 4. 启动
uvicorn app.main:app --reload --port 8000
```

### 生产环境部署

```bash
# 1. 拉取代码
git clone <repo> /opt/api-token-platform
cd /opt/api-token-platform/differentlanguage/api_token_platform_backend

# 2. 配置环境
cp .env.example .env
# 编辑 .env:
#   SECRET_KEY=<使用openssl rand -hex 32生成>
#   DATABASE_URL=postgresql://user:pass@localhost/relay_platform
#   DEBUG=false
#   OPENAI_API_KEY=sk-xxx
#   ANTHROPIC_API_KEY=sk-ant-xxx

# 3. 构建和启动
docker-compose -f docker-compose.prod.yml up -d --build

# 4. 配置Nginx
sudo cp nginx.conf /etc/nginx/sites-available/api-platform
sudo ln -s /etc/nginx/sites-available/api-platform /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 5. 配置SSL证书（Let's Encrypt）
sudo certbot --nginx -d api.your-domain.com

# 6. 验证
curl https://api.your-domain.com/health
```

## 数据库迁移
### 从SQLite迁移到PostgreSQL

```bash
# 1. 修改 .env
DATABASE_URL=postgresql://user:password@localhost:5432/relay_platform

# 2. 安装PostgreSQL驱动
pip install psycopg2-binary

# 3. 重新创建表（或使用Alembic迁移）
python -c "from app.database import init_db; init_db()"
```

### Alembic数据库迁移
```bash
# 初始化Alembic
alembic init alembic

# 生成迁移脚本
alembic revision --autogenerate -m "Initial schema"

# 执行迁移
alembic upgrade head

# 回滚
alembic downgrade -1
```

## 监控与运维
### 健康检查端点
```bash
# 基础健康检查
curl http://localhost:8000/health
# → {"status": "ok", "service": "API Token Relay Platform"}

# Docker健康检查
docker inspect --format='{{.State.Health.Status}}' <container_id>
```

### 日志管理

```bash
# Docker日志
docker-compose logs -f app

# 查看最近100条日志
docker-compose logs --tail=100 app

# 按时间过滤
docker-compose logs --since=2024-01-01T00:00:00 app
```

### 性能监控

关键指标：
- **请求延迟**：P50/P95/P99延迟（存储在request_logs中）
- **错误率**：5xx响应的比例
- **限流触发率**：429响应的比例
- **厂商可用性**：各厂商的成功率

### 备份策略

```bash
#!/bin/bash
# 每日备份脚本 (cron: 0 2 * * *)

BACKUP_DIR="/backup/relay-platform"
DATE=\$(date +%Y%m%d)

# SQLite备份
cp data/relay_platform.db "\$BACKUP_DIR/relay_platform_\$DATE.db"

# PostgreSQL备份
pg_dump \$DATABASE_URL > "\$BACKUP_DIR/relay_platform_\$DATE.sql"

# 保留最近30天的备份
find \$BACKUP_DIR -mtime +30 -delete

# 加密备份文件
gpg --encrypt --recipient admin@example.com \\
    "\$BACKUP_DIR/relay_platform_\$DATE.sql"
```

## CI/CD 示例（GitHub Actions）
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: \${{ secrets.SERVER_HOST }}
          username: deploy
          key: \${{ secrets.SSH_KEY }}
          script: |
            cd /opt/api-token-platform
            git pull
            docker-compose up -d --build
```

''';
