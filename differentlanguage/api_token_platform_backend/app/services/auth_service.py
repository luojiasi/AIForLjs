"""
认证服务模块

提供用户认证体系的所有核心功能：
- 用户注册与登录（bcrypt 密码哈希）
- 平台 API Key 的生成、存储、验证与撤销
- API Key 的密钥学安全处理（随机生成 + bcrypt 哈希存储）

安全设计要点：
- 用户密码和 API Key 均使用 bcrypt 单向哈希存储，永远不可逆
- API Key 的完整明文仅在创建时返回一次给调用方
- Key 前缀（atp_ + 8位hex）用于快速索引缩小验证范围
"""

import secrets
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from app.models.user import User
from app.models.api_key import PlatformApiKey

# bcrypt 密码上下文（成本因子默认 12，即 2^12 次迭代）
密码上下文 = CryptContext(schemes=["bcrypt"], deprecated="auto")


def 哈希密码(password: str) -> str:
    """对明文密码做 bcrypt 单向哈希"""
    return 密码上下文.hash(password)


hash_password = 哈希密码  # 英文别名，保持向后兼容


def 验证密码(plain: str, hashed: str) -> bool:
    """验证明文密码是否与 bcrypt 哈希匹配"""
    return 密码上下文.verify(plain, hashed)


verify_password = 验证密码  # 英文别名


def 创建用户(db: Session, username: str, password: str) -> User:
    """创建新用户账号（密码自动 bcrypt 哈希存储）"""
    user = User(username=username, hashed_password=哈希密码(password))
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
    """
    生成新的平台 API Key

    使用 secrets.token_hex(32) 生成 256 位密码学安全随机数，
    格式为: atp_<64位十六进制字符>

    返回:
        (完整Key, Key前缀) — 完整Key仅此一次返回，前缀用于数据库索引
    """
    原始密钥 = secrets.token_hex(32)                 # 32字节 → 64个十六进制字符
    完整密钥 = f"atp_{原始密钥}"                       # 添加平台标识前缀
    密钥前缀 = 完整密钥[:12]                           # "atp_" + 8个hex字符，用于快速索引
    return 完整密钥, 密钥前缀


generate_api_key = 生成API密钥


def 创建API密钥(db: Session, user: User, name: str) -> tuple[PlatformApiKey, str]:
    """
    为用户创建一个新的 API Key（bcrypt 哈希存储）

    返回:
        (PlatformApiKey 数据库记录, 完整Key明文)
        注意：完整Key明文仅在此时返回，之后无法从数据库恢复！
    """
    完整密钥, 密钥前缀 = 生成API密钥()
    密钥哈希 = 密码上下文.hash(完整密钥)              # bcrypt 单向哈希，不可逆
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
    """
    验证平台 API Key 并返回对应的用户

    验证流程（性能优化版）：
    1. 提取 Key 前12字符作为前缀
    2. 查询数据库中 key_prefix 匹配且 is_active=True 的记录（大幅缩小范围）
    3. 对候选记录逐条做 bcrypt.verify() 比对
    4. 匹配成功返回 User，全部不匹配返回 None

    时间复杂度：O(候选数) ≈ O(1)，因为前缀机制将搜索范围从全表缩小到个位数
    """
    密钥前缀 = 原始密钥[:12]
    候选记录列表 = db.query(PlatformApiKey).filter(
        PlatformApiKey.key_prefix == 密钥前缀,
        PlatformApiKey.is_active == True,
    ).all()
    for 候选记录 in 候选记录列表:
        if 密码上下文.verify(原始密钥, 候选记录.key_hash):
            return 候选记录.user
    return None


verify_api_key = 验证API密钥


def 列出API密钥(db: Session, user: User) -> list[PlatformApiKey]:
    """列出指定用户的所有 API Key（不返回完整Key哈希）"""
    return db.query(PlatformApiKey).filter(PlatformApiKey.user_id == user.id).all()


list_api_keys = 列出API密钥


def 撤销API密钥(db: Session, user: User, key_id: int) -> bool:
    """
    撤销（软删除）一个 API Key

    将 is_active 设为 False，Key 记录保留用于审计。
    撤销后该 Key 立即失效，无法恢复使用。

    返回: True 表示撤销成功，False 表示 Key 不存在或不属于该用户
    """
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
