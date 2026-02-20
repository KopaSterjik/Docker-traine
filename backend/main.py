"""
FastAPI Backend — регистрация и авторизация пользователей.
"""

import os
from datetime import datetime, timedelta, timezone
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import String, DateTime, select, func

from passlib.context import CryptContext
from jose import jwt, JWTError

# ── Настройки ──
DATABASE_URL = os.getenv("DATABASE_URL")
JWT_SECRET   = os.getenv("JWT_SECRET", "dev-secret")
JWT_ALGO     = "HS256"
JWT_EXPIRE   = 60  # минут

# ── БД ──
engine  = create_async_engine(DATABASE_URL, echo=True)
Session = async_sessionmaker(engine, expire_on_commit=False)

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"
    id:         Mapped[int]      = mapped_column(primary_key=True)
    email:      Mapped[str]      = mapped_column(String(255), unique=True, index=True)
    username:   Mapped[str]      = mapped_column(String(100), unique=True)
    hashed_pw:  Mapped[str]      = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

# ── Lifespan: создаём таблицы при старте ──
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield

app = FastAPI(title="Login API", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ── Схемы ──
class RegisterReq(BaseModel):
    email:    EmailStr
    username: str
    password: str

class LoginReq(BaseModel):
    email:    EmailStr
    password: str

class TokenResp(BaseModel):
    access_token: str
    token_type:   str = "bearer"
    username:     str

class ProfileResp(BaseModel):
    id:         int
    email:      str
    username:   str
    created_at: datetime

# ── Хелперы ──
def create_token(user_id: int) -> str:
    exp = datetime.now(timezone.utc) + timedelta(minutes=JWT_EXPIRE)
    return jwt.encode({"sub": str(user_id), "exp": exp}, JWT_SECRET, algorithm=JWT_ALGO)

async def get_db():
    async with Session() as s:
        yield s

async def get_current_user(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db),
) -> User:
    try:
        scheme, tok = authorization.split(" ", 1)
        if scheme.lower() != "bearer":
            raise ValueError
        payload = jwt.decode(tok, JWT_SECRET, algorithms=[JWT_ALGO])
        user_id = int(payload["sub"])
    except (ValueError, JWTError, KeyError):
        raise HTTPException(401, "Invalid token")

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(401, "User not found")
    return user

# ── Эндпоинты ──
@app.post("/register", response_model=TokenResp)
async def register(req: RegisterReq, db: AsyncSession = Depends(get_db)):
    exists = await db.execute(
        select(User).where((User.email == req.email) | (User.username == req.username))
    )
    if exists.scalar_one_or_none():
        raise HTTPException(409, "User already exists")

    user = User(
        email=req.email,
        username=req.username,
        hashed_pw=pwd.hash(req.password),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    return TokenResp(access_token=create_token(user.id), username=user.username)

@app.post("/login", response_model=TokenResp)
async def login(req: LoginReq, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalar_one_or_none()

    if not user or not pwd.verify(req.password, user.hashed_pw):
        raise HTTPException(401, "Invalid credentials")

    return TokenResp(access_token=create_token(user.id), username=user.username)

@app.get("/profile", response_model=ProfileResp)
async def profile(user: User = Depends(get_current_user)):
    return ProfileResp(
        id=user.id, email=user.email,
        username=user.username, created_at=user.created_at,
    )

@app.get("/health")
async def health():
    return {"status": "ok"}
