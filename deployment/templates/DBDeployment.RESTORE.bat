@echo off

SET DIR=%~d0%~p0%

SET database.name="${database.name}"
SET sql.files.directory="%DIR%${dirs.db}"
SET backup.file="%DIR%${restore.from.path}"
SET server.database="${server.database}"
SET repository.path="${repository.path}"
SET version.file="%DIR%_BuildInfo.xml"
SET version.xpath="//buildInfo/version"
SET environment=${environment}

IF NOT %environment% == LOCAL (
	COLOR 47
	ECHO ERROR: Only allowed locally!
	PAUSE
	EXIT /B 1
)

IF /I %environment:~-3% == DMZ (
	COLOR 47
	ECHO ERROR: Only allowed outside of DMZ
	PAUSE
	EXIT /B 1
)

"%DIR%rh\rh.exe" /t /d=%database.name% /f=%sql.files.directory% /s=%server.database% /vf=%version.file% /vx=%version.xpath% /r=%repository.path% /env=%environment% /simple /restore /rfp=%backup.file% /rt=1200

pause