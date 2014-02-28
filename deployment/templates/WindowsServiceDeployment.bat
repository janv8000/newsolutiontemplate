@echo off

SET environment=${environment}

IF /I %environment:~-3% == DMZ (
	COLOR 47
	ECHO ERROR: Only allowed outside of DMZ
	PAUSE
	EXIT /B 1
)

SET DIR=%~d0%~p0%
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set TIMESTAMP=%ldt:~0,4%%ldt:~4,2%%ldt:~6,2%%ldt:~8,2%%ldt:~10,2%%ldt:~12,2%

SET file.settings=%DIR%..\settings\${environment}.settings
SET dir.deploytarget=${applicationserver.servicedeployment.folder}
SET dir.foldertodeploy=_PublishedApplications\${ApplicationName}
SET deploytargetbackupfolder=%dir.deploytarget%_backup_%TIMESTAMP%

SET servicename=${applicationserver.service.name}

REM First Deploy

IF EXIST "%dir.deploytarget%" (
	call "%DIR%\scripts\safeServiceStop" %servicename%
	"%dir.deploytarget%\${ApplicationName}.exe" uninstall --sudo
)
IF NOT EXIST "%dir.deploytarget%" (
	MKDIR "%dir.deploytarget%"
)

REM Backup first, right purged
robocopy "%dir.deploytarget%" "%deploytargetbackupfolder%" /e /purge

REM Nieuwe versie setten, right purged
robocopy "%DIR%..\%dir.foldertodeploy%" "%dir.deploytarget%" /e /purge

REM Copy extra files
COPY "%DIR%..\build_artifacts\_BuildInfo.xml" "%dir.deploytarget%"

REM Copy env specific files
COPY "%DIR%..\environment.files\${environment}\${ApplicationName}.exe.config" "%dir.deploytarget%\${ApplicationName}.exe.config.config"


"%dir.deploytarget%\${ApplicationName}.exe" install ${applicationserver.service.credentialconfig} --sudo
call "%DIR%\scripts\safeServiceStart" %servicename%
pause