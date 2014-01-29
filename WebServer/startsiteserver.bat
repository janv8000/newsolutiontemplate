@echo off
SET DIR=%~d0%~p0%
CD %DIR%
pushd ..
set SITEDIR=%CD%
popd
"%ProgramFiles%\IIS Express\iisexpress.exe" /config:%DIR%\ApplicationHost.config /trace:w

