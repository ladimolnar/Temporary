@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =====================================================================
REM FILE: VerifyXAPFile.bat
REM Used in the post build step for the main web application. 
REM It will make sure that the XAP file with the correct name is deployed.
REM =====================================================================
SETLOCAL

SET VXAP_PathToScriptFolder=%~dp0
CALL %VXAP_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblError

SET VXAP_TargetFound=0
SET VXAP_ExtraFilesFound=0

CALL %VXAP_PathToScriptFolder%\GetBuildInfo.bat 
SET VXAP_XAPFileName=Fractalia_V%FRCT_MajorVersion%_%FRCT_MinorVersion%.xap
SET VXAP_PathToXAPDirectory=%FRCT_SrcRoot%\Fractalia.Web\ClientBin

ECHO target: [%VXAP_XAPFileName%]
FOR  /F "usebackq tokens=*" %%a in (`DIR /B "%VXAP_PathToXAPDirectory%\*.xap"`) DO (
   IF "%%a" == "%VXAP_XAPFileName%" (
      SET VXAP_TargetFound=1
      ECHO Target found
   ) ELSE (
      SET VXAP_ExtraFilesFound=1
      ECHO Error: Unexpected XAP files found: %%a >&2
   )
)

ECHO.
IF "%VXAP_TargetFound%" == "0" (ECHO Error: Target '%VXAP_XAPFileName%' not found >&2& GOTO LblError)
IF "%VXAP_ExtraFilesFound%" == "1" (ECHO Error: Unexpected XAP files found >&2& GOTO LblError)

GOTO LblDone

:LblError
ECHO Error: VerifyXAPFile.bat encountered errors.>&2
ECHO Error: Please make sure that the XAP file is generated with the correct name: '%VXAP_XAPFileName%' and that no unexpected XAP files are left in %VXAP_PathToXAPDirectory%.>&2
SET GBI_ExitCode=1

:LblDone
EXIT /B %GBI_ExitCode%

ENDLOCAL
GOTO :EOF

