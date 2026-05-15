@echo off
title API Backend (Port 8000)
cd /d E:\DeskTop\AIForLjs\differentlanguage\api_token_platform_backend
echo Starting FastAPI backend on port 8000...
uvicorn app.main:app --host 127.0.0.1 --port 8000
pause
