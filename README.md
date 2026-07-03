<div align="center">

```
  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║
  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

**Advanced System Operations Toolkit**  
*PowerShell 7 Edition — RGB TUI — Offline-First — Zero Hardcoding*

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00FFCC?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Hardened-8B5CF6?style=for-the-badge)

</div>

---

## ¿Qué es RYU-TUI?

RYU-TUI es un **launcher TUI profesional** para Windows que unifica 7 herramientas avanzadas de administración de sistema en una interfaz de terminal interactiva con colores RGB de 24 bits. 

Está diseñado con una arquitectura **Modular y Offline-First**. Requiere estrictamente descargar el repositorio completo, ya que se apoya en un archivo de configuración `.env` global y módulos separados. En su formato local, es **100% independiente de internet**, incluyendo copias locales de activadores y debloaters de terceros.

---

## 🚀 Cómo Iniciar RYU-TUI

⚠️ **IMPORTANTE:** RYU-TUI *no puede* ejecutarse mediante comandos rápidos como `curl` o `irm`. Debido a su arquitectura modular orientada a la seguridad (lectura de un archivo `.env` local y módulos separados), intentar ejecutarlo en memoria causará errores de análisis sintáctico. **Debes descargar el repositorio.**

Si quieres llevar RYU-TUI en un USB o usarlo en equipos sin acceso a la red (aislados o en entornos de alta seguridad), sigue estos pasos:

1. Descarga el repositorio completo en formato ZIP desde GitHub (botón Code -> Download ZIP) y extráelo, o clónalo:
   ```powershell
   git clone https://github.com/Riutexu/Terminal-TUI.git
   ```
2. Navega a la carpeta descargada:
   ```powershell
   cd Terminal-TUI
   ```
3. Ejecuta el script principal:
   ```powershell
    ./ryu-tui.ps1
   ```

**🌟 Ventaja Full Offline:** Cuando descargas el repositorio completo, dependencias externas crudas como **Microsoft Activation Scripts (MAS)** y **Win11Debloat** ya están incluidas dentro de la carpeta `modules/scripts/`. RYU-TUI los detectará y los usará de forma local automáticamente sin requerir peticiones a GitHub o servidores externos.

---

## 📐 Arquitectura del Proyecto

```
Terminal TUI/
├── ryu-tui.ps1                    ← Punto de entrada / Bootstrapper online
├── .env                         ← Archivo de configuración maestro
└── modules/
    ├── core/
    │   ├── TUI.psm1             ← Motor RGB ANSI 24-bit + menús
    │   ├── Logger.psm1          ← Motor de registro de auditoría
    │   └── Network.psm1        ← Obtención de IP/Geo (con Fallback offline)
    └── scripts/
        ├── HardwareScanner.psm1  
        ├── DeepCleaner.psm1      
        ├── DiskOptimizer.psm1    
        ├── SystemProvisioner.psm1 
        ├── HistoryWiper.psm1     
        ├── Win11Debloat.psm1     (Usa Win11Debloat.zip si existe)
        ├── WindowsActivator.psm1 (Usa MAS_AIO.cmd si existe)
        ├── Win11Debloat.zip      ← (Paquete offline precargado)
        └── MAS_AIO.cmd           ← (Script activador offline precargado)
```

---

## 🎮 Controles del TUI

| Tecla | Acción |
|---|---|
| `↑` / `↓` | Navegar entre opciones |
| `Enter` | Seleccionar opción |
| `Escape` | Volver al menú anterior / Salir |
| `1` - `8` | Acceso directo por número |

---

## 📦 Módulos Incluidos

### 🔍 Hardware Scanner
Reconocimiento profundo del sistema con un **benchmark FPU real**. Extrae información precisa sobre tu CPU, RAM (Slots/MHz/DDR), GPU (VRAM), e implementa un **Tier List algorítmico (S/A/B/C/D)** sobre el poder de tu máquina.

### 🧹 Deep System Cleaner
Limpieza con TUI interactiva para:
- Purga estricta de `%TEMP%` y `Windows\Temp`
- Detección y borrado seguro de carpetas vacías
- Gestor interactivo de archivos pesados (Configurable, defecto > 250MB)

### 💿 Disk Optimizer
Mantenimiento profundo de sistema a nivel Kernel:
- Purgado DNS (`Clear-DnsClientCache`)
- Recorte de componentes huérfanos con **DISM** (WinSxS /ResetBase)
- Optimización TRIM automática (SSD) y Defrag (HDD)

### ⚡ System Provisioner (Requiere Internet)
Prepara entornos de hacking/desarrollo de 0 a 100:
- Instala dependencias base (*Oh My Posh*, *Fastfetch*, *FiraCode Nerd Font*).
- Genera un `$PROFILE` autoconfigurado sin rutas hardcodeadas.

### 🗑️ History Wiper
- Eliminación en caliente y en disco del historial `ConsoleHost_history.txt`.
- Opción de borrar solo el disco, solo memoria, o ambos. 

### 🛡️ Win11 Debloat (Raphire)
Wrapper seguro para deshabilitar Telemetría, Copilot, Recall y eliminar Bloatware de Windows 11. Ejecuta el script oficial de [Raphire](https://github.com/Raphire/Win11Debloat). (*Incluido offline en el repo local*).

### 🔑 Windows Activator (MAS)
Wrapper unificado para los métodos de [Microsoft Activation Scripts](https://massgrave.dev):
- **HWID** — Activación permanente de W10/W11 ligada a la placa base.
- **KMS38** — Licencia KMS local extendida hasta el año 2038.
- **Online KMS** — Para renovaciones temporales (Office / W10 / W11).
(*El archivo `MAS_AIO.cmd` viene incluido offline en el repo local*).

---

## 🔧 Archivo `.env` 

Todo en RYU-TUI se controla desde variables globales de entorno en `.env`. Nada está "hardcodeado".

```ini
# Configuración general
OMP_THEME_NAME=tokyonight_storm.omp.json
RYU_TUI_LOG_RETENTION_DAYS=30

# Variables funcionales
BENCHMARK_DURATION_SECONDS=10
LARGE_FILE_THRESHOLD_MB=250

# Conectividad y timeout
GEO_API_PRIMARY=https://ipapi.co/json/
GEO_TIMEOUT_SECONDS=5

# Comportamiento
DISK_OPTIMIZER_INCLUDE_SSD=true
WIPE_RECYCLE_BIN=true
```

---

<div align="center">
<i>Desarrollado para la máxima eficiencia y seguridad.</i>
</div>
