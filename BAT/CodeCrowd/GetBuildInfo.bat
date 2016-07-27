@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =====================================================================
REM FILE: GetBuildInfo.bat
REM This is the utility that generates 
REM the build info environment variables.
REM =====================================================================

SET GBI_PathToScriptFolder=%~dp0
CALL %GBI_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblError

IF "%1" == "" (ECHO Invalid command line for GetBuildInfo.bat. You need to specify a SVN folder.>&2 & GOTO LblError)
IF NOT "%2" == "" (ECHO Invalid command line for GetBuildInfo.bat.& GOTO LblError)
SET GBI_SVNFolder=%~1

SET GBI_Output="%Temp%\GetBuildInfo.txt"
SET GBI_ExitCode=0

SET GBI_DateTime=%DATE% %TIME%

CALL :SubGetRevisionNumber
IF ERRORLEVEL 1 (
   ECHO Error: Unable to determine the SVN revision number. >&2 
   GOTO LblError
)

CALL :SubGetSVNOpenState
IF ERRORLEVEL 1 (
   ECHO Error: Unable to determine the SVN file open state. >&2 
   GOTO LblError
)

GOTO LblDone

:LblError
SET GBI_ExitCode=1

:LblDone
EXIT /B %GBI_ExitCode%

GOTO :EOF


REM ==============================================================
REM Sets CC_SvnRevisionNr
REM ==============================================================
:SubGetRevisionNumber

SET GBI_SvnRevisionNrExitCode=0
SET CC_SvnRevisionNr=Unknown

svnversion %GBI_SVNFolder% > %GBI_Output% 2>&1
IF ERRORLEVEL 1 GOTO LblGetRevisionNumberError

FOR /F "usebackq tokens=* delims=:" %%a in (%GBI_Output%) do (
   SET CC_SvnRevisionNr=%%a
)
IF "%CC_SvnRevisionNr%" == "Unknown" (GOTO LblGetRevisionNumberError)
GOTO LblGetRevisionNumberDone

:LblGetRevisionNumberError
SET GBI_SvnRevisionNrExitCode=1

:LblGetRevisionNumberDone
EXIT /B %GBI_SvnRevisionNrExitCode%
GOTO :EOF


REM ==============================================================
REM Sets CC_SvnOpenState
REM ==============================================================
:SubGetSVNOpenState

SET GBI_SvnOpenStateExitCode=0
SET CC_SvnOpenState=false

SVN stat %GBI_SVNFolder% > %GBI_Output% 2>&1
IF ERRORLEVEL 1 GOTO LblGetSVNOpenStateError

FOR /F "usebackq tokens=* delims=." %%a in (%GBI_Output%) do (SET CC_SvnOpenState=true)
GOTO LblGetSVNOpenStateDone

:LblGetSVNOpenStateError
SET GBI_SvnOpenStateExitCode=1

:LblGetSVNOpenStateDone

EXIT /B %GBI_SvnOpenStateExitCode%
GOTO :EOF


