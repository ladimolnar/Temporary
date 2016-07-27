@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File RefreshDB.bat
REM Refreshes the DB schema, functions and stored procedures on a 
REM SQL Server that hosts the database needed by the "CodeCrowd" web site.
REM Arguments: Run "RefreshDB.bat /?"
REM =================================================================
SETLOCAL

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

SET CCR_Clean=0
SET CCR_RemoveAsp=0
SET CCR_SetupAsp=0
SET CCR_OnlyPrepare=0
SET CCR_Configuration=Unknown
SET CCR_NoWait=0
SET CCR_NoWaitForLocal=0
SET CCR_SetupSqlScript=%CC_SqlTarget%\CodeCrowdDBSetup.sql
SET CCR_AspSqlScriptPath=%CC_Temp%\CodeCrowdDBAspSetup.sql
SET CCR_CodeCrowdSqlScriptPath=%CC_Temp%\CodeCrowdDBCoreSetup.sql
SET CCR_SetupAspOutput=%CC_Temp%\SetupAspOutput.txt

:StartArgLoop
IF "%1" == "" (GOTO LblDoneArgs)
IF "%1" == "/?" (CALL :SubHelp & GOTO LblExitOK)

IF /I "%1" == "/Cfg"             (SET CCR_Configuration=%~2& GOTO LblNextArg2)
IF /I "%1" == "/Clean"           (SET CCR_Clean=1& GOTO LblNextArg)
IF /I "%1" == "/OnlyPrepare"     (SET CCR_OnlyPrepare=1& GOTO LblNextArg)
IF /I "%1" == "/SetupAsp"        (SET CCR_SetupAsp=1& GOTO LblNextArg)
IF /I "%1" == "/RemoveAsp"       (SET CCR_RemoveAsp=1& GOTO LblNextArg)
IF /I "%1" == "/SetupAspClean"   (SET CCR_RemoveAsp=1& SET CCR_SetupAsp=1& GOTO LblNextArg)
IF /I "%1" == "/Zero"            (SET CCR_Configuration=Dev& SET CCR_Clean=1& SET CCR_RemoveAsp=1& SET CCR_SetupAsp=1& GOTO LblNextArg)
IF /I "%1" == "/Quiet"           (SET CCR_NoWait=1& GOTO LblNextArg)
IF /I "%1" == "/LQuiet"          (SET CCR_NoWaitForLocal=1& GOTO LblNextArg)

ECHO Error. Unknown argument %1>&2
GOTO LblBadArgs

:LblNextArg2
SHIFT 

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Invalid command line arguments. Use RefreshDB.BAT /? >&2
GOTO LblDoneWithError

:LblDoneArgs

IF "%CCR_Configuration%" == "Unknown" (ECHO You must specify the /Cfg parameter >&2 & GOTO LblBadArgs)

CALL SetConfigVars.bat /%CCR_Configuration%
IF ERRORLEVEL 1 GOTO LblDoneWithError

ECHO.
ECHO Configuration is set to: %CCR_Configuration%
ECHO.

IF /I "%CCR_Configuration%" == "Dev" GOTO LblAfterProdCheck
IF /I "%CCR_Configuration%_%CCR_Clean%" == "Local_0" GOTO LblAfterProdCheck
IF /I "%CCR_Configuration%_%CCR_NoWaitForLocal%" == "Local_1" GOTO LblAfterProdCheck

ECHO.
ECHO =============================================================
ECHO ATTENTION! This is acting on a live database!
ECHO           /OnlyPrepare will be assumed
ECHO =============================================================
ECHO.
ECHO You may hit Ctrl+C to stop.
PAUSE

SET CCR_OnlyPrepare=1

:LblAfterProdCheck

IF "%CCR_NoWait%" == "1" GOTO LblAfterWarning
IF "%CCR_OnlyPrepare%" == "1" GOTO LblAfterWarning

IF "%CCR_Clean%" == "1" (
   ECHO ATTENTION! All the data in the database will be lost. 
   ECHO You may hit Ctrl+C to stop.
   PAUSE
) ELSE (
   ECHO This will not change data, or table definitions. 
   ECHO It will only refresh views, procedures and function.
   ECHO You may hit Ctrl+C to stop.
   PAUSE
)

:LblAfterWarning

CALL :SubPrepareTargetFolder
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%CCR_SetupAsp%%CCR_RemoveAsp%" == "00" GOTO LblAfterSetupAsp

ECHO.
ECHO ========================================
ECHO Generating the SQL scripts for the ASP.NET membership features...
ECHO.

SET CCR_SetupAspParameters=/Out "%CCR_AspSqlScriptPath%" /Cfg %CCR_Configuration%
IF "%CCR_RemoveAsp%" == "1"   (SET CCR_SetupAspParameters=%CCR_SetupAspParameters% /RemoveAsp)
IF "%CCR_SetupAsp%" == "1"    (SET CCR_SetupAspParameters=%CCR_SetupAspParameters% /SetupAsp)

CALL SetupAsp.bat %CCR_SetupAspParameters% >"%CCR_SetupAspOutput%" 2>&1
IF ERRORLEVEL 1 (
   TYPE "%CCR_SetupAspOutput%" >&2
   GOTO LblDoneWithError
)

TYPE "%CCR_AspSqlScriptPath%" >> "%CCR_SetupSqlScript%"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterSetupAsp

ECHO.
ECHO ========================================
ECHO Prepare the CodeCrowd setup SQL script...
ECHO.

SET CCR_BuildDBFilesParameter=/Out "%CCR_CodeCrowdSqlScriptPath%" /Cfg %CCR_Configuration%
IF "%CCR_Clean%" == "1" (SET CCR_BuildDBFilesParameter=%CCR_BuildDBFilesParameter% /Clean)

CALL CodeCrowdUtils.bat /UsageScript "%CC_SQLSources%\Setup\SETUP_0881_InitializeData_LogData_CCT_UsageStatisticsFeature.sql
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL BuildDBFiles.bat %CCR_BuildDBFilesParameter%
IF ERRORLEVEL 1 GOTO LblDoneWithError

TYPE "%CCR_CodeCrowdSqlScriptPath%" >> "%CCR_SetupSqlScript%"
IF ERRORLEVEL 1 GOTO LblDoneWithError

ECHO. >> "%CCR_SetupSqlScript%"
ECHO EXEC Admin.CCP_AllowUsersAccessToAspMembership >> "%CCR_SetupSqlScript%"

ECHO.

IF "%CCR_OnlyPrepare%" == "1" (
   ECHO.
   ECHO The SQL Script file was prepared at:
   ECHO %CCR_SetupSqlScript%
   GOTO LblAfterUserAccessVerification
)

ECHO.
ECHO ========================================
ECHO Running the setup SQL script %CCR_SetupSqlScript% ...
ECHO.
CALL :SubExecuteSQLSetupScript
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterDataSetup

ECHO.
ECHO ========================================
ECHO Verifications...
ECHO.

CALL :SubVerifyUserAccess "Admin User" "%CC_SqlServerLoginAdminUser%" 1
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubVerifyUserAccess "Logged User" "%CC_SqlServerLoginLoggedUser%" 0
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterUserAccessVerification

:LblDoneOK
ECHO.
ECHO RefreshDB ended successfully.

:LblExitOK
SET CCR_ExitCode=0

:LblExit
cmd /C EXIT %CCR_ExitCode%
ENDLOCAL
GOTO :EOF

:LblDoneWithError
ECHO.>&2
ECHO RefreshDB done with errors!>&2
SET CCR_ExitCode=1
GOTO LblExit


REM =================================================================
REM SubVerifyUserAccess
REM Makes sure that the given user does not have access to tables and 
REM only has access to the appropiate set of sprocs.
REM Arguments:
REM   %1 The user name
REM   %2 The login parameters used for this user
REM   %3 The access state for the admin sprocs. 0 or 1
REM Exit Code:
REM      0 - OK
REM   != 0 - Error
REM =================================================================
:SubVerifyUserAccess

SET CRVA_UserTypeString=%1
SET CRVA_SqlServerLogin=%~2
SET CRVA_AdminSprocs=%3

ECHO.
ECHO Making sure that the %CRVA_UserTypeString% does not have access to DB tables ...
SQLCMD -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% %CRVA_SqlServerLogin% -Q "SELECT * FROM LogData.CCT_Log"   -b -o "%CC_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   FOR /F "usebackq tokens=1,2 delims=, " %%a IN ("%CC_Temp%\SqlInitOutput.log") do (IF "%%a"=="Msg" (IF "%%b"=="229" (GOTO LblNoTableAccessPassed)))
)
ECHO User setup error. The %CRVA_UserTypeString% has access to the DB tables or an unexpected error has occurred:>&2
ECHO.
TYPE "%CC_Temp%\SqlInitOutput.log"
GOTO LblVADoneWithError

:LblNoTableAccessPassed

IF "%CRVA_AdminSprocs%"=="0" GOTO LblVerifyNoAccessToAdminSproc
IF "%CRVA_AdminSprocs%"=="1" GOTO LblVerifyHasAccessToAdminSproc

Echo Internal error. Invalid parameters calling SubVerifyUserAccess>&2
GOTO LblVADoneWithError


:LblVerifyNoAccessToAdminSproc
ECHO Making sure that the %CRVA_UserTypeString% does not have access to Admin sprocs ...
SQLCMD -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% %CRVA_SqlServerLogin% -Q "Admin.CCP_Admin_Ping"   -b -o "%CC_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   FOR /F "usebackq tokens=1,2 delims=, " %%a IN ("%CC_Temp%\SqlInitOutput.log") do (IF "%%a"=="Msg" (IF "%%b"=="229" (GOTO LblAdminSprocAccessPassed)))
)
ECHO User setup error. The %CRVA_UserTypeString% has access to the admin procedures or an unexpected error has occurred:>&2
ECHO.
TYPE "%CC_Temp%\SqlInitOutput.log"
GOTO LblVADoneWithError


:LblVerifyHasAccessToAdminSproc
ECHO Making sure that the %CRVA_UserTypeString% has access to Admin sprocs ...
SQLCMD -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% %CRVA_SqlServerLogin% -Q "Admin.CCP_Admin_Ping"   -b -o "%CC_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   ECHO User setup error. The %CRVA_UserTypeString% has no access access to the admin procedures>&2
   TYPE "%CC_Temp%\SqlInitOutput.log"
   GOTO LblVADoneWithError
)

:LblAdminSprocAccessPassed
REM Here the access to the sprocs reserved to the admin user was verified

ECHO Making sure that the %CRVA_UserTypeString% has access to regular sprocs ...
SQLCMD -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% %CRVA_SqlServerLogin% -Q "Admin.CCP_Logged_Ping"   -b -o "%CC_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   ECHO User setup error. The %CRVA_UserTypeString% has no access access to the regular procedures>&2
   TYPE "%CC_Temp%\SqlInitOutput.log"
   GOTO LblVADoneWithError
)

:LblVerifiedLoggedSprocPassed
REM Here the access to the sprocs reserved to the logged user was verified

:LblVADone
cmd /c exit 0
GOTO :EOF

:LblVADoneWithError
cmd /c exit 1
GOTO :EOF

REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO.
ECHO This script will generate and execute the SQL script 
ECHO needed to setup the DB schema for CodeCrowd including 
ECHO the ASP.NET membership portion.
ECHO Note that the empty CodeCrowd database and the
ECHO database users must be created before this script is run.
ECHO.
ECHO Usage: RefreshDB.bat  [/?] ^| ( /Cfg Configuration
ECHO                       [/Clean] [/OnlyPrepare] [/Quiet]
ECHO                       [/SetupAsp ^| /SetupAspClean ^| /RemoveAsp] )
ECHO.
ECHO.  /?                - It will display this help page.
ECHO   /Cfg              - Configuration specifies the configuration type.
ECHO                       Valid values: Dev, Local, Prod, Test, T001, ...
ECHO   /OnlyPrepare      - It will only prepare the SQL script. 
ECHO                       It will not actually run it.
ECHO   /Quiet            - Quiet mode, do not ask for confirmation before 
ECHO                       refreshing the database schema.
ECHO   /Clean            - When specified it will drop and recreate the CodeCrowd
ECHO                       tables from scratch. By default only procedures,
ECHO                       functions and views are regenerated from scratch. 
ECHO                       By default tables are subjected only to
ECHO                       upgrade type changes.
ECHO   /SetupAsp         - Will setup the ASP membership features needed 
ECHO                       by the CodeCrowd application.
ECHO   /SetupAspClean    - Will remove the ASP membership features and then
ECHO                       it will reinstall them.
ECHO   /RemoveAsp        - Will remove the ASP membership features.
ECHO   /Zero             - Equivalent with /Cfg Dev /Clean /SetupAspClean
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

GOTO :EOF

REM =================================================================
REM SubExecuteSQLSetupScript
REM Executes the SQL Setup script.
REM =================================================================
:SubExecuteSQLSetupScript

SQLCMD -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% %CC_SqlServerLoginDbOwnerUser% -i "%CCR_SetupSqlScript%"  -b
GOTO :EOF

REM =================================================================
REM SubPrepareTargetFolder
REM Prepares the default SQL target folder
REM =================================================================
:SubPrepareTargetFolder

RMDIR /S /Q %CC_SqlTarget% >nul 2>&1
IF EXIST %CC_SqlTarget% (
   ECHO Error: Unable to delete the folder "%CC_SqlTarget%" >&2
   GOTO LblPrepareTargetFolderWithError
)

MKDIR %CC_SqlTarget% >nul 2>&1
IF NOT EXIST %CC_SqlTarget% (
   ECHO Error: Unable to create the folder "%CC_SqlTarget%" >&2
   GOTO LblPrepareTargetFolderWithError
)

GOTO :EOF

:LblPrepareTargetFolderWithError
cmd /c exit 1
goto :EOF
