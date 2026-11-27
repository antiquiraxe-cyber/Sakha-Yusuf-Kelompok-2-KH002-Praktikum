@echo off
cd /d "%~dp0"
echo Menjalankan REST API lokal di http://localhost:8080 ...
python mock_api\server.py
pause
