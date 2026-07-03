#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Toolkit del sistema v3.0.
.DESCRIPTION
    Entry point: ANSI/VT, FiraCode font, splash, 12-option menu, dashboard, settings.
    Admin elevation per-module, not at startup.
#>

$script:DirBase = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:DirModules = Join-Path $script:DirBase 'modules'

# ─── LOAD CORE MODULES ───────────────────────────────────────

Import-Module (Join-Path $script:DirModules 'core\config.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path $script:DirModules 'core\TUI.psm1')     -Force -ErrorAction Stop
Import-Module (Join-Path $script:DirModules 'core\Logger.psm1')  -Force -ErrorAction Stop
Import-Module (Join-Path $script:DirModules 'core\Network.psm1') -Force -ErrorAction Stop

# ─── LOAD SCRIPT MODULES ─────────────────────────────────────

$script:Modulos = @(
    @{ Nombre = 'Optimización del Sistema'; Modulo = 'Optimizer';        Icono = '⚡'; Descripcion = 'CPU/GPU/RAM/Energía/Visual'; Funcion = 'Invoke-OPTAll' }
    @{ Nombre = 'Privacidad y Seguridad';   Modulo = 'Privacy';          Icono = '🔒'; Descripcion = 'Telemetry/Copilot/Ads/Edge'; Funcion = 'Invoke-PRVAll' }
    @{ Nombre = 'Ciberseguridad';           Modulo = 'Security';         Icono = '🛡️'; Descripcion = 'Forense/Persistencia/Credenciales'; Funcion = 'Invoke-SECAll' }
    @{ Nombre = 'Red y Latencia';           Modulo = 'NetworkTweaks';    Icono = '🌐'; Descripcion = 'Nagle/DNS/Throttling'; Funcion = 'Invoke-NETAll' }
    @{ Nombre = 'Gaming y Rendimiento';     Modulo = 'Gaming';           Icono = '🎮'; Descripcion = 'GameMode/GPU/Latency/MSI'; Funcion = 'Invoke-GAMAll' }
    @{ Nombre = 'Limpieza Profunda';        Modulo = 'DeepCleaner';      Icono = '🧹'; Descripcion = 'Temp/Cache/Prefetch'; Funcion = 'Start-RyuDeepClean' }
    @{ Nombre = 'Reparación del Sistema';   Modulo = 'Repair';           Icono = '🔧'; Descripcion = 'SFC/DISM/Health'; Funcion = 'Invoke-REPAll' }
    @{ Nombre = 'Perfiles de Optimización'; Modulo = 'Profiles';         Icono = '📊'; Descripcion = 'Gaming/Privacy/Balanced'; Funcion = 'Invoke-PRFSelect' }
    @{ Nombre = 'Escáner de Hardware';      Modulo = 'HardwareScanner';  Icono = '🔍'; Descripcion = 'CPU/RAM/Disco/GPU'; Funcion = 'Search-RyuHardware' }
    @{ Nombre = 'Optimizar Disco';          Modulo = 'DiskOptimizer';    Icono = '💾'; Descripcion = 'TRIM/Defrag'; Funcion = 'Start-RyuDiskOptimize' }
    @{ Nombre = 'Borrador de Historial';    Modulo = 'HistoryWiper';     Icono = '🗑️'; Descripcion = 'Limpieza de historial'; Funcion = 'Start-RyuHistoryWiper' }
    @{ Nombre = 'Debloat Windows 11';       Modulo = 'Win11Debloat';     Icono = '🪟'; Descripcion = 'Eliminación de bloatware'; Funcion = 'Start-RyuWin11Debloat' }
    @{ Nombre = 'Provisionar Sistema';      Modulo = 'SystemProvisioner';Icono = '📦'; Descripcion = 'Winget/Software'; Funcion = 'Start-RyuProvisioner' }
    @{ Nombre = 'Activar Windows';          Modulo = 'WindowsActivator'; Icono = '🔑'; Descripcion = 'KMS/Licencia'; Funcion = 'Start-RyuActivator' }
)

foreach ($mod in $script:Modulos) {
    $path = Join-Path $script:DirModules "scripts\$($mod.Modulo).psm1"
    if (Test-Path $path) { Import-Module $path -Force -ErrorAction SilentlyContinue }
}

# ─── ENABLE ANSI/VT ──────────────────────────────────────────

$script:AnsiHabilitado = $false

function Enable-WinAnsi {
    if ($script:AnsiHabilitado) { return }
    try {
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinVT {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out int lpMode);
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, int dwMode);
}
"@
    } catch {}
    $STDIN  = [WinVT]::GetStdHandle(-10)
    $STDOUT = [WinVT]::GetStdHandle(-11)
    $modo = 0
    [WinVT]::GetConsoleMode($STDIN, [ref]$modo)
    [WinVT]::SetConsoleMode($STDIN, $modo -bor 0x0004) | Out-Null
    [WinVT]::GetConsoleMode($STDOUT, [ref]$modo)
    [WinVT]::SetConsoleMode($STDOUT, $modo -bor 0x0004) | Out-Null
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $script:AnsiHabilitado = $true
}

# ─── ADMIN ELEVATION WRAPPER ─────────────────────────────────

function Invoke-WithAdmin {
    param([Parameter(Mandatory)][string]$Titulo, [Parameter(Mandatory)][scriptblock]$Accion, [string]$Modulo = '')
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    if ($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-RyuLog -Mensaje "Ejecutando $Titulo con admin" -Nivel 'INFO' -Modulo $Modulo
        & $Accion; return
    }
    $confirm = Show-Confirm -Mensaje "Se requieren privilegios de administrador" -Detalle "$Titulo necesita permisos elevados."
    if (-not $confirm) {
        Write-RyuLog -Mensaje "Cancelado (sin admin)" -Nivel 'ADVERTENCIA' -Modulo $Modulo
        Write-StatusMsg -Mensaje "Operación cancelada — se requieren privilegios de administrador" -Tipo 'ADVERTENCIA'
        Show-PausePrompt; return
    }
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Definition }
    $argsStr = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Admin -Action `"$Titulo`""
    try { Start-Process -FilePath 'pwsh.exe' -ArgumentList $argsStr -Verb RunAs -Wait -ErrorAction Stop }
    catch {
        try { Start-Process -FilePath 'powershell.exe' -ArgumentList $argsStr -Verb RunAs -Wait -ErrorAction Stop }
        catch { Write-StatusMsg -Mensaje "No se pudo elevar: $($_.Exception.Message)" -Tipo 'ERROR' }
    }
}

# ─── MODULE DISPATCH ─────────────────────────────────────────

function Invoke-RyuModule {
    param([Parameter(Mandatory)][int]$Indice)
    $mod = $script:Modulos[$Indice]
    $funcs = Get-Command -Module $mod.Modulo -ErrorAction SilentlyContinue
    if (-not $funcs) {
        Write-Notification -Mensaje "Módulo '$($mod.Nombre)' no disponible" -Tipo 'ERROR'
        Show-PausePrompt; return
    }
    $fn = $null
    if ($mod.Funcion) {
        $fn = $funcs | Where-Object { $_.Name -eq $mod.Funcion } | Select-Object -First 1
    }
    if (-not $fn) {
        $fn = $funcs | Where-Object { $_.Name -match '^(Search|Start|Get|Invoke)-' } | Select-Object -First 1
    }
    if (-not $fn) { $fn = $funcs | Select-Object -First 1 }
    if ($fn) {
        Invoke-WithAdmin -Titulo $mod.Nombre -Modulo $mod.Modulo -Accion { & $fn.Name }
    } else {
        Write-Notification -Mensaje "Sin funciones en '$($mod.Nombre)'" -Tipo 'ADVERTENCIA'
        Show-PausePrompt
    }
}

# ─── DASHBOARD ────────────────────────────────────────────────

function Show-RyuDashboard {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Dashboard del Sistema'
    Write-Host ''

    # System metrics
    $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $os = Get-CimInstance Win32_OperatingSystem
    $ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $ramFree = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $ramUsed = [math]::Round($ramTotal - $ramFree, 1)
    $ramPct = [math]::Round(($ramUsed / $ramTotal) * 100)
    $disk = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object -First 1
    $diskFree = if ($disk) { [math]::Round($disk.FreeSpace / 1GB, 1) } else { 0 }
    $diskTotal = if ($disk) { [math]::Round($disk.Size / 1GB, 1) } else { 0 }
    $diskPct = if ($diskTotal -gt 0) { [math]::Round((($diskTotal - $diskFree) / $diskTotal) * 100) } else { 0 }

    # Render tiles
    Write-Host '  ' -NoNewline
    Write-MetricCard -Titulo 'CPU' -Valor "${cpu}%" -ColorValor $(if ($cpu -gt 80) { $t.Error } elseif ($cpu -gt 50) { $t.Warning } else { $t.Success })
    Write-Host '  ' -NoNewline
    Write-MetricCard -Titulo 'RAM' -Valor "${ramUsed}GB" -Tendencia 'stable' -ColorValor $(if ($ramPct -gt 80) { $t.Error } elseif ($ramPct -gt 50) { $t.Warning } else { $t.Success })
    Write-Host '  ' -NoNewline
    Write-MetricCard -Titulo 'DISCO' -Valor "${diskPct}%" -ColorValor $(if ($diskPct -gt 90) { $t.Error } elseif ($diskPct -gt 70) { $t.Warning } else { $t.Success })
    Write-Host '  ' -NoNewline
    Write-MetricCard -Titulo 'RED' -Valor 'Online' -ColorValor $t.Success

    Write-Host ''
    Write-Separator -Ancho $t.Diseno.Ancho

    # Sparklines
    Write-Host "  $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])CPU:$(RST) " -NoNewline
    Write-Sparkline -Datos @(42,45,38,52,61,55,48,44,50,58,62,55,47,43,40,45,52,58,54,48) -Color $t.Primary
    Write-Host "  $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])RAM:$(RST) " -NoNewline
    $ramVal = [int]$ramPct
    Write-Sparkline -Datos @($ramVal, $ramVal, $ramVal, $ramVal, $ramVal, $ramVal, $ramVal, $ramVal, $ramVal, $ramVal) -Color $t.Secondary
    Write-Host ''

    # Bar chart
    Write-BarChart -Datos @{ "CPU" = $cpu; "RAM" = $ramPct; "DISCO" = $diskPct }

    Write-Host ''
    Show-PausePrompt
}

# ─── MAIN MENU ────────────────────────────────────────────────

function Show-MainMenu {
    $t = GetT
    $redInfo = $null
    try { $redInfo = Get-NetworkIdentity -ErrorAction SilentlyContinue } catch {}
    $infoRed = ''
    if ($redInfo -and $redInfo.IP -ne 'Sin conexión') {
        $bandera = Get-BanderaEmoji -Codigo $redInfo.PaisCodigo
        $infoRed = "$bandera $($redInfo.IP) · $($redInfo.Pais)"
    }

    while ($true) {
        $nombres = @('Dashboard del Sistema') + ($script:Modulos | ForEach-Object { $_.Nombre })
        $iconos  = @('📊') + ($script:Modulos | ForEach-Object { $_.Icono })
        $descs   = @('Vista resumen del sistema') + ($script:Modulos | ForEach-Object { $_.Descripcion })

        $seleccion = Show-RyuMenu -Titulo 'Herramientas del Sistema' -Opciones $nombres -Iconos $iconos -Descripciones $descs -SubTitulo 'Gestor de herramientas del sistema' -InfoRed $infoRed
        Show-RyuFooter

        if ($seleccion -eq 0) {
            $salir = Show-Confirm -Mensaje '¿Salir de RYU-TUI?' -Detalle 'Se cerrará la interfaz de usuario.'
            if ($salir) {
                Invoke-RyuCleanup
                Clear-Host
                Write-Rgb -Texto '  ▸ Hasta luego!' -Color $t.Primary -Negrita
                Write-Host ''; return
            }
            continue
        }

        if ($seleccion -eq 1) {
            Show-RyuDashboard
        } elseif ($seleccion -ge 2 -and $seleccion -le ($script:Modulos.Count + 1)) {
            Invoke-RyuModule -Indice ($seleccion - 2)
            Show-PausePrompt
        }
    }
}

# ─── ENTRY POINT ──────────────────────────────────────────────

try {
    Clear-Host
    Enable-WinAnsi
    Initialize-RyuLogger
    Write-RyuLog -Mensaje 'RYU-TUI v3.0 iniciado' -Nivel 'INFO' -Modulo 'Main'

    Show-SplashScreen
    Clear-Host
    Show-MainMenu
}
catch {
    Write-Host "`e[38;2;239;68;68mError fatal: $($_.Exception.Message)`e[0m"
    Write-Host "`e[2m$($_.ScriptStackTrace)`e[0m"
    exit 1
}
