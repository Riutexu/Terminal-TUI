#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Network — Identidad de red con caché, proveedores duales y banderas.
.DESCRIPTION
    Resuelve IP pública, país, ISP y moneda usando ipapi.co/ip-api.com.
    Caché en disco con TTL configurable, datos preciso para herramientas del sistema.
#>

Set-StrictMode -Version Latest

$script:NetworkNombre = 'Network.psm1'
$script:Cache = $null

# ─── FUNCIONES INTERNAS ──────────────────────────────────────

function Invoke-SafeRest {
    param(
        [Parameter(Mandatory)][string]$Uri,
        [int]$Timeout = 5,
        [string]$Agente = 'RYU-TUI-Toolkit/2.0'
    )
    try {
        $resp = Invoke-RestMethod -Uri $Uri -TimeoutSec $Timeout -UseBasicParsing -ErrorAction Stop
        return $resp
    } catch {
        return $null
    }
}

function Read-Cache {
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    $red   = Get-Red   -ErrorAction SilentlyContinue
    if (-not $rutas -or -not $red) { return $null }

    $archivo = $red.ArchivoCache
    if (-not $archivo -or -not (Test-Path $archivo)) { return $null }

    try {
        $datos = Get-Content -Path $archivo -Raw -Encoding UTF8 | ConvertFrom-Json
        $edad = [int]((Get-Date) - [datetime]$datos.Timestamp).TotalSeconds
        if ($edad -lt $red.CacheTTL) { return $datos }
    } catch {}
    return $null
}

function Write-Cache {
    param([Parameter(Mandatory)][hashtable]$Datos)
    $rutas = Get-Rutas -ErrorAction SilentlyContinue
    $red   = Get-Red   -ErrorAction SilentlyContinue
    if (-not $rutas -or -not $red) { return }

    $archivo = $red.ArchivoCache
    if (-not $archivo) { return }

    $dir = Split-Path $archivo -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $Datos.Timestamp = (Get-Date).ToString('o')
    $Datos | ConvertTo-Json -Depth 5 | Set-Content -Path $archivo -Encoding UTF8 -Force
}

# ─── RESOLUCION DE RED ───────────────────────────────────────

function Get-NetworkIdentity {
    # Buscar en caché
    $cache = Read-Cache
    if ($cache) { return $cache }

    # Obtener de proveedores
    $red = Get-Red -ErrorAction SilentlyContinue
    if (-not $red) { $red = @{ Proveedores = @(@{ Url='https://ipapi.co/json/'; Timeout=5 }, @{ Url='https://ip-api.com/json/'; Timeout=5 }); Agente='RYU-TUI-Toolkit/2.0' } }

    $resultado = $null
    foreach ($prov in $red.Proveedores) {
        $raw = Invoke-SafeRest -Uri $prov.Url -Timeout $prov.Timeout -Agente $red.Agente
        if ($raw) {
            # Normalizar respuesta
            if ($raw.ip) {
                $resultado = @{
                    IP          = $raw.ip
                    Pais        = $raw.country_name
                    PaisCodigo  = $raw.country_code
                    Ciudad      = $raw.city
                    Region      = $raw.region
                    ISP         = $raw.org
                    Moneda      = if ($raw.currency) { $raw.currency } else { 'N/A' }
                    Latitud     = $raw.latitude
                    Longitud    = $raw.longitude
                    ZonaHoraria = $raw.timezone
                    Proveedor   = $prov.Url
                }
            } elseif ($raw.query) {
                $resultado = @{
                    IP          = $raw.query
                    Pais        = $raw.country
                    PaisCodigo  = $raw.countryCode
                    Ciudad      = $raw.city
                    Region      = $raw.regionName
                    ISP         = $raw.isp
                    Moneda      = 'N/A'
                    Latitud     = $raw.lat
                    Longitud    = $raw.lon
                    ZonaHoraria = $raw.timezone
                    Proveedor   = $prov.Url
                }
            }
            if ($resultado) { break }
        }
    }

    # Fallback si no hay red
    if (-not $resultado) {
        $resultado = @{
            IP          = 'Sin conexión'
            Pais        = 'Desconocido'
            PaisCodigo  = 'DEFAULT'
            Ciudad      = 'N/A'
            Region      = 'N/A'
            ISP         = 'N/A'
            Moneda      = 'N/A'
            Latitud     = 0
            Longitud    = 0
            ZonaHoraria = 'N/A'
            Proveedor   = 'fallback'
        }
    }

    # Guardar caché
    Write-Cache -Datos $resultado
    return $resultado
}

function Get-NetworkQuick {
    $cache = Read-Cache
    if ($cache) { return $cache.IP }
    $id = Get-NetworkIdentity
    return $id.IP
}

function Test-NetworkConnection {
    $cache = Read-Cache
    if ($cache -and $cache.IP -ne 'Sin conexión') { return $true }
    $quick = Get-NetworkQuick
    return ($quick -ne 'Sin conexión')
}

# ─── EXPORTACIONES ────────────────────────────────────────────

Export-ModuleMember -Function @(
    'Get-NetworkIdentity',
    'Get-NetworkQuick',
    'Test-NetworkConnection'
)
