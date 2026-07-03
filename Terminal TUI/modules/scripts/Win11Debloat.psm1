#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Debloater de Windows 11.
.DESCRIPTION
    Elimina bloatware preinstalado de Windows 11, desactiva telemetría y limpia el sistema.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-RyuWin11Debloat {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Debloat Windows 11'
    Write-RyuLog -Mensaje 'Iniciando debloat de Windows 11' -Nivel 'INFO' -Modulo 'Win11Debloat'

    if (-not (Test-AdminRequired)) {
        Write-StatusMsg -Mensaje 'Se requieren privilegios de administrador para debloater Windows 11' -Tipo 'ERROR'
        Show-PausePrompt
        return
    }

    # ─── PAQUETES BLOATWARE ─────────────────────────
    $bloatware = @(
        'Microsoft.BingNews'
        'Microsoft.BingWeather'
        'Microsoft.GetHelp'
        'Microsoft.Getstarted'
        'Microsoft.MicrosoftOfficeHub'
        'Microsoft.MicrosoftSolitaireCollection'
        'Microsoft.People'
        'Microsoft.SkypeApp'
        'Microsoft.WindowsFeedbackHub'
        'Microsoft.YourPhone'
        'Microsoft.ZuneMusic'
        'Microsoft.ZuneVideo'
        'king.com.CandyCrushSaga'
        'king.com.CandyCrushSodaSaga'
        'SpotifyAB.SpotifyMusic'
        'Disney.37853FC22B2CE'
        'BytedancePte.Ltd.TikTok'
    )

    # ─── SELECCIONAR ACCIONES ───────────────────────
    $acciones = @(
        'Eliminar bloatware preinstalado',
        'Desactivar telemetría',
        'Deshabilitar servicios innecesarios',
        'Limpiar menú inicio'
    )
    $iconos = @('◈','◆','◇','▣')

    $seleccion = Show-RyuMultiMenu -Titulo 'Seleccionar acciones de debloat' -Opciones $acciones -Iconos $iconos -SeleccionDefault @(0,1,2)

    if ($seleccion.Count -eq 0) {
        Write-StatusMsg -Mensaje 'Debloat cancelado' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    $confirm = Show-Confirm -Mensaje '¿Ejecutar debloat de Windows 11?' -Detalle 'Se realizarán cambios significativos en el sistema. Se recomienda crear un punto de restauración primero.'
    if (-not $confirm) {
        Write-StatusMsg -Mensaje 'Debloat cancelado' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    # ─── CREAR PUNTO DE RESTAURACIÓN ────────────────
    Write-StatusMsg -Mensaje 'Creando punto de restauración...' -Tipo 'INFO'
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Pre-Debloat RYU-TUI" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-StatusMsg -Mensaje 'Punto de restauración creado' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "No se pudo crear punto de restauración: $($_.Exception.Message)" -Tipo 'ADVERTENCIA'
    }

    $eliminados = 0
    $errores = 0

    # ─── ELIMINAR BLOATWARE ─────────────────────────
    if (0 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Eliminando bloatware preinstalado...' -Tipo 'INFO'
        foreach ($pkg in $bloatware) {
            try {
                $existe = Get-AppxPackage -Name $pkg -AllUsers -ErrorAction SilentlyContinue
                if ($existe) {
                    Get-AppxPackage -Name $pkg -AllUsers | Remove-AppxPackage -ErrorAction Stop
                    Write-StatusMsg -Mensaje "Eliminado: $pkg" -Tipo 'EXITO'
                    $eliminados++
                }
            } catch {
                Write-StatusMsg -Mensaje "No se pudo eliminar: $pkg" -Tipo 'ADVERTENCIA'
                $errores++
            }
        }
    }

    # ─── DESACTIVAR TELEMETRÍA ──────────────────────
    if (1 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Desactivando telemetría...' -Tipo 'INFO'
        try {
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 -Force -ErrorAction Stop
            Stop-Service -Name 'DiagTrack' -Force -ErrorAction SilentlyContinue
            Set-Service -Name 'DiagTrack' -StartupType Disabled -ErrorAction SilentlyContinue
            Write-StatusMsg -Mensaje 'Telemetría desactivada' -Tipo 'EXITO'
        } catch {
            Write-StatusMsg -Mensaje "Error desactivando telemetría: $($_.Exception.Message)" -Tipo 'ERROR'
            $errores++
        }
    }

    # ─── DESHABILITAR SERVICIOS ─────────────────────
    if (2 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Deshabilitando servicios innecesarios...' -Tipo 'INFO'
        $servicios = @('SysMain', 'WSearch', 'RetailDemo')
        foreach ($svc in $servicios) {
            try {
                Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                Write-StatusMsg -Mensaje "Servicio $svc deshabilitado" -Tipo 'EXITO'
            } catch {
                Write-StatusMsg -Mensaje "No se pudo deshabilitar: $svc" -Tipo 'ADVERTENCIA'
            }
        }
    }

    # ─── LIMPIAR MENÚ INICIO ────────────────────────
    if (3 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Limpiando menú inicio...' -Tipo 'INFO'
        $startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
        if (Test-Path $startMenu) {
            $inicios = Get-ChildItem -Path $startMenu -Filter '*.lnk' -Recurse -ErrorAction SilentlyContinue
            $eliminados += $inicios.Count
            Write-StatusMsg -Mensaje "Atajos de menú inicio analizados: $($inicios.Count)" -Tipo 'INFO'
        }
    }

    # ─── RESULTADOS ─────────────────────────────────
    Write-Host ''
    Show-RyuModal -Titulo 'Debloat Completado' -Lineas @(
        "▸ Paquetes eliminados: $eliminados",
        "▸ Errores: $errores",
        "▸ Estado: $(if ($errores -eq 0) { 'Exitoso' } else { 'Parcial' })"
    ) -ColorTitulo $(if ($errores -eq 0) { $t.Success } else { $t.Warning })

    Write-RyuLog -Mensaje "Debloat completado — $eliminados eliminados, $errores errores" -Nivel 'EXITO' -Modulo 'Win11Debloat'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Start-RyuWin11Debloat')