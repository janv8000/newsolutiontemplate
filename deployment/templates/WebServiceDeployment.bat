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
SET deploytargetbackupfolder=${deploy.backuprootfolder.dir}\${webservicename}_backup_%TIMESTAMP%

REM First Deploy
IF NOT EXIST "%dir.deploytarget%" (
	MKDIR "%dir.deploytarget%"
)

REM Backup first, right purged
robocopy "%dir.deploytarget%" "%deploytargetbackupfolder%" /e /purge

REM Disable application
COPY "%DIR%..\%dir.foldertodeploy%\app_offline.htm.disabled" "%dir.deploytarget%\app_offline.htm"

REM Nieuwe versie setten, app_offline moet blijven, right purged
robocopy "%DIR%..\%dir.foldertodeploy%" "%dir.deploytarget%" /e /purge /r:3 /w:5 /xf app_offline.htm

REM Copy extra files
COPY "%DIR%..\build_artifacts\_BuildInfo.xml" "%dir.deploytarget%"

REM Copy env specific files
COPY "%DIR%..\environment.files\${environment}\Service.web.config" "%dir.deploytarget%\web.config"

REM Re-enable application
DEL "%dir.deploytarget%\app_offline.htm"

pause