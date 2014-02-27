@echo off

SET environment=${environment}

IF /I %environment:~-3% == LAN (
	COLOR 47
	ECHO ERROR: Only allowed in DMZ
	PAUSE
	EXIT /B 1
)

SET DIR=%~d0%~p0%
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set TIMESTAMP=%ldt:~0,4%%ldt:~4,2%%ldt:~6,2%%ldt:~8,2%%ldt:~10,2%%ldt:~12,2%

SET file.settings=%DIR%..\settings\${environment}.settings
SET dir.deploytarget=${share.webserver.webservicedeployment}
SET dir.foldertodeploy=_PublishedWebSites\${webservicename}

REM Backup first
SET deploytargetbackupfolder=%dir.deploytarget%_backup_%TIMESTAMP%
IF EXIST "%deploytargetbackupfolder%" RMDIR /S /Q "%deploytargetbackupfolder%"
MKDIR "%deploytargetbackupfolder%"
IF EXIST "%dir.deploytarget%" XCOPY /E "%dir.deploytarget%" "%deploytargetbackupfolder%"

REM Prepare "to be" folder
SET deploytargetnewfolder=%dir.deploytarget%_new_%TIMESTAMP%
IF EXIST "%deploytargetnewfolder%" RMDIR /S /Q "%deploytargetnewfolder%"
MKDIR "%deploytargetnewfolder%"

XCOPY /e "%DIR%..\%dir.foldertodeploy%" "%deploytargetnewfolder%"
COPY "%DIR%..\build_artifacts\_BuildInfo.xml" "%deploytargetnewfolder%"
COPY "%DIR%..\environment.files\${environment}\Service.Web.config" "%deploytargetnewfolder%\web.config"

REM First Deploy
IF NOT EXIST "%dir.deploytarget%" (
	MKDIR "%dir.deploytarget%"
	XCOPY /e "%deploytargetnewfolder%" "%dir.deploytarget%"
)

REM app_offline enabled
MOVE "%dir.deploytarget%\app_offline.htm.disabled" "%dir.deploytarget%\app_offline.htm"

REM alle bestaande dirs verwijderen
FOR /D %%i in ("%dir.deploytarget%\*.*"); do RMDIR /S /Q "%%i"

REM alle bestanden behalve app_offline.htm verwijderen
FOR %%I in ("%dir.deploytarget%\*.*") DO (
  IF /I NOT %%~nxI == app_offline.htm DEL /Q "%%~fI"
  )

XCOPY /e "%deploytargetnewfolder%" "%dir.deploytarget%"

REM Enable application
DEL "%dir.deploytarget%\app_offline.htm"

pause