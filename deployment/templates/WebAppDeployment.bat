@echo off

SET DIR=%~d0%~p0%
For /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/: " %%a in ("%TIME%") do (set mytime=%%a%%b)

SET file.settings=%DIR%..\settings\${environment}.settings
SET dir.deploytarget=${share.webserver.websitedeployment}
SET dir.foldertodeploy=_PublishedWebSites\${WebsiteName}

REM Backup first
SET deploytargetbackupfolder=%dir.deploytarget%_backup_%mydate%_%mytime%
IF EXIST "%deploytargetbackupfolder%" RMDIR /S /Q "%deploytargetbackupfolder%"
MKDIR "%deploytargetbackupfolder%"
IF EXIST "%dir.deploytarget%" XCOPY /E "%dir.deploytarget%" "%deploytargetbackupfolder%"

REM Prepare "to be" folder
SET deploytargetnewfolder=%dir.deploytarget%_new_%mydate%_%mytime%
IF EXIST "%deploytargetnewfolder%" RMDIR /S /Q "%deploytargetnewfolder%"
MKDIR "%deploytargetnewfolder%"

XCOPY /e "%DIR%..\%dir.foldertodeploy%" "%deploytargetnewfolder%"
COPY "%DIR%..\build_artifacts\_BuildInfo.xml" "%deploytargetnewfolder%"
COPY "%DIR%..\environment.files\${environment}\Web.config" "%deploytargetnewfolder%\web.config"

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