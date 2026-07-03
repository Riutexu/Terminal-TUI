#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Limpieza profunda del sistema.
.DESCRIPTION
    Elimina archivos temporales, cache de navegador, logs antiguos y otros residuos.
#>

Set-StrictMode -Version Latest

function Start-RyuDeepClean {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Limpieza Profunda'
    Write-RyuLog -Mensaje 'Iniciando limpieza profunda del sistema' -Nivel 'INFO' -Modulo 'DeepCleaner'

    $confirm = Show-Confirm -Mensaje '¿Iniciar limpieza profunda?' -Detalle 'Se eliminarán archivos temporales, caché y residuos del sistema. Esta acción es segura pero irreversible.'
    if (-not $confirm) {
        Write-StatusMsg -Mensaje 'Limpieza cancelada por el usuario' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    $totalLiberado = 0
    $errores = 0

    # ─── TEMP USUARIO ───────────────────────────────
    Write-StatusMsg -Mensaje 'Limpiando archivos temporales del usuario...' -Tipo 'INFO'
    $tempUser = $env:TEMP
    if (Test-Path $tempUser) {
        $archivos = Get-ChildItem -Path $tempUser -Recurse -Force -ErrorAction SilentlyContinue
        $tamano = ($archivos | Measure-Object -Property Length -Sum).Sum
        $totalLiberado += $tamano
        $archivos | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje "Temp usuario: $([math]::Round($tamano / 1MB, 2))MB eliminados" -Tipo 'EXITO'
    }

    # ─── TEMP WINDOWS ───────────────────────────────
    Write-StatusMsg -Mensaje 'Limpiando archivos temporales de Windows...' -Tipo 'INFO'
    $tempWin = Join-Path $env:SystemRoot 'Temp'
    if (Test-Path $tempWin) {
        $archivos = Get-ChildItem -Path $tempWin -Recurse -Force -ErrorAction SilentlyContinue
        $tamano = ($archivos | Measure-Object -Property Length -Sum).Sum
        $totalLiberado += $tamano
        $archivos | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje "Temp Windows: $([math]::Round($tamano / 1MB, 2))MB eliminados" -Tipo 'EXITO'
    }

    # ─── PREFETCH ───────────────────────────────────
    Write-StatusMsg -Mensaje 'Limpiando prefetch...' -Tipo 'INFO'
    $prefetch = Join-Path $env:SystemRoot 'Prefetch'
    if (Test-Path $prefetch) {
        $archivos = Get-ChildItem -Path $prefetch -Force -ErrorAction SilentlyContinue
        $tamano = ($archivos | Measure-Object -Property Length -Sum).Sum
        $totalLiberado += $tamano
        $archivos | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje "Prefetch: $([math]::Round($tamano / 1MB, 2))MB eliminados" -Tipo 'EXITO'
    }

    # ─── CACHÉ NAVEGADORES ──────────────────────────
    Write-StatusMsg -Mensaje 'Limpiando caché de navegadores...' -Tipo 'INFO'
    $caches = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*.default-release\cache2",
        "$env:APPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache"
    )
    foreach ($cache in $caches) {
        $resolved = Resolve-Path $cache -ErrorAction SilentlyContinue
        if ($resolved) {
            foreach ($path in $resolved) {
                $archivos = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                $tamano = ($archivos | Measure-Object -Property Length -Sum).Sum
                $totalLiberado += $tamano
                $archivos | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # ─── Papelera de reciclaje ──────────────────────
    Write-StatusMsg -Mensaje 'Vaciando papelera de reciclaje...' -Tipo 'INFO'
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje 'Papelera de reciclaje vaciada' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje 'No se pudo vaciar la papelera' -Tipo 'ADVERTENCIA'
        $errores++
    }

    # ─── RESULTADOS ─────────────────────────────────
    Write-Host ''
    Show-RyuModal -Titulo 'Limpieza Completada' -Lineas @(
        "▸ Espacio liberado: $([math]::Round($totalLiberado / 1MB, 2))MB",
        "▸ Errores encontrados: $errores",
        "▸ Estado: $(if ($errores -eq 0) { 'Exitoso' } else { 'Parcial' })"
    ) -ColorTitulo $t.Success

    Write-RyuLog -Mensaje "Limpieza completada — $([math]::Round($totalLiberado / 1MB, 2))MB liberados, $errores errores" -Nivel 'EXITO' -Modulo 'DeepCleaner'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Start-RyuDeepClean')
