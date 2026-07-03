#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Profiles — Perfiles de optimización predefinidos.
.DESCRIPTION
    Gaming, Privacy, Balanced, Aggressive, DesktopLite con restauración.
    Inspirado en: O&O ShutUp10, WinAero Tweaker, TechBloat.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return [System.Security.Principal.WindowsPrincipal]::new($id).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Save-ProfileUndo {
    param([string]$Nombre, [hashtable]$Valores)
    $t = GetT
    $undoPath = Join-Path $t.Rutas.PerfilRuta "undo_$Nombre.json"
    $backup = @()
    foreach ($key in $Valores.Keys) {
        $path = $key.Substring(0, $key.LastIndexOf('\'))
        $name = $key.Substring($key.LastIndexOf('\') + 1)
        if (Test-Path $path) {
            $current = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
            if ($current) {
                $backup += @{ Path = $path; Name = $name; Value = $current.$name }
            }
        }
    }
    $backup | ConvertTo-Json -Depth 3 | Set-Content -Path $undoPath -Encoding UTF8 -Force
    Write-StatusMsg -Mensaje "Backup guardado: $undoPath" -Tipo 'INFO'
}

function Restore-ProfileUndo {
    param([string]$Nombre)
    $t = GetT
    $undoPath = Join-Path $t.Rutas.PerfilRuta "undo_$Nombre.json"
    if (-not (Test-Path $undoPath)) {
        Write-StatusMsg -Mensaje "No se encontró backup para perfil $Nombre" -Tipo 'ERROR'
        return
    }
    $backup = Get-Content -Path $undoPath -Raw | ConvertFrom-Json
    $restored = 0
    foreach ($entry in $backup) {
        try {
            if (Test-Path $entry.Path) {
                Set-ItemProperty -Path $entry.Path -Name $entry.Name -Value $entry.Value -Type DWord -Force -ErrorAction SilentlyContinue
                $restored++
            }
        } catch {}
    }
    Write-StatusMsg -Mensaje "Restaurados $restored valores del perfil $Nombre" -Tipo 'EXITO'
}

function Invoke-PRFGaming {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando perfil Gaming...' -Tipo 'INFO'
    try {
        # Guardar estado actual
        Save-ProfileUndo -Nombre 'Gaming' -Valores @{
            'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl\Win32PrioritySeparation' = 'Win32PrioritySeparation'
            'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\NetworkThrottlingIndex' = 'NetworkThrottlingIndex'
            'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\SystemResponsiveness' = 'SystemResponsiveness'
        }

        # Win32PrioritySeparation
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 0x26 -Type DWord -Force
        # Network Throttling
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'NetworkThrottlingIndex' -Value 0xffffffff -Type DWord -Force
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 0 -Type DWord -Force
        # Game Mode
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 1 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Value 1 -Type DWord -Force
        # Game DVR off
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        # HAGS
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Value 2 -Type DWord -Force
        # Game priority
        $gamePath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
        if (-not (Test-Path $gamePath)) { New-Item -Path $gamePath -Force | Out-Null }
        Set-ItemProperty -Path $gamePath -Name 'GPU Priority' -Value 8 -Type DWord -Force
        Set-ItemProperty -Path $gamePath -Name 'Priority' -Value 6 -Type DWord -Force
        Set-ItemProperty -Path $gamePath -Name 'Scheduling Category' -Value 'High' -Type String -Force
        Set-ItemProperty -Path $gamePath -Name 'SFIO Priority' -Value 'High' -Type String -Force
        # Nagle off
        $interfaces = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
        foreach ($iface in $interfaces) {
            $id = $iface.InterfaceGuid
            $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{$id}"
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $path -Name 'TCPNoDelay' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            }
        }
        Write-StatusMsg -Mensaje 'Perfil Gaming aplicado: throttling off, prioridad alta, Game Mode, HAGS' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRFPrivacy {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando perfil Privacy...' -Tipo 'INFO'
    try {
        # Guardar estado actual
        Save-ProfileUndo -Nombre 'Privacy' -Valores @{
            'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry' = 'AllowTelemetry'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\RotatingLockScreenOverlayEnabled' = 'RotatingLockScreenOverlayEnabled'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SystemPaneSuggestionsEnabled' = 'SystemPaneSuggestionsEnabled'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SoftLandingEnabled' = 'SoftLandingEnabled'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338389Enabled' = 'SubscribedContent-338389Enabled'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-310093Enabled' = 'SubscribedContent-310093Enabled'
        }

        # Telemetry
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 -Type DWord -Force
        # Advertising ID
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        # Content Delivery
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenOverlayEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SoftLandingEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-310093Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        # Telemetry services
        $svcNames = @('DiagTrack', 'dmwappushservice', 'WerSvc')
        foreach ($svc in $svcNames) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Write-StatusMsg -Mensaje 'Perfil Privacy aplicado: telemetría off, ads off, suggestions off' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRFBalanced {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando perfil Balanced...' -Tipo 'INFO'
    try {
        # Guardar estado actual
        Save-ProfileUndo -Nombre 'Balanced' -Valores @{
            'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl\Win32PrioritySeparation' = 'Win32PrioritySeparation'
            'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\NetworkThrottlingIndex' = 'NetworkThrottlingIndex'
            'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry' = 'AllowTelemetry'
        }

        # Win32PrioritySeparation (balanced)
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 0x2 -Type DWord -Force
        # Network Throttling (balanced)
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'NetworkThrottlingIndex' -Value 10 -Type DWord -Force
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 20 -Type DWord -Force
        # Telemetry (basic)
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 1 -Type DWord -Force
        # Game Mode off
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AutoGameModeEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje 'Perfil Balanced aplicado: configuración estándar de Windows' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRFAggressive {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando perfil Aggressive...' -Tipo 'INFO'
    try {
        # Guardar estado actual
        Save-ProfileUndo -Nombre 'Aggressive' -Valores @{
            'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl\Win32PrioritySeparation' = 'Win32PrioritySeparation'
            'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\NetworkThrottlingIndex' = 'NetworkThrottlingIndex'
            'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\DisablePagingExecutive' = 'DisablePagingExecutive'
        }

        # Win32PrioritySeparation (aggressive)
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Value 0x26 -Type DWord -Force
        # Network Throttling
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'NetworkThrottlingIndex' -Value 0xffffffff -Type DWord -Force
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness' -Value 0 -Type DWord -Force
        # Pagefile
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 1 -Type DWord -Force
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'LargeSystemCache' -Value 1 -Type DWord -Force
        # Boot
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'WaitToKillServiceTimeout' -Value '2000' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'WaitToKillAppTimeout' -Value '2000' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'HungAppTimeout' -Value '1000' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -Value '1' -Type String -Force
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'Serialize' -Value 0 -Type DWord -Force
        # Telemetry
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 -Type DWord -Force
        # HAGS
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Value 2 -Type DWord -Force
        # Core Parking off
        & powercfg -setacvalueindex SCHEME_CURRENT sub_processor CPMINCORES 100 2>&1 | Out-Null
        & powercfg -setactive SCHEME_CURRENT 2>&1 | Out-Null
        Write-StatusMsg -Mensaje 'Perfil Aggressive aplicado: todo al máximo, telemetría off, boot rápido' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRFDesktopLite {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando perfil Desktop Lite...' -Tipo 'INFO'
    try {
        # Guardar estado actual
        Save-ProfileUndo -Nombre 'DesktopLite' -Valores @{
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting' = 'VisualFXSetting'
            'HKCU:\Control Panel\Desktop\MenuShowDelay' = 'MenuShowDelay'
            'HKCU:\Control Panel\Desktop\FontSmoothing' = 'FontSmoothing'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\EnableTransparency' = 'EnableTransparency'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAnimations' = 'TaskbarAnimations'
        }

        # Visual effects minimal
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 3 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'FontSmoothing' -Value '2' -Type String -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 0 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Value 0 -Type DWord -Force
        # Deshabilitar servicios innecesarios
        $svcNames = @('DiagTrack', 'dmwappushservice', 'WerSvc', 'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc')
        foreach ($svc in $svcNames) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Write-StatusMsg -Mensaje 'Perfil Desktop Lite aplicado: efectos mínimos, servicios reducidos' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRFSelect {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    $perfiles = @(
        @{ Nombre = 'Gaming';        Icono = '🎮'; Descripcion = 'Maximiza rendimiento para juegos' },
        @{ Nombre = 'Privacy';       Icono = '🔒'; Descripcion = 'Máxima privacidad, telemetría off' },
        @{ Nombre = 'Balanced';      Icono = '⚖️'; Descripcion = 'Equilibrio rendimiento/estabilidad' },
        @{ Nombre = 'Aggressive';    Icono = '⚡'; Descripcion = 'Todo al máximo, sin límites' },
        @{ Nombre = 'Desktop Lite';  Icono = '🖥️'; Descripcion = 'Efectos mínimos, servicios reducidos' }
    )
    $nombres = $perfiles | ForEach-Object { $_.Nombre }
    $iconos  = $perfiles | ForEach-Object { $_.Icono }
    $descs   = $perfiles | ForEach-Object { $_.Descripcion }

    $seleccion = Show-RyuMenu -Titulo 'Seleccionar Perfil' -Opciones $nombres -Iconos $iconos -Descripciones $descs
    if ($seleccion -eq 0) { Write-StatusMsg -Mensaje 'Selección cancelada' -Tipo 'ADVERTENCIA'; return }

    $perfil = $perfiles[$seleccion - 1]
    $confirm = Show-Confirm -Mensaje "¿Aplicar perfil $($perfil.Nombre)?" -Detalle $perfil.Descripcion
    if (-not $confirm) { Write-StatusMsg -Mensaje 'Perfil no aplicado' -Tipo 'ADVERTENCIA'; return }

    switch ($seleccion) {
        1 { Invoke-PRFGaming }
        2 { Invoke-PRFPrivacy }
        3 { Invoke-PRFBalanced }
        4 { Invoke-PRFAggressive }
        5 { Invoke-PRFDesktopLite }
    }
}

Export-ModuleMember -Function @(
    'Invoke-PRFGaming', 'Invoke-PRFPrivacy', 'Invoke-PRFBalanced',
    'Invoke-PRFAggressive', 'Invoke-PRFDesktopLite', 'Restore-ProfileUndo',
    'Invoke-PRFSelect'
)