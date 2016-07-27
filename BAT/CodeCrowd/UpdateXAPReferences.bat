@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File UpdateXAPReferences.bat
REM Updates all the references to the XAP file according
REM to the AssemblyFileVersion value as stored in 
REM CodeCrowd\trunk\CodeCrowd\CodeCrowd\CodeCrowd\Properties\AssemblyInfo.cs
REM =================================================================

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%1" == "/?" (
   ECHO This tool invokes UpdateXAPReferences.EXE with the appropiate parameters.
   GOTO LblExitOK
)

REM Clean the content of CodeCrowd.Web\ClientBin
DEL /F /Q %CC_ProjectSources%\CodeCrowd.Web\ClientBin\*.xap
IF EXIST %CC_ProjectSources%\CodeCrowd.Web\ClientBin\*.xap (
   ECHO Error: Unable to delete %CC_ProjectSources%\CodeCrowd.Web\ClientBin\*.* >&2
   GOTO LblDoneWithError
)

REM Update the references to the XAP file using the correct name
%CC_Bin%\UpdateXAPReferences.EXE CodeCrowd %CC_ProjectSources%\CodeCrowd\Properties\AssemblyInfo.cs %CC_ProjectSources%\CodeCrowd\CodeCrowd.csproj %CC_ProjectSources%\CodeCrowd.Web\CodeCrowd.Web.csproj

:LblExitOK
cmd /c exit 0
GOTO :EOF

:LblDoneWithError
ECHO.
ECHO UpdateXAPReferences done with errors!
cmd /c exit 1
GOTO :EOF
