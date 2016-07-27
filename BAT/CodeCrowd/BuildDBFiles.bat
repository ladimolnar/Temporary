@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File BuildDBFiles.BAT
REM Prepares the SQL files so that they can be executed by SQL Server.
REM =================================================================
SETLOCAL

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

SET CCDB_Clean=0
SET CCDB_SetupSqlScript=Unknown
SET CCDB_Configuration=Unknown

:StartArgLoop
IF "%1" == "" (GOTO LblDoneArgs)
IF "%1" == "/?" (CALL :SubHelp & GOTO LblExitOK)
IF /I "%1" == "/Cfg"          (SET CCDB_Configuration=%~2& GOTO LblNextArg2)
IF /I "%1" == "/Out"          (SET CCDB_SetupSqlScript=%~2& GOTO LblNextArg2)
IF /I "%1" == "/Clean"        (SET CCDB_Clean=1& GOTO LblNextArg)
GOTO LblBadArgs

:LblNextArg2
SHIFT 

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Invalid command line arguments. Use BuildDBFiles.BAT /? >&2
GOTO LblDoneWithError

:LblDoneArgs

IF "%CCDB_Configuration%" == "Unknown" (ECHO You must specify the /Cfg parameter >&2 & GOTO LblBadArgs)

CALL SetConfigVars.bat /%CCDB_Configuration%
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%CCDB_SetupSqlScript%" == "Unknown" (ECHO You must specify the /Out parameter >&2 & GOTO LblBadArgs)


DEL /F /Q "%CCDB_SetupSqlScript%" >nul 2>&1
IF EXIST %CCDB_SetupSqlScript% (
   ECHO Error: Unable to delete "%CCDB_SetupSqlScript%" >&2
   GOTO LblDoneWithError
)

ECHO USE [%CC_SqlServerDatabaseName%] >> "%CCDB_SetupSqlScript%"

CALL :SubProcessAndAddSqlScript "%CC_SQLSources%\Cleanup\CleanProcedures.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubProcessAndAddSqlScript "%CC_SQLSources%\Cleanup\CleanViews.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF NOT "%CCDB_Clean%" == "1" GOTO LblAfterClean
ECHO.

CALL :SubProcessAndAddSqlScript "%CC_SQLSources%\Cleanup\CleanTables.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError
CALL :SubProcessAndAddSqlScript "%CC_SQLSources%\Cleanup\CleanSchemas.sql"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblAfterClean
ECHO.
FOR /F "tokens=* usebackq" %%a in (`dir /B /ON "%CC_SQLSources%\Setup\SETUP_????_*.sql"`) do (
   CALL :SubProcessAndAddSqlScript "%CC_SQLSources%\Setup\%%a"
   IF ERRORLEVEL 1 GOTO LblDoneWithError
)

REM This will replace in the final SQL script three or more consecutive empty lines with two empty lines.
%CC_Bin%\FR.EXE "%CCDB_SetupSqlScript%" "%CCDB_SetupSqlScript%"
IF ERRORLEVEL 1 GOTO LblDoneWithError

:LblDoneOK
ECHO.
ECHO Script: "%CCDB_SetupSqlScript%"
ECHO BuildDBFiles ended successfully.

:LblExitOK
SET CC_ExitCode=0

:LblExit
cmd /C EXIT %CC_ExitCode%
ENDLOCAL
GOTO :EOF

:LblDoneWithError
ECHO.>&2
ECHO BuildDBFiles done with errors! >&2
SET CC_ExitCode=1
GOTO LblExit


REM =================================================================
REM SubProcessAndAddSqlScript
REM Processes and adds the SQL script given by %1 to the file given by %CCDB_SetupSqlScript%
REM =================================================================
:SubProcessAndAddSqlScript

SET CC_ScriptFileName=%~nx1
SET CC_ScriptFilePath=%~1

ECHO Process %CC_ScriptFileName%

REM Replace the '--' sql comments with '//' C style comments
%CC_Bin%\FR.EXE "%CC_ScriptFilePath%" "%CC_Temp%\%CC_ScriptFileName%"
IF ERRORLEVEL 1 GOTO LblProcessScriptWithError

REM Compile the source files into the actual SQL file that can be executed by SQL Server
CL.EXE /nologo "%CC_Temp%\%CC_ScriptFileName%" /EP /I "%CC_SQLSources%" /DMACRO_AdminUserName=%CC_AdminUserName% /DMACRO_LoggedUserName=%CC_LoggedUserName% > "%CC_Temp%\Target_%CC_ScriptFileName%" 2>"%CC_Temp%\CLOutput.log"
IF ERRORLEVEL 1 (
   ECHO Error running CL.EXE. Make sure that you are running in a VS command prompt. >&2
   TYPE "%CC_Temp%\CLOutput.log" >&2
   GOTO LblProcessScriptWithError
)

ECHO /*============================================================= >> "%CCDB_SetupSqlScript%"
ECHO Source: %CC_ScriptFileName% >> "%CCDB_SetupSqlScript%"
ECHO =============================================================*/ >> "%CCDB_SetupSqlScript%"
ECHO. >> "%CCDB_SetupSqlScript%"
TYPE "%CC_Temp%\Target_%CC_ScriptFileName%">> "%CCDB_SetupSqlScript%"
IF ERRORLEVEL 1 (GOTO :EOF)
ECHO. >> "%CCDB_SetupSqlScript%"

GOTO :EOF

:LblProcessScriptWithError
cmd /c exit 1
goto :EOF



REM ==============================================================
REM Prints a help page to the output
REM ==============================================================
:SubHelp

ECHO.
ECHO BuildDBFiles.BAT - Will generate the SQL script needed
ECHO                    to setup the CodeCrowd database.
ECHO.
ECHO Usage: BuildDBFiles.BAT  [/?] (/Cfg Configuration)) 
ECHO                          [/Clean] [/Out PathToSqlScript]
ECHO.
ECHO.    /?       Will display this help page.
ECHO     /Cfg     Configuration specifies the configuration type.
ECHO              Valid values: Dev, Prod, Test, ...
ECHO     /Clean   If specified the SQL script that is generated will 
ECHO              contain a cleanup portion. 
ECHO              By default only procedures, functions 
ECHO              and views are regenerated from scratch. 
ECHO              By default tables are subjected only to upgrade 
ECHO              type changes.
ECHO     /Out     PathToSqlScript is the path to the SQL script that 
ECHO              will be generated. This script will contain the 
ECHO              SQL commands that will setup the CodeCrowd database.
ECHO.
ECHO Exit Code:
ECHO     0 - Script completed successfully.
ECHO     1 - There were errors completing the script.

GOTO :EOF

