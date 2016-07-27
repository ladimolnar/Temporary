@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File CodeCrowdUtils.bat
REM Invokes CodeCrowdUtils.exe
REM =================================================================

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

%CC_Bin%\CodeCrowdUtils\CodeCrowdUtils.EXE %*
IF ERRORLEVEL 1 GOTO LblDoneWithError

cmd /c exit 0
GOTO :EOF

:LblDoneWithError
ECHO.
ECHO CodeCrowdUtils done with errors!
cmd /c exit 1
GOTO :EOF
