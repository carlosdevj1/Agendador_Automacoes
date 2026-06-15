@echo off
chcp 65001 > nul

set VENV=C:\Users\carlo\OneDrive\Documentos\Python\teste_email\venv\Scripts\activate.bat
set LOG=C:\automacao\logs\rodar_tudo.log

if not exist "C:\automacao\logs" mkdir "C:\automacao\logs"

echo [%DATE% %TIME%] ===================================
echo [%DATE% %TIME%] =================================== >> "%LOG%"

:: ─── Lancamento de Debitos ───
echo [%DATE% %TIME%] Iniciando Lancamento Debitos
echo [%DATE% %TIME%] Iniciando Lancamento Debitos >> "%LOG%"
cd /d "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\lancamento_debitos"
call "%VENV%"
python main.py >> "%LOG%" 2>&1
echo [%DATE% %TIME%] Lancamento Debitos finalizado >> "%LOG%"

:: ─── Anexa Documentos ───
echo [%DATE% %TIME%] Iniciando Anexa Documentos
echo [%DATE% %TIME%] Iniciando Anexa Documentos >> "%LOG%"
cd /d "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\anexa_documentos"
call "%VENV%"
python main.py >> "%LOG%" 2>&1
echo [%DATE% %TIME%] Anexa Documentos finalizado >> "%LOG%"

echo [%DATE% %TIME%] ===================================
echo [%DATE% %TIME%] =================================== >> "%LOG%"
exit /b
