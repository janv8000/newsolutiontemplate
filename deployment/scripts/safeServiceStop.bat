@echo off
:: This script originally authored by Eric Falsken

IF [%1]==[] GOTO usage

SC query %1 | FIND "STATE" 
IF errorlevel 1 GOTO SystemOffline

:ResolveInitialState
SC query %1 | FIND "STATE" | FIND "RUNNING" 
IF errorlevel 0 IF NOT errorlevel 1 GOTO StopService
SC query %1 | FIND "STATE" | FIND "STOPPED" 
IF errorlevel 0 IF NOT errorlevel 1 GOTO StopedService
SC query %1 | FIND "STATE" | FIND "PAUSED" 
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline
echo Service State is changing, waiting for service to resolve its state before making changes
sc query %1 | Find "STATE"
timeout /t 2 /nobreak 
GOTO ResolveInitialState

:StopService
echo Stopping %1
sc stop %1 

GOTO StopingService
:StopingServiceDelay
echo Waiting for %1 to stop
timeout /t 2 /nobreak 
:StopingService
SC query %1 | FIND "STATE" | FIND "STOPPED" 
IF errorlevel 1 GOTO StopingServiceDelay

:StopedService
echo %1 on is stopped
GOTO:eof

:SystemOffline
echo Server or service %1 is not accessible or is offline
GOTO:eof

:usage
echo Will cause a remote service to STOP (if not already stopped).
echo This script will waiting for the service to enter the stpped state if necessary.
echo.
echo %0 [service name]
echo Example: %0 MyService
echo.
echo For reason codes, run "sc stop"
GOTO:eof
GOTO:eof