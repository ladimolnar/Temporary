@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File LocalSetup.bat
REM Prepares the 'Local' environment in the test SDV client.
REM =================================================================
SETLOCAL

SET LS_TestClientRoot=E:\Sources\SVNClient\TestClients\CodeCrowd
SET LS_TestClientSolutionPath=%LS_TestClientRoot%\trunk\CodeCrowd\CodeCrowd\CodeCrowd.sln
SET LS_PathToScriptFolder=%~dp0
CALL %LS_PathToScriptFolder%\SetCoreEnvVars.bat
CALL SetConfigVars.bat /Local
SET LS_DateTime=%DATE%_%TIME%
SET LS_DateTime=%LS_DateTime: =%
SET LS_DateTime=%LS_DateTime::=_%
SET LS_DateTime=%LS_DateTime:.=_%
SET LS_DateTime=%LS_DateTime:/=_%
SET LS_PathToBackupFile=%CC_SVNRoot%\DBBackups\%CC_SqlServerDatabaseName%_%LS_DateTime%.BAK
SET LS_RefreshDB=1
SET LS_Output="%Temp%\LS_Output.txt"

:StartArgLoop
IF "%1" == ""           (GOTO LblDoneArgs)
IF "%1" == "/?"         (CALL :SubHelp & GOTO LblExitOK)
IF /I "%1" == "/NoDB"   (SET LS_RefreshDB=0& GOTO LblNextArg)

ECHO Error. Unknown argument %1>&2
GOTO LblBadArgs

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Error! Invalid command line arguments. Use LocalSetup.bat /? >&2
GOTO LblDoneWithError

:LblDoneArgs

CALL %LS_PathToScriptFolder%\GetBuildInfo.bat "%CC_SVNArea%\CodeCrowd"
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF NOT "%CC_SvnOpenState%"=="false" (
   ECHO Warning:  There are files still opened in SVN.>&2
   ECHO           Note that this script will execute the SVN submitted version all the scripts.>&2
   ECHO           Consider especially TransferData.SQL>&2
   ECHO You may hit Ctrl+C to stop.
   PAUSE
)

ECHO.
PUSHD %LS_TestClientRoot%

ECHO Update the SVN test client...
SVN.EXE update >%LS_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to update the SVN test client. >&2
   ECHO See %LS_Output% >&2
   GOTO LblDoneWithError
)

CD %LS_TestClientRoot%\trunk\CodeCrowd\Scripts
ECHO Set the configuration to 'Local'...
CALL SetConfig.bat Local >%LS_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to set the configuration to 'Local'. >&2
   ECHO See %LS_Output% >&2
   GOTO LblDoneWithError
)

ECHO Rebuild the CodeCrowd solution %LS_TestClientSolutionPath%...
devenv /build Debug %LS_TestClientSolutionPath% >%LS_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to build the CodeCrowd solution. >&2
   ECHO See %LS_Output% >&2
   GOTO LblDoneWithError
)

ECHO Creating the database backup in %LS_PathToBackupFile%...
SQLCMD.EXE -b -S %CC_SqlServerName% -E -Q "BACKUP DATABASE %CC_SqlServerDatabaseName% TO DISK='%LS_PathToBackupFile%'" >%LS_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to create the database backup in %LS_PathToBackupFile%. >&2
   ECHO See %LS_Output% >&2
   GOTO LblDoneWithError
)

IF "%LS_RefreshDB%"=="0" GOTO LblAfterRefreshDB

CALL CleanAndRestoreData.bat /Cfg Local /Backup %LS_PathToBackupFile%
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterRefreshDB

START %LS_TestClientRoot%\trunk\CodeCrowd\CodeCrowd\CodeCrowd.sln

ECHO.
ECHO The Local Environment was prepared.

cmd /C EXIT 0
GOTO LblExit

:LblDoneWithError
ECHO.
ECHO LocalSetup.bat completed with errors! >&2
cmd /C EXIT 1
GOTO LblExit

:LblExit
REM POPD
GOTO :EOF

REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO.
ECHO This script will prepare the 'Local' environment needed
ECHO to use the CodeCrowd application on a local database. This consists from:
ECHO     - Create a backup of the local database.
ECHO     - Update the SVN test client.
ECHO     - Refresh clean the 'local' database. This will bring the 'local'
ECHO       database to the latest schema.
ECHO     - Transfer data from the backup into the 'local' database.
ECHO     - Create the test account on the 'local' database.
ECHO     - Give access to the test account to all projects in the 'local' database.
ECHO.
ECHO Usage: LocalSetup.bat  [/?] ^| [/NoDB]
ECHO.
ECHO.  /?      - It will display this help page.
ECHO   /NoDB   - Do not refresh the 'local' database. The 'local' database 
ECHO             is left untouched.
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

GOTO :EOF
