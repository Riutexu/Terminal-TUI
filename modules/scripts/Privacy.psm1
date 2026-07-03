#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Privacy — 7 funciones de privacidad y seguridad.
.DESCRIPTION
    Telemetry, Copilot, Ads, Edge, Bloatware, Telemetry Services, Telemetry Tasks.
    Inspirado en: Win-Debloat7, esicera/Windows11OptimizationScript, wininit.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return [System.Security.Principal.WindowsPrincipal]::new($id).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-PRVTelemetry {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando telemetría completa...' -Tipo 'INFO'
    try {
        $dcPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
        New-ItemProperty -Path $dcPath -Name 'AllowTelemetry' -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path $dcPath -Name 'DoNotShowFeedbackNotifications' -PropertyType DWord -Value 1 -Force | Out-Null
        New-ItemProperty -Path $dcPath -Name 'LimitDiagnosticLogCollection' -PropertyType DWord -Value 1 -Force | Out-Null

        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 -Type DWord -Force
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Input\TIPC' -Name 'Enabled' -Value 0 -Type DWord -Force

        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' -Name 'AITEnable' -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' -Name 'DisableInventory' -PropertyType DWord -Value 1 -Force | Out-Null

        Write-StatusMsg -Mensaje 'Telemetría deshabilitada (registry + advertising ID)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRVCopilot {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando Copilot y Recall...' -Tipo 'INFO'
    try {
        $copilotPath = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
        New-Item -Path $copilotPath -Force | Out-Null
        Set-ItemProperty -Path $copilotPath -Name 'TurnOffWindowsCopilot' -Value 1 -Type DWord -Force

        $machPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'
        New-Item -Path $machPath -Force | Out-Null
        Set-ItemProperty -Path $machPath -Name 'TurnOffWindowsCopilot' -Value 1 -Type DWord -Force

        $recallPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'
        New-Item -Path $recallPath -Force | Out-Null
        Set-ItemProperty -Path $recallPath -Name 'AllowRecallEnablement' -Value 0 -Type DWord -Force

        Write-StatusMsg -Mensaje 'Copilot y Recall deshabilitados' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRVAds {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando publicidad y tracking...' -Tipo 'INFO'
    try {
        $cdmPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Set-ItemProperty -Path $cdmPath -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $cdmPath -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $cdmPath -Name 'SilentInstalledAppsEnabled' -Value 0 -Type DWord -Force

        $tipsPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Set-ItemProperty -Path $tipsPath -Name 'SoftLandingEnabled' -Value 0 -Type DWord -Force

        Write-StatusMsg -Mensaje 'Publicidad, suggestions y tracking deshabilitados' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRVEdge {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Removiendo Microsoft Edge...' -Tipo 'INFO'
    try {
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
        if (Test-Path $edgePath) {
            $version = (Get-ChildItem "$edgePath\*\Installer" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1).Name
            if ($version) {
                Start-Process "$edgePath\$version\Installer\setup.exe" -ArgumentList '--uninstall --system-level --verbose-logging' -Wait -NoNewWindow -ErrorAction Stop
            }
        }
        $blockPath = 'HKLM:\SOFTWARE\Microsoft\EdgeUpdate'
        New-Item -Path $blockPath -Force | Out-Null
        Set-ItemProperty -Path $blockPath -Name 'DoNotUpdateToEdgeWithChromium' -Value 1 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Edge removido y bloqueado de actualizaciones' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-PRVBloatware {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Removiendo bloatware...' -Tipo 'INFO'
    $bloatware = @(
        'Microsoft.BingNews','Microsoft.BingWeather','Microsoft.GetHelp','Microsoft.Getstarted'
        'Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.People'
        'Microsoft.SkypeApp','Microsoft.WindowsFeedbackHub','Microsoft.YourPhone'
        'Microsoft.ZuneMusic','Microsoft.ZuneVideo','king.com.CandyCrushSaga'
        'king.com.CandyCrushSodaSaga','SpotifyAB.SpotifyMusic','Clipchamp'
        'Microsoft.PowerAutomateDesktop','Microsoft.WindowsAlarms','Microsoft.WindowsMaps'
        'Microsoft.WindowsSoundRecorder','Microsoft.549981C3F5F10','Microsoft.Windows.Copilot'
        'Microsoft.OutlookForWindows','Microsoft.Todos','Microsoft.Windows.Photos'
        'Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameOverlay'
        'Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider'
        'Microsoft.XboxSpeechToTextOverlay'
    )
    $eliminados = 0
    foreach ($pkg in $bloatware) {
        try {
            $exists = Get-AppxPackage -Name $pkg -AllUsers -ErrorAction SilentlyContinue
            if ($exists) {
                Get-AppxPackage -Name $pkg -AllUsers | Remove-AppxPackage -ErrorAction Stop
                $eliminados++
            }
        } catch {}
    }
    Write-StatusMsg -Mensaje "Bloatware eliminado: $eliminados paquetes" -Tipo 'EXITO'
}

function Invoke-PRVTelemetryServices {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando servicios de telemetría...' -Tipo 'INFO'
    $servicios = @('DiagTrack','dmwappushservice','WerSvc')
    foreach ($svc in $servicios) {
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
            Write-StatusMsg -Mensaje "Servicio $svc deshabilitado" -Tipo 'EXITO'
        } catch {}
    }
}

function Invoke-PRVTelemetryTasks {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando tareas de telemetría...' -Tipo 'INFO'
    $tareas = @(
        '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
        '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
        '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
        '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
        '\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask',
        '\Microsoft\Windows\Autochk\Proxy',
        '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
        '\Microsoft\Windows\Feedback\Siuf\DmClient',
        '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'
    )
    $desabilitadas = 0
    foreach ($tarea in $tareas) {
        $result = Disable-ScheduledTask -TaskName $tarea -ErrorAction SilentlyContinue
        if ($result) { $desabilitadas++ }
    }
    Write-StatusMsg -Mensaje "Tareas de telemetría deshabilitadas: $desabilitadas" -Tipo 'EXITO'
}

function Invoke-PRVAll {
    $t = GetT
    Write-StatusMsg -Mensaje 'Aplicando todas las optimizaciones de privacidad...' -Tipo 'INFO'
    Invoke-PRVTelemetry
    Invoke-PRVCopilot
    Invoke-PRVAds
    Invoke-PRVEdge
    Invoke-PRVBloatware
    Invoke-PRVTelemetryServices
    Invoke-PRVTelemetryTasks
    Write-StatusMsg -Mensaje 'Todas las optimizaciones de privacidad aplicadas' -Tipo 'EXITO'
}

Export-ModuleMember -Function @(
    'Invoke-PRVTelemetry','Invoke-PRVCopilot','Invoke-PRVAds',
    'Invoke-PRVEdge','Invoke-PRVBloatware','Invoke-PRVTelemetryServices',
    'Invoke-PRVTelemetryTasks', 'Invoke-PRVAll'
)
