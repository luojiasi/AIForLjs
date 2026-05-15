@echo off
title Cloudflare Tunnel
echo Starting Cloudflare Tunnel...
cloudflared tunnel run relay-platform
pause
