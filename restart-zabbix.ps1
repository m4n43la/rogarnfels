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

if (-not $svc) {
    Add-Content -Path $logFile -Value "$logTimestamp ERROR - No se encontró ningún servicio Zabbix"
    exit
}

try {
    if ($svc.Status -ne 'Running') {
        Start-Service -Name $svc.Name
        Start-Sleep -Seconds 5

        $svc = Get-Service -Name $svc.Name

        if ($svc.Status -ne 'Running') {
            Restart-Service -Name $svc.Name -Force
        }

        Add-Content -Path $logFile -Value "$logTimestamp OK - Servicio $($svc.Name) levantado correctamente"
    }
    else {
        Add-Content -Path $logFile -Value "$logTimestamp INFO - Servicio $($svc.Name) ya estaba en ejecución"
    }
}
catch {
    Add-Content -Path $logFile -Value "$logTimestamp ERROR - $($_.Exception.Message)"
}