pause

http://www.nachmore.com/2010/profiling-silverlight-4-with-visual-studio-2010/

VSPerfClrEnv /sampleon
VSPerfCmd -start:sample -output:somefile.vsp
VSPerfCmd -globalon
VSPerfCmd -launch:"c:\Program Files (x86)\Internet Explorer\iexplore.exe" -args:""
VSPerfCmd -shutdown
VSPerfClrEnv /off


@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =====================================================================
REM FILE: Perf.bat
REM Starts IE with the CodeCrowd application with profiler sampling attached
REM ATENTION! You need to start this in a cmd prompt that runs with administrator priviledges
REM the build info environment variables.
REM =====================================================================

SETLOCAL

SET CCP_Push=0
SET CCP_PathToScriptFolder=%~dp0
CALL %CCP_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblError

SET CCP_CodeCrowdBinaries=%CC_SrcRoot%\CodeCrowd\CodeCrowd\Bin\Debug\
ECHO %CCP_CodeCrowdBinaries%

SET CCP_SampleFile=%CCP_CodeCrowdBinaries%\CodeCrowd.VSP
SET CCP_Push=1
PUSHD %CCP_CodeCrowdBinaries%

CALL VSPerfClrEnv /sampleon
IF ERRORLEVEL 1 GOTO LblError

reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\Main" /v TabProcGrowth /t REG_DWORD /d 0 /f
IF ERRORLEVEL 1 GOTO LblError

START "C:\Program Files\Internet Explorer\iexplore.exe" http://localhost:49247/CodeCrowd.aspx
REM VSPerfCmd -launch:"C:\Program Files\Internet Explorer\iexplore.exe"  -args:"http://localhost:49247/CodeCrowd.aspx"
IF ERRORLEVEL 1 GOTO LblError

SET /P CCP_ProcessPid=IE PID? 
CALL VSPerfCmd /start:sample /output:%CCP_SampleFile% /attach:%CCP_ProcessPid%
IF ERRORLEVEL 1 GOTO LblError

pause

CALL VSPerfCmd /detach
CALL VSPerfCmd /shutdown
CALL VSPerfClrEnv /off

ECHO.
ECHO All Done. Sample file: %CCP_SampleFile%
GOTO LblDone

:LblError
SET CCP_ExitCode=1

:LblDone
IF "%CCP_Pushd%"=="1" POPD
REM reg delete "HKCU\Software\Microsoft\Internet Explorer\Main" /v TabProcGrowth /f

CMD /C EXIT %CCP_ExitCode%
ENDLOCAL
GOTO :EOF

