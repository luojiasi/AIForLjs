"""
认证服务模块

提供用户认证体系的所有核心功能：
- 用户注册与登录（bcrypt 密码哈希）
- 平台 API Key 的生成、存储、验证与撤销
- API Key 的密钥学安全处理（随机生成 + bcrypt 哈希存储）
"""

import secrets
import bcrypt
from sqlalchemy.orm import Session
from app.models.user import User
from app.models.api_key import PlatformApiKey


def 哈希密码(password: str) -> str:
    """对明文密码做 bcrypt 单向哈希"""
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


hash_password = 哈希密码


def 验证密码(plain: str, hashed: str) -> bool:
    """验证明文密码是否与 bcrypt 哈希匹配"""
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))


verify_password = 验证密码


def 创建用户(db: Session, username: str, password: str, email: str | None = None) -> User:
    """创建新用户账号（密码自动 bcrypt 哈希存储）"""
    user = User(username=username, hashed_password=哈希密码(password), email=email)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


create_user = 创建用户


def 认证用户(db: Session, username: str, password: str) -> User | None:
    """验证用户名密码，成功返回 User 对象，失败返回 None"""
    user = db.query(User).filter(User.username == username).first()
    if user and 验证密码(password, user.hashed_password):
        return user
    return None


authenticate_user = 认证用户


def 生成API密钥() -> tuple[str, str]:
    """生成新的平台 API Key，返回 (完整Key, 密钥前缀)"""
    原始密钥 = secrets.token_hex(32)
    完整密钥 = f"atp_{原始密钥}"
    密钥前缀 = 完整密钥[:12]
    return 完整密钥, 密钥前缀


generate_api_key = 生成API密钥


def 创建API密钥(db: Session, user: User, name: str) -> tuple[PlatformApiKey, str]:
    """为用户创建一个新的 API Key（bcrypt 哈希存储），返回 (记录, 明文Key)"""
    完整密钥, 密钥前缀 = 生成API密钥()
    密钥哈希 = bcrypt.hashpw(完整密钥.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    api_key = PlatformApiKey(
        user_id=user.id,
        key_hash=密钥哈希,
        key_prefix=密钥前缀,
        name=name,
    )
    db.add(api_key)
    db.commit()
    db.refresh(api_key)
    return api_key, 完整密钥


create_api_key = 创建API密钥


def 验证API密钥(db: Session, 原始密钥: str) -> User | None:
    """验证平台 API Key 并返回对应的用户"""
    密钥前缀 = 原始密钥[:12]
    候选记录列表 = db.query(PlatformApiKey).filter(
        PlatformApiKey.key_prefix == 密钥前缀,
        PlatformApiKey.is_active == True,
    ).all()
    for 候选记录 in 候选记录列表:
        if bcrypt.checkpw(原始密钥.encode("utf-8"), 候选记录.key_hash.encode("utf-8")):
            return 候选记录.user
    return None


verify_api_key = 验证API密钥


def 列出API密钥(db: Session, user: User) -> list[PlatformApiKey]:
    """列出指定用户的所有活跃 API Key"""
    return db.query(PlatformApiKey).filter(
        PlatformApiKey.user_id == user.id,
        PlatformApiKey.is_active == True,
    ).all()


list_api_keys = 列出API密钥


def 撤销API密钥(db: Session, user: User, key_id: int) -> bool:
    """撤销（软删除）一个 API Key，返回是否成功"""
    key = db.query(PlatformApiKey).filter(
        PlatformApiKey.id == key_id,
        PlatformApiKey.user_id == user.id,
    ).first()
    if key:
        key.is_active = False
        db.commit()
        return True
    return False


revoke_api_key = 撤销API密钥
