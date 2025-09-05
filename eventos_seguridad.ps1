# Propósito: Extraer y exportar eventos del log de seguridad de Windows
#           para análisis y monitoreo automatizado
#
# Requisitos: Ejecutar con privilegios de administrador para acceder
#            al log de seguridad del sistema

#Requires -RunAsAdministrator

# Función para mostrar encabezado del script
function Show-Header {
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "DHARMA - SISTEMA DE MONITOREO DE EVENTOS DE SEGURIDAD" -ForegroundColor Yellow
    Write-Host "Extrayendo eventos del log de seguridad de Windows..." -ForegroundColor White
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host ""
}

# Función para verificar si el servicio de Event Log está disponible
function Test-EventLogService {
    try {
        $service = Get-Service -Name "EventLog" -ErrorAction Stop
        if ($service.Status -eq "Running") {
            Write-Host "✓ Servicio Event Log está activo" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  Servicio Event Log no está ejecutándose" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ Error al verificar el servicio Event Log: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Función para obtener eventos de seguridad
function Get-SecurityEvents {
    param(
        [int]$MaxEvents = 50
    )
    
    Write-Host "📊 Obteniendo los últimos $MaxEvents eventos del log de seguridad..." -ForegroundColor Cyan
    
    try {
        # Usar Get-EventLog para extraer eventos del log de Security
        $eventos = Get-EventLog -LogName Security -Newest $MaxEvents -ErrorAction Stop
        
        # Estructura condicional para verificar si se obtuvieron eventos
        if ($eventos.Count -gt 0) {
            Write-Host "✓ Se obtuvieron $($eventos.Count) eventos de seguridad" -ForegroundColor Green
            
            # Mostrar estadísticas básicas de los eventos
            $eventosInfo = $eventos | Group-Object -Property EntryType | Sort-Object Name
            Write-Host ""
            Write-Host "📈 Resumen de tipos de eventos:" -ForegroundColor Yellow
            
            # Bucle para mostrar estadísticas por tipo
            foreach ($tipoEvento in $eventosInfo) {
                Write-Host "   $($tipoEvento.Name): $($tipoEvento.Count) eventos" -ForegroundColor White
            }
            
            return $eventos
        } else {
            Write-Host "⚠️  No se encontraron eventos en el log de seguridad" -ForegroundColor Yellow
            return $null
        }
        
    }
    catch [System.Security.SecurityException] {
        Write-Host "❌ Error de permisos: Se requieren privilegios de administrador" -ForegroundColor Red
        Write-Host "   Ejecute el script como administrador" -ForegroundColor Yellow
        return $null
    }
    catch [System.ArgumentException] {
        Write-Host "❌ Error: El log 'Security' no está disponible en este sistema" -ForegroundColor Red
        return $null
    }
    catch {
        Write-Host "❌ Error al obtener eventos: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Función para exportar eventos a CSV
function Export-EventsToCSV {
    param(
        [Object[]]$Events,
        [string]$FilePath = "eventos.csv"
    )
    
    Write-Host ""
    Write-Host "💾 Exportando eventos a archivo CSV..." -ForegroundColor Cyan
    
    try {
        # Seleccionar las propiedades más relevantes para el análisis de seguridad
        $eventosFormateados = $Events | Select-Object @{
            Name = "Fecha_Hora"
            Expression = { $_.TimeGenerated.ToString("yyyy-MM-dd HH:mm:ss") }
        }, @{
            Name = "Tipo_Evento"
            Expression = { $_.EntryType }
        }, @{
            Name = "ID_Evento"
            Expression = { $_.EventID }
        }, @{
            Name = "Origen"
            Expression = { $_.Source }
        }, @{
            Name = "Usuario"
            Expression = { $_.UserName }
        }, @{
            Name = "Computadora"
            Expression = { $_.MachineName }
        }, @{
            Name = "Mensaje"
            Expression = { ($_.Message -replace "`r`n", " " -replace "`n", " ").Trim() }
        }
        
        # Exportar usando Export-Csv con codificación UTF8
        $eventosFormateados | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
        
        Write-Host "✓ Eventos exportados exitosamente a: $FilePath" -ForegroundColor Green
        return $true
        
    }
    catch [System.UnauthorizedAccessException] {
        Write-Host "❌ Error de permisos: No se puede escribir en la ubicación especificada" -ForegroundColor Red
        return $false
    }
    catch {
        Write-Host "❌ Error al exportar eventos: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Función para verificar la creación exitosa del archivo
function Test-FileCreation {
    param(
        [string]$FilePath
    )
    
    Write-Host ""
    Write-Host "🔍 Verificando creación del archivo..." -ForegroundColor Cyan
    
    # Usar Test-Path para verificar existencia del archivo
    if (Test-Path -Path $FilePath -PathType Leaf) {
        # Obtener información adicional del archivo
        $archivoInfo = Get-Item -Path $FilePath
        $tamañoKB = [Math]::Round($archivoInfo.Length / 1024, 2)
        
        Write-Host "✓ Archivo creado exitosamente:" -ForegroundColor Green
        Write-Host "   Ruta completa: $($archivoInfo.FullName)" -ForegroundColor White
        Write-Host "   Tamaño: $tamañoKB KB" -ForegroundColor White
        Write-Host "   Fecha de creación: $($archivoInfo.CreationTime)" -ForegroundColor White
        
        return $true
    } else {
        Write-Host "❌ Error: El archivo no fue creado correctamente" -ForegroundColor Red
        return $false
    }
}

# Función principal del script
function Main {
    # Mostrar encabezado
    Show-Header
    
    # Verificar privilegios de administrador
    $esAdmin = ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $esAdmin) {
        Write-Host "⚠️  ADVERTENCIA: No se detectaron privilegios de administrador" -ForegroundColor Yellow
        Write-Host "   Algunos eventos de seguridad pueden no estar disponibles" -ForegroundColor Yellow
        Write-Host "   Para obtener resultados completos, ejecute como administrador" -ForegroundColor Yellow
        Write-Host ""
        
        # Dar opción al usuario de continuar
        $respuesta = Read-Host "¿Desea continuar de todos modos? (S/N)"
        if ($respuesta -notmatch "^[SsYy]") {
            Write-Host "Operación cancelada por el usuario" -ForegroundColor Yellow
            return
        }
    }
    
    # Verificar servicio de Event Log
    if (-not (Test-EventLogService)) {
        Write-Host "❌ No se puede continuar sin acceso al servicio Event Log" -ForegroundColor Red
        return
    }
    
    # Configuración de archivos
    $archivoCSV = "eventos.csv"
    $numeroEventos = 50
    
    # Obtener eventos de seguridad
    $eventos = Get-SecurityEvents -MaxEvents $numeroEventos
    
    # Estructura condicional principal
    if ($eventos -ne $null -and $eventos.Count -gt 0) {
        
        # Exportar eventos a CSV
        $exportacionExitosa = Export-EventsToCSV -Events $eventos -FilePath $archivoCSV
        
        # Verificar creación del archivo solo si la exportación fue exitosa
        if ($exportacionExitosa) {
            $archivoCreado = Test-FileCreation -FilePath $archivoCSV
            
            # Condicional final para mostrar resumen
            if ($archivoCreado) {
                Write-Host ""
                Write-Host "=" * 70 -ForegroundColor Green
                Write-Host "✓ PROCESO COMPLETADO EXITOSAMENTE" -ForegroundColor Green
                Write-Host "=" * 70 -ForegroundColor Green
                Write-Host "Resumen de la operación:" -ForegroundColor White
                Write-Host "• Eventos procesados: $($eventos.Count)" -ForegroundColor White
                Write-Host "• Archivo generado: $archivoCSV" -ForegroundColor White
                Write-Host "• Estado: Listo para análisis" -ForegroundColor White
            } else {
                Write-Host ""
                Write-Host "❌ PROCESO COMPLETADO CON ERRORES" -ForegroundColor Red
                Write-Host "   Los eventos se obtuvieron pero no se pudo crear el archivo CSV" -ForegroundColor Yellow
            }
        } else {
            Write-Host ""
            Write-Host "❌ Error en la exportación de eventos" -ForegroundColor Red
        }
        
    } else {
        Write-Host ""
        Write-Host "⚠️  No se pudieron obtener eventos de seguridad" -ForegroundColor Yellow
        Write-Host "   Verifique permisos y disponibilidad del log de seguridad" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Presione cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Punto de entrada del script
# Ejecutar función principal solo si el script se ejecuta directamente
if ($MyInvocation.InvocationName -ne ".") {
    Main
}
