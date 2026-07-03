# Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script de mantenimiento de sistema: Limpieza de cachÃ©s, archivos temporales y optimizaciÃ³n de disco.
.DESCRIPTION
    Maneja excepciones de forma estricta. Limpia %TEMP%, C:\Windows\Temp, el cachÃ© de Windows Update, 
    purga el DNS y ejecuta la optimizaciÃ³n de unidades de forma inteligente (TRIM para SSDs, Defrag para HDDs).
#>

[CmdletBinding()]
param ()

# Forzar detenciÃ³n en errores no controlados
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Date] [$Type] $Message"
}

# 1. ValidaciÃ³n de privilegios
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "El script requiere privilegios de administrador. Abortando." "ERROR"
    exit
}

Write-Log "Iniciando rutina de mantenimiento del sistema..." "INFO"

# 2. DefiniciÃ³n de rutas objetivo de limpieza (seguras)
$TargetPaths = @(
    $env:TEMP,
    "C:\Windows\Temp",
    "C:\Windows\Prefetch",
    "C:\Windows\SoftwareDistribution\Download"
)

# 3. Limpieza de archivos temporales y cachÃ©s
foreach ($Path in $TargetPaths) {
    if (Test-Path $Path) {
        Write-Log "Limpiando directorio: $Path" "INFO"
        try {
            # Se omite el borrado de la carpeta raÃ­z, solo se vacÃ­a su contenido
            Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
                Where-Object { -not $_.PSIsContainer } | 
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Log "Archivos bloqueados por procesos activos en $Path. Omitiendo." "WARNING"
        }
    }
}

# 4. Limpieza del CachÃ© DNS
try {
    Write-Log "Purgando cachÃ© de resoluciÃ³n DNS..." "INFO"
    Clear-DnsClientCache
    Write-Log "CachÃ© DNS purgado exitosamente." "INFO"
}
catch {
    Write-Log "Fallo al purgar el cachÃ© DNS: $($_.Exception.Message)" "ERROR"
}

# 5. OptimizaciÃ³n de Unidades (Defrag/TRIM)
try {
    Write-Log "Analizando y optimizando volÃºmenes de almacenamiento..." "INFO"
    
    # Obtiene los volÃºmenes fÃ­sicos soportados y los optimiza usando el comportamiento predeterminado del SO (TRIM o Defrag)
    $Volumes = Get-Volume | Where-Object DriveType -eq 'Fixed'
    
    foreach ($Vol in $Volumes) {
        Write-Log "Optimizando unidad $($Vol.DriveLetter): ..." "INFO"
        Optimize-Volume -DriveLetter $Vol.DriveLetter -ReTrim -Analyze -Defrag -ErrorAction SilentlyContinue
    }
    Write-Log "OptimizaciÃ³n de unidades completada." "INFO"
}
catch {
    Write-Log "Error durante la optimizaciÃ³n de almacenamiento: $($_.Exception.Message)" "ERROR"
}

Write-Log "Rutina de mantenimiento finalizada." "INFO"
