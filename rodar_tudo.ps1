$python = "C:\Users\carlo\OneDrive\Documentos\Python\teste_email\venv\Scripts\python.exe"
$log = "C:\automacao\logs\rodar_tudo.log"

New-Item -ItemType Directory -Force -Path "C:\automacao\logs" | Out-Null

$msg = "[$(Get-Date)] ==================================="
Write-Host $msg
$msg | Out-File $log -Append -Encoding ASCII

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
    $msg = "[$(Get-Date)] Matando $($todosZumbis.Count) processos Playwright zumbis..."
    Write-Host $msg
    $msg | Out-File $log -Append -Encoding ASCII
    $todosZumbis | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
}

# Aguarda liberacao de RAM
Start-Sleep -Seconds 5

function Executar-Projeto {
    param($nome, $pasta)
    $msg = "[$(Get-Date)] Iniciando $nome"
    Write-Host $msg
    $msg | Out-File $log -Append -Encoding ASCII

    Set-Location -LiteralPath $pasta
    $saida = & $python main.py 2>&1
    $saida | Out-File $log -Append -Encoding ASCII

    $msg = "[$(Get-Date)] $nome finalizado"
    Write-Host $msg
    $msg | Out-File $log -Append -Encoding ASCII

    # Pausa entre projetos para liberar recursos
    Start-Sleep -Seconds 10
}

Executar-Projeto "Lancamento Debitos" "C:\DokLine\Autodespa-Kaizencrm\lancamento_debitos"
Executar-Projeto "Anexa Documentos"  "C:\DokLine\Autodespa-Kaizencrm\anexa_documentos"
Executar-Projeto "Atualiza Tarefas"  "C:\DokLine\Autodespa-Kaizencrm\atualiza_tarefas"

$msg = "[$(Get-Date)] ==================================="
Write-Host $msg
$msg | Out-File $log -Append -Encoding ASCII
