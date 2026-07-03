#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Logger — Registro centralizado con flush automático.
.DESCRIPTION
    Niveles español: INFO, EXITO, ADVERTENCIA, ERROR.
    Flush a archivo al inicio y salida. Limpieza de logs antiguos.
#>

Set-StrictMode -Version Latest

$script:ColaMensajes = [System.Collections.ArrayList]::new()
$script:LogFile = $null

# ─── COLORES FALLBACK ─────────────────────────────────────────

$script:Niveles = @{
    'INFO'        = @{ Icono = '●'; Color = @(59, 130, 246) }
    'EXITO'       = @{ Icono = '✓'; Color = @(34, 197, 94) }
    'ADVERTENCIA' = @{ Icono = '▲'; Color = @(245, 158, 11) }
    'ERROR'       = @{ Icono = '✖'; Color = @(239, 68, 68) }
}

# ─── INIT ─────────────────────────────────────────────────────

function Initialize-RyuLogger {
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    $dir = if ($rutas) { $rutas.DirLogs } else { Join-Path $env:APPDATA 'RYU-TUI\logs' }
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $fecha = Get-Date -Format 'yyyyMMdd_HHmmss'
    $script:LogFile = Join-Path $dir "ryu_${fecha}.log"

    # Clean old logs
    Remove-OldLogs -Directorio $dir
}

# ─── LOG ──────────────────────────────────────────────────────

function Write-RyuLog {
    param(
        [Parameter(Mandatory)][string]$Mensaje,
        [ValidateSet('INFO','EXITO','ADVERTENCIA','ERROR')][string]$Nivel = 'INFO',
        [string]$Modulo = ''
    )
    $t = Get-Tema -ErrorAction SilentlyContinue
    $colores = @{
        'INFO'        = if ($t -and $t.Info) { $t.Info } else { $script:Niveles['INFO'].Color }
        'EXITO'       = if ($t -and $t.Success) { $t.Success } else { $script:Niveles['EXITO'].Color }
        'ADVERTENCIA' = if ($t -and $t.Warning) { $t.Warning } else { $script:Niveles['ADVERTENCIA'].Color }
        'ERROR'       = if ($t -and $t.Error) { $t.Error } else { $script:Niveles['ERROR'].Color }
    }
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $mod = if ($Modulo) { "[$Modulo]" } else { '' }
    $col = $colores[$Nivel]
    $icono = $script:Niveles[$Nivel].Icono

    Write-Host "`e[2m[$ts]${mod} ${icono}$($Nivel.PadRight(12))${Mensaje}`e[0m"

    $null = $script:ColaMensajes.Add(@{ Ts = $ts; Nivel = $Nivel; Modulo = $Modulo; Mensaje = $Mensaje })
}

# ─── FLUSH ────────────────────────────────────────────────────

function Save-LogBuffer {
    if ($script:ColaMensajes.Count -eq 0) { return }
    if (-not $script:LogFile) { Initialize-RyuLogger }

    $lineas = [System.Collections.ArrayList]::new()
    foreach ($entry in $script:ColaMensajes) {
        $mod = if ($entry.Modulo) { "[$($entry.Modulo)]" } else { '' }
        $null = $lineas.Add("[$($entry.Ts)] $($entry.Nivel.PadRight(12)) $mod $($entry.Mensaje)")
    }

    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::AppendAllLines($script:LogFile, [string[]]$lineas.ToArray(), $utf8)
    $script:ColaMensajes.Clear()
}

# ─── CLEANUP ──────────────────────────────────────────────────

function Remove-OldLogs {
    param([string]$Directorio, [int]$DiasRetencion = 30)
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    if (-not $Directorio -and $rutas) { $Directorio = $rutas.DirLogs }
    if (-not $Directorio -or -not (Test-Path $Directorio)) { return }

    $umbral = (Get-Date).AddDays(-$DiasRetencion)
    Get-ChildItem -Path $Directorio -Filter '*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $umbral } |
        ForEach-Object { Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue }
}

function Invoke-RyuCleanup {
    Save-LogBuffer
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    if ($rutas) { Remove-OldLogs -Directorio $rutas.DirLogs -DiasRetencion $rutas.DiasLog }
}

# ─── READ ─────────────────────────────────────────────────────

function Get-LogContent {
    param([Parameter(Mandatory)][string]$Archivo, [int]$MaxLineas = 100)
    if (-not (Test-Path $Archivo)) { return @() }
    Get-Content -Path $Archivo -Tail $MaxLineas -Encoding UTF8
}

function Get-LogStats {
    param([Parameter(Mandatory)][string]$Archivo)
    if (-not (Test-Path $Archivo)) { return @{ Total = 0; Info = 0; Exito = 0; Advertencia = 0; Error = 0 } }
    $content = Get-Content -Path $Archivo -Encoding UTF8
    $stats = @{ Total = $content.Count; Info = 0; Exito = 0; Advertencia = 0; Error = 0 }
    foreach ($linea in $content) {
        if ($linea -match '\bINFO\b') { $stats.Info++ }
        if ($linea -match '\bEXITO\b') { $stats.Exito++ }
        if ($linea -match '\bADVERTENCIA\b') { $stats.Advertencia++ }
        if ($linea -match '\bERROR\b') { $stats.Error++ }
    }
    return $stats
}

Export-ModuleMember -Function @(
    'Initialize-RyuLogger','Write-RyuLog','Save-LogBuffer',
    'Remove-OldLogs','Invoke-RyuCleanup','Get-LogContent','Get-LogStats'
)
