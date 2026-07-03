#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Repair — Reparación del sistema.
.DESCRIPTION
    SFC, DISM, Health, Storage, Repair.
    Inspirado en: Windows-Repairs, DISM-GUI, SFC-Fixer.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return [System.Security.Principal.WindowsPrincipal]::new($id).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-REPSFC {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Ejecutando System File Checker (sfc /scannow)...' -Tipo 'INFO'
    try {
        $result = & sfc /scannow 2>&1
        $output = $result -join "`n"
        if ($output -match 'No violaciones de integridad') {
            Write-StatusMsg -Mensaje 'SFC completado: todos los archivos del sistema intactos' -Tipo 'EXITO'
        } elseif ($output -match 'reparó exitosamente') {
            Write-StatusMsg -Mensaje 'SFC completado: archivos corruptos reparados' -Tipo 'EXITO'
        } else {
            Write-StatusMsg -Mensaje "SFC completado: revisar logs en $env:SystemRoot\Logs\CBS\CBS.log" -Tipo 'INFO'
        }
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-REPDISM {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Ejecutando DISM: reparación de imagen...' -Tipo 'INFO'
    try {
        $result = & DISM /Online /Cleanup-Image /RestoreHealth 2>&1
        $output = $result -join "`n"
        if ($output -match 'completado correctamente') {
            Write-StatusMsg -Mensaje 'DISM completado: imagen reparada correctamente' -Tipo 'EXITO'
        } else {
            Write-StatusMsg -Mensaje "DISM completado: revisar logs" -Tipo 'INFO'
        }
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-REPHealth {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Verificando salud del sistema...' -Tipo 'INFO'
    try {
        $checks = @()
        # Verificar servicio Windows Update
        $wu = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        $checks += "Windows Update: $($wu.Status)"
        # Verificar servicio de firewall
        $fw = Get-Service -Name mpssvc -ErrorAction SilentlyContinue
        $checks += "Firewall: $($fw.Status)"
        # Verificar servicio de cryptografía
        $crypto = Get-Service -Name CryptSvc -ErrorAction SilentlyContinue
        $checks += "CryptSvc: $($crypto.Status)"
        # Verificar servicio de eventos
        $event = Get-Service -Name EventLog -ErrorAction SilentlyContinue
        $checks += "EventLog: $($event.Status)"
        # Verificar espacio en disco
        $disk = Get-PSDrive -Name C -ErrorAction SilentlyContinue
        $freeGB = [math]::Round($disk.Free / 1GB, 1)
        $checks += "Disco C: libre $freeGB GB"
        # Verificar memoria
        $mem = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        $freeMem = [math]::Round($mem.FreePhysicalMemory / 1024, 0)
        $checks += "RAM libre: $freeMem MB"
        # Verificar temperatura CPU (si disponible)
        $temp = Get-CimInstance MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($temp) {
            $tempC = [math]::Round(($temp.CurrentTemperature - 2732) / 10, 0)
            $checks += "CPU temp: ${tempC}°C"
        }
        Write-StatusMsg -Mensaje "Salud del sistema:`n$($checks -join "`n")" -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-REPStorage {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Reparando almacenamiento...' -Tipo 'INFO'
    try {
        # Verificar y reparar errores de disco
        $result = & chkdsk C: /F /R 2>&1
        $output = $result -join "`n"
        if ($output -match 'Windows no puede verificar el disco') {
            Write-StatusMsg -Mensaje 'CHKDSK requiere reinicio para ejecutarse' -Tipo 'INFO'
        } else {
            Write-StatusMsg -Mensaje 'CHKDSK completado' -Tipo 'EXITO'
        }
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-REPRepair {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Ejecutando reparación completa del sistema...' -Tipo 'INFO'
    try {
        # 1. Verificar archivos del sistema
        Write-StatusMsg -Mensaje '[1/4] Verificando archivos del sistema...' -Tipo 'INFO'
        & sfc /verifyonly 2>&1 | Out-Null
        # 2. Reparar imagen
        Write-StatusMsg -Mensaje '[2/4] Reparando imagen de Windows...' -Tipo 'INFO'
        & DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
        # 3. Reparar componentes
        Write-StatusMsg -Mensaje '[3/4] Reparando componentes de Windows...' -Tipo 'INFO'
        & DISM /Online /Cleanup-Image /StartComponentCleanup 2>&1 | Out-Null
        # 4. Reparar Windows Update
        Write-StatusMsg -Mensaje '[4/4] Reparando Windows Update...' -Tipo 'INFO'
        & net stop wuauserv 2>&1 | Out-Null
        & net stop cryptSvc 2>&1 | Out-Null
        & net stop bits 2>&1 | Out-Null
        & net stop msiserver 2>&1 | Out-Null
        Rename-Item -Path "$env:SystemRoot\SoftwareDistribution" -NewName 'SoftwareDistribution.old' -Force -ErrorAction SilentlyContinue
        Rename-Item -Path "$env:SystemRoot\System32\catroot2" -NewName 'catroot2.old' -Force -ErrorAction SilentlyContinue
        & net start wuauserv 2>&1 | Out-Null
        & net start cryptSvc 2>&1 | Out-Null
        & net start bits 2>&1 | Out-Null
        & net start msiserver 2>&1 | Out-Null
        Write-StatusMsg -Mensaje 'Reparación completa finalizada (recomendado: reiniciar)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-REPAll {
    $t = GetT
    Write-StatusMsg -Mensaje 'Ejecutando reparación completa del sistema...' -Tipo 'INFO'
    Invoke-REPSFC
    Invoke-REPDISM
    Invoke-REPHealth
    Invoke-REPStorage
    Invoke-REPRepair
    Write-StatusMsg -Mensaje 'Reparación completa finalizada' -Tipo 'EXITO'
}

Export-ModuleMember -Function @(
    'Invoke-REPSFC', 'Invoke-REPDISM', 'Invoke-REPHealth',
    'Invoke-REPStorage', 'Invoke-REPRepair', 'Invoke-REPAll'
)