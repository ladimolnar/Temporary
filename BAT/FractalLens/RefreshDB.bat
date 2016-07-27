@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File RefreshDB.bat
REM Refreshes the DB schema, functions and stored procedures on a 
REM SQL Server that hosts the database needed by the "Fractalia" web site.
REM Arguments: Run "RefreshDB.bat /?"
REM =================================================================

SET FRCT_PathToScriptFolder=%~dp0
CALL %FRCT_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL SetDBVars.bat

SET FRCT_ResetData=0
SET FRCT_EnvironmentMode=Unknown
SET FRCT_Temp_SQLSetupScript="%FRCT_Temp%\SetupScripts.sql"
SET FRCT_Final_SQLSetupScript="%FRCT_Target%\SetupScripts.sql"

:StartArgLoop
IF "%1" == "" (GOTO LblDoneArgs)
IF "%1" == "/?" (CALL :SubHelp & GOTO LblExit)
IF /I "%1" == "/Test" (CALL :SubSetTestConnection & GOTO LblNextArg)
IF /I "%1" == "/Prod" (CALL :SubSetProductionConnection & GOTO LblNextArg)
IF /I "%1" == "/ResetData" (SET FRCT_ResetData=1& GOTO LblNextArg)

GOTO LblBadArgs

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Invalid command line arguments. Use RefreshDB /? >&2
GOTO LblDoneWithError

:LblDoneArgs

IF "%FRCT_EnvironmentMode%" == "Unknown" (ECHO You must specify one of /Test or /Prod parameters & GOTO LblBadArgs)

IF "%FRCT_ResetData%" == "1" (
   ECHO ATENTION! All the data in the database will be lost. 
   ECHO Hit Ctrl+C to stop.
   PAUSE
) ELSE (
   ECHO This will not change data, or table definitions. 
   ECHO It will only refresh views, procedures and function.
   PAUSE
)

ECHO.
ECHO ========================================
ECHO Prepare the setup SQL script...
ECHO.

CALL BuildDBFiles.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL :SubAddSqlCommand "PRINT 'Clean the database procedures and functions ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CleanProcedures.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL :SubAddSqlCommand "PRINT 'Clean the database views ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CleanViews.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError


IF "%FRCT_ResetData%" == "0" GOTO LblAfterCleanTables
CALL :SubAddSqlCommand "PRINT 'Clean the database tables ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CleanTables.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterCleanTables

IF "%FRCT_ResetData%" == "0" GOTO LblAfterCleanSchemas
CALL :SubAddSqlCommand "PRINT 'Clean the schemas ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CleanSchemas.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterCleanSchemas

CALL :SubAddSqlCommand "PRINT 'Create the new schemas ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CreateSchemas.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%FRCT_ResetData%" == "0" GOTO LblAfterCreateTables
CALL :SubAddSqlCommand "PRINT 'Create the tables ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CreateTables.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterCreateTables

CALL :SubAddSqlCommand "PRINT 'Create the views ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CreateViews.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL :SubAddSqlCommand "PRINT 'Create the procedures and functions ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\CreateSprocs.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%FRCT_ResetData%" == "0" GOTO LblAfterInitDatabase

CALL :SubAddSqlCommand "PRINT 'Initializing the database to a clean state ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlCommand "Admin.FRP_InitCleanDatabase"
IF ERRORLEVEL 1 GOTO LblDoneWithError

REM CALL :SubAddSqlCommand "PRINT 'Initializing the database with test data ...'"
REM IF ERRORLEVEL 1 GOTO LblDoneWithError
REM CALL :SubAddSqlCommand "Admin.FRP_InitTestData"
REM IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL :SubAddSqlCommand "PRINT 'Inserting seed data ...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubAddSqlScriptFile "%FRCT_Target%\InitSeedData.SQL"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterInitDatabase

CALL :SubAddSqlCommand "PRINT 'Restrict the Admin user via all the standard roles...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
SET FRCT_SqlCommand=^"Admin.RestrictsUserWithStandardRoles '%FRCT_AdminUserName%'^"
CALL :SubAddSqlCommand %FRCT_SqlCommand%
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL :SubAddSqlCommand "PRINT 'Restrict the Anonymous user via all the standard roles...'"
IF ERRORLEVEL 1 GOTO LblDoneWithError
SET FRCT_SqlCommand=^"Admin.RestrictsUserWithStandardRoles '%FRCT_AnonymousUserName%'^"
CALL :SubAddSqlCommand %FRCT_SqlCommand%
IF ERRORLEVEL 1 GOTO LblDoneWithError

%FRCT_Bin%\FR.EXE %FRCT_Temp_SQLSetupScript% "%FRCT_Final_SQLSetupScript%"
IF ERRORLEVEL 1 GOTO :LblDoneWithError

IF "%FRCT_EnvironmentMode%" == "Prod" (
   ECHO.
   ECHO Until SQL access to production server is granted please use:
   ECHO %FRCT_Final_SQLSetupScript%
   CALL NOTEPAD.EXE %FRCT_Final_SQLSetupScript%
   GOTO LblAfterUserAccessVerification
)

ECHO.
ECHO ========================================
ECHO Running the setup SQL script %FRCT_Final_SQLSetupScript% ...
ECHO.
CALL :SubExecuteSQLSetupScript
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterDataSetup

ECHO.
ECHO ========================================
ECHO Verifications...
ECHO.

CALL :SubVerifyUserAccess "Admin User" "%FRCT_SqlServerLoginAdminUser%" 1
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubVerifyUserAccess "Anonymous User" "%FRCT_SqlServerLoginAnonymousUser%" 0
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterUserAccessVerification

:LblDone
ECHO.
ECHO RefreshDB ended successfully.

:LblExit
cmd /c exit 0
GOTO :EOF

:LblDoneWithError
ECHO.
ECHO RefreshDB done with errors!
cmd /c exit 1
GOTO :EOF


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

SET FRVA_UserTypeString=%1
SET FRVA_SqlServerLogin=%~2
SET FRVA_AdminSprocs=%3

ECHO.
ECHO Making sure that the %FRVA_UserTypeString% does not have access to DB tables ...
SQLCMD -S %FRCT_SqlServerName% -d %FRCT_SqlServerDatabaseName% %FRVA_SqlServerLogin% -Q "SELECT * FROM Data.FRT_FractalDefinition"   -b -o "%FRCT_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   FOR /F "usebackq tokens=1,2 delims=, " %%a IN ("%FRCT_Temp%\SqlInitOutput.log") do (IF "%%a"=="Msg" (IF "%%b"=="229" (GOTO LblNoTableAccessPassed)))
)
ECHO User setup error. The %FRVA_UserTypeString% has access to the DB tables or an unexpected error has occured:
ECHO.
TYPE "%FRCT_Temp%\SqlInitOutput.log"
GOTO LblVADoneWithError

:LblNoTableAccessPassed

IF "%FRVA_AdminSprocs%"=="0" GOTO LblVerifyNoAccessToAdminSproc
IF "%FRVA_AdminSprocs%"=="1" GOTO LblVerifyHasAccessToAdminSproc

Echo Internal error. Invalid parameters calling SubVerifyUserAccess>&2
GOTO LblVADoneWithError


:LblVerifyNoAccessToAdminSproc
ECHO Making sure that the %FRVA_UserTypeString% does not have access to Admin sprocs ...
SQLCMD -S %FRCT_SqlServerName% -d %FRCT_SqlServerDatabaseName% %FRVA_SqlServerLogin% -Q "Admin.FRP_Admin_Ping"   -b -o "%FRCT_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   FOR /F "usebackq tokens=1,2 delims=, " %%a IN ("%FRCT_Temp%\SqlInitOutput.log") do (IF "%%a"=="Msg" (IF "%%b"=="229" (GOTO LblAdminSprocAccessPassed)))
)
ECHO User setup error. The %FRVA_UserTypeString% has access to the admin procedures or an unexpected error has occured:
ECHO.
TYPE "%FRCT_Temp%\SqlInitOutput.log"
GOTO LblVADoneWithError


:LblVerifyHasAccessToAdminSproc
ECHO Making sure that the %FRVA_UserTypeString% has access to Admin sprocs ...
SQLCMD -S %FRCT_SqlServerName% -d %FRCT_SqlServerDatabaseName% %FRVA_SqlServerLogin% -Q "Admin.FRP_Admin_Ping"   -b -o "%FRCT_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   ECHO User setup error. The %FRVA_UserTypeString% has no access access to the admin procedures
   TYPE "%FRCT_Temp%\SqlInitOutput.log"
   GOTO LblVADoneWithError
)

:LblAdminSprocAccessPassed
REM Here the access to the admin sprocs was verified

ECHO Making sure that the %FRVA_UserTypeString% has access to regular sprocs ...
SQLCMD -S %FRCT_SqlServerName% -d %FRCT_SqlServerDatabaseName% %FRVA_SqlServerLogin% -Q "Admin.FRP_Anonymous_Ping"   -b -o "%FRCT_Temp%\SqlInitOutput.log"
IF ERRORLEVEL 1 (
   ECHO User setup error. The %FRVA_UserTypeString% has no access access to the regular procedures
   TYPE "%FRCT_Temp%\SqlInitOutput.log"
   GOTO LblVADoneWithError
)

:LblVerifiedAnonymousSprocPassed
REM Here the access to the anonymous sprocs was verified

:LblVADone
cmd /c exit 0
GOTO :EOF

:LblVADoneWithError
cmd /c exit 1
GOTO :EOF



REM =================================================================
REM SubSetTestConnection
REM Sets the environment varibles so that the SQL will connect with 
REM the test server
REM =================================================================
:SubSetTestConnection

SET FRCT_EnvironmentMode=Test
SET FRCT_SqlServerName=localhost

GOTO :EOF

REM =================================================================
REM SubSetProductionConnection
REM Sets the environment varibles so that the SQL will connect with 
REM the production server
REM =================================================================
:SubSetProductionConnection

SET FRCT_EnvironmentMode=Prod
SET FRCT_SqlServerName=%FRCT_ProductionSqlServerName%

GOTO :EOF


REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO.
ECHO Usage: RefreshDB.bat  /Test ^| /Prod [/ResetData]
ECHO     /Test       - Will refresh the test DB
ECHO     /Prod       - Will refresh the Production DB
ECHO     /ResetData  - Will erase and re-initialize data.
ECHO                   By default only procedures, functions 
ECHO                   and views are refreshed.
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

GOTO :EOF


REM =================================================================
REM SubAddSqlCommand
REM Appends a SQL command at the end of the SQL Setup script.
REM =================================================================
:SubAddSqlCommand 

SET FRCT_SqlCmd=%~1
ECHO. >> %FRCT_Temp_SQLSetupScript%
ECHO %FRCT_SqlCmd% >> %FRCT_Temp_SQLSetupScript%
ECHO GO >> %FRCT_Temp_SQLSetupScript%
ECHO. >> %FRCT_Temp_SQLSetupScript%

GOTO :EOF


REM =================================================================
REM SubAddSqlScriptFile
REM Appends the content of a file at the end of the SQL Setup script.
REM =================================================================
:SubAddSqlScriptFile

SET FRCT_SqlScriptFile=%1
ECHO. >> %FRCT_Temp_SQLSetupScript%
TYPE %FRCT_SqlScriptFile% >> %FRCT_Temp_SQLSetupScript%
ECHO. >> %FRCT_Temp_SQLSetupScript%

GOTO :EOF


REM =================================================================
REM SubExecuteSQLSetupScript
REM Executes the SQL Setup script.
REM =================================================================
:SubExecuteSQLSetupScript

SQLCMD -S %FRCT_SqlServerName% -d %FRCT_SqlServerDatabaseName% %FRCT_SqlServerLoginDbOwnerUser% -i %FRCT_Final_SQLSetupScript%  -b
GOTO :EOF
