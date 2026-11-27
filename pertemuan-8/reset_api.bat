@echo off
cd /d "%~dp0"
copy /Y mock_api\db.seed.json mock_api\db.json >nul
echo Data API dikembalikan ke seed (user 1524, admin 817).
pause
