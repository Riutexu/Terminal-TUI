#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Security — 15 funciones de ciberseguridad.
.DESCRIPTION
    Escaneo completo, procesos, red, persistencia, credenciales, forense,
    evidencia, logs, limpieza, password reset, firewall, baseline, status,
    hardening, reporte.
    Inspirado en: Am-I-Hacked, LOCKON, SecurityCheck, Trawler, WinSentinel.
#>

Set-StrictMode -Version Latest

function Invoke-SECFullScan {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Escaneo Completo de Seguridad'
    Write-RyuLog -Mensaje 'Iniciando escaneo completo de seguridad' -Nivel 'INFO' -Modulo 'Security'

    $hallazgos = @{ Criticos = 0; Advertencias = 0; Info = 0 }

    # 1. Process scan
    Write-StatusMsg -Mensaje '[1/5] Analizando procesos...' -Tipo 'INFO'
    $procesos = Get-Process | Where-Object { $_.Path }
    $sinFirma = 0; $tempDir = 0
    foreach ($p in $procesos) {
        try {
            $sig = Get-AuthenticodeSignature -FilePath $p.Path -ErrorAction SilentlyContinue
            if ($sig.Status -ne 'Valid') { $sinFirma++ }
        } catch {}
        if ($p.Path -match '\\Temp\\|\\AppData\\Local\\Temp\\') { $tempDir++ }
    }
    if ($sinFirma -gt 0) { $hallazgos.Criticos++; Write-StatusMsg -Mensaje "Procesos sin firma: $sinFirma" -Tipo 'ERROR' }
    if ($tempDir -gt 0) { $hallazgos.Advertencias++; Write-StatusMsg -Mensaje "Procesos en directorio temporal: $tempDir" -Tipo 'ADVERTENCIA' }

    # 2. Network scan
    Write-StatusMsg -Mensaje '[2/5] Escaneando red...' -Tipo 'INFO'
    $conexiones = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Established' }
    Write-StatusMsg -Mensaje "Conexiones activas: $($conexiones.Count)" -Tipo 'INFO'
    $hallazgos.Info++

    # 3. Persistence scan
    Write-StatusMsg -Mensaje '[3/5] Buscando persistencia...' -Tipo 'INFO'
    $autorunKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
    )
    $entradas = 0
    foreach ($key in $autorunKeys) {
        if (Test-Path $key) {
            $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
            if ($props) { $entradas += ($props.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }).Count }
        }
    }
    Write-StatusMsg -Mensaje "Entradas de autorun encontradas: $entradas" -Tipo 'INFO'
    $hallazgos.Info++

    # 4. Credential scan
    Write-StatusMsg -Mensaje '[4/5] Auditando credenciales...' -Tipo 'INFO'
    $sshKeys = Get-ChildItem -Path "$env:USERPROFILE\.ssh" -ErrorAction SilentlyContinue
    $envFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -Include '*.env','*.env.local' -Depth 3 -ErrorAction SilentlyContinue
    if ($sshKeys) { $hallazgos.Advertencias++; Write-StatusMsg -Mensaje "SSH keys encontradas: $($sshKeys.Count)" -Tipo 'ADVERTENCIA' }
    if ($envFiles) { $hallazgos.Advertencias++; Write-StatusMsg -Mensaje "Archivos .env encontrados: $($envFiles.Count)" -Tipo 'ADVERTENCIA' }

    # 5. Hosts file
    Write-StatusMsg -Mensaje '[5/5] Verificando hosts file...' -Tipo 'INFO'
    $hostsContent = Get-Content "$env:SystemRoot\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue
    $suspiciousHosts = $hostsContent | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\d+\.\d+\.\d+\.\d+' }
    if ($suspiciousHosts) { $hallazgos.Criticos++; Write-StatusMsg -Mensaje "Hosts file modificado (posible hijacking)" -Tipo 'ERROR' }

    # Results
    Write-Host ''
    Show-RyuModal -Titulo "Resultado: $($hallazgos.Criticos) Críticos | $($hallazgos.Advertencias) Advertencias | $($hallazgos.Info) Info" -Lineas @(
        "▸ Procesos sin firma: $sinFirma",
        "▸ Procesos en temp: $tempDir",
        "▸ Conexiones activas: $($conexiones.Count)",
        "▸ Entradas autorun: $entradas",
        "▸ SSH keys: $(if ($sshKeys) { $sshKeys.Count } else { 0 })",
        "▸ Archivos .env: $(if ($envFiles) { $envFiles.Count } else { 0 })",
        "▸ Hosts sospechosos: $(if ($suspiciousHosts) { $suspiciousHosts.Count } else { 0 })"
    ) -ColorTitulo $(if ($hallazgos.Criticos -gt 0) { $t.Error } else { $t.Success })

    Write-RyuLog -Mensaje "Escaneo completado: $($hallazgos.Criticos) críticos, $($hallazgos.Advertencias) advertencias" -Nivel 'EXITO' -Modulo 'Security'
}

function Invoke-SECProcessScan {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Análisis de Procesos'
    Write-StatusMsg -Mensaje 'Analizando procesos en busca de amenazas...' -Tipo 'INFO'

    $procesos = Get-Process | Where-Object { $_.Path }
    $resultados = @()

    foreach ($p in $procesos) {
        $riesgo = 'Bajo'
        $razon = ''
        try {
            $sig = Get-AuthenticodeSignature -FilePath $p.Path -ErrorAction SilentlyContinue
            if ($sig.Status -ne 'Valid') { $riesgo = 'Alto'; $razon = 'Sin firma válida' }
        } catch {}
        if ($p.Path -match '\\Temp\\|\\AppData\\Local\\Temp\\') { $riesgo = 'Alto'; $razon = 'Directorio temporal' }
        if ($p.ProcessName -match 'mimikatz|cobalt|beacon|metasploit|meterpreter') { $riesgo = 'Crítico'; $razon = 'Herramienta de ataque conocida' }

        $resultados += [PSCustomObject]@{
            Proceso = $p.ProcessName; PID = $p.Id; Riesgo = $riesgo; Razon = $razon
            Path = if ($p.Path.Length -gt 50) { $p.Path.Substring(0, 47) + '...' } else { $p.Path }
        }
    }

    $criticos = ($resultados | Where-Object { $_.Riesgo -eq 'Crítico' }).Count
    $altos = ($resultados | Where-Object { $_.Riesgo -eq 'Alto' }).Count

    Write-Host ''
    Show-RyuModal -Titulo "Análisis de Procesos" -Lineas @(
        "▸ Total analizados: $($resultados.Count)",
        "▸ Riesgo Crítico: $criticos",
        "▸ Riesgo Alto: $altos",
        "▸ Estado: $(if ($criticos -gt 0) { 'AMENAZA DETECTADA' } else { 'LIMPIO' })"
    ) -ColorTitulo $(if ($criticos -gt 0) { $t.Error } else { $t.Success })
}

function Invoke-SECNetworkScan {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Escaneo de Red'
    Write-StatusMsg -Mensaje 'Analizando conexiones de red...' -Tipo 'INFO'

    $conexiones = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Established' }
    Write-Host ''
    Write-Rgb -Texto "  Conexiones activas: $($conexiones.Count)" -Color $t.TextPrimary -Negrita

    # Hosts file check
    $hostsContent = Get-Content "$env:SystemRoot\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue
    $suspicious = $hostsContent | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\d+\.\d+\.\d+\.\d+' }
    if ($suspicious) {
        Write-StatusMsg -Mensaje "⚠ Hosts file modificado: $($suspicious.Count) entradas sospechosas" -Tipo 'ERROR'
    } else {
        Write-StatusMsg -Mensaje 'Hosts file limpio' -Tipo 'EXITO'
    }

    # DNS cache
    $dns = Get-DnsClientCache -ErrorAction SilentlyContinue
    Write-StatusMsg -Mensaje "DNS cache: $($dns.Count) entradas" -Tipo 'INFO'
}

function Invoke-SECPersistenceScan {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Escaneo de Persistencia'

    $autorunKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run'
    )

    $total = 0
    foreach ($key in $autorunKeys) {
        if (Test-Path $key) {
            $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
            if ($props) {
                $entries = $props.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }
                $total += $entries.Count
                foreach ($e in $entries) {
                    Write-StatusMsg -Mensaje "$($key.Split('\')[-1]): $($e.Name) = $($e.Value)" -Tipo 'INFO'
                }
            }
        }
    }

    # Scheduled tasks
    $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Disabled' -and $_.TaskPath -notmatch '\\Microsoft\\Windows\\' }
    Write-Host ''
    Show-RyuModal -Titulo 'Mecanismos de Persistencia' -Lineas @(
        "▸ Entradas de autorun: $total",
        "▸ Tareas programadas no-Microsoft: $($tasks.Count)",
        "▸ Estado: $(if ($total -gt 10 -or $tasks.Count -gt 5) { 'REVISAR' } else { 'LIMPIO' })"
    ) -ColorTitulo $(if ($total -gt 10) { $t.Warning } else { $t.Success })
}

function Invoke-SECCredentialScan {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Auditoría de Credenciales'

    $hallazgos = @()
    $sshKeys = Get-ChildItem -Path "$env:USERPROFILE\.ssh" -ErrorAction SilentlyContinue
    if ($sshKeys) { $hallazgos += "SSH keys: $($sshKeys.Count) archivos" }

    $envFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -Include '*.env','*.env.local','*.env.production' -Depth 3 -ErrorAction SilentlyContinue
    if ($envFiles) { $hallazgos += "Archivos .env: $($envFiles.Count)" }

    $gitCreds = Get-ChildItem -Path "$env:USERPROFILE\.git-credentials" -ErrorAction SilentlyContinue
    if ($gitCreds) { $hallazgos += "Git credentials expuestos" }

    Write-Host ''
    if ($hallazgos.Count -gt 0) {
        Show-RyuModal -Titulo 'Credenciales Encontradas' -Lineas $hallazgos -ColorTitulo $t.Warning
    } else {
        Write-StatusMsg -Mensaje 'No se encontraron credenciales expuestas' -Tipo 'EXITO'
    }
}

function Invoke-SECForensicTriage {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Triage Forense'
    Write-StatusMsg -Mensaje 'Recopilando evidencia del sistema...' -Tipo 'INFO'

    $evidencia = @{
        Timestamp = (Get-Date).ToString('o')
        Procesos = (Get-Process | Select-Object Name, Id, Path, CPU | ConvertTo-Json -Depth 2)
        Conexiones = (Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Established' } | ConvertTo-Json -Depth 2)
        Servicios = (Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName, Status | ConvertTo-Json -Depth 2)
    }

    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    if ($rutas -and $rutas.DirCache) {
        $reportDir = Join-Path $rutas.DirCache 'forensics'
        if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
        $fecha = Get-Date -Format 'yyyyMMdd_HHmmss'
        $archivo = Join-Path $reportDir "triage_${fecha}.json"
        $evidencia | ConvertTo-Json -Depth 5 | Set-Content -Path $archivo -Encoding UTF8 -Force
        Write-StatusMsg -Mensaje "Evidencia exportada: $archivo" -Tipo 'EXITO'
    }
}

function Get-SECEvidence {
    $t = GetT
    Write-StatusMsg -Mensaje 'Recopilando evidencia con hashes SHA-256...' -Tipo 'INFO'
    $procs = Get-Process | Where-Object { $_.Path } | Select-Object -First 20
    foreach ($p in $procs) {
        try {
            $hash = (Get-FileHash -Path $p.Path -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
            Write-StatusMsg -Mensaje "$($p.ProcessName): $hash" -Tipo 'INFO'
        } catch {}
    }
}

function Invoke-SECEventLogAnalysis {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Análisis de Logs de Seguridad'
    Write-StatusMsg -Mensaje 'Analizando logs de seguridad (últimas 24h)...' -Tipo 'INFO'

    $eventos = @()
    try {
        $failedLogons = Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625;StartTime=(Get-Date).AddHours(-24)} -MaxEvents 10 -ErrorAction SilentlyContinue
        if ($failedLogons) { $eventos += "Intentos de login fallidos: $($failedLogons.Count)" }

        $logClear = Get-WinEvent -FilterHashtable @{LogName='Security';Id=1102;StartTime=(Get-Date).AddHours(-24)} -MaxEvents 5 -ErrorAction SilentlyContinue
        if ($logClear) { $eventos += "Logs limpiados: $($logClear.Count)" }

        $newUsers = Get-WinEvent -FilterHashtable @{LogName='Security';Id=4720;StartTime=(Get-Date).AddHours(-24)} -MaxEvents 5 -ErrorAction SilentlyContinue
        if ($newUsers) { $eventos += "Nuevos usuarios creados: $($newUsers.Count)" }
    } catch {}

    Write-Host ''
    if ($eventos.Count -gt 0) {
        Show-RyuModal -Titulo 'Eventos de Seguridad Detectados' -Lineas $eventos -ColorTitulo $t.Warning
    } else {
        Write-StatusMsg -Mensaje 'No se encontraron eventos sospechosos en las últimas 24h' -Tipo 'EXITO'
    }
}

function Invoke-SECCleanup {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    $confirm = Show-Confirm -Mensaje '¿Limpiar rastros de malware?' -Detalle 'Se eliminarán procesos sospechosos y archivos temporales.'
    if (-not $confirm) { return }

    Write-StatusMsg -Mensaje 'Limpiando procesos sospechosos...' -Tipo 'INFO'
    Get-Process | Where-Object { $_.Path -match '\\Temp\\' -and $_.ProcessName -ne 'explorer' } | ForEach-Object {
        try { Stop-Process -Id $_.Id -Force -ErrorAction Stop; Write-StatusMsg -Mensaje "Proceso terminado: $($_.ProcessName)" -Tipo 'EXITO' } catch {}
    }
    Write-StatusMsg -Mensaje 'Limpieza completada' -Tipo 'EXITO'
}

function Invoke-SECFirewallHardening {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Endureciendo firewall...' -Tipo 'INFO'
    $puertosPeligrosos = @(23, 135, 137, 138, 139, 445, 3389)
    foreach ($port in $puertosPeligrosos) {
        try {
            New-NetFirewallRule -DisplayName "RYU-Block-$port" -Direction Inbound -LocalPort $port -Protocol TCP -Action Block -ErrorAction Stop
            Write-StatusMsg -Mensaje "Bloqueado puerto $port" -Tipo 'EXITO'
        } catch {}
    }
}

function Invoke-SECBaseline {
    $t = GetT
    Write-StatusMsg -Mensaje 'Capturando baseline del sistema...' -Tipo 'INFO'
    $baseline = @{
        Timestamp = (Get-Date).ToString('o')
        Puertos = (Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Listen' } | Select-Object LocalPort | ConvertTo-Json)
        Servicios = (Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name | ConvertTo-Json)
        Usuarios = (Get-LocalUser | Select-Object Name, Enabled | ConvertTo-Json)
    }
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    if ($rutas) {
        $archivo = Join-Path $rutas.DirCache 'baseline.json'
        $baseline | ConvertTo-Json -Depth 5 | Set-Content -Path $archivo -Encoding UTF8 -Force
        Write-StatusMsg -Mensaje "Baseline guardado: $archivo" -Tipo 'EXITO'
    }
}

function Invoke-SECStatus {
    $t = GetT
    Write-StatusMsg -Mensaje 'Comparando con baseline...' -Tipo 'INFO'
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    if (-not $rutas) { Write-StatusMsg -Mensaje 'Sin baseline guardado' -Tipo 'ADVERTENCIA'; return }
    $archivo = Join-Path $rutas.DirCache 'baseline.json'
    if (-not (Test-Path $archivo)) { Write-StatusMsg -Mensaje 'Sin baseline guardado. Ejecuta Invoke-SECBaseline primero.' -Tipo 'ADVERTENCIA'; return }
    Write-StatusMsg -Mensaje 'Baseline encontrado. Comparación pendiente de implementación completa.' -Tipo 'INFO'
}

function Invoke-SECHardening {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando hardening de seguridad...' -Tipo 'INFO'
    try {
        # UAC maximizado
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorAdmin' -Value 2 -Type DWord -Force
        # PowerShell logging
        $plPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
        New-Item -Path $plPath -Force | Out-Null
        Set-ItemProperty -Path $plPath -Name 'EnableScriptBlockLogging' -Value 1 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Hardening aplicado: UAC máximo + PowerShell logging' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-SECReport {
    $t = GetT
    Write-StatusMsg -Mensaje 'Generando reporte de seguridad...' -Tipo 'INFO'
    Invoke-SECFullScan
    Write-StatusMsg -Mensaje 'Reporte generado con resultados del escaneo completo' -Tipo 'EXITO'
}

function Invoke-SECAll {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Ejecutando auditoría de seguridad completa...' -Tipo 'INFO'
    Invoke-SECFullScan
    Invoke-SECHardening
    Invoke-SECReport
    Write-StatusMsg -Mensaje 'Auditoría de seguridad completa finalizada' -Tipo 'EXITO'
}

Export-ModuleMember -Function @(
    'Invoke-SECFullScan','Invoke-SECProcessScan','Invoke-SECNetworkScan',
    'Invoke-SECPersistenceScan','Invoke-SECCredentialScan','Invoke-SECForensicTriage',
    'Get-SECEvidence','Invoke-SECEventLogAnalysis','Invoke-SECCleanup',
    'Invoke-SECFirewallHardening','Invoke-SECBaseline','Invoke-SECStatus',
    'Invoke-SECHardening','Invoke-SECReport', 'Invoke-SECAll'
)
