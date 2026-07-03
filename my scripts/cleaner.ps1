<#
.SYNOPSIS
    Script de limpieza profunda y purga de archivos temporales en Windows.
    Requiere ejecuciÃ³n con privilegios de Administrador.
#>

# Forzar codificaciÃ³n UTF-8 y manejo estricto de errores
$ErrorActionPreference = "SilentlyContinue"

Write-Output "============= INICIANDO LIMPIEZA PROFUNDA DEL SISTEMA ============="

# 1. Detener servicios que bloquean archivos de cachÃ© de actualizaciÃ³n
Write-Output "[*] Deteniendo servicios de Windows Update y optimizaciÃ³n..."
Stop-Service -Name "wuauserv" -Force
Stop-Service -Name "bits" -Force

# 2. DefiniciÃ³n de rutas crÃ­ticas de basura
$RutasBasura = @(
    "$env:SystemRoot\Temp\*",                                 # C:\Windows\Temp
    "$env:LOCALAPPDATA\Temp\*",                               # %temp%
    "$env:SystemRoot\Prefetch\*",                             # Prefetch del sistema
    "$env:SystemDrive\System Volume Information\Chkdsk\*",    # Fragmentos de disco
    "$env:SystemRoot\SoftwareDistribution\Download\*",        # CachÃ© de Windows Update
    "$env:LOCALAPPDATA\Microsoft\Windows\WER\*"               # Reportes de error de Windows
)

# 3. Purga de directorios
foreach ($Ruta in $RutasBasura) {
    if (Test-Path (Split-Path $Ruta)) {
        Write-Output "[+] Limpiando: $Ruta"
        Remove-Item -Path $Ruta -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Limpieza de componentes del sistema (WinSxS) y optimizaciÃ³n de entrega
Write-Output "[*] Purgando almacÃ©n de componentes (WinSxS)..."
& dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# 5. Vaciar Papelera de Reciclaje de todos los discos
Write-Output "[*] Vaciando papelera de reciclaje..."
Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue

# 6. Reactivar servicios del sistema
Write-Output "[*] Reactivando servicios..."
Start-Service -Name "wuauserv"
Start-Service -Name "bits"

Write-Output "============= LIMPIEZA FINALIZADA CON Ã‰XITO ============="
