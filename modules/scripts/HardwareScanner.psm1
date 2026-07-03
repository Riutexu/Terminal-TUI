#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Escáner de hardware con lista de nivel del sistema.
.DESCRIPTION
    Analiza CPU, RAM, disco, GPU y genera una clasificación por nivel (S/A/B/C/D/F).
#>

Set-StrictMode -Version Latest

function Search-RyuHardware {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Escáner de Hardware'
    Write-RyuLog -Mensaje 'Iniciando análisis de hardware' -Nivel 'INFO' -Modulo 'HardwareScanner'

    # ─── CPU ────────────────────────────────────────
    Write-StatusMsg -Mensaje 'Analizando procesador...' -Tipo 'INFO'
    $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $cpuInfo = @{
        Nombre      = if ($cpu) { $cpu.Name } else { 'Desconocido' }
        Nucleos     = if ($cpu) { $cpu.NumberOfCores } else { 0 }
        Hilos       = if ($cpu) { $cpu.NumberOfLogicalProcessors } else { 0 }
        Velocidad   = if ($cpu) { [math]::Round($cpu.MaxClockSpeed / 1000, 2) } else { 0 }
        Uso         = [math]::Round((Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average, 1)
    }

    # ─── RAM ────────────────────────────────────────
    Write-StatusMsg -Mensaje 'Analizando memoria RAM...' -Tipo 'INFO'
    $ram = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction SilentlyContinue
    $ramTotal = if ($ram) { [math]::Round(($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2) } else { 0 }
    $ramSlot = if ($ram) { $ram.Count } else { 0 }
    $ramVelocidad = if ($ram) { ($ram | Measure-Object -Property Speed -Maximum).Maximum } else { 0 }
    $ramLibre = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)

    # ─── DISCO ──────────────────────────────────────
    Write-StatusMsg -Mensaje 'Analizando unidades de disco...' -Tipo 'INFO'
    $discos = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction SilentlyContinue
    $discosInfo = @()
    foreach ($d in $discos) {
        $particiones = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq ($d.DeviceID -replace '\\\\.\\','') }
        $libre = if ($particiones) { [math]::Round($particiones.FreeSpace / 1GB, 2) } else { 0 }
        $total = if ($particiones) { [math]::Round($particiones.Size / 1GB, 2) } else { 0 }
        $discosInfo += @{
            Modelo    = $d.Model
            Tipo      = if ($d.MediaType -match 'SSD') { 'SSD' } elseif ($d.MediaType -match 'NVMe') { 'NVMe' } else { 'HDD' }
            Tamano    = $total
            Libre     = $libre
            Interfaz = $d.InterfaceType
        }
    }

    # ─── GPU ────────────────────────────────────────
    Write-StatusMsg -Mensaje 'Analizando tarjeta gráfica...' -Tipo 'INFO'
    $gpu = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
    $gpuInfo = @{
        Nombre   = if ($gpu) { $gpu.Name } else { 'Desconocida' }
        VRAM     = if ($gpu) { [math]::Round($gpu.AdapterRAM / 1MB, 0) } else { 0 }
        Driver   = if ($gpu) { $gpu.DriverVersion } else { 'N/A' }
    }

    # ─── SISTEMA OPERATIVO ──────────────────────────
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -First 1
    $osInfo = @{
        Nombre    = if ($os) { $os.Caption } else { 'Desconocido' }
        Version   = if ($os) { $os.Version } else { 'N/A' }
        Arquitectura = if ($os) { $os.OSArchitecture } else { 'N/A' }
    }

    # ─── PLACA BASE ─────────────────────────────────
    $mb = Get-CimInstance -ClassName Win32_BaseBoard -ErrorAction SilentlyContinue | Select-Object -First 1
    $mbInfo = @{
        Fabricante = if ($mb) { $mb.Manufacturer } else { 'Desconocido' }
        Modelo     = if ($mb) { $mb.Product } else { 'N/A' }
    }

    # ─── CLASIFICACIÓN ──────────────────────────────
    Write-StatusMsg -Mensaje 'Calculando nivel del sistema...' -Tipo 'INFO'
    $puntos = 0

    # CPU (0-30 puntos)
    if ($cpuInfo.Nucleos -ge 8) { $puntos += 30 }
    elseif ($cpuInfo.Nucleos -ge 6) { $puntos += 25 }
    elseif ($cpuInfo.Nucleos -ge 4) { $puntos += 20 }
    else { $puntos += 10 }

    # RAM (0-25 puntos)
    if ($ramTotal -ge 32) { $puntos += 25 }
    elseif ($ramTotal -ge 16) { $puntos += 20 }
    elseif ($ramTotal -ge 8) { $puntos += 15 }
    else { $puntos += 5 }

    # Disco (0-25 puntos)
    $tieneSSD = $discosInfo | Where-Object { $_.Tipo -eq 'SSD' -or $_.Tipo -eq 'NVMe' }
    if ($tieneSSD) { $puntos += 25 }
    else { $puntos += 10 }

    # GPU (0-20 puntos)
    if ($gpuInfo.VRAM -ge 8192) { $puntos += 20 }
    elseif ($gpuInfo.VRAM -ge 4096) { $puntos += 15 }
    elseif ($gpuInfo.VRAM -ge 2048) { $puntos += 10 }
    else { $puntos += 5 }

    # Clasificación
    $nivel = switch ($puntos) {
        { $_ -ge 90 } { @{ Grado = 'S'; Color = $t.Gold;        Desc = 'Élite' } }
        { $_ -ge 75 } { @{ Grado = 'A'; Color = $t.Success;     Desc = 'Alto rendimiento' } }
        { $_ -ge 60 } { @{ Grado = 'B'; Color = $t.Info;        Desc = 'Bueno' } }
        { $_ -ge 40 } { @{ Grado = 'C'; Color = $t.Warning;     Desc = 'Regular' } }
        { $_ -ge 20 } { @{ Grado = 'D'; Color = $t.Error;       Desc = 'Básico' } }
        default       { @{ Grado = 'F'; Color = $t.TextMuted;    Desc = 'Obsoleto' } }
    }

    # ─── MOSTRAR RESULTADOS ─────────────────────────
    Write-Host ''
    Show-RyuModal -Titulo "Resultado: Sistema Nivel $($nivel.Grado)" -Lineas @(
        "▸ $($nivel.Desc) — Puntos: $puntos/100",
        '',
        "▸ CPU: $($cpuInfo.Nombre)",
        "  $($cpuInfo.Nucleos) núcleos / $($cpuInfo.Hilos) hilos / $($cpuInfo.Velocidad) GHz",
        "  Uso actual: $($cpuInfo.Uso)%",
        '',
        "▸ RAM: ${ramTotal}GB en ${ramSlot} slots @ ${ramVelocidad}MHz",
        "  Disponible: ${ramLibre}GB",
        '',
        "▸ Disco(s): $($discosInfo.Count) unidad(es)",
        ($discosInfo | ForEach-Object { "  $($_.Tipo) $($_.Tamano)GB — $($_.Modelo)" }) -join "`n",
        '',
        "▸ GPU: $($gpuInfo.Nombre) ($($gpuInfo.VRAM)MB VRAM)",
        "  Driver: $($gpuInfo.Driver)"
    ) -ColorTitulo $nivel.Color

    Write-RyuLog -Mensaje "Análisis completado — Nivel $($nivel.Grado) ($puntos puntos)" -Nivel 'EXITO' -Modulo 'HardwareScanner'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Search-RyuHardware')
