# Configura 1 tarefa que roda Lancamento + Anexa em sequencia
# Execute como Administrador no PowerShell
# Remove tarefas antigas e cria a nova unificada

$ps1 = "C:\Users\carlo\OneDrive\Documentos\Claude\Projects\automacao_autodespa\Autodespa-Kaizencrm\agendador\rodar_tudo.ps1"
$usuario = $env:USERNAME

# Remove todas as tarefas antigas
foreach ($nome in @("LancamentoDebitos_08h", "LancamentoDebitos_13h", "LancamentoDebitos_17h", "AnexaDocumentos_13h")) {
    if (Get-ScheduledTask -TaskName $nome -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $nome -Confirm:$false
        Write-Host "Removida: $nome"
    }
}

$acao = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -ExecutionPolicy Bypass -File `"$ps1`""

$config = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Hours 3) `
    -MultipleInstances IgnoreNew `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# Horarios: 08:00, 13:00, 17:00 (seg a sex)
foreach ($hora in @("08:00", "13:00", "17:00")) {
    $nome = "Automacao_$($hora.Replace(':',''))h"
    
    if (Get-ScheduledTask -TaskName $nome -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $nome -Confirm:$false
    }
    
    $trigger = New-ScheduledTaskTrigger -Weekly -At $hora -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday
    
    Register-ScheduledTask `
        -TaskName $nome `
        -Action $acao `
        -Trigger $trigger `
        -Settings $config `
        -Description "Lancamento + Anexa Docs - diario $hora" `
        -RunLevel Highest
    
    Write-Host "OK: $nome configurada diariamente as $hora (seg a sex)"
}

Write-Host "Agendamento unificado concluido!"
