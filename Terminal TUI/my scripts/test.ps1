# ==============================================================================
# DEEP SYSTEM RECONNAISSANCE & MODULAR BENCHMARK ENGINE + TIER LIST GENERATOR
# ==============================================================================
& {
    $ErrorActionPreference = "Stop"
    [System.Console]::Clear()

    try {
        $host.UI.RawUI.WindowTitle = "Advanced Hardware Matrix & Tier List Diagnostics v5.0"

        # --- ASCII Art Elegante ---
        $ascii = @'
 â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
â–ˆâ–ˆâ•”â•â•â•â•â•â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â•â•â•â–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ•‘â•šâ•â•â–ˆâ–ˆâ•”â•â•â•â–ˆâ–ˆâ•”â•â•â•â•â•
â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â–ˆâ–ˆâ–ˆâ–ˆâ•”â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â–ˆâ–ˆâ•— â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ•”â–ˆâ–ˆâ•— â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘
â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â•â• â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•â•â•  â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘   â•šâ•â•â•â•â–ˆâ–ˆâ•‘
â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘ â•šâ•â• â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘     â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•â–ˆâ–ˆâ•‘ â•šâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘ â•šâ–ˆâ–ˆâ–ˆâ–ˆâ•‘   â•šâ•â•   â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘
 â•šâ•â•â•â•â•â• â•šâ•â•â•â•â•â• â•šâ•â•     â•šâ•â•â•šâ•â•      â•šâ•â•â•â•â•â• â•šâ•â•  â•šâ•â•â•â•â•šâ•â•â•â•â•â•â•â•šâ•â•  â•šâ•â•â•â•   â•šâ•â•   â•šâ•â•â•â•â•â•â•
 ðŸ“Š DEEP HARDWARE RECONNAISSANCE & TIER LIST VALIDATOR â€¢ ENGINE v7.x
'@
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan
        [System.Console]::WriteLine($ascii)
        [System.Console]::ForegroundColor = [System.ConsoleColor]::DarkGray
        [System.Console]::WriteLine(("â•" * 90))

        # --- 1. EXTRACCIÃ“N Y TELEMETRÃA PROFUNDA ---
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
        [System.Console]::WriteLine(" [+] [INIT] Escaneando capas de Hardware (Interno y Externo)...`n")

        $osData = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        $boardData = Get-CimInstance -ClassName Win32_BaseBoard -ErrorAction SilentlyContinue
        
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue
        $cpuName = if ($null -ne $cpu) { $cpu.Name.Trim() } else { "Desconocido" }
        $cpuCores = if ($null -ne $cpu) { $cpu.NumberOfCores } else { 0 }
        $cpuLogical = if ($null -ne $cpu) { $cpu.NumberOfLogicalProcessors } else { 0 }

        $ramChips = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction SilentlyContinue
        $ramTotalBytes = if ($ramChips) { ($ramChips | Measure-Object -Property Capacity -Sum).Sum } else { 0 }
        $ramGB = if ($ramTotalBytes -gt 0) { [Math]::Round($ramTotalBytes / 1GB, 1) } else { 0 }
        
        $ramSpeed = if ($ramChips) { ($ramChips | Select-Object -First 1).Speed } else { 0 }
        $ddrType = "DDR"
        if ($ramSpeed -gt 4800) { $ddrType = "DDR5" }
        elseif ($ramSpeed -gt 2133) { $ddrType = "DDR4" }
        elseif ($ramSpeed -gt 1066) { $ddrType = "DDR3" }

        $gpuData = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue
        $gpuName = if ($gpuData) { ($gpuData | ForEach-Object { if($_.Name){$_.Name.Trim()}else{"GenÃ©rica"} }) -join " / " } else { "GrÃ¡ficos Integrados" }
        $gpuRes = if ($gpuData) { ($gpuData | Select-Object -First 1).VideoModeDescription } else { "N/A" }

        $disks = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction SilentlyContinue
        $diskList = [System.Collections.Generic.List[string]]::new()
        if ($disks) {
            foreach ($d in $disks) {
                $sizeGb = if($d.Size){ [Math]::Round($d.Size / 1GB, 1) } else { 0 }
                $type = if ($d.MediaType -match "Fixed") { "SSD/HDD Interno" } else { "Externo/Removible" }
                $model = if($d.Model){ $d.Model.Trim() } else { "Disco Desconocido" }
                $diskList.Add("$model ($sizeGb GB | $type)")
            }
        } else {
            $diskList.Add("No se detectaron discos dinÃ¡micos")
        }

        $monitors = Get-CimInstance -ClassName Win32_DesktopMonitor -ErrorAction SilentlyContinue
        $monitorCount = if ($monitors) { @($monitors).Count } else { 1 }

        # --- PARSER SEGURO PARA TERMINALES (Evita desbordamiento de Substring) ---
        function Get-SafeLine ($text, $width = 60) {
            if ($null -eq $text) { $text = "N/A" }
            $rawStr = $text.ToString()
            if ($rawStr.Length -gt $width) {
                return $rawStr.Substring(0, $width)
            }
            return $rawStr.PadRight($width)
        }

        # --- DISPLAY COMPONENTES ---
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan
        [System.Console]::WriteLine(" â•”" + "â•" * 33 + " [ HARDWARE MATRIX ] " + "â•" * 34 + "â•—")
        [System.Console]::ForegroundColor = [System.ConsoleColor]::White
        
        $osString = if($osData){ $osData.Caption } else { "Desconocido" }
        $moboString = if($boardData){ "$($boardData.Manufacturer) $($boardData.Product)" } else { "Desconocido" }

        [System.Console]::WriteLine(" â•‘  â€¢ SISTEMA OPERATIVO : " + (Get-SafeLine $osString) + " â•‘")
        [System.Console]::WriteLine(" â•‘  â€¢ PLACA BASE (MOBO) : " + (Get-SafeLine $moboString) + " â•‘")
        [System.Console]::WriteLine(" â•‘  â€¢ PROCESADOR (CPU)  : " + (Get-SafeLine "$cpuName ($cpuCores NÃºcleos / $cpuLogical Hilos)") + " â•‘")
        [System.Console]::WriteLine(" â•‘  â€¢ MEMORIA RAM       : " + (Get-SafeLine "$ramGB GB $ddrType @ $ramSpeed MHz") + " â•‘")
        [System.Console]::WriteLine(" â•‘  â€¢ GRÃFICOS (GPU)    : " + (Get-SafeLine $gpuName) + " â•‘")
        [System.Console]::WriteLine(" â•‘  â€¢ RESOLUCIÃ“N PRINC. : " + (Get-SafeLine $gpuRes) + " â•‘")
        
        $idx = 1
        foreach ($disk in $diskList) {
            [System.Console]::WriteLine(" â•‘  â€¢ ALMACENAMIENTO $idx : " + (Get-SafeLine $disk) + " â•‘")
            $idx++
        }
        [System.Console]::WriteLine(" â•‘  â€¢ PERIFÃ‰RICOS PANT. : " + (Get-SafeLine "$monitorCount Monitor(es) detectado(s)") + " â•‘")
        
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan
        [System.Console]::WriteLine(" â•š" + "â•" * 88 + "â•")
        [System.Console]::ForegroundColor = [System.ConsoleColor]::DarkGray
        [System.Console]::WriteLine(("â•" * 90))

        # --- 2. MODULAR BENCHMARK (TESTEO DE RENDIMIENTO) ---
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
        [System.Console]::WriteLine(" [+] [BENCHMARK] Evaluando componentes contra la GeneraciÃ³n Actual...")
        [System.Console]::ForegroundColor = [System.ConsoleColor]::DarkGray
        [System.Console]::WriteLine("     [!] Estresando la arquitectura... Espera 10 segundos.")

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $iterations = 0L
        $seed = 8743.9213

        while ($stopwatch.Elapsed.TotalSeconds -lt 10) {
            [Math]::Sqrt([Math]::Exp([Math]::Log([Math]::Pow($seed, 3)))) | Out-Null
            $iterations++
        }
        $stopwatch.Stop()

        # --- 3. ALGORITMO DE CALIFICACIÃ“N ---
        $cpuScore = [Math]::Round(($iterations / 140000), 1)
        if ($cpuScore -gt 10.0) { $cpuScore = 10.0 } elseif ($cpuScore -lt 1.0) { $cpuScore = 1.0 }

        $baseRamScore = ($ramGB / 4)
        if ($ddrType -eq "DDR5") { $baseRamScore += 1.5 }
        if ($ramSpeed -ge 5200) { $baseRamScore += 0.5 }
        $ramScore = [Math]::Round($baseRamScore, 1)
        if ($ramScore -gt 10.0) { $ramScore = 10.0 } elseif ($ramScore -lt 1.0) { $ramScore = 1.0 }

        $gpuScore = 4.0
        if ($gpuName -match "RTX 40" -or $gpuName -match "RX 7000" -or $gpuName -match "RTX 50") { $gpuScore = 9.8 }
        elseif ($gpuName -match "RTX 30" -or $gpuName -match "RX 6000") { $gpuScore = 8.2 }
        elseif ($gpuName -match "GTX" -or $gpuName -match "RX 500") { $gpuScore = 5.0 }
        elseif ($gpuName -match "Intel" -or $gpuName -match "Radeon") { $gpuScore = 4.0 }
        
        $stScore = 6.0
        if (($diskList -join " ") -match "NVMe" -or ($diskList -join " ") -match "SSD") { $stScore = 9.0 }
        if (($diskList -join " ") -match "SATA") { $stScore = 7.0 }

        $globalScore = [Math]::Round((($cpuScore * 0.35) + ($gpuScore * 0.35) + ($ramScore * 0.15) + ($stScore * 0.15)), 1)

        # --- 4. ASIGNACIÃ“N DINÃMICA DE TIER LIST + ARGUMENTACIÃ“N ---
        $tierLetter = "D"
        $tierColor = [System.ConsoleColor]::Red
        $argumento = ""

        if ($globalScore -ge 9.0) {
            $tierLetter = "TIER S (ENTUSIASTA / TOP GENERACIÃ“N)"
            $tierColor = [System.ConsoleColor]::Magenta
            $argumento = "Hardware de vanguardia. Tu CPU rompiÃ³ la escala FPU, tienes memoria ultrarrÃ¡pida ($ddrType) y grÃ¡ficos preparados para cualquier carga moderna en resoluciones masivas. Cero cuellos de botella significativos."
        }
        elseif ($globalScore -ge 7.5) {
            $tierLetter = "TIER A (ALTO RENDIMIENTO / ELITE)"
            $tierColor = [System.ConsoleColor]::Cyan
            $argumento = "Excelente balance de hardware de gama alta. Capaz de ejecutar software demandante y streaming sin inmutarse. Se sitÃºa cÃ³modamente sobre el 80% de los ordenadores del mercado global actual."
        }
        elseif ($globalScore -ge 5.5) {
            $tierLetter = "TIER B (ESTÃNDAR COMPETITIVO / MEDIA)"
            $tierColor = [System.ConsoleColor]::Green
            $argumento = "Gama media perfectamente equilibrada. Ideal para multitarea estÃ¡ndar y flujos de trabajo convencionales. Tu RAM ($ramGB GB) o GPU imponen un lÃ­mite sano pero muy solvente frente a la generaciÃ³n actual."
        }
        elseif ($globalScore -ge 4.0) {
            $tierLetter = "TIER C (ENTRADA / LEGADO)"
            $tierColor = [System.ConsoleColor]::Yellow
            $argumento = "Equipo funcional orientado a tareas bÃ¡sicas u ofimÃ¡tica. Los puntajes de CPU/GPU denotan que la arquitectura pertenece a generaciones pasadas o utiliza grÃ¡ficos integrados, limitando procesos pesados."
        }
        else {
            $tierLetter = "TIER D (REQUERIRÃ ACTUALIZACIÃ“N)"
            $tierColor = [System.ConsoleColor]::Red
            $argumento = "Hardware crÃ­tico para los estÃ¡ndares tecnolÃ³gicos vigentes. La escasez de RAM, la velocidad del bus de datos o una CPU saturada requerirÃ¡n una renovaciÃ³n para correr aplicaciones fluidas."
        }

        # --- 5. PANEL DE RENDIMIENTO GRANULAR PROTEGIDO ---
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
        [System.Console]::WriteLine("`n â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”")
        [System.Console]::WriteLine(" â”‚                           MÃ‰TRICAS DE RENDIMIENTO GRANULAR (1/10)                       â”‚")
        [System.Console]::WriteLine(" â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤")
        
        [System.Console]::ForegroundColor = [System.ConsoleColor]::White
        [System.Console]::WriteLine(" â”‚   â€¢ PROCESADOR (CPU)        : [ " + $cpuScore.ToString("F1").PadLeft(4) + " / 10.0 ]" + (" " * 49) + "â”‚")
        [System.Console]::WriteLine(" â”‚   â€¢ MEMORIA RAM (" + $ddrType.PadRight(4) + ")     : [ " + $ramScore.ToString("F1").PadLeft(4) + " / 10.0 ]" + (" " * 49) + "â”‚")
        [System.Console]::WriteLine(" â”‚   â€¢ TARJETA GRÃFICA (GPU)   : [ " + $gpuScore.ToString("F1").PadLeft(4) + " / 10.0 ]" + (" " * 49) + "â”‚")
        [System.Console]::WriteLine(" â”‚   â€¢ ALMACENAMIENTO          : [ " + $stScore.ToString("F1").PadLeft(4) + " / 10.0 ]" + (" " * 49) + "â”‚")
        
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
        [System.Console]::WriteLine(" â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤")
        
        # Fila de Score Global Ponderado
        [System.Console]::Write(" â”‚")
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Magenta
        $globalString = "   >> PUNTAJE GLOBAL INDEXADO: [ $globalScore / 10.0 ]"
        [System.Console]::Write($globalString.PadRight(88))
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
        [System.Console]::WriteLine("â”‚")
        
        [System.Console]::WriteLine(" â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤")
        
        # Fila del TIER LIST
        [System.Console]::Write(" â”‚")
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
        [System.Console]::Write("   >> ESTADO EN LA TIER LIST:  ")
        [System.Console]::ForegroundColor = $tierColor
        [System.Console]::Write($tierLetter.PadRight(61))
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
        [System.Console]::WriteLine("â”‚")

        # Fila de la ArgumentaciÃ³n TÃ©cnica REPARADA BAJO FILOSOFÃA CLI
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
        [System.Console]::WriteLine(" â”‚                                                                                        â”‚")
        
        $textoCompleto = "ARGUMENTACIÃ“N TÃ‰CNICA: " + $argumento
        while ($textoCompleto.Length -gt 0) {
            $chunkSize = if ($textoCompleto.Length -le 82) { $textoCompleto.Length } else { 82 }
            $linea = $textoCompleto.Substring(0, $chunkSize)
            
            [System.Console]::Write(" â”‚   ")
            [System.Console]::ForegroundColor = [System.ConsoleColor]::White
            [System.Console]::Write($linea.PadRight(82))
            [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
            [System.Console]::WriteLine("â”‚")
            
            $textoCompleto = $textoCompleto.Substring($chunkSize)
        }

        [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
        [System.Console]::WriteLine(" â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜")

    } catch {
        # Debugging Hash de Excepciones para rastrear lÃ­neas exactas si algo falla internamente
        [System.Console]::ForegroundColor = [System.ConsoleColor]::Red
        [System.Console]::WriteLine("`n[!] ERROR CRÃTICO DEL SISTEMA")
        [System.Console]::WriteLine(" Mensaje: " + $_.Exception.Message)
        [System.Console]::WriteLine(" LÃ­nea detectada: " + $_.InvocationInfo.ScriptLineNumber)
    } finally {
        [System.Console]::ForegroundColor = [System.ConsoleColor]::White
        [System.Console]::BackgroundColor = [System.ConsoleColor]::DarkBlue
        [System.Console]::WriteLine("`n â”€â”€> DIAGNÃ“STICO COMPLETADO. Presiona ENTER para cerrar la ventana de forma segura. <â”€â”€ ")
        [System.Console]::ResetColor()
        $null = Read-Host
    }
}
