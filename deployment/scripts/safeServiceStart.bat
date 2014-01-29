@echo off
:: This script originally authored by Eric Falsken

IF [%1]==[] GOTO usage

SC query %1 | FIND "STATE" 
IF errorlevel 1 GOTO SystemOffline

:ResolveInitialState
SC query %1 | FIND "STATE" | FIND "STOPPED" 
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartService
SC query %1 | FIND "STATE" | FIND "RUNNING" 
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartedService
SC query %1 | FIND "STATE" | FIND "PAUSED" 
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline
echo Service State is changing, waiting for service to resolve its state before making changes
sc query %1 | Find "STATE"
timeout /t 2 /nobreak 
GOTO ResolveInitialState

:StartService
echo Starting %1
sc start %1 

GOTO StartingService
:StartingServiceDelay
echo Waiting for %1 to start
timeout /t 2 /nobreak 
:StartingService
SC query %1 | FIND "STATE" | FIND "RUNNING" 
IF errorlevel 1 GOTO StartingServiceDelay

:StartedService
echo %1 on is started
GOTO:eof

:SystemOffline
echo Server is not accessible or is offline
GOTO:eof

:usage
echo %0 [service name]
echo Example: %0 MyService
echo.
GOTO:eof