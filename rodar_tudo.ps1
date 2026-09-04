$python = "C:\Users\carlo\OneDrive\Documentos\Python\teste_email\venv\Scripts\python.exe"
$dia = Get-Date -Format "yyyyMMdd"
$log = "C:\automacao\logs\automacao_$dia.log"

New-Item -ItemType Directory -Force -Path "C:\automacao\logs" | Out-Null

function Escrever-Log {
    param([string]$msg)
    Write-Host $msg
    $msg | Out-File $log -Append -Encoding utf8
}

Escrever-Log "[$(Get-Date)] ==================================="

# ── Lock de instancia unica ─────────────────────────────────────────────
# Impede que duas instancias do orquestrador rodem em paralelo (evita corrida
# nos checkpoints e duplicacao de lancamentos/anexos).
$lockFile = "C:\automacao\rodar_tudo.lock"
try {
    $lockHandle = [System.IO.File]::Open($lockFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    Escrever-Log "[$(Get-Date)] Lock adquirido."
} catch {
    Escrever-Log "[$(Get-Date)] Outra instancia do orquestrador ja esta em execucao. Abortando."
    exit 0
}

# Mata APENAS processos Playwright (identificados pelo argumento --remote-debugging-pipe)
# Nunca fecha o navegador pessoal do usuario
$zumbis = Get-WmiObject Win32_Process -Filter "Name='chrome.exe' OR Name='msedge.exe' OR Name='chromium.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match "remote-debugging-pipe|playwright" } |
    ForEach-Object { Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue }

$pythonZumbis = Get-WmiObject Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match "playwright|autodespa|kaizencrm" } |
    ForEach-Object { Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue }

$todosZumbis = @($zumbis) + @($pythonZumbis) | Where-Object { $_ -ne $null }
if ($todosZumbis.Count -gt 0) {
    Escrever-Log "[$(Get-Date)] Matando $($todosZumbis.Count) processos Playwright zumbis..."
    $todosZumbis | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
}

# Aguarda liberacao de RAM
Start-Sleep -Seconds 5

function Executar-Projeto {
    param($nome, $pasta)
    Escrever-Log "[$(Get-Date)] ===== Iniciando $nome ====="

    Set-Location -LiteralPath $pasta
    # As 3 automacoes gravam direto no log unificado diario (automacao_YYYYMMDD.log)
    & $python main.py 2>&1 | Out-Null

    Escrever-Log "[$(Get-Date)] ===== $nome finalizado ====="

    # Pausa entre projetos para liberar recursos
    Start-Sleep -Seconds 10
}

Executar-Projeto "Lancamento Debitos" "C:\DokLine\Autodespa-Kaizencrm\lancamento_debitos"
Executar-Projeto "Anexa Documentos"  "C:\DokLine\Autodespa-Kaizencrm\anexa_documentos"
Executar-Projeto "Atualiza Tarefas"  "C:\DokLine\Autodespa-Kaizencrm\atualiza_tarefas"

Escrever-Log "[$(Get-Date)] ==================================="

# ── Libera o lock ───────────────────────────────────────────────────────
if ($lockHandle -ne $null) {
    $lockHandle.Close()
    Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
}
