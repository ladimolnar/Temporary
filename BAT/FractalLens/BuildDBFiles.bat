@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File BuildDBFiles.bat
REM Prepares the SQL files so that they can be executed by SQL Server.
REM =================================================================

SET FRCT_PathToScriptFolder=%~dp0
CALL %FRCT_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

SET FRCT_BuildDBStage=0
RMDIR /S /Q %FRCT_Target% >nul 2>&1
IF EXIST %FRCT_Target% (
   ECHO Error: Unable to delete the folder "%FRCT_Target%" >&2
   GOTO LblDoneWithError
)

MKDIR %FRCT_Target% >nul 2>&1
IF NOT EXIST %FRCT_Target% (
   ECHO Error: Unable to create the folder "%FRCT_Target%" >&2
   GOTO LblDoneWithError
)

SET FRCT_BuildDBStage=1

ECHO.
ECHO Replace the '--' sql comments with '//' C style comments
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CleanProcedures.sql"            "%FRCT_Temp%\CleanProcedures.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CleanTables.sql"                "%FRCT_Temp%\CleanTables.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CleanViews.sql"                 "%FRCT_Temp%\CleanViews.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CreateTables.sql"               "%FRCT_Temp%\CreateTables.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CreateViews.sql"                "%FRCT_Temp%\CreateViews.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CreateSprocs.sql"               "%FRCT_Temp%\CreateSprocs.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError

%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\Data.sql"                       "%FRCT_Temp%\Data.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\Log.sql"                        "%FRCT_Temp%\Log.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\InitDatabase.sql"               "%FRCT_Temp%\InitDatabase.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CleanSchemas.sql"               "%FRCT_Temp%\CleanSchemas.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\CreateSchemas.sql"              "%FRCT_Temp%\CreateSchemas.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\DefMacros.h"                    "%FRCT_Temp%\DefMacros.h"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\MacroFractalDefinitions.h"      "%FRCT_Temp%\MacroFractalDefinitions.h"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
%FRCT_Bin%\FR.EXE "%FRCT_SQLSources%\InitSeedData.sql"               "%FRCT_Temp%\InitSeedData.sql"
IF ERRORLEVEL 1 GOTO :LblDoneWithError

SET FRCT_BuildDBStage=2
ECHO Compile source files into the actual SQL files that can be executed by SQL Server
CL /nologo "%FRCT_Temp%\CleanProcedures.sql" /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CleanProcedures.sql"  2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CleanTables.sql"     /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CleanTables.sql"      2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CleanViews.sql"      /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CleanViews.sql"       2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CleanSchemas.sql"    /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CleanSchemas.sql"     2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CreateSprocs.sql"    /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CreateSprocs.sql"     2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CreateTables.sql"    /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CreateTables.sql"     2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CreateViews.sql"     /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CreateViews.sql"      2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\CreateSchemas.sql"   /EP /I "%FRCT_Temp%" > "%FRCT_Target%\CreateSchemas.sql"    2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError
CL /nologo "%FRCT_Temp%\InitSeedData.sql"    /EP /I "%FRCT_Temp%" > "%FRCT_Target%\InitSeedData.sql"     2>"%FRCT_Temp%\CLOutput.log"
IF ERRORLEVEL 1 GOTO :LblDoneWithError

SET FRCT_BuildDBStage=3

:LblDone
ECHO.
ECHO BuildDBFiles ended successfully.

cmd /c exit 0
goto :EOF

:LblDoneWithError
ECHO.
ECHO BuildDBFiles done with errors!
IF "%FRCT_BuildDBStage%" == "2" (type "%FRCT_Temp%\CLOutput.log" >&2)
cmd /c exit 1
goto :EOF
