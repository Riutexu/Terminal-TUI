#Requires -Version 7.0

<#
.SYNOPSIS
    TUI CLI de limpieza profunda y gestiÃ³n de espacio.
#>

[CmdletBinding()]
param()

# ConfiguraciÃ³n estricta de entorno
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Show-Header {
    Clear-Host
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host " TUI SYSTEM CLEANER - HIGH PERFORMANCE SCAN (PWSH 7)  " -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-SafeTempCleanup {
    Write-Host "[*] Inicializando purga de directorios temporales..." -ForegroundColor Yellow
    $tempPaths = @($env:TEMP, "$env:SystemRoot\Temp")
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            try {
                $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                $total = $items.Count
                if ($total -eq 0) { continue }

                $current = 0
                foreach ($item in $items) {
                    $current++
                    if ($current % 10 -eq 0 -or $current -eq $total) {
                        $percent = [math]::Round(($current / $total) * 100)
                        Write-Progress -Activity "Purgando temporales en ${path}" -Status "$percent% completado" -PercentComplete $percent
                    }
                    
                    try {
                        Remove-Item -Path $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                    } catch {
                        # Silenciamos archivos bloqueados en uso por el sistema operativo
                    }
                }
            } catch {
                Write-Host "[!] ExcepciÃ³n de acceso en la ruta ${path} - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    Write-Progress -Activity "Purgando temporales" -Completed
    Write-Host "[+] Purga de archivos temporales finalizada.`n" -ForegroundColor Green
}

function Remove-SafeEmptyDirectories {
    Write-Host "[*] Analizando Ã¡rboles de directorios vacÃ­os (Ãmbito de Usuario)..." -ForegroundColor Yellow
    $safePaths = @("$env:USERPROFILE\Downloads", "$env:USERPROFILE\Documents")
    
    foreach ($path in $safePaths) {
        if (Test-Path $path) {
            try {
                $directories = Get-ChildItem -Path $path -Recurse -Directory -ErrorAction SilentlyContinue
                # Filtrar solo carpetas sin hijos
                $emptyDirs = $directories | Where-Object { 
                    (Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0 
                }
                
                $total = $emptyDirs.Count
                if ($total -eq 0) { continue }
                
                $current = 0
                foreach ($dir in $emptyDirs) {
                    $current++
                    $percent = [math]::Round(($current / $total) * 100)
                    Write-Progress -Activity "Eliminando carpetas vacÃ­as en ${path}" -Status "$percent% completado" -PercentComplete $percent
                    
                    try {
                        Remove-Item -Path $dir.FullName -Force -ErrorAction SilentlyContinue
                    } catch {
                        # Archivo o carpeta en uso
                    }
                }
            } catch {
                # CorrecciÃ³n del parser: DelimitaciÃ³n de variable con ${}
                Write-Host "[!] Error procesando la ruta ${path}: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    Write-Progress -Activity "Eliminando carpetas vacÃ­as" -Completed
    Write-Host "[+] Limpieza de directorios vacÃ­os finalizada.`n" -ForegroundColor Green
}

function Invoke-LargeFileManager {
    Write-Host "[*] Mapeando el disco en busca de archivos > 250MB (Ãmbito de Usuario)..." -ForegroundColor Yellow
    $targetPath = $env:USERPROFILE
    
    try {
        $largeFiles = Get-ChildItem -Path $targetPath -Recurse -File -ErrorAction SilentlyContinue | 
                      Where-Object { $_.Length -gt 250MB } | 
                      Sort-Object Length -Descending
    } catch {
        Write-Host "[!] Fallo crÃ­tico en el mapeo de archivos: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not $largeFiles) {
        Write-Host "[+] Rendimiento Ã³ptimo: No se detectaron archivos mayores a 250MB en ${targetPath}.`n" -ForegroundColor Green
        return
    }

    foreach ($file in $largeFiles) {
        if (-not (Test-Path $file.FullName)) { continue } # Por si se borrÃ³ externamente

        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        $validInput = $false
        
        while (-not $validInput) {
            Show-Header
            Write-Host "================== ANOMALÃA DE ESPACIO ===================" -ForegroundColor Magenta
            Write-Host "Archivo: " -NoNewline; Write-Host $file.FullName -ForegroundColor White
            Write-Host "TamaÃ±o:  " -NoNewline; Write-Host "$sizeMB MB" -ForegroundColor Yellow
            Write-Host "==========================================================" -ForegroundColor Magenta
            Write-Host "`nSeleccione el vector de acciÃ³n:"
            Write-Host "  [1] Destruir archivo (Remove-Item Force)"
            Write-Host "  [2] Conservar archivo (Ignorar)"
            Write-Host "  [3] Abrir 'Programas y CaracterÃ­sticas' (Software instalado relacionado)"
            
            Write-Host "`nPresione 1, 2 o 3..." -ForegroundColor DarkGray -NoNewline
            
            $key = $null
            while ($key -notmatch '^[123]$') {
                $keyInfo = [System.Console]::ReadKey($true)
                $key = $keyInfo.KeyChar.ToString()
            }
            Write-Host $key -ForegroundColor Cyan
            
            switch ($key) {
                '1' {
                    try {
                        Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                        Write-Host "[+] Archivo destruido con Ã©xito." -ForegroundColor Green
                        Start-Sleep -Seconds 1
                        $validInput = $true
                    } catch {
                        Write-Host "`n[!] Bloqueo de I/O: $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host "Presione cualquier tecla para continuar..." -ForegroundColor DarkGray
                        $null = [System.Console]::ReadKey($true)
                        $validInput = $true
                    }
                }
                '2' {
                    Write-Host "[*] Archivo conservado en disco." -ForegroundColor DarkGray
                    Start-Sleep -Milliseconds 600
                    $validInput = $true
                }
                '3' {
                    Write-Host "`n[*] Abriendo appwiz.cpl. Resuelva dependencias de software y regrese aquÃ­." -ForegroundColor Cyan
                    try {
                        Start-Process appwiz.cpl -Wait
                    } catch {
                        Write-Host "[!] No se pudo invocar el panel de control." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                    }
                }
            }
        }
    }
    Write-Host "`n[+] AuditorÃ­a de archivos pesados finalizada.`n" -ForegroundColor Green
}

# ==========================================
# RUTINA DE EJECUCIÃ“N PRINCIPAL
# ==========================================
try {
    Show-Header
    Invoke-SafeTempCleanup
    Remove-SafeEmptyDirectories
    Invoke-LargeFileManager

    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "         RUTINA DE MANTENIMIENTO CONCLUIDA            " -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Cyan
} catch {
    Write-Host "`n[!] ERROR FATAL NO CONTROLADO: $($_.Exception.Message)" -ForegroundColor Red
}
