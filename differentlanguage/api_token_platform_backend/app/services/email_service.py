"""
邮件通知服务

支持通过 SMTP 发送邮件通知：
- 注册审批通过通知
- 配额告警通知
- 自定义通知

配置方式（.env 文件）:
    SMTP_HOST=smtp.gmail.com
    SMTP_PORT=587
    SMTP_USER=your-email@gmail.com
    SMTP_PASSWORD=your-app-password
    SMTP_FROM=noreply@tokenrelay.com
"""

import logging
import smtplib
import threading
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.config import settings

logger = logging.getLogger(__name__)


def _send_email_sync(to_email: str, subject: str, html_body: str) -> bool:
    """同步发送邮件（在后台线程中调用）"""
    if not settings.smtp_host:
        logger.info(f"SMTP not configured, skipping email to {to_email}: {subject}")
        return False

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = settings.smtp_from
        msg["To"] = to_email
        msg.attach(MIMEText(html_body, "html", "utf-8"))

        if settings.smtp_port == 465:
            server = smtplib.SMTP_SSL(settings.smtp_host, settings.smtp_port, timeout=15)
        else:
            server = smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=15)
            server.starttls()

        server.login(settings.smtp_user, settings.smtp_password)
        server.sendmail(settings.smtp_from, [to_email], msg.as_string())
        server.quit()
        logger.info(f"Email sent to {to_email}: {subject}")
        return True
    except Exception as e:
        logger.error(f"Failed to send email to {to_email}: {e}")
        return False


def send_email_async(to_email: str, subject: str, html_body: str):
    """异步发送邮件（不阻塞主线程）"""
    thread = threading.Thread(target=_send_email_sync, args=(to_email, subject, html_body), daemon=True)
    thread.start()


def send_approval_notification(to_email: str, username: str):
    """发送账号审批通过通知"""
    subject = "TokenRelay — 您的账号已通过审批"
    html_body = f"""
    <div style="max-width:600px;margin:0 auto;font-family:Inter,system-ui,sans-serif">
        <div style="background:linear-gradient(135deg,#6366f1,#8b5cf6);padding:24px;border-radius:12px 12px 0 0">
            <h1 style="color:#fff;margin:0;font-size:20px">TokenRelay</h1>
            <p style="color:rgba(255,255,255,0.8);margin:8px 0 0">API Token 中转平台</p>
        </div>
        <div style="background:#1c1917;border:1px solid rgba(255,255,255,0.08);border-top:none;padding:32px 24px;border-radius:0 0 12px 12px">
            <h2 style="color:#fff;margin:0 0 16px">账号已通过审批</h2>
            <p style="color:rgba(255,255,255,0.7);line-height:1.6">
                您好 <strong style="color:#a5b4fc">{username}</strong>，<br><br>
                您的 TokenRelay 账号已通过管理员审批。现在可以登录并使用平台的全部功能。
            </p>
            <a href="{settings.frontend_url}/#/auth/login" style="display:inline-block;margin:20px 0;padding:12px 24px;background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;text-decoration:none;border-radius:8px;font-weight:600">前往登录</a>
            <p style="color:rgba(255,255,255,0.4);font-size:12px;margin-top:24px">
                此邮件由系统自动发送，请勿回复。
            </p>
        </div>
    </div>
    """
    send_email_async(to_email, subject, html_body)


def send_quota_warning(to_email: str, username: str, used_percent: float):
    """发送配额告警通知"""
    subject = f"TokenRelay — 配额使用已达 {used_percent:.0f}%"
    html_body = f"""
    <div style="max-width:600px;margin:0 auto;font-family:Inter,system-ui,sans-serif">
        <div style="background:linear-gradient(135deg,#f59e0b,#ef4444);padding:24px;border-radius:12px 12px 0 0">
            <h1 style="color:#fff;margin:0;font-size:20px">配额告警</h1>
        </div>
        <div style="background:#1c1917;border:1px solid rgba(255,255,255,0.08);border-top:none;padding:32px 24px;border-radius:0 0 12px 12px">
            <h2 style="color:#fff;margin:0 0 16px">您的 Token 配额即将耗尽</h2>
            <p style="color:rgba(255,255,255,0.7);line-height:1.6">
                您好 <strong style="color:#fbbf24">{username}</strong>，<br><br>
                您的 API Token 配额已使用 <strong style="color:#ef4444">{used_percent:.0f}%</strong>。
                请及时联系管理员充值或扩展配额。
            </p>
            <p style="color:rgba(255,255,255,0.4);font-size:12px;margin-top:24px">
                此邮件由系统自动发送，请勿回复。
            </p>
        </div>
    </div>
    """
    send_email_async(to_email, subject, html_body)
