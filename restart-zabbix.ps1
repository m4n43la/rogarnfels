# Servicios posibles
$serviceNames = @("Zabbix Agent", "Zabbix Agent 2")

# Buscar qué servicio existe
$svc = $null
foreach ($name in $serviceNames) {
    $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($svc) { break }
}

# Crear log
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\Program Files (x86)\ossec-agent\active-response\log_$timestamp.txt"
$logTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Validar servicio
if (-not $svc) {
    Add-Content -Path $logFile -Value "$logTimestamp ERROR - No se encontró ningún servicio Zabbix"
    exit 1
}

# Determinar nombre del proceso según servicio
$processName = if ($svc.Name -eq "Zabbix Agent 2") { "zabbix_agent2" } else { "zabbix_agentd" }

try {
    if ($svc.Status -ne 'Running') {

        Add-Content -Path $logFile -Value "$logTimestamp INFO - Intentando iniciar servicio $($svc.Name)"

        Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5

        $svc = Get-Service -Name $svc.Name

        if ($svc.Status -ne 'Running') {

            Add-Content -Path $logFile -Value "$logTimestamp WARN - Servicio no arranca, aplicando recuperación agresiva"

            # 🔥 MODO AGRESIVO

            # Matar proceso si existe
            $proc = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($proc) {
                Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
                Add-Content -Path $logFile -Value "$logTimestamp INFO - Proceso $processName terminado"
            }

            # Parar servicio (por si está en estado inconsistente)
            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2

            # Intentar arrancar nuevamente
            Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 5

            $svc = Get-Service -Name $svc.Name

            if ($svc.Status -ne 'Running') {
                Add-Content -Path $logFile -Value "$logTimestamp ERROR - No se pudo levantar el servicio tras recuperación agresiva"
                exit 2
            }
            else {
                Add-Content -Path $logFile -Value "$logTimestamp OK - Servicio $($svc.Name) recuperado con reinicio forzado"
            }
        }
        else {
            Add-Content -Path $logFile -Value "$logTimestamp OK - Servicio $($svc.Name) levantado correctamente"
        }
    }
    else {
        Add-Content -Path $logFile -Value "$logTimestamp INFO - Servicio $($svc.Name) ya estaba en ejecución"
    }
}
catch {
    Add-Content -Path $logFile -Value "$logTimestamp ERROR - $($_.Exception.Message)"
    exit 3
}
