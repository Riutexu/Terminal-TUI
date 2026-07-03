#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Network Tweaks — Optimización de red y latencia.
.DESCRIPTION
    Nagle, Throttling, DNS, Adapter, Registry.
    Inspirado en: TCP-Optimizer, DNS-Jumper, Network-Throttle-Indexer.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return [System.Security.Principal.WindowsPrincipal]::new($id).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-NETNagle {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando Nagle Algorithm...' -Tipo 'INFO'
    try {
        $adapters = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\*' -ErrorAction SilentlyContinue
        $interfaces = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
        $count = 0
        foreach ($iface in $interfaces) {
            $id = $iface.InterfaceGuid
            $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{$id}"
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $path -Name 'TCPNoDelay' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $path -Name 'TcpDelAckTicks' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                $count++
            }
        }
        Write-StatusMsg -Mensaje "Nagle deshabilitado en $count adaptadores (TcpAckFrequency=1, TCPNoDelay=1, TcpDelAckTicks=0)" -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-NETThrottling {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Deshabilitando Network Throttling Index...' -Tipo 'INFO'
    try {
        $netPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
        Set-ItemProperty -Path $netPath -Name 'NetworkThrottlingIndex' -Value 0xffffffff -Type DWord -Force
        Set-ItemProperty -Path $netPath -Name 'SystemResponsiveness' -Value 0 -Type DWord -Force
        Write-StatusMsg -Mensaje 'Network Throttling deshabilitado (NetworkThrottlingIndex=0xffffffff, SystemResponsiveness=0)' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-NETDNS {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Configurando DNS Cloudflare (1.1.1.1, 1.0.0.1)...' -Tipo 'INFO'
    try {
        $dns = @('1.1.1.1', '1.0.0.1')
        $interfaces = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
        $count = 0
        foreach ($iface in $interfaces) {
            Set-DnsClientServerAddress -InterfaceIndex $iface.ifIndex -ServerAddresses $dns -ErrorAction SilentlyContinue
            $count++
        }
        Write-StatusMsg -Mensaje "DNS configurado en $count adaptadores: $($dns -join ', ')" -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-NETAdapter {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Optimizando adaptadores de red...' -Tipo 'INFO'
    try {
        $interfaces = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
        $count = 0
        foreach ($iface in $interfaces) {
            $props = Get-NetAdapterAdvancedProperty -Name $iface.Name -ErrorAction SilentlyContinue
            # Deshabilitar coalescing de paquetes (mejor latencia)
            Set-NetAdapterAdvancedProperty -Name $iface.Name -DisplayName 'Interrupt Moderation' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue
            # Deshabilitar energía ahorradora
            Set-NetAdapterAdvancedProperty -Name $iface.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue
            # Deshabilitar flow control
            Set-NetAdapterAdvancedProperty -Name $iface.Name -DisplayName 'Flow Control' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue
            # Maximizar rendimiento del búfer de recepción
            Set-NetAdapterAdvancedProperty -Name $iface.Name -DisplayName 'Receive Buffers' -Value 1024 -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $iface.Name -DisplayName 'Transmit Buffers' -Value 1024 -ErrorAction SilentlyContinue
            $count++
        }
        Write-StatusMsg -Mensaje "Adaptadores optimizados: $count (Interrupt Moderation off, buffers 1024)" -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-NETRegistry {
    $t = GetT
    if (-not (Test-AdminRequired)) { Write-StatusMsg -Mensaje 'Se requiere admin' -Tipo 'ERROR'; return }

    Write-StatusMsg -Mensaje 'Aplicando tweaks de red avanzados...' -Tipo 'INFO'
    try {
        $tcpPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
        # Deshabilitar heurísticas de autotuning
        Set-ItemProperty -Path $tcpPath -Name 'TcpAutoTuningLevel' -Value 3 -Type DWord -Force -ErrorAction SilentlyContinue
        # Maximizar ventana de recepción
        Set-ItemProperty -Path $tcpPath -Name 'TcpWindowSize' -Value 65535 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpPath -Name 'GlobalMaxTcpWindowSize' -Value 65535 -Type DWord -Force -ErrorAction SilentlyContinue
        # Deshabilitar chimney offload (puede causar problemas)
        Set-ItemProperty -Path $tcpPath -Name 'EnableTCPChimney' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        # Habilitar ECN (reducción de congestión)
        Set-ItemProperty -Path $tcpPath -Name 'EnableECN' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        # Habilitar DCA (Direct Cache Access)
        Set-ItemProperty -Path $tcpPath -Name 'EnableDca' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        # Maximizar MTU
        Set-ItemProperty -Path $tcpPath -Name 'TcpMaxDataRetransmissions' -Value 5 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-StatusMsg -Mensaje 'Tweaks de red aplicados: auto-tuning, window size, ECN, DCA' -Tipo 'EXITO'
    } catch {
        Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
    }
}

function Invoke-NETAll {
    $t = GetT
    Write-StatusMsg -Mensaje 'Aplicando todos los tweaks de red...' -Tipo 'INFO'
    Invoke-NETNagle
    Invoke-NETThrottling
    Invoke-NETDNS
    Invoke-NETAdapter
    Invoke-NETRegistry
    Write-StatusMsg -Mensaje 'Todos los tweaks de red aplicados' -Tipo 'EXITO'
}

Export-ModuleMember -Function @(
    'Invoke-NETNagle', 'Invoke-NETThrottling', 'Invoke-NETDNS',
    'Invoke-NETAdapter', 'Invoke-NETRegistry', 'Invoke-NETAll'
)