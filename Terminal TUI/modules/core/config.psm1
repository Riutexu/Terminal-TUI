#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI Configuracion — 13 Temas, animaciones, layout, rutas, red, undo system.
.DESCRIPTION
    Fuente unica de verdad. Editar este archivo personaliza toda la apariencia.
    13 temas True Color: Cyberpunk, Matrix, Aurora, Sunset, Neon, Ocean, Fire,
    Candy, Monokai, Dracula, Solarized, Retro80s, Minimal.
#>

Set-StrictMode -Version Latest

# ─── SISTEMA DE TEMAS: 13 Paletas True Color 24-bit ─────────

$script:Temas = @{}

# 1. CYBERPUNK (default)
$script:Temas['Cyberpunk'] = @{
    Primary = @(0, 230, 200);    Secondary = @(139, 92, 246);   Accent = @(255, 0, 220)
    Success = @(34, 197, 94);    Warning = @(245, 158, 11);     Error = @(239, 68, 68)
    Info = @(59, 130, 246);      Gold = @(250, 204, 21)
    BgBase = @(15, 17, 23);      BgSurface = @(24, 26, 33);     BgOverlay = @(30, 33, 42)
    Border = @(55, 60, 75);      BorderActive = @(0, 230, 200)
    TextPrimary = @(205, 214, 244); TextSecondary = @(108, 112, 134); TextMuted = @(69, 71, 90)
    TextLink = @(137, 180, 250)
    GradientStart = @(0, 230, 200); GradientEnd = @(139, 92, 246); GradientMid = @(250, 204, 21)
    ShimmerFrom = @(0, 230, 200); ShimmerTo = @(255, 0, 220)
}

# 2. MATRIX
$script:Temas['Matrix'] = @{
    Primary = @(0, 255, 65);     Secondary = @(0, 180, 45);     Accent = @(0, 200, 80)
    Success = @(0, 255, 65);     Warning = @(180, 255, 0);      Error = @(255, 50, 50)
    Info = @(0, 200, 80);        Gold = @(0, 255, 65)
    BgBase = @(5, 10, 5);        BgSurface = @(10, 18, 10);     BgOverlay = @(15, 25, 15)
    Border = @(0, 80, 20);       BorderActive = @(0, 255, 65)
    TextPrimary = @(0, 230, 60); TextSecondary = @(0, 140, 40);  TextMuted = @(0, 80, 20)
    TextLink = @(0, 200, 80)
    GradientStart = @(0, 255, 65); GradientEnd = @(0, 100, 30); GradientMid = @(180, 255, 0)
    ShimmerFrom = @(0, 255, 65); ShimmerTo = @(0, 180, 45)
}

# 3. AURORA
$script:Temas['Aurora'] = @{
    Primary = @(0, 200, 200);    Secondary = @(120, 80, 255);   Accent = @(0, 255, 128)
    Success = @(0, 255, 128);    Warning = @(255, 200, 0);      Error = @(255, 80, 80)
    Info = @(0, 180, 255);       Gold = @(255, 220, 0)
    BgBase = @(8, 12, 20);       BgSurface = @(14, 20, 30);     BgOverlay = @(20, 28, 40)
    Border = @(30, 60, 80);      BorderActive = @(0, 200, 200)
    TextPrimary = @(200, 220, 240); TextSecondary = @(100, 130, 160); TextMuted = @(50, 70, 90)
    TextLink = @(0, 180, 255)
    GradientStart = @(0, 200, 200); GradientEnd = @(120, 80, 255); GradientMid = @(0, 255, 128)
    ShimmerFrom = @(0, 200, 200); ShimmerTo = @(0, 255, 128)
}

# 4. SUNSET
$script:Temas['Sunset'] = @{
    Primary = @(255, 120, 50);   Secondary = @(255, 50, 120);   Accent = @(200, 80, 200)
    Success = @(100, 220, 80);   Warning = @(255, 180, 0);      Error = @(255, 60, 60)
    Info = @(255, 150, 80);      Gold = @(255, 200, 50)
    BgBase = @(20, 12, 15);      BgSurface = @(30, 18, 22);     BgOverlay = @(40, 22, 28)
    Border = @(80, 40, 50);      BorderActive = @(255, 120, 50)
    TextPrimary = @(255, 220, 210); TextSecondary = @(180, 130, 120); TextMuted = @(100, 70, 65)
    TextLink = @(255, 150, 80)
    GradientStart = @(255, 120, 50); GradientEnd = @(200, 80, 200); GradientMid = @(255, 50, 120)
    ShimmerFrom = @(255, 120, 50); ShimmerTo = @(255, 50, 120)
}

# 5. NEON
$script:Temas['Neon'] = @{
    Primary = @(255, 0, 180);    Secondary = @(0, 220, 255);    Accent = @(255, 255, 0)
    Success = @(0, 255, 100);    Warning = @(255, 255, 0);      Error = @(255, 0, 60)
    Info = @(0, 220, 255);       Gold = @(255, 255, 0)
    BgBase = @(12, 8, 18);       BgSurface = @(20, 14, 28);     BgOverlay = @(28, 18, 38)
    Border = @(60, 30, 80);      BorderActive = @(255, 0, 180)
    TextPrimary = @(240, 230, 255); TextSecondary = @(150, 130, 180); TextMuted = @(80, 60, 100)
    TextLink = @(0, 220, 255)
    GradientStart = @(255, 0, 180); GradientEnd = @(0, 220, 255); GradientMid = @(255, 255, 0)
    ShimmerFrom = @(255, 0, 180); ShimmerTo = @(0, 220, 255)
}

# 6. OCEAN
$script:Temas['Ocean'] = @{
    Primary = @(0, 150, 255);    Secondary = @(0, 200, 200);    Accent = @(0, 180, 180)
    Success = @(50, 220, 120);   Warning = @(255, 180, 50);     Error = @(255, 80, 80)
    Info = @(0, 150, 255);       Gold = @(255, 200, 80)
    BgBase = @(8, 14, 22);       BgSurface = @(12, 22, 35);     BgOverlay = @(16, 30, 45)
    Border = @(20, 60, 90);      BorderActive = @(0, 150, 255)
    TextPrimary = @(200, 220, 245); TextSecondary = @(100, 140, 180); TextMuted = @(50, 80, 110)
    TextLink = @(0, 180, 255)
    GradientStart = @(0, 150, 255); GradientEnd = @(0, 200, 200); GradientMid = @(0, 180, 180)
    ShimmerFrom = @(0, 150, 255); ShimmerTo = @(0, 200, 200)
}

# 7. FIRE
$script:Temas['Fire'] = @{
    Primary = @(255, 80, 30);    Secondary = @(255, 160, 0);    Accent = @(255, 200, 0)
    Success = @(100, 220, 60);   Warning = @(255, 200, 0);      Error = @(255, 40, 40)
    Info = @(255, 120, 50);      Gold = @(255, 200, 0)
    BgBase = @(18, 10, 8);       BgSurface = @(28, 16, 12);     BgOverlay = @(38, 22, 16)
    Border = @(80, 35, 20);      BorderActive = @(255, 80, 30)
    TextPrimary = @(255, 225, 210); TextSecondary = @(180, 120, 100); TextMuted = @(100, 60, 50)
    TextLink = @(255, 150, 80)
    GradientStart = @(255, 80, 30); GradientEnd = @(255, 200, 0); GradientMid = @(255, 160, 0)
    ShimmerFrom = @(255, 80, 30); ShimmerTo = @(255, 200, 0)
}

# 8. CANDY
$script:Temas['Candy'] = @{
    Primary = @(255, 100, 180);  Secondary = @(180, 100, 255);  Accent = @(0, 220, 220)
    Success = @(100, 255, 150);  Warning = @(255, 220, 50);     Error = @(255, 80, 100)
    Info = @(100, 180, 255);     Gold = @(255, 200, 100)
    BgBase = @(18, 12, 20);      BgSurface = @(26, 18, 30);     BgOverlay = @(34, 22, 38)
    Border = @(70, 40, 80);      BorderActive = @(255, 100, 180)
    TextPrimary = @(255, 230, 240); TextSecondary = @(180, 140, 170); TextMuted = @(100, 70, 90)
    TextLink = @(100, 180, 255)
    GradientStart = @(255, 100, 180); GradientEnd = @(0, 220, 220); GradientMid = @(180, 100, 255)
    ShimmerFrom = @(255, 100, 180); ShimmerTo = @(180, 100, 255)
}

# 9. MONOKAI
$script:Temas['Monokai'] = @{
    Primary = @(166, 226, 46);   Secondary = @(174, 129, 255);  Accent = @(249, 38, 114)
    Success = @(166, 226, 46);   Warning = $(@(230, 219, 116));  Error = @(249, 38, 114)
    Info = $(@(102, 217, 239));  Gold = $(@(230, 219, 116))
    BgBase = @(39, 40, 34);      BgSurface = @(49, 50, 44);     BgOverlay = @(59, 60, 54)
    Border = @(85, 85, 85);      BorderActive = @(166, 226, 46)
    TextPrimary = $(@(248, 248, 242)); TextSecondary = $(@(166, 166, 166)); TextMuted = $(@(115, 115, 115))
    TextLink = $(@(102, 217, 239))
    GradientStart = @(166, 226, 46); GradientEnd = @(174, 129, 255); GradientMid = @(249, 38, 114)
    ShimmerFrom = @(166, 226, 46); ShimmerTo = @(174, 129, 255)
}

# 10. DRACULA
$script:Temas['Dracula'] = @{
    Primary = @(189, 147, 249);  Secondary = @(255, 121, 198);  Accent = $(@(139, 233, 253))
    Success = $(@(80, 250, 123)); Warning = $(@(241, 250, 140));  Error = $(@(255, 85, 85))
    Info = $(@(139, 233, 253));  Gold = $(@(241, 250, 140))
    BgBase = $(@(40, 42, 54));   BgSurface = $(@(50, 52, 64));  BgOverlay = $(@(60, 62, 74))
    Border = $(@(98, 114, 164)); BorderActive = @(189, 147, 249)
    TextPrimary = $(@(248, 248, 242)); TextSecondary = $(@(165, 172, 186)); TextMuted = $(@(100, 108, 126))
    TextLink = $(@(139, 233, 253))
    GradientStart = @(189, 147, 249); GradientEnd = $(@(139, 233, 253)); GradientMid = $(@(255, 121, 198))
    ShimmerFrom = @(189, 147, 249); ShimmerTo = $(@(255, 121, 198))
}

# 11. SOLARIZED
$script:Temas['Solarized'] = @{
    Primary = $(@(38, 139, 210)); Secondary = $(@(42, 161, 152)); Accent = $(@(181, 137, 0))
    Success = $(@(42, 161, 152)); Warning = $(@(181, 137, 0));   Error = $(@(220, 50, 47))
    Info = $(@(38, 139, 210));   Gold = $(@(181, 137, 0))
    BgBase = $(@(0, 43, 54));    BgSurface = $(@(7, 54, 66));    BgOverlay = $(@(17, 64, 76))
    Border = $(@(88, 110, 117)); BorderActive = $(@(38, 139, 210))
    TextPrimary = $(@(253, 246, 227)); TextSecondary = $(@(147, 161, 161)); TextMuted = $(@(101, 115, 119))
    TextLink = $(@(38, 139, 210))
    GradientStart = $(@(38, 139, 210)); GradientEnd = $(@(42, 161, 152)); GradientMid = $(@(181, 137, 0))
    ShimmerFrom = $(@(38, 139, 210)); ShimmerTo = $(@(42, 161, 152))
}

# 12. RETRO80S
$script:Temas['Retro80s'] = @{
    Primary = $(@(255, 0, 255));  Secondary = $(@(0, 255, 255));  Accent = $(@(255, 255, 0))
    Success = $(@(0, 255, 128));  Warning = $(@(255, 255, 0));    Error = $(@(255, 0, 80))
    Info = $(@(0, 255, 255));     Gold = $(@(255, 255, 0))
    BgBase = $(@(15, 5, 20));     BgSurface = $(@(25, 10, 32));   BgOverlay = $(@(35, 15, 44))
    Border = $(@(80, 20, 100));   BorderActive = $(@(255, 0, 255))
    TextPrimary = $(@(255, 230, 255)); TextSecondary = $(@(180, 130, 200)); TextMuted = $(@(100, 60, 120))
    TextLink = $(@(0, 255, 255))
    GradientStart = $(@(255, 0, 255)); GradientEnd = $(@(0, 255, 255)); GradientMid = $(@(255, 255, 0))
    ShimmerFrom = $(@(255, 0, 255)); ShimmerTo = $(@(0, 255, 255))
}

# 13. MINIMAL
$script:Temas['Minimal'] = @{
    Primary = $(@(200, 200, 200)); Secondary = $(@(140, 140, 140)); Accent = $(@(100, 100, 100))
    Success = $(@(120, 200, 120)); Warning = $(@(200, 180, 100));  Error = $(@(200, 100, 100))
    Info = $(@(140, 160, 200));   Gold = $(@(200, 180, 100))
    BgBase = $(@(18, 18, 18));    BgSurface = $(@(25, 25, 25));   BgOverlay = $(@(32, 32, 32))
    Border = $(@(50, 50, 50));    BorderActive = $(@(200, 200, 200))
    TextPrimary = $(@(220, 220, 220)); TextSecondary = $(@(140, 140, 140)); TextMuted = $(@(80, 80, 80))
    TextLink = $(@(160, 180, 200))
    GradientStart = $(@(200, 200, 200)); GradientEnd = $(@(100, 100, 100)); GradientMid = $(@(150, 150, 150))
    ShimmerFrom = $(@(200, 200, 200)); ShimmerTo = $(@(140, 140, 140))
}

# ─── TEMA ACTUAL ────────────────────────────────────────────

$script:TemaActual = 'Cyberpunk'
$script:Tema = $script:Temas[$script:TemaActual]

# ─── ANIMACION: Milisegundos ─────────────────────────────────

$script:Anim = @{
    SplashPuntos     = 200
    SplashLinea      = 50
    SplashPasoBarra  = 20
    SplashFinal      = 200
    SpinnerFrame     = 70
    TransicionPaso   = 5
    SeparatorStep    = 8
    ShimmerStep      = 50
    ShimmerPasos     = 20
    CRTStep          = 30
    MenuRender       = 0
    CajaRender       = 15
    NotificationMs   = 3000
}

# ─── DISENO: Dimensiones ─────────────────────────────────────

$script:Diseno = @{
    Ancho         = 68
    AnchoCaja     = 68
    Sangria       = 2
    MaxItemsMenu  = 5
    AnchoBarra    = 44
    AnchoTile     = 20
    AnchoModal    = 60
    MaxDescLen    = 35
    AnchoSparkline = 20
    AnchoChart     = 30
}

# ─── SETTINGS (Runtime) ─────────────────────────────────────

$script:Settings = @{
    TemaNombre     = 'Cyberpunk'
    Fuente         = 'FiraCode Nerd Font'
    TamanoFuente   = 18
    Animaciones    = $true
    Shimmer        = $true
    CRTEffect      = $false
    Idioma         = 'es'
    LogoStyle      = 'ascii'
    BarStyle       = 'gradient'
    GradientPreset = 'default'
}

# ─── RUTAS ────────────────────────────────────────────────────

$script:Rutas = @{
    DirLogs    = if ($env:RYU_TUI_LOG_DIR) { $env:RYU_TUI_LOG_DIR } else { Join-Path $env:APPDATA 'RYU-TUI\logs' }
    DiasLog    = if ($env:RYU_TUI_LOG_RETENTION_DAYS) { [int]$env:RYU_TUI_LOG_RETENTION_DAYS } else { 30 }
    DirCache   = if ($env:RYU_TUI_CACHE_DIR) { $env:RYU_TUI_CACHE_DIR } else { Join-Path $env:LOCALAPPDATA 'RYU-TUI\cache' }
    DirUndo    = Join-Path $env:LOCALAPPDATA 'RYU-TUI\undo'
    DirReports = Join-Path $env:LOCALAPPDATA 'RYU-TUI\reports'
}

# ─── RED ──────────────────────────────────────────────────────

$script:Red = @{
    Proveedores = @(
        @{ Url = 'https://ipapi.co/json/'; Timeout = 5 }
        @{ Url = 'https://ip-api.com/json/'; Timeout = 5 }
    )
    Agente      = 'RYU-TUI-Toolkit/3.0'
    CacheTTL    = 5400
    ArchivoCache = Join-Path $script:Rutas.DirCache 'network_cache.json'
    TimeoutDefault = 5
}

# ─── BANDERAS: Emoji regional indicators ──────────────────────

$script:Banderas = @{}
function script:Construir-Banderas {
    $codigos = @{
        'US'=@(0x1F1FA,0x1F1F8);'GB'=@(0x1F1EC,0x1F1E7);'DE'=@(0x1F1E9,0x1F1EA)
        'FR'=@(0x1F1EB,0x1F1F7);'ES'=@(0x1F1EA,0x1F1F8);'IT'=@(0x1F1EE,0x1F1F9)
        'PT'=@(0x1F1F5,0x1F1F9);'BR'=@(0x1F1E7,0x1F1F7);'MX'=@(0x1F1F2,0x1F1FD)
        'AR'=@(0x1F1E6,0x1F1F7);'CL'=@(0x1F1E8,0x1F1F1);'CO'=@(0x1F1E8,0x1F1F4)
        'JP'=@(0x1F1EF,0x1F1F5);'KR'=@(0x1F1F0,0x1F1F7);'CN'=@(0x1F1E8,0x1F1F3)
        'IN'=@(0x1F1EE,0x1F1F3);'RU'=@(0x1F1F7,0x1F1FA);'CA'=@(0x1F1E8,0x1F1E6)
        'AU'=@(0x1F1E6,0x1F1FA);'NL'=@(0x1F1F3,0x1F1F1);'SE'=@(0x1F1F8,0x1F1EA)
        'NO'=@(0x1F1F3,0x1F1F4);'FI'=@(0x1F1EB,0x1F1EE);'PL'=@(0x1F1F5,0x1F1F1)
        'CH'=@(0x1F1E8,0x1F1ED);'AT'=@(0x1F1E6,0x1F1F9);'BE'=@(0x1F1E7,0x1F1EA)
        'IE'=@(0x1F1EE,0x1F1EA);'NZ'=@(0x1F1F3,0x1F1FF);'ZA'=@(0x1F1FF,0x1F1E6)
        'TR'=@(0x1F1F9,0x1F1F7);'SA'=@(0x1F1F8,0x1F1E6);'AE'=@(0x1F1E6,0x1F1EA)
        'SG'=@(0x1F1F8,0x1F1EC);'TH'=@(0x1F1F9,0x1F1ED);'VN'=@(0x1F1FB,0x1F1F3)
        'PH'=@(0x1F1F5,0x1F1ED);'ID'=@(0x1F1EE,0x1F1E9);'MY'=@(0x1F1F2,0x1F1FE)
        'PE'=@(0x1F1F5,0x1F1EA);'EC'=@(0x1F1EA,0x1F1E8);'VE'=@(0x1F1FB,0x1F1EA)
        'UY'=@(0x1F1FA,0x1F1FE);'PY'=@(0x1F1F5,0x1F1FE);'CU'=@(0x1F1E8,0x1F1FA)
        'DO'=@(0x1F1E9,0x1F1F4);'CR'=@(0x1F1E8,0x1F1F7);'PA'=@(0x1F1F5,0x1F1E6)
        'GT'=@(0x1F1EC,0x1F1F9);'HN'=@(0x1F1ED,0x1F1F3);'SV'=@(0x1F1F8,0x1F1FB)
        'NI'=@(0x1F1F3,0x1F1EE);'CZ'=@(0x1F1E8,0x1F1FF);'SK'=@(0x1F1F8,0x1F1F0)
        'HU'=@(0x1F1ED,0x1F1FA);'RO'=@(0x1F1F7,0x1F1F4);'BG'=@(0x1F1E7,0x1F1EC)
        'GR'=@(0x1F1EC,0x1F1F7);'HR'=@(0x1F1ED,0x1F1F7);'RS'=@(0x1F1F7,0x1F1F8)
        'UA'=@(0x1F1FA,0x1F1E6);'IL'=@(0x1F1EE,0x1F1F1);'EG'=@(0x1F1EA,0x1F1EC)
        'NG'=@(0x1F1F3,0x1F1EC);'KE'=@(0x1F1F0,0x1F1EA);'GH'=@(0x1F1EC,0x1F1ED)
        'TZ'=@(0x1F1F9,0x1F1FF);'ET'=@(0x1F1EA,0x1F1F9);'DEFAULT'=@(0x1F30D)
    }
    foreach ($kvp in $codigos.GetEnumerator()) {
        $chars = @(); foreach ($cp in $kvp.Value) { $chars += [System.Char]::ConvertFromUtf32($cp) }
        $script:Banderas[$kvp.Key] = $chars -join ''
    }
}
Construir-Banderas

# ─── GRADIENT PRESETS (14) ───────────────────────────────────

$script:GradientPresets = @{
    'default'  = @{ From = @(0, 230, 200);   To = @(139, 92, 246) }
    'ocean'    = @{ From = @(0, 100, 255);    To = @(0, 200, 200) }
    'fire'     = @{ From = @(255, 50, 0);     To = @(255, 200, 0) }
    'aurora'   = @{ From = @(0, 200, 200);    To = @(120, 80, 255) }
    'candy'    = @{ From = @(255, 100, 180);  To = @(0, 220, 220) }
    'neon'     = @{ From = @(255, 0, 180);    To = @(0, 220, 255) }
    'forest'   = @{ From = @(0, 180, 80);     To = @(0, 100, 40) }
    'purple'   = @{ From = @(180, 0, 255);    To = @(100, 0, 180) }
    'cyber'    = @{ From = @(0, 255, 100);    To = @(0, 100, 255) }
    'mono'     = @{ From = @(200, 200, 200);  To = @(100, 100, 100) }
    'heatmap'  = @{ From = @(255, 0, 0);      To = @(255, 255, 0) }
    'sunset'   = @{ From = @(255, 100, 0);    To = @(200, 0, 200) }
    'matrix'   = @{ From = @(0, 255, 65);     To = @(0, 100, 30) }
    'ice'      = @{ From = @(150, 220, 255);  To = @(50, 100, 200) }
}

# ─── EXPORTACIONES ────────────────────────────────────────────

function Get-Tema       { return $script:Tema }
function Get-Temas      { return $script:Temas }
function Get-TemaActual { return $script:TemaActual }
function Get-Anim       { return $script:Anim }
function Get-Diseno     { return $script:Diseno }
function Get-Settings   { return $script:Settings }
function Get-Rutas      { return $script:Rutas }
function Get-Red        { return $script:Red }
function Get-Banderas   { return $script:Banderas }
function Get-BanderaEmoji {
    param([string]$Codigo = 'DEFAULT')
    $c = $Codigo.ToUpper()
    if ($script:Banderas.ContainsKey($c)) { return $script:Banderas[$c] }
    return $script:Banderas['DEFAULT']
}
function Get-GradientPreset {
    param([string]$Nombre = 'default')
    if ($script:GradientPresets.ContainsKey($Nombre)) { return $script:GradientPresets[$Nombre] }
    return $script:GradientPresets['default']
}
function Get-GradientPresets { return $script:GradientPresets }

function Set-Tema {
    param([Parameter(Mandatory)][string]$Nombre)
    if ($script:Temas.ContainsKey($Nombre)) {
        $script:TemaActual = $Nombre
        $script:Tema = $script:Temas[$Nombre]
        $script:Settings.TemaNombre = $Nombre
        return $true
    }
    return $false
}

function Set-Setting {
    param([Parameter(Mandatory)][string]$Clave, $Valor)
    if ($script:Settings.ContainsKey($Clave)) {
        $script:Settings[$Clave] = $Valor
        return $true
    }
    return $false
}

function Get-NombresTemas { return @($script:Temas.Keys | Sort-Object) }

# Aliases de compatibilidad
Set-Alias -Name Get-RyuConfig  -Value Get-Tema
Set-Alias -Name Get-RyuAnim    -Value Get-Anim
Set-Alias -Name Get-RyuLayout  -Value Get-Diseno
Set-Alias -Name Get-RyuPaths   -Value Get-Rutas
Set-Alias -Name Get-RyuNetwork -Value Get-Red
Set-Alias -Name Get-RyuFlags   -Value Get-Banderas
Set-Alias -Name Get-FlagEmoji  -Value Get-BanderaEmoji

Export-ModuleMember -Function @(
    'Get-Tema','Get-Temas','Get-TemaActual','Get-Anim','Get-Diseno','Get-Settings',
    'Get-Rutas','Get-Red','Get-Banderas','Get-BanderaEmoji','Get-GradientPreset','Get-GradientPresets',
    'Get-NombresTemas','Set-Tema','Set-Setting',
    'Get-RyuConfig','Get-RyuAnim','Get-RyuLayout','Get-RyuPaths','Get-RyuNetwork','Get-RyuFlags','Get-FlagEmoji'
)
Export-ModuleMember -Alias @(
    'Get-RyuConfig','Get-RyuAnim','Get-RyuLayout','Get-RyuPaths','Get-RyuNetwork','Get-RyuFlags','Get-FlagEmoji'
)
