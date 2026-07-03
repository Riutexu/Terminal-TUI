#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Optimizer — 10 funciones de optimización del sistema.
.DESCRIPTION
    CPU, GPU, RAM, Energía, Visual, Pagefile, Servicios, Tareas, Boot, Core Parking.
    Inspirado en: Ultimate-Windows-System-Optimizer, Win-Debloat7, High-Performance-Windows-Toolkit.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return [System.Security.Principal.WindowsPrincipal]::new($id).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Save-RegistryBackup {
    param([string]$Ruta)
    $backup = @()
    $keys = @(
        'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl',
        'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
        'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects',
        'HKCU:\Control Panel\Desktop',
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    )
    foreach ($key in $keys) {
        if (Test-Path $key) {
            $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
            if ($props) {
                $psObj = $props.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }
                foreach ($p in $psObj) {
                    $backup += @{ Key = $key; Name = $p.Name; Value = $p.Value }
                }
            }
        }
    }
    $backup | ConvertTo-Json -Depth 3 | Set-Content -Path $Ruta -Encoding UTF8 -Force
}

function Invoke-OPTPowerPlan {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Configurando plan de energía Ultimate Performance...' -Tipo 'INFO'
    try {
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-Null
        $plan = powercfg -list | Select-String 'e9a42b02'
        if ($plan) {
            $guid = ($plan -split '\s+')[3]
            powercfg -setactive $guid
            Write-StatusMsg -Mensaje 'Plan Ultimate Performance activado' -Tipo 'EXITO'
        } else {
            powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-StatusMsg -Mensaje 'Plan High Performance activado (fallback)' -Tipo 'EXITO'
        }
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTCPU {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando CPU: Win32PrioritySeparation...' -Tipo 'INFO'
    try {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 0x26 -Type DWord -Force
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'IRQ0Priority' -Value 1 -Type DWord -Force
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'IRQ8Priority' -Value 1 -Type DWord -Force
        Write-StatusMsg -Mensaje 'CPU optimizado: foreground priority boost activado' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTGPU {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Habilitando Hardware-Accelerated GPU Scheduling...' -Tipo 'INFO'
    try {
        $gpuPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
        Set-ItemProperty -Path $gpuPath -Name 'HwSchMode' -Value 2 -Type DWord -Force
        Write-StatusMsg -Mensaje 'HAGS habilitado (requiere reinicio)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTVisuals {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando efectos visuales...' -Tipo 'INFO'
    try {
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 2 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'FontSmoothing' -Value '2' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 0 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 0 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Efectos visuales optimizados (font smoothing conservado)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTPagefile {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando pagefile...' -Tipo 'INFO'
    try {
        $mmPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
        Set-ItemProperty -Path $mmPath -Name 'DisablePagingExecutive' -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $mmPath -Name 'LargeSystemCache' -Value 1 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Pagefile optimizado: kernel en RAM, LargeSystemCache' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTServices {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando servicios innecesarios...' -Tipo 'INFO'
    $servicios = @(
        'DiagTrack','dmwappushservice','WerSvc','XblAuthManager','XblGameSave',
        'XboxGipSvc','XboxNetApiSvc','Fax','RetailDemo','wisvc','MapsBroker',
        'lfsvc','PhoneSvc','MessagingService','PcaSvc','WMPNetworkSvc','icssvc',
        'AJRouter','WalletService','WpcMonSvc','SEMgrSvc','SmsRouter',
        'CDPSvc','CDPUserSvc','TrkWks','NPSMSvc','RmSvc','Spooler'
    )
    $desabilitados = 0
    foreach ($svc in $servicios) {
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Manual -ErrorAction Stop
            $desabilitados++
        } catch {}
    }
    Write-StatusMsg -Mensaje "Servicios optimizados: $desabilitados/$($servicios.Count)" -Tipo 'EXITO'
}

function Invoke-OPTScheduledTasks {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando tareas programadas innecesarias...' -Tipo 'INFO'
    $tareas = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
        '\Microsoft\Windows\Autochk\Proxy',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Feedback\Siuf\DmClient',
        '\Microsoft\Windows\Maps\MapsToastTask',
        '\Microsoft\Windows\Maps\MapsUpdateTask',
        '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem',
        '\Microsoft\Windows\Shell\FamilySafetyMonitor',
        '\Microsoft\Windows\Windows Error Reporting\QueueReporting'
    )
    $desabilitadas = 0
    foreach ($tarea in $tareas) {
        $result = Disable-ScheduledTask -TaskName $tarea -ErrorAction SilentlyContinue
        if ($result) { $desabilitadas++ }
    }
    Write-StatusMsg -Mensaje "Tareas deshabilitadas: $desabilitadas/$($tareas.Count)" -Tipo 'EXITO'
}

function Invoke-OPTBoot {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando tiempo de arranque...' -Tipo 'INFO'
    try {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'WaitToKillServiceTimeout' -Value '2000' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'WaitToKillAppTimeout' -Value '2000' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'HungAppTimeout' -Value '1000' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -Value '1' -Type String -Force
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'Serialize' -Value 0 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Boot optimizado: timeouts reducidos, startup delay eliminado' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTHibernation {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando hibernación...' -Tipo 'INFO'
    try {
        & powercfg /hibernate off 2>&1 | Out-Null
        Write-StatusMsg -Mensaje 'Hibernación desactivada (ahorra espacio en disco)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTCoreParking {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando Core Parking...' -Tipo 'INFO'
    try {
        & powercfg -setacvalueindex SCHEME_CURRENT sub_processor CPMINCORES 100 2>&1 | Out-Null
        & powercfg -setactive SCHEME_CURRENT 2>&1 | Out-Null
        Write-StatusMsg -Mensaje 'Core Parking deshabilitado: todos los núcleos activos' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-OPTAll {
    $t = GetT
    Write-StatusMsg -Mensaje 'Aplicando todas las optimizaciones del sistema...' -Tipo 'INFO'
    Invoke-OPTPowerPlan
    Invoke-OPTCPU
    Invoke-OPTGPU
    Invoke-OPTVisuals
    Invoke-OPTPagefile
    Invoke-OPTServices
    Invoke-OPTScheduledTasks
    Invoke-OPTBoot
    Invoke-OPTHibernation
    Invoke-OPTCoreParking
    Write-StatusMsg -Mensaje 'Todas las optimizaciones aplicadas' -Tipo 'EXITO'
}

Export-ModuleMember -Function @(
    'Invoke-OPTPowerPlan','Invoke-OPTCPU','Invoke-OPTGPU','Invoke-OPTVisuals',
    'Invoke-OPTPagefile','Invoke-OPTServices','Invoke-OPTScheduledTasks',
    'Invoke-OPTBoot','Invoke-OPTHibernation','Invoke-OPTCoreParking',
    'Invoke-OPTAll'
)
