@echo off
setlocal enabledelayedexpansion

REM ================================
REM Copia evidencias.txt con fecha actual
REM y elimina copias anteriores
REM ================================

REM Obtener fecha actual
for /f "tokens=2-4 delims=/.- " %%a in ('date /t') do (
    set dd=%%a
    set mm=%%b
    set yyyy=%%c
)

REM Ajustar según formato regional
if "%yyyy%"=="" (
    for /f "tokens=1-3 delims=/.- " %%a in ('date /t') do (
        set dd=%%a
        set mm=%%b
        set yyyy=%%c
    )
)

REM Formato YYYY-MM-DD
set fecha=%yyyy%-%mm%-%dd%

REM Directorio de trabajo
set ruta=C:\backup

REM Archivo origen y destino
set origen=%ruta%\evidencias.txt
set destino=%ruta%\evidencias_%fecha%.txt

REM Eliminar copias anteriores
del /q "%ruta%\evidencias_*.txt" 2>nul

REM Crear nueva copia
copy "%origen%" "%destino%" >nul

echo Archivo copiado como: %destino%

endlocal