#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Provisionador de sistema.
.DESCRIPTION
    Instala software esencial del sistema: navegadores, utilidades, codecs, etc.
#>

Set-StrictMode -Version Latest

function Test-AdminRequired {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Start-RyuProvisioner {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Provisionar Sistema'
    Write-RyuLog -Mensaje 'Iniciando provisionamiento del sistema' -Nivel 'INFO' -Modulo 'SystemProvisioner'

    if (-not (Test-AdminRequired)) {
        Write-StatusMsg -Mensaje 'Se requieren privilegios de administrador para provisionar el sistema' -Tipo 'ERROR'
        Show-PausePrompt
        return
    }

    # ─── CATEGORÍAS DE SOFTWARE ─────────────────────
    $categorias = @(
        @{
            Nombre = 'Navegadores'
            Paquetes = @(
                @{ Id = 'Google.Chrome';         Nombre = 'Google Chrome' },
                @{ Id = 'Mozilla.Firefox';       Nombre = 'Mozilla Firefox' },
                @{ Id = 'Microsoft.Edge';        Nombre = 'Microsoft Edge' },
                @{ Id = 'Brave.Brave';           Nombre = 'Brave Browser' }
            )
        },
        @{
            Nombre = 'Utilidades'
            Paquetes = @(
                @{ Id = '7zip.7zip';             Nombre = '7-Zip' },
                @{ Id = 'Notepad++.Notepad++';   Nombre = 'Notepad++' },
                @{ Id = 'Git.Git';               Nombre = 'Git' },
                @{ Id = 'Microsoft.PowerToys';   Nombre = 'PowerToys' }
            )
        },
        @{
            Nombre = 'Multimedia'
            Paquetes = @(
                @{ Id = 'VideoLAN.VLC';          Nombre = 'VLC Media Player' },
                @{ Id = 'GIMP.GIMP';             Nombre = 'GIMP' }
            )
        },
        @{
            Nombre = 'Desarrollo'
            Paquetes = @(
                @{ Id = 'Microsoft.VisualStudioCode'; Nombre = 'Visual Studio Code' },
                @{ Id = 'Python.Python.3.12';         Nombre = 'Python 3.12' },
                @{ Id = 'OpenJS.NodeJS.LTS';          Nombre = 'Node.js LTS' }
            )
        }
    )

    # ─── VERIFICAR WINGET ───────────────────────────
    Write-StatusMsg -Mensaje 'Verificando Windows Package Manager...' -Tipo 'INFO'
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-StatusMsg -Mensaje 'Windows Package Manager (winget) no encontrado' -Tipo 'ERROR'
        Write-StatusMsg -Mensaje 'Instalar winget desde: https://aka.ms/getwinget' -Tipo 'INFO'
        Show-PausePrompt
        return
    }

    # ─── SELECCIONAR CATEGORÍAS ─────────────────────
    $nombresCats = $categorias | ForEach-Object { $_.Nombre }
    $seleccionCat = Show-RyuMenu -Titulo 'Seleccionar categorías a instalar' -Opciones $nombresCats -Iconos @('◈','◆','◇','▣') -Descripciones @(
        'Chrome, Firefox, Edge, Brave',
        '7-Zip, Notepad++, Git, PowerToys',
        'VLC, GIMP',
        'VS Code, Python, Node.js'
    )

    if ($seleccionCat -eq 0) {
        Write-StatusMsg -Mensaje 'Provisionamiento cancelado' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    $catSeleccionada = $categorias[$seleccionCat - 1]
    $paquetes = $catSeleccionada.Paquetes

    # ─── CONFIRMAR E INSTALAR ───────────────────────
    $nombresPaq = $paquetes | ForEach-Object { $_.Nombre }
    $confirm = Show-Confirm -Mensaje "¿Instalar $($catSeleccionada.Nombre)?" -Detalle ($nombresPaq -join ', ')
    if (-not $confirm) {
        Write-StatusMsg -Mensaje 'Instalación cancelada' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    $exitosos = 0
    $fallidos = 0

    foreach ($pkg in $paquetes) {
        Write-StatusMsg -Mensaje "Instalando $($pkg.Nombre)..." -Tipo 'INFO'
        try {
            $resultado = & winget install --id $pkg.Id --accept-package-agreements --accept-source-agreements 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-StatusMsg -Mensaje "$($pkg.Nombre) instalado correctamente" -Tipo 'EXITO'
                $exitosos++
            } else {
                Write-StatusMsg -Mensaje "Error instalando $($pkg.Nombre)" -Tipo 'ERROR'
                $fallidos++
            }
        } catch {
            Write-StatusMsg -Mensaje "Excepción instalando $($pkg.Nombre): $($_.Exception.Message)" -Tipo 'ERROR'
            $fallidos++
        }
    }

    # ─── RESULTADOS ─────────────────────────────────
    Write-Host ''
    Show-RyuModal -Titulo "Provisionamiento: $($catSeleccionada.Nombre)" -Lineas @(
        "▸ Instalados exitosamente: $exitosos",
        "▸ Fallidos: $fallidos",
        "▸ Total paquetes: $($paquetes.Count)"
    ) -ColorTitulo $(if ($fallidos -eq 0) { $t.Success } else { $t.Warning })

    Write-RyuLog -Mensaje "Provisionamiento completado — $exitosos exitosos, $fallidos fallidos" -Nivel 'EXITO' -Modulo 'SystemProvisioner'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Start-RyuProvisioner')
