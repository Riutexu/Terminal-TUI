#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Optimizador de disco.
.DESCRIPTION
    Desfragmenta unidades HDD, optimiza SSD y analiza estado de salud del disco.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-RyuDiskOptimize {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Optimizar Disco'
    Write-RyuLog -Mensaje 'Iniciando optimización de disco' -Nivel 'INFO' -Modulo 'DiskOptimizer'

    if (-not (Test-AdminRequired)) {
        Write-StatusMsg -Mensaje 'Se requieren privilegios de administrador para optimizar discos' -Tipo 'ERROR'
        Show-PausePrompt
        return
    }

    # ─── ANALIZAR UNIDADES ──────────────────────────
    Write-StatusMsg -Mensaje 'Analizando unidades de disco...' -Tipo 'INFO'
    $unidades = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

    $resultados = @()
    foreach ($u in $unidades) {
        $letra = $u.DeviceID
        Write-StatusMsg -Mensaje "Analizando $letra..." -Tipo 'INFO'

        # Verificar si es SSD
        $disco = Get-CimInstance -ClassName Win32_DiskDrive | Where-Object {
            Get-CimInstance -ClassName Win32_Partition | Where-Object { $_.DeviceID -eq "$($letra -replace ':','')" }
        } | Select-Object -First 1

        $esSSD = $false
        if ($disco) {
            $esSSD = $disco.MediaType -match 'SSD' -or $disco.MediaType -match 'NVMe'
        }

        $totalGB = [math]::Round($u.Size / 1GB, 2)
        $libreGB = [math]::Round($u.FreeSpace / 1GB, 2)
        $uso = [math]::Round((($u.Size - $u.FreeSpace) / $u.Size) * 100, 1)

        $resultados += @{
            Letra   = $letra
            Tipo    = if ($esSSD) { 'SSD' } else { 'HDD' }
            Total   = $totalGB
            Libre   = $libreGB
            Uso     = $uso
            Modelo  = if ($disco) { $disco.Model } else { 'N/A' }
        }
    }

    # ─── MOSTRAR ESTADO ─────────────────────────────
    Write-Host ''
    $lineas = @()
    foreach ($r in $resultados) {
        $indicador = if ($r.Uso -gt 90) { '✖' } elseif ($r.Uso -gt 70) { '▲' } else { '✓' }
        $lineas += "$indicador $($r.Letra) [$($r.Tipo)] $($r.Libre)GB libres de $($r.Total)GB ($($r.Uso)% usado)"
    }
    Show-RyuModal -Titulo 'Estado de Unidades' -Lineas $lineas -ColorTitulo $t.Info

    # ─── OPTIMIZAR ──────────────────────────────────
    $confirm = Show-Confirm -Mensaje '¿Optimizar unidades?' -Detalle 'Se ejecutará TRIM en SSDs y desfragmentación en HDDs.'
    if (-not $confirm) {
        Write-StatusMsg -Mensaje 'Optimización cancelada' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    foreach ($r in $resultados) {
        $letra = $r.Letra
        Write-StatusMsg -Mensaje "Optimizando $letra ($($r.Tipo))..." -Tipo 'INFO'
        try {
            Optimize-Volume -DriveLetter ($letra -replace ':','') -ErrorAction Stop
            Write-StatusMsg -Mensaje "$letra optimizado correctamente" -Tipo 'EXITO'
        } catch {
            Write-StatusMsg -Mensaje "Error optimizando ${letra}: $($_.Exception.Message)" -Tipo 'ERROR'
        }
    }

    Write-Host ''
    Write-StatusMsg -Mensaje 'Optimización de disco completada' -Tipo 'EXITO'
    Write-RyuLog -Mensaje 'Optimización de disco completada' -Nivel 'EXITO' -Modulo 'DiskOptimizer'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Start-RyuDiskOptimize')
