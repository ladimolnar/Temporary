@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File SetupAsp.bat
REM Sets up the DB objects needed by the ASP.NET membership and role provider
REM Arguments: Run "SetupAsp.bat /?"
REM =================================================================
SETLOCAL

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

SET CCA_PathRemoveAspSqlScript=%CC_Temp%\RemoveAsp.sql
SET CCA_PathSetupAspSqlScript=%CC_Temp%\SetupAsp.sql

SET CCA_RemoveAsp=0
SET CCA_SetupAsp=0
SET CCA_SqlScriptPath=Unknown
SET CCA_Configuration=Unknown

:StartArgLoop
IF "%1" == "" (GOTO LblDoneArgs)
IF "%1" == "/?" (CALL :SubHelp & GOTO LblExitOK)
IF /I "%1" == "/Cfg"          (SET CCA_Configuration=%~2& GOTO LblNextArg2)
IF /I "%1" == "/RemoveAsp"    (SET CCA_RemoveAsp=1& GOTO LblNextArg)
IF /I "%1" == "/SetupAsp"     (SET CCA_SetupAsp=1& GOTO LblNextArg)
IF /I "%1" == "/Out"          (SET CCA_SqlScriptPath=%~2& GOTO LblNextArg2)

GOTO LblBadArgs

:LblNextArg2
SHIFT 

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Invalid command line arguments. Use SetupAsp.BAT /? >&2
GOTO LblDoneWithError

:LblDoneArgs

IF "%CCA_Configuration%" == "Unknown" (ECHO You must specify the /Cfg parameter >&2 & GOTO LblBadArgs)

CALL SetConfigVars.bat /%CCA_Configuration%
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%CCA_SqlScriptPath%" == "Unknown" (ECHO You must specify the /Out parameter & GOTO LblBadArgs)
IF "%CCA_SetupAsp%%CCA_RemoveAsp%" == "00" (ECHO You must specify one of the /SetupAsp or /RemoveAsp parameters & GOTO LblBadArgs)


DEL /F /Q %CCA_SqlScriptPath% >nul 2>&1
IF EXIST %CCA_SqlScriptPath% (
   ECHO Error: Unable to delete %CCA_SqlScriptPath% >&2
   GOTO LblDoneWithError
)

IF NOT "%CCA_RemoveAsp%" == "1" GOTO LblAfterRemoveAsp

DEL /F /Q %CCA_PathRemoveAspSqlScript% >nul 2>&1
IF EXIST %CCA_PathRemoveAspSqlScript% (
   ECHO Error: Unable to delete %CCA_PathRemoveAspSqlScript% >&2
   GOTO LblDoneWithError
)

Aspnet_regsql.exe -d %CC_SqlServerDatabaseName% -sqlexportonly %CCA_PathRemoveAspSqlScript% -R all
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterRemoveAsp

IF NOT "%CCA_SetupAsp%" == "1" GOTO LblAfterSetupAsp

DEL /F /Q %CCA_PathSetupAspSqlScript% >nul 2>&1
IF EXIST %CCA_PathSetupAspSqlScript% (
   ECHO Error: Unable to delete %CCA_PathSetupAspSqlScript% >&2
   GOTO LblDoneWithError
)

Aspnet_regsql.exe -d %CC_SqlServerDatabaseName% -sqlexportonly %CCA_PathSetupAspSqlScript% -A mr
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterSetupAsp

IF "%CCA_RemoveAsp%" == "1" (

   ECHO. >> "%CCA_SqlScriptPath%"
   ECHO /*============================================================= >> "%CCA_SqlScriptPath%"
   ECHO This section will remove ASP.NET features. >> "%CCA_SqlScriptPath%"
   ECHO Generated by Aspnet_regsql.exe >> "%CCA_SqlScriptPath%"
   ECHO =============================================================*/ >> "%CCA_SqlScriptPath%"
   ECHO. >> "%CCA_SqlScriptPath%"
   
   ECHO Remove script: %CCA_PathRemoveAspSqlScript%
   TYPE %CCA_PathRemoveAspSqlScript% >> %CCA_SqlScriptPath%
   IF ERRORLEVEL 1 GOTO LblDoneWithError
)

IF "%CCA_SetupAsp%" == "1" (

   ECHO. >> "%CCA_SqlScriptPath%"
   ECHO /*============================================================= >> "%CCA_SqlScriptPath%"
   ECHO This section will install ASP.NET features. >> "%CCA_SqlScriptPath%"
   ECHO Generated by Aspnet_regsql.exe >> "%CCA_SqlScriptPath%"
   ECHO =============================================================*/ >> "%CCA_SqlScriptPath%"
   ECHO. >> "%CCA_SqlScriptPath%"

   TYPE %CCA_PathSetupAspSqlScript% >> %CCA_SqlScriptPath%
   ECHO. >> "%CCA_SqlScriptPath%"

   ECHO EXEC dbo.aspnet_Applications_CreateApplication 'CodeCrowd', 'B6DEC9A8-E256-4F84-9C4D-4624AC3C56A5'>> "%CCA_SqlScriptPath%"
   ECHO EXEC dbo.aspnet_Roles_CreateRole 'CodeCrowd', 'Administrator'>> "%CCA_SqlScriptPath%"
   ECHO EXEC dbo.aspnet_Roles_CreateRole 'CodeCrowd', 'Guest'>> "%CCA_SqlScriptPath%"
   ECHO. >> "%CCA_SqlScriptPath%"

   IF ERRORLEVEL 1 GOTO LblDoneWithError
)

:LblDoneOK
ECHO.
ECHO SetupAsp ended successfully.
ECHO The SQL script was generated in %CCA_SqlScriptPath%

:LblExitOK
SET CCA_ExitCode=0

:LblExit
cmd /C EXIT %CCA_ExitCode%
ENDLOCAL
GOTO :EOF

:LblDoneWithError
ECHO.>&2
ECHO SetupAsp done with errors!>&2
SET CCA_ExitCode=1
GOTO LblExit

REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO This batch will generate the SQL script needed to install the
ECHO ASP.NET membership features needed by the CodeCrowd application.
ECHO.
ECHO Usage: SetupAsp.bat   [/?] ^| ( (/Cfg Configuration)
ECHO                       [/RemoveAsp] [/SetupAsp] /Out PathToSqlScript )
ECHO.  /?                - It will display this help page.
ECHO   /Cfg              - Configuration specifies the configuration type.
ECHO                       Valid values: Dev, Prod, Test, ...
ECHO   /RemoveAsp        - The generated script will contain a section that will
ECHO                       remove the ASP features.
ECHO   /SetupAsp         - The generated script will contain a section that will
ECHO                       install the ASP features.
ECHO                       Note that you can use both /RemoveAsp and /SetupAsp
ECHO                       in order to install clean the ASP features.
ECHO   /Out              - PathToSqlScript will specify the path 
ECHO                       to the generated script.
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

GOTO :EOF
