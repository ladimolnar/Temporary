@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File CleanAndRestoreData.bat
REM Restores data from a database backup file. 
REM =================================================================
SETLOCAL

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
SET CRD_TempDbName=CodeCrowdTemp
SET CRD_Configuration=Unknown
SET CRD_PathToBackupFile=Unknown
SET CRD_Output="%Temp%\CRD_Output.txt"

:StartArgLoop
IF "%1" == ""           (GOTO LblDoneArgs)
IF "%1" == "/?"         (CALL :SubHelp & GOTO LblExitOK)
IF /I "%1" == "/Cfg"    (SET CRD_Configuration=%~2& GOTO LblNextArg2)
IF /I "%1" == "/Backup" (SET CRD_PathToBackupFile=%~2& GOTO LblNextArg2)

ECHO Error. Unknown argument %1>&2
GOTO LblBadArgs

:LblNextArg2
SHIFT 
:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Error! Invalid command line arguments. Use CleanAndRestoreData.bat /? >&2
GOTO LblDoneWithError

:LblDoneArgs

IF "%CRD_Configuration%" == "Unknown" (ECHO You must specify the /Cfg parameter >&2 & GOTO LblBadArgs)
IF "%CRD_PathToBackupFile%" == "Unknown" (ECHO You must specify the /Backup parameter >&2 & GOTO LblBadArgs)

ECHO.

CALL SetConfigVars.bat /%CRD_Configuration%
IF ERRORLEVEL 1 GOTO LblDoneWithError

CALL SetConfig.bat %CRD_Configuration% >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to set the configuration "%CRD_Configuration%". >&2
   ECHO See %CRD_Output% >&2
   GOTO LblDoneWithError
)

ECHO Drop database %CRD_TempDbName%...
SQLCMD.EXE -b -S %CC_SqlServerName% -E -Q "IF EXISTS (SELECT [name] FROM sys.databases WHERE [name] = '%CRD_TempDbName%') BEGIN; DROP DATABASE [%CRD_TempDbName%]; END" >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to drop database %CRD_TempDbName%. >&2
   ECHO See %CRD_Output% >&2
   GOTO LblDoneWithError
)

ECHO Restore the backup in database %CRD_TempDbName%...
SQLCMD.EXE -b -S %CC_SqlServerName% -E -Q "RESTORE DATABASE %CRD_TempDbName% FROM DISK = '%CRD_PathToBackupFile%' WITH MOVE '%CC_SqlServerDatabaseName%' TO '%TEMP%\%CC_SqlServerDatabaseName%.mdf', MOVE '%CC_SqlServerDatabaseName%_Log' TO '%TEMP%\%CC_SqlServerDatabaseName%.ldf'" >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to restore the backup in database %CRD_TempDbName%. >&2
   ECHO See %CRD_Output% >&2
   GOTO LblDoneWithError
)

ECHO Refresh clean the %CC_SqlServerDatabaseName% database...
CALL RefreshDB.bat /Cfg %CRD_Configuration% /Clean /SetupAspClean /Quiet /LQuiet >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO. >&2
   ECHO Error! Unable to refresh the %CC_SqlServerDatabaseName% database. >&2
   ECHO See %CRD_Output% >&2
   GOTO LblDoneWithErrorAfterDBWasLost
)

ECHO Create the test accounts...
CALL CodeCrowdUtils.bat /AddUsers >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to create the test account >&2
   ECHO See %CRD_Output% >&2
   GOTO LblDoneWithErrorAfterDBWasLost
)

ECHO Transfer data from %CRD_TempDbName% into the %CC_SqlServerDatabaseName% database...
SQLCMD.EXE -b -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% -E -i "%CC_SQLSources%\Utils\TransferData.SQL" >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to transfer data from %CRD_TempDbName% into the %CC_SqlServerDatabaseName% database. >&2
   GOTO LblDoneWithErrorAfterDBWasLost
)

ECHO Give access to all the test account to all projects...
SQLCMD.EXE -b -S %CC_SqlServerName% -d %CC_SqlServerDatabaseName% %CC_SqlServerLoginDbOwnerUser% -Q "INSERT INTO UserData.CCT_ProjectAccessByUser (ProjectUid, UserUid, AccessLevelCreatedDateUtc, AccessLevelCreatedRevision, AccessLevelModifiedDateUtc, AccessLevelModifiedRevision, SetByClientSessionUid, AccessLevel) SELECT CCT_Project.ProjectUid, Users.UserUid, GETDATE(), 1, GETDATE(), 1, CAST ('00000000-0000-0000-0000-000000000000' AS uniqueidentifier), 31 FROM Data.CCT_Project, (SELECT CCT_User.UserUid FROM UserData.CCT_User INNER JOIN dbo.aspnet_Users ON aspnet_Users.UserId = CCT_User.Asp_UserUid) AS Users" >%CRD_Output% 2>&1
IF ERRORLEVEL 1 (
   ECHO Error! Unable to give access to the test account to all projects. >&2
   ECHO See %CRD_Output% >&2
   GOTO LblDoneWithError
)

ECHO Drop database %CRD_TempDbName%...
SQLCMD.EXE -b -S %CC_SqlServerName% -E -Q "IF EXISTS (SELECT [name] FROM sys.databases WHERE [name] = '%CRD_TempDbName%') BEGIN; DROP DATABASE [%CRD_TempDbName%]; END"
IF ERRORLEVEL 1 (ECHO Warning: Unable to drop database %CRD_TempDbName%.)

ECHO.
ECHO The backup %CRD_PathToBackupFile% was restored.

:LblExitOK
cmd /C EXIT 0
GOTO LblExit

:LblDoneWithErrorAfterDBWasLost

ECHO Consider following these steps:>&2
ECHO     1. Update TransferData.SQL>&2
ECHO     2. Run SetConfig.bat %CRD_Configuration%>&2
ECHO     3. Run: CleanAndRestoreData.bat /Cfg %CRD_Configuration% /Backup %CRD_PathToBackupFile%>&2
ECHO Error. See %CRD_Output% >&2

:LblDoneWithError
ECHO.
ECHO CleanAndRestoreData.bat completed with errors! >&2
cmd /C EXIT 1
GOTO LblExit

:LblExit
REM POPD
GOTO :EOF

REM ==============================================================
REM Prints a help page to the output
REM ==============================================================
:SubHelp

ECHO.
ECHO CleanAndRestoreData.bat - Cleans and restores the data from a 
ECHO                           database backup file.
ECHO Usage: CleanAndRestoreData.bat [/?]  /Cfg Configuration 
ECHO                              /Backup PathToDatabaseBackupFile
ECHO.
ECHO. /?       - Will display this help page.
ECHO  /Cfg     - Configuration specifies the configuration type.
ECHO             Valid values: Dev, Local, Prod, Test, ...
ECHO  /Backup  - PathToDatabaseBackupFile specifies the path to 
ECHO             a database backup file.
ECHO.
ECHO  This script assumes but does not verifies that the backup corresponds 
ECHO  to a database that is compatible with the latest schema. That is a 
ECHO  database that can be handled by TransferData.SQL.
ECHO.
ECHO  The database backup is temporarily restored in a database called 
ECHO  CodeCrowdTemp. CodeCrowdTemp is dropped at the begining and end 
ECHO  of a successful procedure.
ECHO.
ECHO Exit Code:
ECHO     0 - Script completed successfully.
ECHO     1 - There were errors completing the script.

GOTO :EOF
