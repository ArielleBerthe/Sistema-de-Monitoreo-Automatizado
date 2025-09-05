# Sistema-de-Monitoreo-Automatizado
Este sistema de doble script está diseñado para automatizar tareas de mantenimiento y monitoreo de seguridad en entornos híbridos Windows/Linux, cumpliendo con los objetivos de trazabilidad, portabilidad y claridad de ejecucución.

# Documentación y Análisis de Scripts de Monitoreo
Documentación Técnica y Guía de Implementación:

📋 Instrucciones de Ejecución
Script Python (log_monitor.py)
Requisitos previos:

Python 3.x instalado
Permisos de lectura/escritura en el directorio de trabajo

Ejecución:
bash# En Linux/macOS
python3 log_monitor.py

# En Windows
python log_monitor.py
Archivos generados:

reporte_sudo.txt - Reporte detallado con eventos detectados
accesos.log - Archivo de ejemplo (si no existe previamente)

Script PowerShell (eventos_seguridad.ps1)
Requisitos previos:

Windows con PowerShell 5.0 o superior
Privilegios de administrador (requerido para acceder al log de seguridad)
Política de ejecución configurada: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

Ejecución:
powershell# Ejecutar como administrador
.\eventos_seguridad.ps1
Archivos generados:

eventos.csv - Exportación de eventos de seguridad


🔧 Análisis Técnico de Implementación
1. Estructuras de Control Utilizadas
Script Python - log_monitor.py
Estructuras condicionales (if):

Línea 25-28: Verificación de existencia de archivo
Línea 48: Detección de líneas con 'sudo'
Línea 71-82: Manejo de diferentes tipos de excepciones
Línea 97: Verificación de ocurrencias encontradas
Línea 109-112: Análisis de seguridad (alerta por alto número de comandos)

Bucles (for):

Línea 44-52: Iteración línea por línea del archivo de log
Línea 103-104: Escritura iterativa de líneas detectadas

Script PowerShell - eventos_seguridad.ps1
Estructuras condicionales (if):

Líneas 38-46: Verificación del estado del servicio Event Log
Líneas 66-74: Validación de eventos obtenidos
Líneas 150-156: Verificación de privilegios de administrador
Líneas 174-192: Lógica principal de procesamiento

Bucles (foreach):

Líneas 78-80: Iteración para mostrar estadísticas por tipo de evento

2. Funciones de Lectura y Escritura de Archivos
Python - Funciones implementadas:
Lectura de archivos:
pythonwith open(archivo_log, 'r', encoding='utf-8') as archivo:
    for linea in archivo:  # Lectura línea por línea eficiente
Características:

Uso de context manager (with) para manejo seguro de archivos
Codificación UTF-8 explícita para compatibilidad internacional
Manejo de excepciones específicas (FileNotFoundError, PermissionError, UnicodeDecodeError)

Escritura de archivos:
pythonwith open(archivo_reporte, 'w', encoding='utf-8') as archivo:
    archivo.write(contenido)  # Escritura estructurada
Ventajas implementadas:

Cierre automático de archivos
Control granular de errores
Trazabilidad con números de línea

3. Cmdlets y Condicionales en PowerShell
Cmdlets utilizados:

Get-EventLog: Extracción de eventos del sistema
powershell$eventos = Get-EventLog -LogName Security -Newest $MaxEvents -ErrorAction Stop

Export-Csv: Exportación estructurada a formato CSV
powershell$eventosFormateados | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8

Test-Path: Verificación de existencia de archivos
powershellif (Test-Path -Path $FilePath -PathType Leaf)

Get-Service: Verificación del estado de servicios
powershell$service = Get-Service -Name "EventLog" -ErrorAction Stop


Condicionales avanzadas:

Validación de privilegios de administrador
Manejo de excepciones específicas por tipo
Verificación de estado de servicios del sistema

4. Buenas Prácticas de Portabilidad y Seguridad
Portabilidad:
Python:

Uso de os.path para manejo multiplataforma de rutas
Codificación UTF-8 explícita
Shebang (#!/usr/bin/env python3) para compatibilidad Unix
Funciones modulares reutilizables

PowerShell:

Comentario #Requires -RunAsAdministrator para validación automática
Manejo de errores específicos de Windows
Funciones parametrizadas para flexibilidad

Seguridad:
Medidas implementadas:

Validación de permisos:

Verificación de privilegios de administrador en PowerShell
Manejo de excepciones de permisos en Python


Manejo seguro de archivos:

Context managers en Python
Validación de existencia antes del procesamiento
Control de errores específicos


Trazabilidad:

Logs detallados con timestamps
Numeración de líneas para seguimiento
Reportes estructurados con metadatos


Principio de menor privilegio:

Scripts ejecutan solo con permisos necesarios
Validaciones antes de operaciones críticas



Características de seguridad adicionales:

Sanitización de datos: Limpieza de caracteres de control en mensajes de eventos
Logging detallado: Registro completo de operaciones para auditoría
Validación de entrada: Verificación de archivos antes del procesamiento
Manejo de errores robusto: Prevención de terminación inesperada


📊 Resultados Esperados
Archivo reporte_sudo.txt (Ejemplo)
======================================================================
REPORTE DE MONITOREO - COMANDOS SUDO DETECTADOS
Empresa Dharma - Sistema de Seguridad Automatizado
Fecha de generación: 2025-01-15 14:30:22
======================================================================

Se detectaron 4 líneas con comandos 'sudo':

[001] Línea 2: 2025-01-15 08:31:22 user1 sudo apt update
[002] Línea 4: 2025-01-15 08:33:10 user1 sudo systemctl restart nginx
[003] Línea 6: 2025-01-15 08:35:20 admin sudo cat /var/log/auth.log
[004] Línea 8: 2025-01-15 08:37:30 user1 sudo chmod 755 /home/user1/script.sh

----------------------------------------------------------------------
TOTAL DE OCURRENCIAS ENCONTRADAS: 4
Consola PowerShell (Salida esperada)
======================================================================
DHARMA - SISTEMA DE MONITOREO DE EVENTOS DE SEGURIDAD
Extrayendo eventos del log de seguridad de Windows...
======================================================================

✓ Servicio Event Log está activo
📊 Obteniendo los últimos 50 eventos del log de seguridad...
✓ Se obtuvieron 50 eventos de seguridad

📈 Resumen de tipos de eventos:
   Information: 35 eventos
   Warning: 12 eventos
   Error: 3 eventos

💾 Exportando eventos a archivo CSV...
✓ Eventos exportados exitosamente a: eventos.csv

🔍 Verificando creación del archivo...
✓ Archivo creado exitosamente:
   Ruta completa: C:\Scripts\eventos.csv
   Tamaño: 25.67 KB
   Fecha de creación: 15/01/2025 14:32:15

======================================================================
✓ PROCESO COMPLETADO EXITOSAMENTE
======================================================================

🚀 Beneficios del Sistema

Automatización completa: Reduce intervención manual en tareas repetitivas
Multiplataforma: Funciona en entornos Windows y Linux
Trazabilidad: Registro detallado de todas las operaciones
Escalabilidad: Fácil modificación para diferentes tipos de eventos
Seguridad: Implementa principios de seguridad desde el diseño
Mantenibilidad: Código modular y bien documentado

Este sistema proporciona una base sólida para la automatización de seguridad en Dharma, con capacidad de expansión para futuras necesidades de monitoreo.
