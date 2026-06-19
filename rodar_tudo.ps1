$python = "C:\Users\carlo\OneDrive\Documentos\Python\teste_email\venv\Scripts\python.exe"
$log = "C:\automacao\logs\rodar_tudo.log"

New-Item -ItemType Directory -Force -Path "C:\automacao\logs" | Out-Null

$msg = "[$(Get-Date)] ==================================="
Write-Host $msg
$msg | Out-File $log -Append -Encoding ASCII

# Mata processos zumbis que consomem RAM (causa HRESULT 8007000e)
$zumbis = Get-Process -Name "chrome","chromium","msedge","python" -ErrorAction SilentlyContinue
if ($zumbis) {
    $msg = "[$(Get-Date)] Matando $($zumbis.Count) processos zumbis..."
    Write-Host $msg
    $msg | Out-File $log -Append -Encoding ASCII
    $zumbis | Stop-Process -Force -ErrorAction SilentlyContinue
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

Executar-Projeto "Lancamento Debitos" "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\lancamento_debitos"
Executar-Projeto "Anexa Documentos"  "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\anexa_documentos"

$msg = "[$(Get-Date)] ==================================="
Write-Host $msg
$msg | Out-File $log -Append -Encoding ASCII
