pregunta 1
Ya cambiaste tu nombre de perfil a "Riutexu" o sigue siendo "hecto"?


instalaciÃ³n de OhMyPosh

â–¶ winget install ohmyposh -s winget 
â–¶ winget install JanDeDobbeleer.OhMyPosh --source winget
â–¶ (& 'C:\Users\hecto\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe' init pwsh --config='C:\Users\hecto\AppData\Local\Programs\oh-my-posh\themes\jandedobbeleer.omp.json' --print) -join "`n" | Invoke-Expression
â–¶ (& 'C:\Users\hecto\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe' init pwsh --config='C:\Users\hecto\AppData\Local\Programs\oh-my-posh\themes\tokyonight_storm.omp.json' --print) -join "`n" | Invoke-Expression
â–¶ Install-Module -Name Terminal-Icons -Repository PSGallery
â–¶ Set-PSReadLineOption -PredictionViewStyle ListView

instalaciÃ³n de FastFetch

â–¶ clear
â–¶ winget install fastfetch
â–¶ Crear carpeta oculta llamada ".config"
â–¶ Crear dentro de esa carpeta otra carpeta llamada "fastfetch"
â–¶ meter los archivos ".txt" y ".jsonc" del repositorio "https://github.com/SleepyCatHey/Ultimate-Win11-Setup/tree/main/Fastfetch"
â–¶al finalizar vas a escribir en el "Notepad $PROFILE" los siguientes comandos:
# 1. Cargar Oh My Posh de forma mÃ¡s segura
$ompPath = 'C:\Users\hecto\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe'
$themePath = 'C:\Users\hecto\AppData\Local\Programs\oh-my-posh\themes\tokyonight_storm.omp.json'

if (Test-Path $ompPath) {
    & $ompPath init pwsh --config $themePath | Invoke-Expression
}

# 2. MÃ³dulos esenciales
Import-Module Terminal-Icons

# 3. ConfiguraciÃ³n de PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView

# 4. Fastfetch con validaciÃ³n (Esto evitarÃ¡ el error molesto)
$fastfetchPath = "C:\Users\hecto\AppData\Local\Microsoft\WinGet\Links\fastfetch.exe"

if (Test-Path $fastfetchPath) {
    & $fastfetchPath
} else {
    Write-Host "Fastfetch no encontrado. Verifica la ruta." -ForegroundColor Yellow
}
â–¶Mostrar un ASCII art bonito de que instalaciÃ³n fue completada
