@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File SetConfig.bat
REM Can promote a certain configuration to the active configuration.
REM Can also compare various versions of the config files.
REM Arguments: Run "SetConfig.bat /?"
REM =================================================================
SETLOCAL

SET CCCFG_PathToScriptFolder=%~dp0
SET CCCFG_ExitCode=0
SET CCCFG_Configuration=Unknown
SET CCCFG_WebConfigFolder=%CCCFG_PathToScriptFolder%..\CodeCrowd\CodeCrowd.Web
SET CCCFG_UtilsConfigFolder=%CCCFG_PathToScriptFolder%..\CodeCrowd\CodeCrowdUtils
SET CCCFG_UnitTestConfigFolder=%CCCFG_PathToScriptFolder%..\CodeCrowd\CodeCrowTest

REM Set parameters corresponding to default values
SET CCCFG_Function=NotSet
SET CCCFG_CompareVersion1=Dev
SET CCCFG_CompareVersion2=Test
SET CCCFG_CompareVersion3=Prod

IF "%1" == "" (
   ECHO Invalid command line arguments. You must specify an action. Use SetConfig.bat /? >&2
   GOTO LblFatalError
)

IF "%1" == "/?"            (CALL :SubHelp & GOTO LblExit)
IF /I "%1" == "/C"         (GOTO LblCompareArgs)
IF /I "%1" == "/Compare"   (GOTO LblCompareArgs)

SET CCCFG_Configuration=%~1

SET CCCFG_Function=PromoteConfig
GOTO LblDoneArgs

:LblCompareArgs


REM for comparision the configuration is not important. 
REM However, we need to set it to a value so that we can call SetConfigVars.bat
REM We need the call SetConfigVars.bat so that variables like CC_WebConfigName_XXX are set.
SET CCCFG_Configuration=Dev

SET CCCFG_Function=Compare

IF "%2" == "" (GOTO LblDoneArgs)
IF "%3" == "" (GOTO LblBadArgs) 
IF NOT "%5" == "" (GOTO LblBadArgs) 
SET CCCFG_CompareVersion1=%2
SET CCCFG_CompareVersion2=%3
SET CCCFG_CompareVersion3=%4

IF /I "%CCCFG_CompareVersion1%" == "Dev" GOTO LblVersion1OK
IF /I "%CCCFG_CompareVersion1%" == "Local" GOTO LblVersion1OK
IF /I "%CCCFG_CompareVersion1%" == "Prod" GOTO LblVersion1OK
IF /I "%CCCFG_CompareVersion1%" == "Test" GOTO LblVersion1OK
IF /I "%CCCFG_CompareVersion1%" == "T001" GOTO LblVersion1OK

GOTO LblBadArgs

:LblVersion1OK

IF /I "%CCCFG_CompareVersion2%" == "Dev" GOTO LblVersion2OK
IF /I "%CCCFG_CompareVersion2%" == "Local" GOTO LblVersion2OK
IF /I "%CCCFG_CompareVersion2%" == "Prod" GOTO LblVersion2OK
IF /I "%CCCFG_CompareVersion2%" == "Test" GOTO LblVersion2OK
IF /I "%CCCFG_CompareVersion2%" == "T001" GOTO LblVersion2OK

GOTO LblBadArgs

:LblVersion2OK

IF /I "%CCCFG_CompareVersion3%" == "" GOTO LblVersion3OK
IF /I "%CCCFG_CompareVersion3%" == "Dev" GOTO LblVersion3OK
IF /I "%CCCFG_CompareVersion3%" == "Local" GOTO LblVersion3OK
IF /I "%CCCFG_CompareVersion3%" == "Prod" GOTO LblVersion3OK
IF /I "%CCCFG_CompareVersion3%" == "Test" GOTO LblVersion3OK
IF /I "%CCCFG_CompareVersion3%" == "T001" GOTO LblVersion3OK

GOTO LblBadArgs

:LblVersion3OK

IF /I "%CCCFG_CompareVersion1%" == "%CCCFG_CompareVersion2%" (ECHO Attempt to compare a version with itself is invalid>&2 & GOTO LblBadArgs)
IF /I "%CCCFG_CompareVersion1%" == "%CCCFG_CompareVersion3%" (ECHO Attempt to compare a version with itself is invalid>&2 & GOTO LblBadArgs)
IF /I "%CCCFG_CompareVersion2%" == "%CCCFG_CompareVersion3%" (ECHO Attempt to compare a version with itself is invalid>&2 & GOTO LblBadArgs)

GOTO LblDoneArgs

:LblBadArgs

ECHO Invalid command line arguments. Use SetConfig.bat /? >&2
GOTO LblFatalError

:LblDoneArgs

CALL SetConfigVars.bat /%CCCFG_Configuration%
IF ERRORLEVEL 1 GOTO LblFatalError

if "%CCCFG_Function%"=="Compare" (
   CALL :SubCompare %CCCFG_CompareVersion1% %CCCFG_CompareVersion2% %CCCFG_CompareVersion3%
   IF ERRORLEVEL 1 GOTO LblFatalError
   GOTO LblDone
)

if "%CCCFG_Function%"=="PromoteConfig" (
   CALL :SubPromoteConfig %CCCFG_ActiveConfig%
   IF ERRORLEVEL 1 GOTO LblFatalError
   GOTO LblDone
)

:LblDone

IF %CCCFG_ExitCode% EQU 0 (ECHO.&ECHO SetConfig.bat Completed Successfully! >&2) ELSE (ECHO.&ECHO SetConfig.bat Failed! >&2)

:LblExit
EXIT /B %CCCFG_ExitCode%

ENDLOCAL
GOTO :EOF

:LblFatalError
SET CCCFG_ExitCode=1
GOTO LblDone

REM =================================================================
REM :SubCompare
REM =================================================================
:SubCompare

IF /I "%1" == "Dev"     (SET CCCFG_ConfigPath1=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Dev%)
IF /I "%1" == "Local"   (SET CCCFG_ConfigPath1=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Local%)
IF /I "%1" == "Prod"    (SET CCCFG_ConfigPath1=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Prod%)
IF /I "%1" == "Test"    (SET CCCFG_ConfigPath1=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Test%)
IF /I "%1" == "T001"    (SET CCCFG_ConfigPath1=%CCCFG_WebConfigFolder%\%CC_WebConfigName_T001%)

IF /I "%2" == "Dev"     (SET CCCFG_ConfigPath2=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Dev%)
IF /I "%2" == "Local"   (SET CCCFG_ConfigPath2=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Local%)
IF /I "%2" == "Prod"    (SET CCCFG_ConfigPath2=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Prod%)
IF /I "%2" == "Test"    (SET CCCFG_ConfigPath2=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Test%)
IF /I "%2" == "T001"    (SET CCCFG_ConfigPath2=%CCCFG_WebConfigFolder%\%CC_WebConfigName_T001%)
   
SET CCCFG_ConfigPath3=
IF /I "%3" == "Dev"     (SET CCCFG_ConfigPath3=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Dev%)
IF /I "%3" == "Local"   (SET CCCFG_ConfigPath3=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Local%)
IF /I "%3" == "Prod"    (SET CCCFG_ConfigPath3=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Prod%)
IF /I "%3" == "Test"    (SET CCCFG_ConfigPath3=%CCCFG_WebConfigFolder%\%CC_WebConfigName_Test%)
IF /I "%3" == "T001"    (SET CCCFG_ConfigPath3=%CCCFG_WebConfigFolder%\%CC_WebConfigName_T001%)

BCompare.EXE %CCCFG_ConfigPath1% %CCCFG_ConfigPath2% %CCCFG_ConfigPath3%
GOTO :EOF
   

REM =================================================================
REM :SubPromoteConfig
REM =================================================================
:SubPromoteConfig

SET CCCFG_ConfigSourcePath=%CCCFG_WebConfigFolder%\%CC_WebConfigFileName%
SET CCCFG_ConfigDestinationPath=%CCCFG_WebConfigFolder%\Web.config

ECHO.
ECHO COPY %CC_WebConfigFileName% to Web.config
COPY %CCCFG_ConfigSourcePath% %CCCFG_ConfigDestinationPath%
IF ERRORLEVEL 1 GOTO LblPromoteConfigError

REM IF /I "%CCCFG_Configuration%" == "Dev"    GOTO LblPromoteDevAppsConfig
REM IF /I "%CCCFG_Configuration%" == "Local"  GOTO LblPromoteDevAppsConfig
REM GOTO LblPromoteConfigDoneOK

:LblPromoteDevAppsConfig

SET CCCFG_ConfigSourcePath=%CCCFG_UtilsConfigFolder%\%CC_AppConfigFileName%
SET CCCFG_ConfigDestinationPath=%CCCFG_UtilsConfigFolder%\App.config

ECHO.
ECHO COPY %CC_AppConfigFileName% to App.config in CodeCrowdUtils
COPY %CCCFG_ConfigSourcePath% %CCCFG_ConfigDestinationPath%
IF ERRORLEVEL 1 GOTO LblPromoteConfigError

SET CCCFG_ConfigSourcePath=%CCCFG_UtilsConfigFolder%\%CC_AppConfigFileName%
SET CCCFG_ConfigDestinationPath=%CCCFG_PathToScriptFolder%\Binaries\CodeCrowdUtils\CodeCrowdUtils.exe.config

ECHO COPY %CC_AppConfigFileName% to Scripts\Binaries\CodeCrowdUtils\CodeCrowdUtils.exe.config
COPY %CCCFG_ConfigSourcePath% %CCCFG_ConfigDestinationPath%
IF ERRORLEVEL 1 GOTO LblPromoteConfigError

SET CCCFG_ConfigSourcePath=%CCCFG_UnitTestConfigFolder%\%CC_AppConfigFileName%
SET CCCFG_ConfigDestinationPath=%CCCFG_UnitTestConfigFolder%\App.config

ECHO.
ECHO COPY %CC_AppConfigFileName% to App.config in CodeCrowTest
COPY %CCCFG_ConfigSourcePath% %CCCFG_ConfigDestinationPath%
IF ERRORLEVEL 1 GOTO LblPromoteConfigError

:LblPromoteConfigDoneOK

cmd /c exit 0
goto :EOF

:LblPromoteConfigError
cmd /c exit 1
goto :EOF


REM =================================================================
REM SubHelp
REM Displays the help page
REM =================================================================
:SubHelp
ECHO.
ECHO This script promotes a given configuration to the active configuration.
ECHO It can also be used to compare various versions of the config files.
ECHO.
ECHO Usage: SetConfig.bat  [/?] ^| 
ECHO        (Configuration) ^| (/C[ompare] [version1 version2 [version3]]) )
ECHO.
ECHO  Configuration  - Specifies the configuration type.
ECHO                   Valid values: Dev, Local, Prod, Test, T001
ECHO  /Compare       - Will compare the config files of two or three versions.
ECHO                   version1, version2 and version3 can be: 
ECHO                   Dev, Local, Prod, Test, T001
ECHO                   If the versions are not specified it will 
ECHO                   run a three way comparison between Dev, Prod and Test
ECHO.
ECHO Exit code:
ECHO      0 - OK
ECHO   != 0 - Error
ECHO.

goto :EOF

