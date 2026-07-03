$files = Get-ChildItem -Path "C:\Users\hecto\OneDrive\Desktop\Terminal TUI" -Recurse -Include *.ps1,*.psm1

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # 1. Environment variables coalescing
    $content = [regex]::Replace($content, '\$env:([A-Z_]+)\s*\?\?\s*([0-9]+)', '$(if ($env:$1) { $env:$1 } else { $2 })')
    $content = [regex]::Replace($content, '\$env:([A-Z_]+)\s*\?\?\s*(''[^'']*'')', '$(if ($env:$1) { $env:$1 } else { $2 })')
    
    # 2. Network.psm1 property coalescing
    $content = $content -replace '\$data\.country_code \?\? ''''', '$(if ($data.country_code) { $data.country_code } else { '''' })'
    $content = $content -replace '\$data\.country_name \?\? \$data\.country \?\? ''Unknown''', '$(if ($data.country_name) { $data.country_name } elseif ($data.country) { $data.country } else { ''Unknown'' })'
    $content = $content -replace '\$data\.region \?\? ''''', '$(if ($data.region) { $data.region } else { '''' })'
    $content = $content -replace '\$data\.city \?\? ''''', '$(if ($data.city) { $data.city } else { '''' })'
    $content = $content -replace '\$data\.org \?\? \$data\.asn \?\? ''Unknown''', '$(if ($data.org) { $data.org } elseif ($data.asn) { $data.asn } else { ''Unknown'' })'
    
    $content = $content -replace '\$data2\.countryCode \?\? ''''', '$(if ($data2.countryCode) { $data2.countryCode } else { '''' })'
    $content = $content -replace '\$data2\.country \?\? ''Unknown''', '$(if ($data2.country) { $data2.country } else { ''Unknown'' })'
    $content = $content -replace '\$data2\.regionName \?\? ''''', '$(if ($data2.regionName) { $data2.regionName } else { '''' })'
    $content = $content -replace '\$data2\.city \?\? ''''', '$(if ($data2.city) { $data2.city } else { '''' })'
    $content = $content -replace '\$data2\.isp \?\? \$data2\.org \?\? ''Unknown''', '$(if ($data2.isp) { $data2.isp } elseif ($data2.org) { $data2.org } else { ''Unknown'' })'

    # 3. TUI.psm1
    $content = [regex]::Replace($content, '\$NetworkInfo\[''(.*?)''\]\s*\?\?\s*(''[^'']*'')', '$(if ($NetworkInfo[''$1'']) { $NetworkInfo[''$1''] } else { $2 })')

    # 4. HardwareScanner.psm1 null conditional
    $content = $content -replace '\(\$ramChips \| Select-Object -First 1\)\.Speed \?\? 0', '$(if ($ramChips) { $spd = ($ramChips | Select-Object -First 1).Speed; if ($spd) { $spd } else { 0 } } else { 0 })'
    $content = $content -replace '\$t = \$s\?\.ToString\(\) \?\? ''N/A''', '$t = if ($null -ne $s) { $s.ToString() } else { ''N/A'' }'

    # 5. HistoryWiper.psm1
    $content = $content -replace '\(\$historyPath \?\? ''No encontrado''\)', '$(if ($historyPath) { $historyPath } else { ''No encontrado'' })'

    # 6. Win11Debloat count fix
    $content = $content -replace '\$scriptArgs\.Count', '@($scriptArgs).Count'

    # 7. DeepCleaner.psm1 specific string interpolation fix
    $content = $content -replace '"Gestor de archivos grandes \(> \$\(\$env:LARGE_FILE_THRESHOLD_MB \?\? 250\) MB\)"', '"Gestor de archivos grandes (> $(if ($env:LARGE_FILE_THRESHOLD_MB) { $env:LARGE_FILE_THRESHOLD_MB } else { 250 }) MB)"'
    
    # Save back
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

