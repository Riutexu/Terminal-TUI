<div align="center">

                                                                                                                                      
                                                                                                                                      
RRRRRRRRRRRRRRRRR                                                               TTTTTTTTTTTTTTTTTTTTTTTUUUUUUUU     UUUUUUUUIIIIIIIIII
R::::::::::::::::R                                                              T:::::::::::::::::::::TU::::::U     U::::::UI::::::::I
R::::::RRRRRR:::::R                                                             T:::::::::::::::::::::TU::::::U     U::::::UI::::::::I
RR:::::R     R:::::R                                                            T:::::TT:::::::TT:::::TUU:::::U     U:::::UUII::::::II
  R::::R     R:::::Ryyyyyyy           yyyyyyyuuuuuu    uuuuuu                   TTTTTT  T:::::T  TTTTTT U:::::U     U:::::U   I::::I  
  R::::R     R:::::R y:::::y         y:::::y u::::u    u::::u                           T:::::T         U:::::D     D:::::U   I::::I  
  R::::RRRRRR:::::R   y:::::y       y:::::y  u::::u    u::::u                           T:::::T         U:::::D     D:::::U   I::::I  
  R:::::::::::::RR     y:::::y     y:::::y   u::::u    u::::u   ---------------         T:::::T         U:::::D     D:::::U   I::::I  
  R::::RRRRRR:::::R     y:::::y   y:::::y    u::::u    u::::u   -:::::::::::::-         T:::::T         U:::::D     D:::::U   I::::I  
  R::::R     R:::::R     y:::::y y:::::y     u::::u    u::::u   ---------------         T:::::T         U:::::D     D:::::U   I::::I  
  R::::R     R:::::R      y:::::y:::::y      u::::u    u::::u                           T:::::T         U:::::D     D:::::U   I::::I  
  R::::R     R:::::R       y:::::::::y       u:::::uuuu:::::u                           T:::::T         U::::::U   U::::::U   I::::I  
RR:::::R     R:::::R        y:::::::y        u:::::::::::::::uu                       TT:::::::TT       U:::::::UUU:::::::U II::::::II
R::::::R     R:::::R         y:::::y          u:::::::::::::::u                       T:::::::::T        UU:::::::::::::UU  I::::::::I
R::::::R     R:::::R        y:::::y            uu::::::::uu:::u                       T:::::::::T          UU:::::::::UU    I::::::::I
RRRRRRRR     RRRRRRR       y:::::y               uuuuuuuu  uuuu                       TTTTTTTTTTT            UUUUUUUUU      IIIIIIIIII
                          y:::::y                                                                                                     
                         y:::::y                                                                                                      
                        y:::::y                                                                                                       
                       y:::::y                                                                                                        
                      yyyyyyy                                                                                                         
                                                                                                                                      
```

### **Toolkit Profesional de Operaciones del Sistema**

*Motor TUI RGB 24-bit · 13 Temas True Color · 14 Módulos · PowerShell 7+*

<p align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=powershell,windows,git,vscode" />
  </a>
</p>

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-GPLv3-00FFCC?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-3.0-FF6B6B?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Hardened-8B5CF6?style=for-the-badge)

</div>

---

## Que es RYU-TUI

RYU-TUI es un **toolkit profesional de operaciones del sistema** para Windows que unifica 14 herramientas avanzadas de administracion en una interfaz de terminal interactiva con colores RGB de 24 bits.

Construido con una arquitectura **modular y offline-first`, funciona sin conexion a internet. El motor TUI incluye gradientes RGB, efecto shimmer, sparklines, gauge bars, y un dashboard en tiempo real con metricas de CPU, RAM y disco.

---

## Caracteristicas principales

| Caracteristica | Detalle |
|---|---|
| **13 Temas True Color** | Cyberpunk, Matrix, Aurora, Sunset, Neon, Ocean, Fire, Candy, Monokai, Dracula, Solarized, Retro80s, Minimal |
| **Motor TUI RGB** | Gradientes por caracter, wave animation, shimmer, CRT scanlines, sparklines |
| **Dashboard en vivo** | CPU, RAM, Disco, Red con metric cards y barras de progreso |
| **14 Modulos** | Optimizacion, Privacidad, Seguridad, Red, Gaming, Limpieza, Reparacion, Perfiles, Hardware, Disco, Historial, Debloat, Provisioner, Activador |
| **5 Perfiles** | Gaming, Privacy, Balanced, Aggressive, Desktop Lite con undo/restore |
| **Elevacion admin** | Per-module, no al inicio. Solicitud con confirmacion |
| **Multi-select** | Menu con soporte para seleccion multiple y viewport scroll |
| **55 Banderas** | Emoji flags para deteccion automatica de pais |
| **Logger centralizado** | 4 niveles, flush a archivo, limpieza automatica |

---

## Requisitos

- **Windows 10/11**
- **PowerShell 7+** ([instalar](https://github.com/PowerShell/PowerShell/releases))
- **Windows Terminal** ([instalar](https://aka.ms/terminal))

---

## Inicio rapido

```powershell
# Clonar el repositorio
git clone https://github.com/Riutexu/Terminal-TUI.git

# Navegar a la carpeta
cd Terminal-TUI

# Ejecutar
./ryu-tui.ps1
```

> **Nota:** RYU-TUI requiere descarga completa del repositorio. No se puede ejecutar via `curl` o `irm` debido a su arquitectura modular.

---

## Arquitectura

```
Terminal TUI/
├── ryu-tui.ps1                    # Punto de entrada
├── .env.example                   # Plantilla de configuracion
├── LICENSE                        # GPLv3
│
├── modules/
│   ├── core/                      # Framework central
│   │   ├── config.psm1           # 13 temas, ajustes, rutas, red
│   │   ├── TUI.psm1             # Motor de renderizado RGB
│   │   ├── Logger.psm1          # Sistema de logging
│   │   └── Network.psm1         # Resolucion IP/Geo con cache
│   │
│   └── scripts/                   # Modulos de funcion
│       ├── Optimizer.psm1        # CPU/GPU/RAM/Energia/Visual
│       ├── Privacy.psm1          # Telemetry/Copilot/Ads/Edge
│       ├── Security.psm1         # Forense/Persistencia/Credenciales
│       ├── NetworkTweaks.psm1    # Nagle/DNS/Throttling
│       ├── Gaming.psm1           # GameMode/GPU/Latency/MSI
│       ├── DeepCleaner.psm1      # Temp/Cache/Prefetch
│       ├── Repair.psm1           # SFC/DISM/Health
│       ├── Profiles.psm1         # 5 perfiles con undo
│       ├── HardwareScanner.psm1  # CPU/RAM/Disco/GPU + Tier List
│       ├── DiskOptimizer.psm1    # TRIM/Defrag
│       ├── HistoryWiper.psm1     # Limpieza de historial
│       ├── Win11Debloat.psm1     # Eliminacion de bloatware
│       ├── SystemProvisioner.psm1 # Winget/Software
│       └── WindowsActivator.psm1 # KMS/Licencia
│
├── MAS/                           # Microsoft Activation Scripts
└── my scripts/                    # Scripts de utilidad
```

### Diagrama de dependencias

```
ryu-tui.ps1
    │
    ├── config.psm1 ─────────── Temas, Ajustes, Rutas, Red
    │                              │
    ├── TUI.psm1 ──────────────── Motor RGB, Menus, Dialogos
    │                              │
    ├── Logger.psm1 ────────────── Write-RyuLog, Save, Cleanup
    │                              │
    ├── Network.psm1 ───────────── IP/Geo con cache
    │                              │
    └── 14 Modulos Scripts ──────── Todos leen config via GetT()
```

---

## Controles del TUI

| Tecla | Accion |
|---|---|
| `↑` / `↓` | Navegar entre opciones |
| `←` / `→` | Seleccionar / Volver |
| `Enter` | Seleccionar opcion |
| `Escape` | Volver al menu anterior |
| `Espacio` | Toggle (multi-select) |
| `1` - `14` | Acceso directo por numero |
| `F5` | Refrescar pantalla |

---

## Modulos

### Optimizacion del Sistema
Plan de energia, prioridad CPU, GPU scheduling, visuales, pagefile, servicios, tareas, boot, hibernacion, core parking.

### Privacidad y Seguridad
Telemetry off, Copilot off, Ads off, Edge hardening, bloatware removal, servicios deshabilitados.

### Ciberseguridad
Full scan, process scan, network scan, persistence scan, credential scan, forensic triage, event log analysis, firewall hardening, baseline.

### Red y Latencia
Nagle off, throttling off, DNS optimization, adapter tuning, registry tweaks.

### Gaming y Rendimiento
Game Mode, GPU optimization, latency reduction, priority boost, Nagle off.

### Limpieza Profunda
Temp purge, Windows Temp, Prefetch, browser cache, recycle bin.

### Reparacion del Sistema
SFC, DISM, health check, storage repair, Windows Update repair.

### Perfiles de Optimizacion
5 perfiles predefinidos con undo/restore: Gaming, Privacy, Balanced, Aggressive, Desktop Lite.

### Escaner de Hardware
CPU/RAM/Disco/GPU con benchmark FPU real y tier list algoritmico (S/A/B/C/D/F).

### Optimizar Disco
TRIM automatico (SSD) y Defrag (HDD).

### Borrador de Historial
Limpieza multi-categoria de historial con seleccion multiple.

### Debloat Windows 11
Eliminacion de bloatware con punto de restauracion.

### Provisionar Sistema
Instalacion via Winget: Oh My Posh, Fastfetch, FiraCode Nerd Font.

### Activar Windows
HWID, KMS38, Online KMS via Microsoft Activation Scripts.

---

## Temas

| Tema | Colores |
|---|---|
| **Cyberpunk** | Cyan / Purple / Pink |
| **Matrix** | Verde monocromatico |
| **Aurora** | Teal / Purple / Green |
| **Sunset** | Orange / Pink / Purple |
| **Neon** | Pink / Cyan / Yellow |
| **Ocean** | Blue / Teal |
| **Fire** | Red / Orange / Yellow |
| **Candy** | Pink / Purple / Cyan |
| **Monokai** | Clasico Monokai |
| **Dracula** | Purple / Pink / Cyan |
| **Solarized** | Blue / Green / Gold |
| **Retro80s** | Magenta / Cyan / Yellow |
| **Minimal** | Escala de grises |

---

## Configuracion

RYU-TUI se configura via variables de entorno en el archivo `.env`:

```ini
# Directorio de logs
RYU_TUI_LOG_DIR=C:\Users\tu-usuario\logs\ryu-tui

# Retencion de logs (dias)
RYU_TUI_LOG_RETENTION_DAYS=30

# Directorio de cache
RYU_TUI_CACHE_DIR=C:\Users\tu-usuario\.cache\ryu-tui

# Timeout de geolocalizacion (segundos)
GEO_TIMEOUT_SECONDS=5

# API principal de geolocalizacion
GEO_API_PRIMARY=https://ipapi.co/json/
```

Ver `.env.example` para todas las opciones disponibles.

---

## Estadisticas del Proyecto

| Metrica | Valor |
|---|---|
| **Lineas de codigo** | ~4,600 |
| **Modulos core** | 4 |
| **Modulos de scripts** | 14 |
| **Funciones totales** | ~157 |
| **Temas** | 13 |
| **Presets de gradiente** | 14 |
| **Banderas de paises** | 55 |

---

## Licencia

Este proyecto esta licenciado bajo la **GNU General Public License v3 (GPLv3)**.

---

<div align="center">

**Desarrollado por [Riutexu](https://github.com/Riutexu)**

*Eficiencia, seguridad y rendimiento en una sola interfaz.*

</div>
