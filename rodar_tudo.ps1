$python = "C:\Users\carlo\OneDrive\Documentos\Python\teste_email\venv\Scripts\python.exe"
$log = "C:\automacao\logs\rodar_tudo.log"

New-Item -ItemType Directory -Force -Path "C:\automacao\logs" | Out-Null

$msg = "[$(Get-Date)] ==================================="
Write-Host $msg
$msg | Out-File $log -Append -Encoding ASCII

# Evita conflito: aguarda execucao anterior terminar
$timeout = Get-Date
while (Get-Process python -ErrorAction SilentlyContinue) {
    if ((Get-Date) - $timeout -gt [TimeSpan]::FromMinutes(30)) {
        $msg = "[$(Get-Date)] Timeout aguardando execucao anterior - forcando"
        Write-Host $msg
        $msg | Out-File $log -Append -Encoding ASCII
        break
    }
    $msg = "[$(Get-Date)] Aguardando execucao anterior terminar..."
    Write-Host $msg
    $msg | Out-File $log -Append -Encoding ASCII
    Start-Sleep -Seconds 30
}

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
}

Executar-Projeto "Lancamento Debitos" "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\lancamento_debitos"
Executar-Projeto "Anexa Documentos"  "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\anexa_documentos"

$msg = "[$(Get-Date)] ==================================="
Write-Host $msg
$msg | Out-File $log -Append -Encoding ASCII
