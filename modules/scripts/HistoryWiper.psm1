#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Borrador de historial del sistema.
.DESCRIPTION
    Limpia historial de navegación, archivos recientes, caché de Windows y más.
#>

Set-StrictMode -Version Latest

function Start-RyuHistoryWiper {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Borrar Historial'
    Write-RyuLog -Mensaje 'Iniciando limpieza de historial' -Nivel 'INFO' -Modulo 'HistoryWiper'

    # ─── CATEGORÍAS DE HISTORIAL ────────────────────
    $categorias = @(
        'Historial de navegación',
        'Archivos recientes',
        'Caché DNS',
        'Historial de ejecución',
        'Papelera de reciclaje',
        'Caché de Windows Update'
    )
    $iconos = @('◈','◆','◇','▣','◆','◈')

    # ─── SELECCIONAR QUÉ BORRAR ─────────────────────
    $seleccion = Show-RyuMultiMenu -Titulo 'Seleccionar historial a borrar' -Opciones $categorias -Iconos $iconos -SeleccionDefault @(0,1,3,4)

    if ($seleccion.Count -eq 0) {
        Write-StatusMsg -Mensaje 'Limpieza de historial cancelada' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    $confirm = Show-Confirm -Mensaje '¿Borrar historial seleccionado?' -Detalle 'Esta acción es irreversible. Se eliminarán los datos seleccionados permanentemente.'
    if (-not $confirm) {
        Write-StatusMsg -Mensaje 'Limpieza cancelada' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    $totalBorrado = 0

    # ─── HISTORIAL NAVEGADORES ──────────────────────
    if (0 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Borrando historial de navegadores...' -Tipo 'INFO'
        $perfiles = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default",
            "$env:APPDATA\BraveSoftware\Brave-Browser\User Data\Default"
        )
        foreach ($perfil in $perfiles) {
            if (Test-Path $perfil) {
                $historial = Join-Path $perfil 'History'
                if (Test-Path $historial) {
                    Remove-Item -Path $historial -Force -ErrorAction SilentlyContinue
                    $totalBorrado++
                }
            }
        }
        Write-StatusMsg -Mensaje 'Historial de navegadores borrado' -Tipo 'EXITO'
    }

    # ─── ARCHIVOS RECIENTES ─────────────────────────
    if (1 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Borrando archivos recientes...' -Tipo 'INFO'
        $recentPath = Join-Path $env:APPDATA 'Microsoft\Windows\Recent'
        if (Test-Path $recentPath) {
            $archivos = Get-ChildItem -Path $recentPath -Force -ErrorAction SilentlyContinue
            $totalBorrado += $archivos.Count
            $archivos | Remove-Item -Force -ErrorAction SilentlyContinue
        }
        Write-StatusMsg -Mensaje 'Archivos recientes borrados' -Tipo 'EXITO'
    }

    # ─── CACHÉ DNS ──────────────────────────────────
    if (2 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Limpiando caché DNS...' -Tipo 'INFO'
        try {
            Clear-DnsClientCache -ErrorAction Stop
            Write-StatusMsg -Mensaje 'Caché DNS limpiada' -Tipo 'EXITO'
        } catch {
            Write-StatusMsg -Mensaje 'No se pudo limpiar caché DNS' -Tipo 'ADVERTENCIA'
        }
    }

    # ─── HISTORIAL EJECUCIÓN ────────────────────────
    if (3 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Borrando historial de ejecución...' -Tipo 'INFO'
        try {
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -Force -ErrorAction Stop
            Write-StatusMsg -Mensaje 'Historial de ejecución borrado' -Tipo 'EXITO'
        } catch {
            Write-StatusMsg -Mensaje 'No se pudo borrar historial de ejecución' -Tipo 'ADVERTENCIA'
        }
    }

    # ─── PAPELERA RECICLAJE ─────────────────────────
    if (4 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Vaciando papelera de reciclaje...' -Tipo 'INFO'
        try {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-StatusMsg -Mensaje 'Papelera vaciada' -Tipo 'EXITO'
        } catch {
            Write-StatusMsg -Mensaje 'No se pudo vaciar la papelera' -Tipo 'ADVERTENCIA'
        }
    }

    # ─── CACHÉ WINDOWS UPDATE ───────────────────────
    if (5 -in $seleccion) {
        Write-StatusMsg -Mensaje 'Limpiando caché de Windows Update...' -Tipo 'INFO'
        $wuPath = Join-Path $env:SystemRoot 'SoftwareDistribution\Download'
        if (Test-Path $wuPath) {
            $archivos = Get-ChildItem -Path $wuPath -Recurse -Force -ErrorAction SilentlyContinue
            $totalBorrado += $archivos.Count
            $archivos | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-StatusMsg -Mensaje 'Caché de Windows Update limpiada' -Tipo 'EXITO'
    }

    # ─── RESULTADOS ─────────────────────────────────
    Write-Host ''
    Show-RyuModal -Titulo 'Historial Borrado' -Lineas @(
        "▸ Elementos procesados: $totalBorrado",
        "▸ Estado: Completado"
    ) -ColorTitulo $t.Success

    Write-RyuLog -Mensaje "Historial borrado — $totalBorrado elementos procesados" -Nivel 'EXITO' -Modulo 'HistoryWiper'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Start-RyuHistoryWiper')