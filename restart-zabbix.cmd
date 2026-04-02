@echo off
powershell.exe -ExecutionPolicy Bypass -File "C:\Program Files (x86)\ossec-agent\active-response\bin\restart-zabbix.ps1"
exit /b 0