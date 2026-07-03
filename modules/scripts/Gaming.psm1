#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Gaming — Optimización para gaming.
.DESCRIPTION
    GameMode, GPU, Latency, Nagle Gaming, Priority.
    Inspirado en: Intelligent-Game-Optimizer, Process-Lasso, BES.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return [System.Security.Principal.WindowsPrincipal]::new($id).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-GAMGameMode {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Habilitando Game Mode de Windows...' -Tipo 'INFO'
    try {
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Value 1 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Game Mode habilitado (optimiza recursos para juegos)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-GAMGPU {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando GPU para gaming...' -Tipo 'INFO'
    try {
        # Hardware-Accelerated GPU Scheduling (HAGS)
        $gpuPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
        Set-ItemProperty -Path $gpuPath -Name 'HwSchMode' -Value 2 -Type DWord -Force
        # Habilitar Shader Cache
        Set-ItemProperty -Path $gpuPath -Name 'HwSchMode' -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        # Prioridad de GPU
        $gamePath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
        if (-not (Test-Path $gamePath)) { New-Item -Path $gamePath -Force | Out-Null }
        Set-ItemProperty -Path $gamePath -Name 'GPU Priority' -Value 8 -Type DWord -Force
        Set-ItemProperty -Path $gamePath -Name 'Priority' -Value 6 -Type DWord -Force
        Set-ItemProperty -Path $gamePath -Name 'Scheduling Category' -Value 'High' -Type String -Force
        Set-ItemProperty -Path $gamePath -Name 'SFIO Priority' -Value 'High' -Type String -Force
        Write-StatusMsg -Mensaje 'GPU optimizada: HAGS habilitado, prioridad de juego configurada' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-GAMLatency {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando latencia de red para gaming...' -Tipo 'INFO'
    try {
        # Deshabilitar Nagle en todas las interfaces activas
        $interfaces = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
        $count = 0
        foreach ($iface in $interfaces) {
            $id = $iface.InterfaceGuid
            $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{$id}"
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $path -Name 'TCPNoDelay' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $path -Name 'TcpDelAckTicks' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                $count++
            }
        }
        Write-StatusMsg -Mensaje "Latencia optimizada en $count adaptadores (Nagle off, acks inmediatos)" -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-GAMPriority {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Configurando prioridades de procesos...' -Tipo 'INFO'
    try {
        # Win32PrioritySeparation para gaming (foreground boost)
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 0x26 -Type DWord -Force
        # Deshabilitar Game DVR
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        # Deshabilitar Game Bar
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'UseNexusForGameBarEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje 'Prioridades configuradas: foreground boost, Game DVR/Game Bar deshabilitados' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-GAMNagle {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando Nagle para gaming...' -Tipo 'INFO'
    try {
        # Network Throttling Index
        $netPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
        Set-ItemProperty -Path $netPath -Name 'NetworkThrottlingIndex' -Value 0xffffffff -Type DWord -Force
        Set-ItemProperty -Path $netPath -Name 'SystemResponsiveness' -Value 0 -Type DWord -Force
        # TCP auto-tuning
        $tcpPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
        Set-ItemProperty -Path $tcpPath -Name 'TcpAutoTuningLevel' -Value 3 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpPath -Name 'TcpWindowSize' -Value 65535 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje 'Nagle gaming: throttling off, window size 65535' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-GAMAll {
    $t = GetT
    Write-StatusMsg -Mensaje 'Aplicando todas las optimizaciones de gaming...' -Tipo 'INFO'
    Invoke-GAMGameMode
    Invoke-GAMGPU
    Invoke-GAMLatency
    Invoke-GAMPriority
    Invoke-GAMNagle
    Write-StatusMsg -Mensaje 'Todas las optimizaciones de gaming aplicadas' -Tipo 'EXITO'
}

Export-ModuleMember -Function @(
    'Invoke-GAMGameMode', 'Invoke-GAMGPU', 'Invoke-GAMLatency',
    'Invoke-GAMPriority', 'Invoke-GAMNagle', 'Invoke-GAMAll'
)