<#
.SYNOPSIS
    Instalador automatizado y profesional para entorno de terminal Windows.
.DESCRIPTION
    Script de nivel empresarial para desplegar Oh My Posh, Fastfetch, FiraCode Nerd Font,
    y configurar los mÃ³dulos de PowerShell correspondientes con manejo estricto de errores.
#>

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "System Provisioning - Terminal Environment"

# ==========================================
# VARIABLES GLOBALES
# ==========================================
$UserConfigDir = "$env:USERPROFILE\.config\fastfetch"
$OmpThemeName  = "tokyonight_storm.omp.json"

# ==========================================
# FUNCIONES DE UI Y LOGGING
# ==========================================
function Write-Log {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARN", "ERROR")][string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Level) {
        "INFO"    { Write-Host "[$timestamp] [ INFO  ] $Message" -ForegroundColor Cyan }
        "SUCCESS" { Write-Host "[$timestamp] [  OK   ] $Message" -ForegroundColor Green }
        "WARN"    { Write-Host "[$timestamp] [ WARN  ] $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[$timestamp] [ ERROR ] $Message" -ForegroundColor Red }
    }
}

function Write-Header {
    Clear-Host
    Write-Host @"

    â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ•—     
    â•šâ•â•â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•”â•â•â•â•â•â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘     
       â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•”â–ˆâ–ˆâ–ˆâ–ˆâ•”â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â–ˆâ–ˆâ•— â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘     
       â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•”â•â•â•  â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘     
       â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘ â•šâ•â• â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘ â•šâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
       â•šâ•â•   â•šâ•â•â•â•â•â•â•â•šâ•â•  â•šâ•â•â•šâ•â•     â•šâ•â•â•šâ•â•â•šâ•â•  â•šâ•â•â•â•â•šâ•â•  â•šâ•â•â•šâ•â•â•â•â•â•â•
                                                                     
"@ -ForegroundColor DarkCyan
    Write-Host "  Automated Environment Provisioning Script v2.0`n" -ForegroundColor Gray
}

# ==========================================
# FUNCIONES DE INSTALACIÃ“N
# ==========================================
function Install-WingetPackage {
    param([string]$PackageId, [string]$DisplayName)
    
    Write-Log "Verificando paquete: $DisplayName..." "INFO"
    $check = winget list --id $PackageId --exact 2>$null
    
    if ($check -match $PackageId) {
        Write-Log "$DisplayName ya estÃ¡ instalado. Omitiendo." "SUCCESS"
    } else {
        Write-Log "Instalando $DisplayName..." "INFO"
        try {
            # Modo silencioso estricto
            $null = winget install --id $PackageId --exact --silent --accept-source-agreements --accept-package-agreements --force
            Write-Log "$DisplayName instalado correctamente." "SUCCESS"
        } catch {
            Write-Log "Fallo al instalar $DisplayName. Detalle: $_" "ERROR"
        }
    }
}

function Install-PowerShellModule {
    param([string]$ModuleName)
    
    Write-Log "Verificando mÃ³dulo: $ModuleName..." "INFO"
    if (Get-Module -ListAvailable -Name $ModuleName) {
        Write-Log "El mÃ³dulo $ModuleName ya estÃ¡ disponible." "SUCCESS"
    } else {
        Write-Log "Instalando mÃ³dulo $ModuleName desde PSGallery..." "INFO"
        try {
            Install-Module -Name $ModuleName -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Log "$ModuleName instalado correctamente." "SUCCESS"
        } catch {
            Write-Log "Fallo al instalar el mÃ³dulo $ModuleName. Detalle: $_" "ERROR"
        }
    }
}

# ==========================================
# EJECUCIÃ“N PRINCIPAL
# ==========================================
Write-Header

try {
    # 1. ValidaciÃ³n de Administrador
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "El script no se estÃ¡ ejecutando como Administrador. Algunos paquetes (fuentes) podrÃ­an fallar." "WARN"
        Start-Sleep -Seconds 2
    }

    Write-Host "`n--- Fase 1: Despliegue de Paquetes ---" -ForegroundColor DarkGray
    Install-WingetPackage -PackageId "JanDeDobbeleer.OhMyPosh" -DisplayName "Oh My Posh"
    Install-WingetPackage -PackageId "fastfetch-cli.fastfetch" -DisplayName "Fastfetch"
    Install-WingetPackage -PackageId "NerdFonts.FiraCode" -DisplayName "FiraCode Nerd Font"

    Write-Host "`n--- Fase 2: MÃ³dulos de Entorno ---" -ForegroundColor DarkGray
    Install-PowerShellModule -ModuleName "Terminal-Icons"
    Install-PowerShellModule -ModuleName "PSReadLine"

    Write-Host "`n--- Fase 3: Estructura de Archivos ---" -ForegroundColor DarkGray
    if (-not (Test-Path $UserConfigDir)) {
        Write-Log "Creando directorio de configuraciÃ³n de Fastfetch..." "INFO"
        $null = New-Item -Path $UserConfigDir -ItemType Directory -Force
        Write-Log "Directorio $UserConfigDir creado." "SUCCESS"
    } else {
        Write-Log "El directorio de Fastfetch ya existe." "SUCCESS"
    }

    Write-Host "`n--- Fase 4: InyecciÃ³n de Perfil ---" -ForegroundColor DarkGray
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path $profileDir)) { $null = New-Item -ItemType Directory -Path $profileDir -Force }

    Write-Log "Construyendo configuraciÃ³n dinÃ¡mica..." "INFO"
    
    # Heredoc protegido (usando comillas simples al inicio para evitar expansiÃ³n prematura, excepto en variables que sÃ­ queremos inyectar al generar)
    $profileContent = @"
# =====================================================================
# PERFIL AUTOGENERADO - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# =====================================================================

# 1. Variables de Entorno y Rutas
`$LocalAppData = `"$env:LOCALAPPDATA`"
`$OmpExecutable = Join-Path `$LocalAppData "Programs\oh-my-posh\bin\oh-my-posh.exe"
`$OmpTheme      = Join-Path `$LocalAppData "Programs\oh-my-posh\themes\$OmpThemeName"
`$FastfetchExe  = Join-Path `$LocalAppData "Microsoft\WinGet\Links\fastfetch.exe"

# 2. ConfiguraciÃ³n PSReadLine (Optimizaciones de Senior Dev)
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 3. MÃ³dulos Visuales
Import-Module Terminal-Icons

# 4. InicializaciÃ³n de Oh My Posh
if (Test-Path `$OmpExecutable) {
    & `$OmpExecutable init pwsh --config `$OmpTheme | Invoke-Expression
}

# 5. Fastfetch (Mensaje de Bienvenida)
Clear-Host
if (Test-Path `$FastfetchExe) {
    & `$FastfetchExe
}
"@

    $profileContent | Out-File -FilePath $PROFILE -Encoding utf8 -Force
    Write-Log "Perfil guardado exitosamente en: $PROFILE" "SUCCESS"

    Write-Host "`n--- FINALIZACIÃ“N ---" -ForegroundColor DarkGray
    Write-Log "Proceso de aprovisionamiento completado. No se detectaron errores crÃ­ticos." "SUCCESS"
    Write-Host "`nAcciÃ³n Requerida:" -ForegroundColor Yellow
    Write-Host "1. Abre la configuraciÃ³n de tu terminal (Windows Terminal)."
    Write-Host "2. Ve a Perfiles -> Valores Predeterminados -> Apariencia."
    Write-Host "3. Cambia la fuente a 'FiraCode Nerd Font' y guarda."
    Write-Host "4. Reinicia tu terminal.`n"

} catch {
    Write-Log "Fallo fatal en el script: $($_.Exception.Message)" "ERROR"
    exit 1
}
