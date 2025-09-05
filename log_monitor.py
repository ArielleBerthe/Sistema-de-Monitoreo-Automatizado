#!/usr/bin/env python3
"""
Script de monitoreo de logs - log_monitor.py

Propósito: Automatizar el análisis de archivos de log para detectar 
          eventos relacionados con comandos sudo y generar reportes
"""

import os
import sys
from datetime import datetime

def verificar_archivo_log(archivo_log):
    """
    Verifica si el archivo de log existe en el directorio actual
    
    Args:
        archivo_log (str): Nombre del archivo de log
        
    Returns:
        bool: True si existe, False en caso contrario
    """
    if not os.path.exists(archivo_log):
        print(f"ERROR: El archivo '{archivo_log}' no existe en el directorio actual")
        return False
    return True

def procesar_archivo_log(archivo_log):
    """
    Lee el archivo de log y busca líneas que contengan 'sudo'
    
    Args:
        archivo_log (str): Nombre del archivo de log
        
    Returns:
        tuple: (lista_lineas_sudo, contador_total)
    """
    lineas_sudo = []
    contador = 0
    
    try:
        with open(archivo_log, 'r', encoding='utf-8') as archivo:
            numero_linea = 0
            
            # Bucle para recorrer cada línea del archivo
            for linea in archivo:
                numero_linea += 1
                
                # Estructura condicional para identificar líneas con 'sudo'
                if 'sudo' in linea.lower():
                    contador += 1
                    # Almacenar línea con número para mayor trazabilidad
                    lineas_sudo.append(f"Línea {numero_linea}: {linea.strip()}")
                    
    except FileNotFoundError:
        print(f"ERROR: No se pudo abrir el archivo '{archivo_log}'")
        return [], 0
    except PermissionError:
        print(f"ERROR: Sin permisos para leer el archivo '{archivo_log}'")
        return [], 0
    except UnicodeDecodeError:
        print(f"ERROR: Problema de codificación en el archivo '{archivo_log}'")
        return [], 0
    
    return lineas_sudo, contador

def generar_reporte(lineas_sudo, contador_total, archivo_reporte):
    """
    Genera el archivo de reporte con las líneas detectadas
    
    Args:
        lineas_sudo (list): Lista de líneas que contienen 'sudo'
        contador_total (int): Número total de ocurrencias
        archivo_reporte (str): Nombre del archivo de reporte
    """
    try:
        with open(archivo_reporte, 'w', encoding='utf-8') as archivo:
            # Encabezado del reporte
            archivo.write("="*70 + "\n")
            archivo.write("REPORTE DE MONITOREO - COMANDOS SUDO DETECTADOS\n")
            archivo.write("Empresa Dharma - Sistema de Seguridad Automatizado\n")
            archivo.write(f"Fecha de generación: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            archivo.write("="*70 + "\n\n")
            
            # Condicional para verificar si se encontraron ocurrencias
            if contador_total > 0:
                archivo.write(f"Se detectaron {contador_total} líneas con comandos 'sudo':\n\n")
                
                # Bucle para escribir cada línea detectada
                for i, linea in enumerate(lineas_sudo, 1):
                    archivo.write(f"[{i:03d}] {linea}\n")
                    
                archivo.write("\n" + "-"*70 + "\n")
                archivo.write(f"TOTAL DE OCURRENCIAS ENCONTRADAS: {contador_total}\n")
                
                # Análisis de seguridad básico
                if contador_total > 10:
                    archivo.write("\n⚠️  ALERTA: Alto número de comandos sudo detectados\n")
                    archivo.write("   Se recomienda revisión manual de los logs\n")
                    
            else:
                archivo.write("No se detectaron líneas con comandos 'sudo' en el archivo de log.\n")
                archivo.write("TOTAL DE OCURRENCIAS ENCONTRADAS: 0\n")
            
            archivo.write("\n" + "="*70 + "\n")
            archivo.write("Fin del reporte\n")
            
        print(f"✓ Reporte generado exitosamente: {archivo_reporte}")
        
    except PermissionError:
        print(f"ERROR: Sin permisos para escribir el archivo '{archivo_reporte}'")
    except Exception as e:
        print(f"ERROR: No se pudo generar el reporte: {str(e)}")

def main():
    """
    Función principal del script
    """
    print("="*70)
    print("DHARMA - SISTEMA DE MONITOREO DE LOGS")
    print("Iniciando análisis de eventos de seguridad...")
    print("="*70)
    
    # Configuración de archivos
    archivo_log = "accesos.log"
    archivo_reporte = "reporte_sudo.txt"
    
    # Verificar existencia del archivo de log
    if not verificar_archivo_log(archivo_log):
        print("\n⚠️  Creando archivo de ejemplo para demostración...")
        # Crear archivo de ejemplo si no existe
        try:
            with open(archivo_log, 'w', encoding='utf-8') as archivo:
                archivo.write("2025-01-15 08:30:15 user1 login successful\n")
                archivo.write("2025-01-15 08:31:22 user1 sudo apt update\n")
                archivo.write("2025-01-15 08:32:45 user2 failed login attempt\n")
                archivo.write("2025-01-15 08:33:10 user1 sudo systemctl restart nginx\n")
                archivo.write("2025-01-15 08:34:05 user3 login successful\n")
                archivo.write("2025-01-15 08:35:20 admin sudo cat /var/log/auth.log\n")
                archivo.write("2025-01-15 08:36:15 user2 login successful\n")
                archivo.write("2025-01-15 08:37:30 user1 sudo chmod 755 /home/user1/script.sh\n")
            print(f"✓ Archivo de ejemplo '{archivo_log}' creado")
        except Exception as e:
            print(f"ERROR: No se pudo crear el archivo de ejemplo: {str(e)}")
            sys.exit(1)
    
    print(f"\n📂 Procesando archivo: {archivo_log}")
    
    # Procesar el archivo de log
    lineas_detectadas, total_ocurrencias = procesar_archivo_log(archivo_log)
    
    # Mostrar resultados en consola
    if total_ocurrencias > 0:
        print(f"✓ Análisis completado: {total_ocurrencias} eventos 'sudo' detectados")
        
        # Mostrar primeras 3 líneas como vista previa
        print("\n📋 Vista previa de eventos detectados:")
        for i, linea in enumerate(lineas_detectadas[:3]):
            print(f"   {linea}")
        
        if len(lineas_detectadas) > 3:
            print(f"   ... y {len(lineas_detectadas) - 3} eventos adicionales")
            
    else:
        print("ℹ️  No se detectaron comandos 'sudo' en el archivo")
    
    # Generar reporte
    print(f"\n📄 Generando reporte: {archivo_reporte}")
    generar_reporte(lineas_detectadas, total_ocurrencias, archivo_reporte)
    
    # Verificar creación exitosa del reporte
    if os.path.exists(archivo_reporte):
        tamaño_archivo = os.path.getsize(archivo_reporte)
        print(f"✓ Reporte creado exitosamente ({tamaño_archivo} bytes)")
        print(f"   Ubicación: {os.path.abspath(archivo_reporte)}")
    else:
        print("❌ Error: No se pudo crear el archivo de reporte")
    
    print("\n" + "="*70)
    print("Proceso de monitoreo completado")
    print("="*70)

# Ejecutar script solo si se llama directamente
if __name__ == "__main__":
    main()
