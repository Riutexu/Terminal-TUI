#Requires -Version 7.0
<#
.SYNOPSIS
    RYU-TUI — Activador de Windows.
.DESCRIPTION
    Activación de Windows 10/11 via Microsoft Activation Scripts (MAS).
#>

Set-StrictMode -Version Latest

function Start-RyuActivator {
    $t = GetT
    Invoke-ScreenTransition -Titulo 'Activar Windows'
    Write-RyuLog -Mensaje 'Iniciando activador de Windows' -Nivel 'INFO' -Modulo 'WindowsActivator'

    # ─── VERIFICAR ESTADO ACTUAL ────────────────────
    Write-StatusMsg -Mensaje 'Verificando estado de activación...' -Tipo 'INFO'
    $licencia = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.LicenseStatus -eq 1 } | Select-Object -First 1
    $os = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -First 1

    $estadoActual = if ($licencia) { "Activado — $($licencia.Name)" } else { "No activado — $($os.Caption)" }

    # ─── INFORMACIÓN DE LICENCIA ────────────────────
    $slmgr = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1
    $claveParcial = if ($slmgr -match 'parcial de la clave: (\S+)') { $Matches[1] } else { 'N/A' }
    $canal = if ($slmgr -match 'canal de licenciamiento: (\S+)') { $Matches[1] } else { 'N/A' }

    # ─── MOSTRAR ESTADO ─────────────────────────────
    Write-Host ''
    Show-RyuModal -Titulo 'Estado de Windows' -Lineas @(
        "▸ $($os.Caption)",
        "▸ $($os.OSArchitecture)",
        "▸ Edición: $($os.Caption)",
        "▸ Clave parcial: $claveParcial",
        "▸ Canal: $canal",
        "▸ Estado: $estadoActual"
    ) -ColorTitulo $(if ($licencia) { $t.Success } else { $t.Warning })

    if ($licencia) {
        Write-StatusMsg -Mensaje 'Windows ya está activado' -Tipo 'EXITO'
        Show-PausePrompt
        return
    }

    # ─── OPCIONES DE ACTIVACIÓN ─────────────────────
    $opciones = @(
        'Activar con clave de producto (KMS)',
        'Activar con licencia digital',
        'Verificar estado de activación'
    )

    $seleccion = Show-RyuMenu -Titulo 'Método de activación' -Opciones $opciones -Iconos @('◆','◇','▣') -Descripciones @(
        'Usa servidor KMS para activación',
        'Busca licencia digital vinculada a la cuenta',
        'Solo verificar el estado actual'
    )

    if ($seleccion -eq 0) {
        Write-StatusMsg -Mensaje 'Activación cancelada' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    # ─── CONFIRMAR ──────────────────────────────────
    $confirm = Show-Confirm -Mensaje '¿Continuar con la activación?' -Detalle 'Se aplicará el método de activación seleccionado. Esto puede requerir conexión a internet.'
    if (-not $confirm) {
        Write-StatusMsg -Mensaje 'Activación cancelada' -Tipo 'ADVERTENCIA'
        Show-PausePrompt
        return
    }

    switch ($seleccion) {
        1 {
            # KMS
            Write-StatusMsg -Mensaje 'Activando con método KMS...' -Tipo 'INFO'
            try {
                $resultado = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /skms 'kms.msguides.com' 2>&1
                Start-Sleep -Seconds 2
                $resultado = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /ato 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-StatusMsg -Mensaje 'Activación KMS completada exitosamente' -Tipo 'EXITO'
                } else {
                    Write-StatusMsg -Mensaje 'Error durante la activación KMS' -Tipo 'ERROR'
                }
            } catch {
                Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
            }
        }
        2 {
            # Licencia digital
            Write-StatusMsg -Mensaje 'Buscando licencia digital...' -Tipo 'INFO'
            try {
                $resultado = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dti 2>&1
                Write-StatusMsg -Mensaje 'Búsqueda de licencia digital completada' -Tipo 'EXITO'
            } catch {
                Write-StatusMsg -Mensaje "Error: $($_.Exception.Message)" -Tipo 'ERROR'
            }
        }
        3 {
            # Verificar
            Write-StatusMsg -Mensaje 'Verificando estado...' -Tipo 'INFO'
            & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli
        }
    }

    Write-RyuLog -Mensaje 'Proceso de activación completado' -Nivel 'EXITO' -Modulo 'WindowsActivator'
    Show-PausePrompt
}

Export-ModuleMember -Function @('Start-RyuActivator')
