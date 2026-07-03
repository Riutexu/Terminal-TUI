#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Motor de renderizado v3.0.
.DESCRIPTION
    13 temas, RGB gradient bars, sparklines, shimmer, CRT, multi-select,
    viewport scroll, metrics cards, charts, notifications, settings.
#>

Set-StrictMode -Version Latest

# ─── INTERNAL HELPERS ─────────────────────────────────────────

function GetT {
    $tema    = Get-Tema      -ErrorAction SilentlyContinue
    $anim    = Get-Anim      -ErrorAction SilentlyContinue
    $diseno  = Get-Diseno    -ErrorAction SilentlyContinue
    $rutas   = Get-Rutas     -ErrorAction SilentlyContinue
    $red     = Get-Red       -ErrorAction SilentlyContinue
    $settings = Get-Settings -ErrorAction SilentlyContinue
    $banderas = Get-Banderas -ErrorAction SilentlyContinue

    if (-not $tema) { return $null }

    $merged = @{}
    foreach ($kvp in $tema.GetEnumerator()) { $merged[$kvp.Key] = $kvp.Value }
    if (-not $merged['Highlight']) { $merged['Highlight'] = $merged['Accent'] }
    if ($anim)     { $merged['Anim']     = $anim }
    if ($diseno)   { $merged['Diseno']   = $diseno }
    if ($rutas)    { $merged['Rutas']    = $rutas }
    if ($red)      { $merged['Red']      = $red }
    if ($settings) { $merged['Settings'] = $settings }
    if ($banderas) { $merged['Banderas'] = $banderas }

    return $merged
}

function FG([int]$R,[int]$G,[int]$B) { "`e[38;2;${R};${G};${B}m" }
function BG([int]$R,[int]$G,[int]$B) { "`e[48;2;${R};${G};${B}m" }
function RST { "`e[0m" }
function BLD { "`e[1m" }
function DIM { "`e[2m" }
function ITL { "`e[3m" }
function CLR { "`e[2K`e[1A" }

# ─── TEXT STYLING ─────────────────────────────────────────────

function Get-RgbString {
    param(
        [Parameter(Mandatory)][string]$Texto,
        [Parameter(Mandatory)][int[]]$Color,
        [switch]$Negrita, [switch]$Apagado, [switch]$Cursiva
    )
    $f = (FG $Color[0] $Color[1] $Color[2])
    $e = (RST)
    $b = if ($Negrita) { BLD } else { '' }
    $d = if ($Apagado) { DIM } else { '' }
    $i = if ($Cursiva) { ITL } else { '' }
    return "${b}${d}${i}${f}${Texto}${e}"
}

function Get-GradientString {
    param(
        [Parameter(Mandatory)][string]$Texto,
        [Parameter(Mandatory)][int[]]$Desde,
        [Parameter(Mandatory)][int[]]$Hasta
    )
    $rs = (RST)
    $sb = [System.Text.StringBuilder]::new()
    $len = $Texto.Length
    for ($i = 0; $i -lt $len; $i++) {
        $t = if ($len -gt 1) { $i / ($len - 1) } else { 1 }
        $r = [int]($Desde[0] + ($Hasta[0] - $Desde[0]) * $t)
        $g = [int]($Desde[1] + ($Hasta[1] - $Desde[1]) * $t)
        $b = [int]($Desde[2] + ($Hasta[2] - $Desde[2]) * $t)
        $null = $sb.Append("$(FG $r $g $b)$($Texto[$i])")
    }
    $null = $sb.Append($rs)
    return $sb.ToString()
}

# ─── OUTPUT ───────────────────────────────────────────────────

function Write-Rgb {
    param([Parameter(Mandatory)][string]$Texto, [Parameter(Mandatory)][int[]]$Color,
          [switch]$Negrita, [switch]$Apagado, [switch]$SinSalto)
    $salida = Get-RgbString -Texto $Texto -Color $Color -Negrita:$Negrita -Apagado:$Apagado
    if ($SinSalto) { [Console]::Write($salida) } else { Write-Host $salida -NoNewline; Write-Host '' }
}

function Write-Gradient {
    param([Parameter(Mandatory)][string]$Texto, [Parameter(Mandatory)][int[]]$Desde, [Parameter(Mandatory)][int[]]$Hasta)
    Write-Host (Get-GradientString -Texto $Texto -Desde $Desde -Hasta $Hasta) -NoNewline; Write-Host ''
}

function Write-WaveGradient {
    param([Parameter(Mandatory)][string]$Texto, [int]$LongitudOnda = 8)
    $t = GetT; $rs = (RST); $sb = [System.Text.StringBuilder]::new()
    for ($i = 0; $i -lt $Texto.Length; $i++) {
        $p = ([Math]::Sin($i * [Math]::PI * 2 / $LongitudOnda) + 1) / 2
        $r = [int]($t.GradientStart[0] + ($t.GradientEnd[0] - $t.GradientStart[0]) * $p)
        $g = [int]($t.GradientStart[1] + ($t.GradientEnd[1] - $t.GradientStart[1]) * $p)
        $b = [int]($t.GradientStart[2] + ($t.GradientEnd[2] - $t.GradientStart[2]) * $p)
        $null = $sb.Append("$(FG $r $g $b)$($Texto[$i])")
    }
    $null = $sb.Append($rs)
    Write-Host $sb.ToString() -NoNewline; Write-Host ''
}

# ─── LAYOUT COMPONENTS ────────────────────────────────────────

function Write-Box {
    param([string[]]$Lineas, [string]$Titulo = '', [int[]]$ColorBorde, [int[]]$ColorTitulo,
          [int]$Ancho = 0, [int]$Sangria = 2, [switch]$Animado)
    $t = GetT
    if (-not $ColorBorde) { $ColorBorde = $t.Border }
    if (-not $ColorTitulo) { $ColorTitulo = $t.Primary }
    if ($Ancho -le 0) { $Ancho = $t.Diseno.Ancho }
    $pad = ' ' * $Sangria; $rs = (RST)
    $cb = (FG $ColorBorde[0] $ColorBorde[1] $ColorBorde[2])
    $ct = (FG $ColorTitulo[0] $ColorTitulo[1] $ColorTitulo[2])
    $inner = $Ancho - 2

    Write-Host "${pad}${cb}┌$(([string][char]0x2500) * $inner)┐${rs}"
    if ($Titulo) {
        $tf = " $Titulo "; $lp = [Math]::Max(0, [Math]::Floor(($inner - $tf.Length) / 2))
        $rp = [Math]::Max(0, $inner - $tf.Length - $lp)
        Write-Host "${pad}${cb}│${rs}$(' ' * $lp)${ct}${tf}${rs}$(' ' * $rp)${cb}│${rs}"
        Write-Host "${pad}${cb}├$(([string][char]0x2500) * $inner)┤${rs}"
    }
    foreach ($linea in $Lineas) {
        $vis = ($linea -replace "`e\[[0-9;]*m", '')
        $rell = [Math]::Max(0, $inner - $vis.Length - 2)
        Write-Host "${pad}${cb}│${rs} ${linea}$(' ' * $rell) ${cb}│${rs}"
    }
    Write-Host "${pad}${cb}└$(([string][char]0x2500) * $inner)┘${rs}"
}

function Write-Separator {
    param([int]$Ancho = 68, [int[]]$Color, [switch]$Animado)
    $t = GetT; $rs = (RST)
    $sb = [System.Text.StringBuilder]::new()
    $null = $sb.Append("  ")
    $mitad = [Math]::Floor(($Ancho - 2) / 2)
    for ($i = 0; $i -lt $mitad; $i++) {
        $p = $i / $mitad
        $r = [int]($t.GradientStart[0] + ($t.GradientEnd[0] - $t.GradientStart[0]) * $p)
        $g = [int]($t.GradientStart[1] + ($t.GradientEnd[1] - $t.GradientStart[1]) * $p)
        $b = [int]($t.GradientStart[2] + ($t.GradientEnd[2] - $t.GradientStart[2]) * $p)
        $null = $sb.Append("$(FG $r $g $b)$([string][char]0x2500)${rs}")
    }
    $null = $sb.Append("$(FG $t.GradientMid[0] $t.GradientMid[1] $t.GradientMid[2])◆${rs}")
    for ($i = $mitad; $i -gt 0; $i--) {
        $p = $i / $mitad
        $r = [int]($t.GradientEnd[0] + ($t.GradientStart[0] - $t.GradientEnd[0]) * $p)
        $g = [int]($t.GradientEnd[1] + ($t.GradientStart[1] - $t.GradientEnd[1]) * $p)
        $b = [int]($t.GradientEnd[2] + ($t.GradientStart[2] - $t.GradientEnd[2]) * $p)
        $null = $sb.Append("$(FG $r $g $b)$([string][char]0x2500)${rs}")
    }
    $null = $sb.Append("$(FG $t.GradientStart[0] $t.GradientStart[1] $t.GradientStart[2])◂${rs}")
    Write-Host ''
    Write-Host $sb.ToString()
    Write-Host ''
}

function Write-Tile {
    param([Parameter(Mandatory)][string]$Titulo, [string]$Subtitulo = '', [string]$Icono = '',
          [int[]]$ColorFondo, [int[]]$ColorTexto, [switch]$Seleccionado, [int]$Ancho = 0)
    $t = GetT
    if ($Ancho -le 0) { $Ancho = $t.Diseno.AnchoTile }
    if (-not $ColorFondo) { $ColorFondo = if ($Seleccionado) { $t.Primary } else { $t.BgSurface } }
    if (-not $ColorTexto) { $ColorTexto = if ($Seleccionado) { $t.Highlight } else { $t.TextSecondary } }
    $rs = (RST); $cf = (BG $ColorFondo[0] $ColorFondo[1] $ColorFondo[2])
    $ct = (FG $ColorTexto[0] $ColorTexto[1] $ColorTexto[2])
    $cbo = if ($Seleccionado) { (FG $t.Primary[0] $t.Primary[1] $t.Primary[2]) } else { (FG $t.Border[0] $t.Border[1] $t.Border[2]) }
    $tf = if ($Icono) { "$Icono $Titulo" } else { $Titulo }
    if ($tf.Length -gt $Ancho - 2) { $tf = $tf.Substring(0, $Ancho - 5) + '...' }
    $lp = [Math]::Floor(($Ancho - $tf.Length) / 2); $rp = $Ancho - $tf.Length - $lp
    Write-Host "  ${cbo}┌$(([string][char]0x2500) * $Ancho)┐${rs}" -NoNewline
    if ($Subtitulo) {
        $sf = if ($Subtitulo.Length -gt $Ancho) { $Subtitulo.Substring(0, $Ancho - 3) + '...' } else { $Subtitulo }
        $lsp = [Math]::Floor(($Ancho - $sf.Length) / 2); $rsp = $Ancho - $sf.Length - $lsp
        Write-Host "  ${cbo}│${cf}$(' ' * $lsp)${ct}${sf}${rs}$(' ' * $rsp)${cbo}│${rs}" -NoNewline
    }
    Write-Host "  ${cbo}│${cf}$(' ' * $lp)${ct}${tf}${rs}$(' ' * $rp)${cbo}│${rs}" -NoNewline
    Write-Host "  ${cbo}└$(([string][char]0x2500) * $Ancho)┘${rs}" -NoNewline
}

# ─── METRIC CARD ──────────────────────────────────────────────

function Write-MetricCard {
    param(
        [Parameter(Mandatory)][string]$Titulo, [Parameter(Mandatory)][string]$Valor,
        [string]$Tendencia = '', [int[]]$ColorValor, [int]$Ancho = 16
    )
    $t = GetT
    if (-not $ColorValor) { $ColorValor = $t.Primary }
    $rs = (RST)
    $cv = (FG $ColorValor[0] $ColorValor[1] $ColorValor[2])
    $ct = (FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])
    $cb = (FG $t.Border[0] $t.Border[1] $t.Border[2])
    $cm = (FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])

    $trendIcon = switch ($Tendencia) {
        'up'     { "$(FG 34 197 94)▲${rs}" }
        'down'   { "$(FG 239 68 68)▼${rs}" }
        'stable' { "$(FG 245 158 11)●${rs}" }
        default  { '' }
    }

    Write-Host "  ${cb}┌$(([string][char]0x2500) * $Ancho)┐${rs}" -NoNewline
    $vp = [Math]::Floor(($Ancho - $Titulo.Length) / 2); $vrp = $Ancho - $Titulo.Length - $vp
    Write-Host "  ${cb}│${rs}$(' ' * $vp)${ct}${Titulo}${rs}$(' ' * $vrp)${cb}│${rs}" -NoNewline
    Write-Host "  ${cb}├$(([string][char]0x2500) * $Ancho)┤${rs}" -NoNewline
    $vp2 = [Math]::Floor(($Ancho - $Valor.Length - 2) / 2); $vrp2 = $Ancho - $Valor.Length - 2 - $vp2
    Write-Host "  ${cb}│${rs}$(' ' * $vp2)${cv}$(BLD)${Valor}${rs} ${trendIcon}$(' ' * [Math]::Max(0,$vrp2))${cb}│${rs}" -NoNewline
    Write-Host "  ${cb}└$(([string][char]0x2500) * $Ancho)┘${rs}" -NoNewline
}

# ─── RGB PROGRESS BAR (gradient + shimmer) ────────────────────

function Write-RGBBar {
    param(
        [int]$Completado = 0, [int]$Total = 100, [int]$Ancho = 44,
        [int[]]$ColorDesde, [int[]]$ColorHasta,
        [string]$Mensaje = '', [switch]$ConETA, [double]$MBporSegundo = 0,
        [switch]$ConShimmer, [int]$ShimmerPos = 0
    )
    $t = GetT
    if (-not $ColorDesde) { $ColorDesde = $t.GradientStart }
    if (-not $ColorHasta) { $ColorHasta = $t.GradientEnd }
    $e = "`e"; $rs = (RST)
    $pct = if ($Total -gt 0) { [math]::Min(100, [math]::Round(($Completado / $Total) * 100)) } else { 0 }
    $filled = [math]::Min($Ancho, [math]::Round($Ancho * $pct / 100))

    $sb = [System.Text.StringBuilder]::new()
    if ($Mensaje) {
        $msg = if ($Mensaje.Length -gt 20) { $Mensaje.Substring(0, 17) + '...' } else { $Mensaje }
        $null = $sb.Append("  $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])${msg}${rs}  ")
    }
    $null = $sb.Append("$(FG $t.TextPrimary[0] $t.TextPrimary[1] $t.TextSecondary[2])[")

    for ($i = 0; $i -lt $Ancho; $i++) {
        $t_norm = if ($Ancho -gt 1) { $i / ($Ancho - 1) } else { 0 }
        $r = [int]($ColorDesde[0] + ($ColorHasta[0] - $ColorDesde[0]) * $t_norm)
        $g = [int]($ColorDesde[1] + ($ColorHasta[1] - $ColorDesde[1]) * $t_norm)
        $b = [int]($ColorDesde[2] + ($ColorHasta[2] - $ColorDesde[2]) * $t_norm)

        if ($i -lt $filled) {
            if ($ConShimmer -and $i -eq (($ShimmerPos % $Ancho))) {
                $null = $sb.Append("${e}[38;2;255;255;255m$([char]0x2588)")
            } else {
                $null = $sb.Append("${e}[38;2;${r};${g};${b}m$([char]0x2588)")
            }
        } else {
            $null = $sb.Append("${e}[38;2;35;40;55m$([char]0x2591)")
        }
    }

    $null = $sb.Append("${rs}] ")
    $null = $sb.Append("$(FG $t.TextPrimary[0] $t.TextPrimary[1] $t.TextPrimary[2])${pct}%${rs}")

    if ($ConETA -and $MBporSegundo -gt 0) {
        $rest = if ($Total -gt $Completado) { "$([math]::Round(($Total - $Completado) / ($MBporSegundo * 1024 * 1024), 1))s" } else { '0s' }
        $null = $sb.Append("  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])⏱${rest}  ▲$([math]::Round($MBporSegundo, 1)) MB/s${rs}")
    }

    [Console]::Write($sb.ToString())
    if ($pct -ge 100) { [Console]::WriteLine('') }
}

# ─── SPARKLINE ────────────────────────────────────────────────

function Write-Sparkline {
    param([double[]]$Datos, [int]$Ancho = 20, [int[]]$Color, [switch]$SinSalto)
    $t = GetT
    if (-not $Color) { $Color = $t.Primary }
    $chars = @('▁','▂','▃','▄','▅','▆','▇','█')
    if ($Datos.Count -eq 0) { return }
    $min = ($Datos | Measure-Object -Minimum).Minimum
    $max = ($Datos | Measure-Object -Maximum).Maximum
    $rango = $max - $min; if ($rango -eq 0) { $rango = 1 }
    $sb = [System.Text.StringBuilder]::new()
    $ultimos = $Datos | Select-Object -Last $Ancho
    foreach ($d in $ultimos) {
        $idx = [math]::Min(7, [math]::Floor((($d - $min) / $rango) * 8))
        $null = $sb.Append($chars[$idx])
    }
    $out = "$(FG $Color[0] $Color[1] $Color[2])$($sb.ToString())$(RST)"
    if ($SinSalto) { [Console]::Write($out) } else { Write-Host $out -NoNewline }
}

# ─── GAUGE (circular arc) ────────────────────────────────────

function Write-Gauge {
    param([int]$Porcentaje = 0, [int[]]$Color, [string]$Label = '')
    $t = GetT
    if (-not $Color) { $Color = $t.Primary }
    $chars = @('░','▒','▓','█')
    $blocks = [math]::Floor($Porcentaje / 25)
    $partial = $Porcentaje % 25
    $sb = [System.Text.StringBuilder]::new()
    for ($i = 0; $i -lt 4; $i++) {
        if ($i -lt $blocks) { $null = $sb.Append("$(FG $Color[0] $Color[1] $Color[2])█") }
        elseif ($i -eq $blocks -and $partial -gt 0) { $null = $sb.Append("$(FG $Color[0] $Color[1] $Color[2])$($chars[$partial / 7])") }
        else { $null = $sb.Append("$(FG 55 60 75)░") }
    }
    $out = "$($sb.ToString())$(RST) $(FG $t.TextPrimary[0] $t.TextPrimary[1] $t.TextPrimary[2])${Porcentaje}%$(RST)"
    if ($Label) { $out = "$(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])${Label}:$(RST) $out" }
    Write-Host "  $out"
}

# ─── BAR CHART ────────────────────────────────────────────────

function Write-BarChart {
    param([hashtable]$Datos, [int]$AnchoMax = 30)
    $t = GetT
    $max = ($Datos.Values | Measure-Object -Maximum).Maximum
    if ($max -eq 0) { $max = 1 }
    foreach ($kvp in $Datos.GetEnumerator()) {
        $pct = [math]::Round(($kvp.Value / $max) * 100)
        $barLen = [math]::Round(($kvp.Value / $max) * $AnchoMax)
        $bar = "$([string][char]0x2588)" * $barLen
        $empty = "$([string][char]0x2591)" * ($AnchoMax - $barLen)
        $label = $kvp.Key.PadRight(12)
        Write-Host "  $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])${label}$(RST) " -NoNewline
        Write-Host "$(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])${bar}$(FG $t.Border[0] $t.Border[1] $t.Border[2])${empty}$(RST) $(FG $t.TextPrimary[0] $t.TextPrimary[1] $t.TextPrimary[2])${pct}%$(RST)"
    }
}

# ─── SHIMMER EFFECT ──────────────────────────────────────────

function Write-Shimmer {
    param([Parameter(Mandatory)][string]$Texto, [int[]]$ColorDesde, [int[]]$ColorHasta, [int]$Pasos = 20)
    $t = GetT
    if (-not $ColorDesde) { $ColorDesde = $t.ShimmerFrom }
    if (-not $ColorHasta) { $ColorHasta = $t.ShimmerTo }
    if (-not $t.Settings.Shimmer) { Write-Host $Texto; return }
    $e = "`e"; $rs = (RST)
    $savedY = [Console]::CursorTop
    for ($p = 0; $p -lt $Pasos; $p++) {
        $offset = $p * 2; $sb = [System.Text.StringBuilder]::new()
        for ($i = 0; $i -lt $Texto.Length; $i++) {
            $t_norm = (($i + $offset) % 40) / 40
            $r = [int]($ColorDesde[0] + ($ColorHasta[0] - $ColorDesde[0]) * $t_norm)
            $g = [int]($ColorDesde[1] + ($ColorHasta[1] - $ColorDesde[1]) * $t_norm)
            $b = [int]($ColorDesde[2] + ($ColorHasta[2] - $ColorDesde[2]) * $t_norm)
            $null = $sb.Append("${e}[38;2;${r};${g};${b}m$($Texto[$i])")
        }
        $null = $sb.Append($rs)
        [Console]::SetCursorPosition(0, $savedY)
        [Console]::Write($sb.ToString())
        Start-Sleep -Milliseconds $t.Anim.ShimmerStep
    }
}

# ─── CRT SCANLINE EFFECT ─────────────────────────────────────

function Write-CRT {
    param([Parameter(Mandatory)][string]$Texto)
    $t = GetT
    if (-not $t.Settings.CRTEffect) { Write-Host $Texto; return }
    $rs = (RST); $sb = [System.Text.StringBuilder]::new()
    for ($i = 0; $i -lt $Texto.Length; $i++) {
        $char = $Texto[$i]
        $null = $sb.Append("${char}`e[2m")
        if (($i + 1) % 2 -eq 0) { $null = $sb.Append("$(DIM)") }
    }
    $null = $sb.Append($rs)
    Write-Host $sb.ToString()
}

# ─── RGB WAVE (header decoration) ────────────────────────────

function Write-RGBWave {
    param([int]$Ancho = 68, [int]$Fase = 0)
    $t = GetT; $sb = [System.Text.StringBuilder]::new()
    for ($i = 0; $i -lt $Ancho; $i++) {
        $r = [math]::Round(128 + 127 * [math]::Sin(($i + $Fase) * 0.09))
        $g = [math]::Round(128 + 127 * [math]::Sin(($i + $Fase) * 0.09 + 2.094))
        $b = [math]::Round(128 + 127 * [math]::Sin(($i + $Fase) * 0.09 + 4.188))
        $null = $sb.Append("$(BG $r $g $b) ")
    }
    $null = $sb.Append("$(RST)")
    Write-Host $sb.ToString()
}

# ─── NOTIFICATION TOAST ──────────────────────────────────────

function Write-Notification {
    param([Parameter(Mandatory)][string]$Mensaje, [ValidateSet('INFO','EXITO','ADVERTENCIA','ERROR')][string]$Tipo = 'INFO')
    $t = GetT
    $icono = switch ($Tipo) { 'INFO' { '●' } 'EXITO' { '✓' } 'ADVERTENCIA' { '▲' } 'ERROR' { '✖' } }
    $color = switch ($Tipo) { 'INFO' { $t.Info } 'EXITO' { $t.Success } 'ADVERTENCIA' { $t.Warning } 'ERROR' { $t.Error } }
    $barra = "$([string][char]0x2500)" * ($Mensaje.Length + 4)
    Write-Host ''
    Write-Host "  $(FG $color[0] $color[1] $color[2])┌$barra┐${rs}"
    Write-Host "  $(FG $color[0] $color[1] $color[2])│${rs} ${icono}  ${Mensaje}  $(FG $color[0] $color[1] $color[2])│${rs}"
    Write-Host "  $(FG $color[0] $color[1] $color[2])└$barra┘${rs}"
    Write-Host ''
}

# ─── SPLASH SCREEN ────────────────────────────────────────────

function Show-SplashScreen {
    param([string]$Version = '3.0')
    $t = GetT; $rs = (RST)

    $logo = @'
    ______  ____  __    ________  ______
   / __ \ \/ / / / /   /_  __/ / / /  _/
  / /_/ /\  / / / /_____/ / / / / // /  
 / _, _/ / / /_/ /_____/ / / /_/ // /   
/_/ |_| /_/\____/     /_/  \____/___/   
'@

    Write-Host ''
    foreach ($linea in $logo) {
        Write-Gradient -Texto $linea -Desde $t.GradientStart -Hasta $t.GradientEnd
        Start-Sleep -Milliseconds $t.Anim.SplashLinea
    }

    Write-Host ''
    Write-Shimmer -Texto "  TUI SYSTEM TOOLKIT v$Version" -Pasos 10
    Write-Rgb -Texto "  Gestor de herramientas del sistema" -Color $t.TextSecondary
    Write-Host ''

    $barAncho = 40
    for ($i = 0; $i -le $barAncho; $i++) {
        Write-RGBBar -Completado $i -Total $barAncho -Ancho $barAncho -ConShimmer -ShimmerPos $i
        [Console]::Write("`r")
        Start-Sleep -Milliseconds $t.Anim.SplashPasoBarra
    }
    Write-Host ''
    Write-Host ''
    Start-Sleep -Milliseconds $t.Anim.SplashFinal
}

# ─── SPINNER ──────────────────────────────────────────────────

function Show-Spinner {
    param([Parameter(Mandatory)][string]$Mensaje, [scriptblock]$Accion, [int[]]$Color)
    $t = GetT
    if (-not $Color) { $Color = $t.Primary }
    $frames = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $job = Start-Job -ScriptBlock { param($sb) & $sb } -ArgumentList $Accion
    $i = 0
    while ($job.State -eq 'Running') {
        $frame = $frames[$i % $frames.Length]
        Write-Host "`r  $(FG $Color[0] $Color[1] $Color[2])${frame}${rs} $Mensaje" -NoNewline
        Start-Sleep -Milliseconds $t.Anim.SpinnerFrame; $i++
    }
    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-Null
    Remove-Job -Job $job -Force
    Write-Host "`r  $(FG $t.Success[0] $t.Success[1] $t.Success[2])✓${rs} $Mensaje          "
}

# ─── SCREEN TRANSITION ───────────────────────────────────────

function Invoke-ScreenTransition {
    param([string]$Titulo = '')
    $t = GetT; $ancho = [Console]::WindowWidth; if ($ancho -le 0) { $ancho = 120 }
    Write-Host ''
    for ($i = 0; $i -lt 3; $i++) {
        Write-RGBWave -Ancho $ancho -Fase ($i * 20)
        Start-Sleep -Milliseconds $t.Anim.TransicionPaso
    }
    if ($Titulo) {
        $lp = [Math]::Max(0, [Math]::Floor(($ancho - $Titulo.Length - 4) / 2))
        Write-Host ''
        Write-Shimmer -Texto (" " * $lp + "▸ $Titulo") -Pasos 8
        Write-Host ''
    }
}

# ─── HEADER ───────────────────────────────────────────────────

function Show-RyuHeader {
    param([string]$SubTitulo = '', [string[]]$LineasExtra = @())
    $t = GetT
    Invoke-ScreenTransition
    $titulo = @'
    ______  ____  __    ________  ______
   / __ \ \/ / / / /   /_  __/ / / /  _/
  / /_/ /\  / / / /_____/ / / / / // /  
 / _, _/ / / /_/ /_____/ / / /_/ // /   
/_/ |_| /_/\____/     /_/  \____/___/   
'@
    foreach ($linea in $titulo) {
        Write-WaveGradient -Texto $linea
    }
    if ($SubTitulo) {
        $vis = $SubTitulo.Length + 4; $lp = [Math]::Max(0, [Math]::Floor(($t.Diseno.Ancho - $vis) / 2))
        Write-Rgb -Texto (" " * $lp + "▹ $SubTitulo") -Color $t.TextSecondary
    }
    foreach ($l in $LineasExtra) { Write-Rgb -Texto "  $l" -Color $t.TextMuted }
    Write-Separator
}

# ─── FOOTER ──────────────────────────────────────────────────

function Show-RyuFooter {
    $t = GetT
    $autor = @'
Script creado por:

    ____  _       __                 
   / __ \(_)_  __/ /____  _  ____  __
  / /_/ / / / / / __/ _ \| |/_/ / / /
 / _, _/ / /_/ / /_/  __/>  </ /_/ / 
/_/ |_/_/\__,_/\__/\___/_/|_|\__,_/  
'@
    Write-Host ''
    Write-Separator -Ancho $t.Diseno.Ancho
    foreach ($linea in $autor) {
        Write-WaveGradient -Texto $linea
    }
}

# ─── MENU (single select with viewport scroll) ────────────────

function Show-RyuMenu {
    param(
        [Parameter(Mandatory)][string]$Titulo, [Parameter(Mandatory)][string[]]$Opciones,
        [string[]]$Iconos = @(), [string[]]$Descripciones = @(),
        [string]$SubTitulo = '', [string]$InfoRed = ''
    )
    $t = GetT; $rs = (RST)
    $ancho = $t.Diseno.Ancho
    $seleccion = 0; $total = $Opciones.Count; $maxVis = $t.Diseno.MaxItemsMenu
    $scrollOffset = 0

    function Draw-Menu {
        $visStart = $scrollOffset
        $visEnd = [Math]::Min($total, $scrollOffset + $maxVis)
        $linesDrawn = 0

        # Menu items
        for ($i = $visStart; $i -lt $visEnd; $i++) {
            $op = $Opciones[$i]; $sel = ($i -eq $seleccion)
            $ico = if ($i -lt $Iconos.Count -and $Iconos[$i]) { $Iconos[$i] } else { [string][char]0x25B6 }
            if ($sel) {
                $linea = "    $(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])▸${rs} $(FG $t.Highlight[0] $t.Highlight[1] $t.Highlight[2])$(BLD)$op${rs}"
            } else {
                $linea = "    $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$ico${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])$op${rs}"
            }
            if ($sel -and $i -lt $Descripciones.Count -and $Descripciones[$i]) {
                $desc = $Descripciones[$i]
                if ($desc.Length -gt $t.Diseno.MaxDescLen) { $desc = $desc.Substring(0, $t.Diseno.MaxDescLen - 3) + '...' }
                $linea += "  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])— $desc${rs}"
            }
            Write-Host "`r$linea"
            $linesDrawn++
        }

        # Scroll indicator
        if ($total -gt $maxVis) {
            $scrollInfo = "  ─ $([char]0x2500) $([Math]::Min($visStart+1,$total))-$([Math]::Min($visEnd,$total))/$total $(if ($visEnd -lt $total) { [string][char]0x25BE } else { '' })"
            Write-Host "`r$(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])${scrollInfo}${rs}"
            $linesDrawn++
        }

        Write-Host ''
        $linesDrawn++

        # Separator (1 line only — no extra empty lines)
        $sb = [System.Text.StringBuilder]::new()
        $null = $sb.Append("  ")
        $mitad = [Math]::Floor(($ancho - 2) / 2)
        for ($i = 0; $i -lt $mitad; $i++) {
            $p = $i / $mitad
            $r = [int]($t.GradientStart[0] + ($t.GradientEnd[0] - $t.GradientStart[0]) * $p)
            $g = [int]($t.GradientStart[1] + ($t.GradientEnd[1] - $t.GradientStart[1]) * $p)
            $b = [int]($t.GradientStart[2] + ($t.GradientEnd[2] - $t.GradientStart[2]) * $p)
            $null = $sb.Append("$(FG $r $g $b)$([string][char]0x2500)${rs}")
        }
        $null = $sb.Append("$(FG $t.GradientMid[0] $t.GradientMid[1] $t.GradientMid[2])◆${rs}")
        for ($i = $mitad; $i -gt 0; $i--) {
            $p = $i / $mitad
            $r = [int]($t.GradientEnd[0] + ($t.GradientStart[0] - $t.GradientEnd[0]) * $p)
            $g = [int]($t.GradientEnd[1] + ($t.GradientStart[1] - $t.GradientEnd[1]) * $p)
            $b = [int]($t.GradientEnd[2] + ($t.GradientStart[2] - $t.GradientEnd[2]) * $p)
            $null = $sb.Append("$(FG $r $g $b)$([string][char]0x2500)${rs}")
        }
        $null = $sb.Append("$(FG $t.GradientStart[0] $t.GradientStart[1] $t.GradientStart[2])◂${rs}")
        Write-Host $sb.ToString()
        $linesDrawn++

        # Footer
        $footer = "  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)↑↓${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])navegar${rs}  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)↵${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])seleccionar${rs}  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)ESC${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])volver${rs}"
        Write-Host "`r$footer"
        $linesDrawn++

        if ($InfoRed) { Write-Rgb -Texto "  $InfoRed" -Color $t.TextMuted -Apagado; $linesDrawn++ }

        return $linesDrawn
    }

    # Initial draw (header + menu)
    Show-RyuHeader -SubTitulo $SubTitulo
    Write-Host "`r  $(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])$(BLD)$Titulo${rs}"
    Write-Host ''
    $menuStartY = [Console]::CursorTop
    $lastLines = Draw-Menu

    while ($true) {
        $k = [Console]::ReadKey($true)

        switch ($k.Key) {
            'UpArrow'    { $seleccion = [Math]::Max(0, $seleccion - 1) }
            'DownArrow'  { $seleccion = [Math]::Min($total - 1, $seleccion + 1) }
            'Enter'      { return $seleccion + 1 }
            'Escape'     { return 0 }
            'RightArrow' { return $seleccion + 1 }
            'LeftArrow'  { return 0 }
            'F5'         { Clear-Host; Show-RyuHeader -SubTitulo $SubTitulo; Write-Host "`r  $(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])$(BLD)$Titulo${rs}"; Write-Host ''; $menuStartY = [Console]::CursorTop; $lastLines = Draw-Menu; continue }
        }

        $num = [int][char]$k.KeyChar - 48
        if ($num -ge 1 -and $num -le $total) { return $num }

        # Viewport scroll
        if ($total -gt $maxVis) {
            if ($seleccion -lt $scrollOffset) { $scrollOffset = $seleccion }
            if ($seleccion -ge $scrollOffset + $maxVis) { $scrollOffset = $seleccion - $maxVis + 1 }
        }

        # Clear only the lines that were drawn, then redraw
        [Console]::SetCursorPosition(0, $menuStartY)
        for ($c = 0; $c -lt $lastLines; $c++) { Write-Host "`r$(' ' * $ancho)" }
        [Console]::SetCursorPosition(0, $menuStartY)
        $lastLines = Draw-Menu
    }
}

# ─── MULTI-SELECT MENU ────────────────────────────────────────

function Show-RyuMultiMenu {
    param(
        [Parameter(Mandatory)][string]$Titulo, [Parameter(Mandatory)][string[]]$Opciones,
        [string[]]$Iconos, [int[]]$SeleccionDefault, [bool[]]$Seleccionadas, [string]$SubTitulo = ''
    )
    $t = GetT; $rs = (RST); $ancho = $t.Diseno.Ancho
    $maxVis = $t.Diseno.MaxItemsMenu
    if ($Seleccionadas) {
        # Use provided bool array
    } elseif ($SeleccionDefault) {
        $Seleccionadas = @($false) * $Opciones.Count
        foreach ($idx in $SeleccionDefault) { if ($idx -lt $Opciones.Count) { $Seleccionadas[$idx] = $true } }
    } else {
        $Seleccionadas = @($false) * $Opciones.Count
    }

    $cursor = 0; $total = $Opciones.Count; $scrollOffset = 0

    function Draw-MultiMenu {
        $visStart = $scrollOffset
        $visEnd = [Math]::Min($total, $scrollOffset + $maxVis)
        $linesDrawn = 0

        # Items
        for ($i = $visStart; $i -lt $visEnd; $i++) {
            $op = $Opciones[$i]; $sel = ($i -eq $cursor); $chk = $Seleccionadas[$i]
            $ico = if ($Iconos -and $i -lt $Iconos.Count -and $Iconos[$i]) { $Iconos[$i] } else { '' }
            $box = if ($chk) { "$(FG $t.Success[0] $t.Success[1] $t.Success[2])[✓]${rs}" } else { "$(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])[ ]${rs}" }
            if ($sel) {
                $linea = "    $(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])▸${rs} ${box} $(FG $t.Highlight[0] $t.Highlight[1] $t.Highlight[2])$(BLD)$ico $op${rs}"
            } else {
                $linea = "      ${box} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])$ico $op${rs}"
            }
            Write-Host "`r$linea"
            $linesDrawn++
        }

        # Scroll indicator
        if ($total -gt $maxVis) {
            $scrollInfo = "  ─ $([char]0x2500) $([Math]::Min($visStart+1,$total))-$([Math]::Min($visEnd,$total))/$total $(if ($visEnd -lt $total) { [string][char]0x25BE } else { '' })"
            Write-Host "`r$(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])${scrollInfo}${rs}"
            $linesDrawn++
        }

        Write-Host ''
        $linesDrawn++

        # Separator (1 line only — no extra empty lines)
        $sb = [System.Text.StringBuilder]::new()
        $null = $sb.Append("  ")
        $mitad = [Math]::Floor(($ancho - 2) / 2)
        for ($i = 0; $i -lt $mitad; $i++) {
            $p = $i / $mitad
            $r = [int]($t.GradientStart[0] + ($t.GradientEnd[0] - $t.GradientStart[0]) * $p)
            $g = [int]($t.GradientStart[1] + ($t.GradientEnd[1] - $t.GradientStart[1]) * $p)
            $b = [int]($t.GradientStart[2] + ($t.GradientEnd[2] - $t.GradientStart[2]) * $p)
            $null = $sb.Append("$(FG $r $g $b)$([string][char]0x2500)${rs}")
        }
        $null = $sb.Append("$(FG $t.GradientMid[0] $t.GradientMid[1] $t.GradientMid[2])◆${rs}")
        for ($i = $mitad; $i -gt 0; $i--) {
            $p = $i / $mitad
            $r = [int]($t.GradientEnd[0] + ($t.GradientStart[0] - $t.GradientEnd[0]) * $p)
            $g = [int]($t.GradientEnd[1] + ($t.GradientStart[1] - $t.GradientEnd[1]) * $p)
            $b = [int]($t.GradientEnd[2] + ($t.GradientStart[2] - $t.GradientEnd[2]) * $p)
            $null = $sb.Append("$(FG $r $g $b)$([string][char]0x2500)${rs}")
        }
        $null = $sb.Append("$(FG $t.GradientStart[0] $t.GradientStart[1] $t.GradientStart[2])◂${rs}")
        Write-Host $sb.ToString()
        $linesDrawn++

        # Footer
        $footer = "  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)↑↓${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])navegar${rs}  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)ESPACIO${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])toggle${rs}  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)↵${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])confirmar${rs}  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])$(BLD)ESC${rs} $(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2])cancelar${rs}"
        Write-Host "`r$footer"
        $linesDrawn++

        return $linesDrawn
    }

    # Initial draw
    Show-RyuHeader -SubTitulo $SubTitulo
    Write-Host "`r  $(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])$(BLD)$Titulo${rs}"
    Write-Host "`r  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])↑↓ navegar  ESPACIO toggle  ↵ confirmar  ESC cancelar${rs}"
    Write-Host ''
    $menuStartY = [Console]::CursorTop
    $lastLines = Draw-MultiMenu

    while ($true) {
        $k = [Console]::ReadKey($true)

        switch ($k.Key) {
            'UpArrow'   { $cursor = [Math]::Max(0, $cursor - 1) }
            'DownArrow' { $cursor = [Math]::Min($total - 1, $cursor + 1) }
            'Enter'     { return $Seleccionadas }
            'Escape'    { return $null }
            'F5'        { Clear-Host; Show-RyuHeader -SubTitulo $SubTitulo; Write-Host "`r  $(FG $t.Primary[0] $t.Primary[1] $t.Primary[2])$(BLD)$Titulo${rs}"; Write-Host "`r  $(FG $t.TextMuted[0] $t.TextMuted[1] $t.TextMuted[2])↑↓ navegar  ESPACIO toggle  ↵ confirmar  ESC cancelar${rs}"; Write-Host ''; $menuStartY = [Console]::CursorTop; $lastLines = Draw-MultiMenu; continue }
        }
        if ($k.KeyChar -eq ' ') { $Seleccionadas[$cursor] = -not $Seleccionadas[$cursor] }

        # Viewport scroll
        if ($total -gt $maxVis) {
            if ($cursor -lt $scrollOffset) { $scrollOffset = $cursor }
            if ($cursor -ge $scrollOffset + $maxVis) { $scrollOffset = $cursor - $maxVis + 1 }
        }

        # Clear only the lines that were drawn, then redraw
        [Console]::SetCursorPosition(0, $menuStartY)
        for ($c = 0; $c -lt $lastLines; $c++) { Write-Host "`r$(' ' * $ancho)" }
        [Console]::SetCursorPosition(0, $menuStartY)
        $lastLines = Draw-MultiMenu
    }
}

# ─── CONFIRM DIALOG ───────────────────────────────────────────

function Show-Confirm {
    param([Parameter(Mandatory)][string]$Mensaje, [string]$Detalle = '', [int[]]$ColorAdvertencia)
    $t = GetT
    if (-not $ColorAdvertencia) { $ColorAdvertencia = $t.Warning }
    $ancho = 56; $pad = '  '; $rs = (RST)
    $cb = (FG $t.Border[0] $t.Border[1] $t.Border[2])
    $ct = (FG $ColorAdvertencia[0] $ColorAdvertencia[1] $ColorAdvertencia[2])

    Write-Host ''
    Write-Host "${pad}${cb}┌$(([string][char]0x2500) * $ancho)┐${rs}"
    $tf = " ⚠  $Mensaje "; $lp = [Math]::Max(0, [Math]::Floor(($ancho - $tf.Length) / 2))
    $rp = [Math]::Max(0, $ancho - $tf.Length - $lp)
    Write-Host "${pad}${cb}│${rs}$(' ' * $lp)${ct}${tf}${rs}$(' ' * $rp)${cb}│${rs}"

    if ($Detalle) {
        Write-Host "${pad}${cb}├$(([string][char]0x2500) * $ancho)┤${rs}"
        $lineas = [System.Collections.ArrayList]::new()
        $palabras = $Detalle -split ' '; $la = ''
        foreach ($p in $palabras) {
            if (($la + ' ' + $p).Trim().Length -gt ($ancho - 4)) { $null = $lineas.Add($la.Trim()); $la = $p }
            else { $la = if ($la) { "$la $p" } else { $p } }
        }
        if ($la.Trim()) { $null = $lineas.Add($la.Trim()) }
        foreach ($l in $lineas) {
            $rell = $ancho - $l.Length
            Write-Host "${pad}${cb}│${rs}  ${ct}$l${rs}$(' ' * [Math]::Max(0,$rell - 2)) ${cb}│${rs}"
        }
    }

    Write-Host "${pad}${cb}├$(([string][char]0x2500) * $ancho)┤${rs}"
    $btnSi = "$(FG $t.Success[0] $t.Success[1] $t.Success[2])$(BLD) ✦ Sí [S] ${rs}"
    $btnNo = "$(FG $t.Error[0] $t.Error[1] $t.Error[2])$(BLD) ✗ No [N] ${rs}"
    $bLen = 24; $libre = $ancho - $bLen; $bPad = [Math]::Floor($libre / 2); $bSpl = $libre - $bPad
    Write-Host "${pad}${cb}│${rs}$(' ' * $bPad)${btnSi} ${btnNo}$(' ' * [Math]::Max(0,$bSpl - 2))${cb}│${rs}"
    Write-Host "${pad}${cb}└$(([string][char]0x2500) * $ancho)┘${rs}"
    Write-Host ''

    while ($true) {
        $k = [Console]::ReadKey($true)
        switch ($k.KeyChar.ToString().ToUpper()) { 'S' { return $true } 'N' { return $false } }
        if ($k.Key -eq 'Escape') { return $false }
    }
}

# ─── MODAL DIALOG ─────────────────────────────────────────────

function Show-RyuModal {
    param(
        [Parameter(Mandatory)][string]$Titulo, [string[]]$Lineas = @(),
        [string]$BotonIzq = 'Aceptar', [string]$BotonDer = '',
        [int[]]$ColorTitulo, [int]$Ancho = 60
    )
    $t = GetT
    if (-not $ColorTitulo) { $ColorTitulo = $t.Primary }
    $pad = '  '; $rs = (RST)
    $cb = (FG $t.Border[0] $t.Border[1] $t.Border[2])
    $ct = (FG $ColorTitulo[0] $ColorTitulo[1] $ColorTitulo[2])
    $cc = (FG $t.TextPrimary[0] $t.TextPrimary[1] $t.TextPrimary[2])

    Write-Host ''
    Write-Host "${pad}${cb}╔$(([string][char]0x2550) * $Ancho)╗${rs}"
    $tf = " $Titulo "; $lp = [Math]::Max(0, [Math]::Floor(($Ancho - $tf.Length) / 2))
    $rp = [Math]::Max(0, $Ancho - $tf.Length - $lp)
    Write-Host "${pad}${cb}║${rs}$(' ' * $lp)${ct}${tf}${rs}$(' ' * $rp)${cb}║${rs}"
    Write-Host "${pad}${cb}╠$(([string][char]0x2550) * $Ancho)╣${rs}"

    foreach ($linea in $Lineas) {
        $vis = ($linea -replace "`e\[[0-9;]*m", '')
        $rell = [Math]::Max(0, $Ancho - $vis.Length - 2)
        Write-Host "${pad}${cb}║${rs} ${cc}${linea}${rs}$(' ' * $rell) ${cb}║${rs}"
    }

    if ($BotonIzq -or $BotonDer) {
        Write-Host "${pad}${cb}╠$(([string][char]0x2550) * $Ancho)╣${rs}"
        $bI = if ($BotonIzq) { "$(FG $t.Success[0] $t.Success[1] $t.Success[2])$(BLD) ◆ $BotonIzq ${rs}" } else { '' }
        $bD = if ($BotonDer) { "$(FG $t.TextSecondary[0] $t.TextSecondary[1] $t.TextSecondary[2]) ◇ $BotonDer ${rs}" } else { '' }
        $bl = ($BotonIzq.Length + 4) + ($BotonDer.Length + 4) + 2; $lb = $Ancho - $bl
        $bp = [Math]::Floor($lb / 2); $bs = $lb - $bp
        Write-Host "${pad}${cb}║${rs}$(' ' * $bp)${bI} ${bD}$(' ' * [Math]::Max(0,$bs))${cb}║${rs}"
    }

    Write-Host "${pad}${cb}╚$(([string][char]0x2550) * $Ancho)╝${rs}"
    Write-Host ''
}

# ─── PAUSE PROMPT ─────────────────────────────────────────────

function Show-PausePrompt {
    param([string]$Mensaje = 'presiona cualquier tecla para continuar...')
    $t = GetT
    Write-Host ''
    Write-Rgb -Texto "  ▸ $Mensaje" -Color $t.TextSecondary -Apagado
    $null = [Console]::ReadKey($true)
}

# ─── STATUS MESSAGE ───────────────────────────────────────────

function Write-StatusMsg {
    param([Parameter(Mandatory)][string]$Mensaje, [ValidateSet('INFO','EXITO','ADVERTENCIA','ERROR')][string]$Tipo = 'INFO')
    $t = GetT
    $cfg = @{
        'INFO'        = @{ Icono = '●'; Color = $t.Info }
        'EXITO'       = @{ Icono = '✓'; Color = $t.Success }
        'ADVERTENCIA' = @{ Icono = '▲'; Color = $t.Warning }
        'ERROR'       = @{ Icono = '✖'; Color = $t.Error }
    }
    $c = $cfg[$Tipo]
    Write-Rgb -Texto "  $($c.Icono)  $Mensaje" -Color $c.Color
}

# ─── SETTINGS MENU ────────────────────────────────────────────

function Show-RyuSettings {
    $t = GetT; $settings = Get-Settings
    $nombresTemas = Get-NombresTemas
    $temaIdx = 0

    while ($true) {
        $ops = @(
            "Tema:         [$($settings.TemaNombre)]",
            "Fuente:       [$($settings.Fuente)]",
            "Tamaño:       [$($settings.TamanoFuente)pt]",
            "Animaciones:  [$(if ($settings.Animaciones) { 'On' } else { 'Off' })]",
            "Shimmer:      [$(if ($settings.Shimmer) { 'On' } else { 'Off' })]",
            "CRT Effect:   [$(if ($settings.CRTEffect) { 'On' } else { 'Off' })]",
            "Bar Style:    [$($settings.BarStyle)]"
        )

        $sel = Show-RyuMenu -Titulo 'Configuración' -Opciones $ops -SubTitulo 'Ajustes en tiempo real'
        if ($sel -eq 0) { return }

        switch ($sel) {
            1 {
                $temaIdx = ($temaIdx + 1) % $nombresTemas.Count
                Set-Tema -Nombre $nombresTemas[$temaIdx]
                Write-Notification -Mensaje "Tema cambiado a: $($nombresTemas[$temaIdx])" -Tipo 'EXITO'
                Start-Sleep -Milliseconds 800
            }
            4 { Set-Setting -Clave 'Animaciones' -Valor (-not $settings.Animaciones) }
            5 { Set-Setting -Clave 'Shimmer' -Valor (-not $settings.Shimmer) }
            6 { Set-Setting -Clave 'CRTEffect' -Valor (-not $settings.CRTEffect) }
            7 {
                $styles = @('gradient','solid','dots')
                $currentIdx = $styles.IndexOf($settings.BarStyle)
                $nextIdx = ($currentIdx + 1) % $styles.Count
                Set-Setting -Clave 'BarStyle' -Valor $styles[$nextIdx]
            }
        }
    }
}

# ─── ALIASES DE COMPATIBILIDAD ────────────────────────────────

Set-Alias -Name Show-NexusHeader  -Value Show-RyuHeader
Set-Alias -Name Show-NexusMenu    -Value Show-RyuMenu
Set-Alias -Name Write-NexusProgress -Value Write-RGBBar
Set-Alias -Name Complete-NexusProgress -Value Complete-RyuProgress

function Write-RyuProgress { Write-RGBBar @args }
function Complete-RyuProgress {
    param([string]$Mensaje = 'completado')
    $t = GetT
    Write-Host ''
    Write-Rgb -Texto "  ✓ $Mensaje" -Color $t.Success -Negrita
}

# ─── EXPORTS ──────────────────────────────────────────────────

Export-ModuleMember -Function @(
    'GetT',
    'FG', 'RST', 'BLD', 'BG',
    'Get-RgbString','Get-GradientString',
    'Write-Rgb','Write-Gradient','Write-WaveGradient',
    'Write-Box','Write-Separator','Write-Tile','Write-MetricCard',
    'Write-RGBBar','Write-Sparkline','Write-Gauge','Write-BarChart',
    'Write-Shimmer','Write-CRT','Write-RGBWave',
    'Write-Notification','Write-StatusMsg',
    'Show-SplashScreen','Show-Spinner','Invoke-ScreenTransition',
    'Show-RyuHeader','Show-RyuFooter','Show-RyuMenu','Show-RyuMultiMenu',
    'Show-Confirm','Show-RyuModal','Show-PausePrompt',
    'Show-RyuSettings',
    'Write-RyuProgress','Complete-RyuProgress',
    'Show-NexusHeader','Show-NexusMenu','Write-NexusProgress','Complete-NexusProgress'
)
Export-ModuleMember -Alias @(
    'Show-NexusHeader','Show-NexusMenu','Write-NexusProgress','Complete-NexusProgress'
)
