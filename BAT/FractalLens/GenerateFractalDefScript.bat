@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File GenerateFractalDefScript.bat
REM See SubHelp or run GenerateFractalDefScript.bat /?
REM =================================================================
SETLOCAL

SET FRGS_ExitCode=0
SET FRGS_XmlCount=0
SET FRGS_UserName=Admin

IF "%1" == "/?" (CALL :SubHelp & GOTO LblDone)

SET FRGS_PathToScriptFolder=%~dp0
CALL %FRGS_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblError

SET FRGS_DirectoryPath=%~1
SET FRGS_GeneratedScriptPath=%~2
SET FRGS_DefaultGeneratedScriptPath=%FRCT_SQLSources%\InitSeedData.SQL


IF "%FRGS_DirectoryPath%" == "" (ECHO Invalid command line. Run GenerateFractalDefScript.bat /?>&2 & GOTO LblError)

IF NOT "%FRGS_GeneratedScriptPath%" == "" GOTO LblAfterCmdArguments
SET FRGS_GeneratedScriptPath=%FRGS_DefaultGeneratedScriptPath%

:LblAfterCmdArguments

CALL :SubGenerateHeader
IF ERRORLEVEL 1 GOTO LblError

FOR /F "tokens=* usebackq" %%a in (`dir /B /O-N "%FRGS_DirectoryPath%\*.xml"`) do (
   CALL :SubGenerateXmlFragment "%FRGS_DirectoryPath%\%%a"
   IF ERRORLEVEL 1 GOTO LblError
)

CALL :SubGenerateFooter
IF ERRORLEVEL 1 GOTO LblError

IF "%FRGS_XmlCount%" == "0" (
   ECHO Error: No XML files were processed.>&2
   GOTO LblError
)

ECHO.
ECHO %FRGS_XmlCount% XML file(s) were processed.
ECHO The SQL script was generated in: "%FRGS_GeneratedScriptPath%"

GOTO LblDone

:LblError
ECHO Error generating the SQL script.>&2
SET FRGS_ExitCode=1

:LblDone
EXIT /B %FRGS_ExitCode%

ENDLOCAL
GOTO :EOF


REM =================================================================
REM SubGenerateHeader
REM =================================================================
:SubGenerateHeader

CALL :SubSetGeneratedScriptName "%FRGS_GeneratedScriptPath%"
ECHO -- FILE %FRGS_GeneratedScriptName% > "%FRGS_GeneratedScriptPath%"
ECHO -- Do not modify. This script is automatically generated.>> "%FRGS_GeneratedScriptPath%"
ECHO -- See GenerateFractalDefScript.bat>> "%FRGS_GeneratedScriptPath%"
ECHO. >> "%FRGS_GeneratedScriptPath%"

GOTO :EOF

:SubSetGeneratedScriptName
SET FRGS_GeneratedScriptName=%~nx1
GOTO :EOF


REM =================================================================
REM SubGenerateXmlFragment
REM =================================================================
:SubGenerateXmlFragment 
SET FRGS_PathToXmlFile=%~1
SET FRGS_XmlFileName=%~n1

ECHO Transfer data from %FRGS_XmlFileName%

ECHO INSERT INTO Data.FRT_FractalDefinition^(UserName, FractalName, FractalDefinition, IpAddress^) VALUES ^( >> "%FRGS_GeneratedScriptPath%"
ECHO '%FRGS_UserName%', >> "%FRGS_GeneratedScriptPath%"
ECHO '%FRGS_XmlFileName%', >> "%FRGS_GeneratedScriptPath%"
ECHO '\>> "%FRGS_GeneratedScriptPath%"
TYPE "%FRGS_PathToXmlFile%">> "%FRGS_GeneratedScriptPath%"
ECHO ',>> "%FRGS_GeneratedScriptPath%"
ECHO '0.0.0.0'^)>> "%FRGS_GeneratedScriptPath%"
ECHO. >> "%FRGS_GeneratedScriptPath%"
ECHO WAITFOR DELAY '0:0:0.02' >> "%FRGS_GeneratedScriptPath%"
ECHO. >> "%FRGS_GeneratedScriptPath%"

SET /A FRGS_XmlCount=FRGS_XmlCount+1

GOTO :EOF

REM =================================================================
REM SubGenerateFooter
REM =================================================================
:SubGenerateFooter

ECHO. >> "%FRGS_GeneratedScriptPath%"
ECHO PRINT 'Seed data was inserted in Data.FRT_FractalDefinition'>> "%FRGS_GeneratedScriptPath%"
ECHO. >> "%FRGS_GeneratedScriptPath%"

GOTO :EOF


REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO.
ECHO Usage: GenerateFractalDefScript.bat PathToSourceDirectory PathToGeneratedSqlScript
ECHO.
ECHO Generates a SQL script that will initialize 
ECHO the table Data.FRT_FractalDefinition with 
ECHO the content of all XML files from a specified directory.
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

GOTO :EOF
