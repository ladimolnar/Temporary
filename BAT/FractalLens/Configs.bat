@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File Configs.bat
REM Can compare config files or set the web.config file to a certain configuration
REM Arguments: Run "Configs.bat /?"
REM =================================================================
SETLOCAL

SET CFG_PathToScriptFolder=%~dp0
SET CFG_ProductionWebConfigName=WebConfig_Production.xml
SET CFG_TestWebConfigName=WebConfig_Test.xml
SET CFG_ExitCode=0

REM Set parameters corresponding to default values
SET CFG_Function=Compare
SET CFG_Compare1=%CFG_TestWebConfigName%
SET CFG_Compare2=%CFG_ProductionWebConfigName%


IF "%1" == "/?" (CALL :SubHelp & GOTO LblExit)
IF "%1" == "" (GOTO LblDoneArgs)
IF /I "%1" == "/C" (GOTO LblCompareArgs)
IF /I "%1" == "/Compare" (GOTO LblCompareArgs)

IF /I "%1" == "/Test" (
   IF NOT "%2" == "" (GOTO LblBadArgs) 
   SET CFG_Function=PromoteTestConfig
   GOTO LblDoneArgs
)

IF /I "%1" == "/Prod" (
   IF NOT "%2" == "" (GOTO LblBadArgs) 
   SET CFG_Function=PromoteProdConfig
   GOTO LblDoneArgs
)

GOTO LblBadArgs

:LblCompareArgs

SET CFG_Function=Compare
IF NOT "%3" == "" (GOTO LblBadArgs) 
IF "%2" == "" (GOTO LblDoneArgs)
IF /I "%2" == "PT" (SET CFG_Compare1=%CFG_TestWebConfigName%&SET CFG_Compare2=%CFG_ProductionWebConfigName%& GOTO LblDoneArgs)
IF /I "%2" == "CT" (SET CFG_Compare1=Web.config&SET CFG_Compare2=%CFG_TestWebConfigName%& GOTO LblDoneArgs)
IF /I "%2" == "CP" (SET CFG_Compare1=Web.config&SET CFG_Compare2=%CFG_ProductionWebConfigName%& GOTO LblDoneArgs)

:LblBadArgs

ECHO Invalid command line arguments. Use Configs.bat /? >&2
GOTO LblFatalError

:LblDoneArgs

if "%CFG_Function%"=="Compare" (
   BCompare.EXE %CFG_PathToScriptFolder%..\Fractalia.Web\%CFG_Compare1% %CFG_PathToScriptFolder%..\Fractalia.Web\%CFG_Compare2%
   IF ERRORLEVEL 1 GOTO :LblFatalError
   GOTO LblDone
)

if "%CFG_Function%"=="PromoteTestConfig" (
   COPY %CFG_PathToScriptFolder%..\Fractalia.Web\%CFG_TestWebConfigName% %CFG_PathToScriptFolder%..\Fractalia.Web\Web.config
   IF ERRORLEVEL 1 GOTO :LblFatalError
   GOTO LblDone
)

if "%CFG_Function%"=="PromoteProdConfig" (
   COPY %CFG_PathToScriptFolder%..\Fractalia.Web\%CFG_ProductionWebConfigName% %CFG_PathToScriptFolder%..\Fractalia.Web\Web.config
   IF ERRORLEVEL 1 GOTO :LblFatalError
   GOTO LblDone
)

:LblDone

IF %CFG_ExitCode% EQU 0 (ECHO.&ECHO Configs.bat Completed Successfully! >&2) ELSE (ECHO.&ECHO Configs.bat Failed! >&2)

:LblExit
EXIT /B %CFG_ExitCode%

ENDLOCAL
GOTO :EOF

:LblFatalError
SET CFG_ExitCode=1
GOTO LblDone




REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO.
ECHO Usage: Configs.bat  /C[ompare] [pt ct cp] ^| /Test ^| /Prod
ECHO  /Compare pt ct cp
ECHO              will compare the config files for test and production.
ECHO                 pt will compare between production and test configs.
ECHO                 ct will compare between current and test configs.
ECHO                 cp will compare between current and production configs.
ECHO                 default is pt
ECHO  /Test       will promote the test config file to the web.config.
ECHO  /Prod       will promote the production config file to the web.config.
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

goto :EOF

