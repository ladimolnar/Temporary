@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File Archive.BAT
REM Archives the project
REM =================================================================
SETLOCAL

SET CA_SVNRepositoryPath=E:\SVNRepos\CodeCrowd
SET CA_WinZipPath=C:\Program Files (x86)\WinZip\WZZIP.EXE

SET CC_PathToScriptFolder=%~dp0
CALL %CC_PathToScriptFolder%\SetCoreEnvVars.bat
IF ERRORLEVEL 1 GOTO LblDoneWithError

SET CA_Mode=Unknown
SET CA_Output=%CC_Temp%\ArchiveOutput.txt


:StartArgLoop
IF "%1" == "" (GOTO LblDoneArgs)
IF "%1" == "/?" (CALL :SubHelp & GOTO LblExitOK)

IF /I "%1" == "/C"         (SET CA_Mode=Copy& SET CA_PathToDestinationFolder=%~2& GOTO LblNextArg2)
IF /I "%1" == "/Z"         (SET CA_Mode=Winzip& SET CA_PathToDestinationZipFile=%~2& GOTO LblNextArg2)

ECHO Error. Unknown argument %1>&2
GOTO LblBadArgs

:LblNextArg2
SHIFT 

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Invalid command line arguments. Use Winzip.BAT /? >&2
GOTO LblDoneWithError

:LblDoneArgs

IF "%CA_Mode%" == "Copy" GOTO LblCopy
IF "%CA_Mode%" == "Winzip" GOTO LblWinzip

ECHO You must specify the /C or /Z parameter >&2
GOTO LblBadArgs

:LblCopy

IF "%CA_PathToDestinationFolder%" == "" (ECHO You must provide the PathToDestinationFolder argument for the parameter /C >&2 & GOTO LblBadArgs)

echo Don't forget to manually archive the LargeFiles folder as well.
pause

ECHO Copying to %CA_PathToDestinationFolder%...
CALL :SubCopy %CA_PathToDestinationFolder%
IF ERRORLEVEL 1 GOTO LblDoneWithError

GOTO LblDoneOK

:LblWinzip

IF "%CA_PathToDestinationZipFile%" == "" (ECHO You must provide the PathToDestinationZipFile argument for the parameter /Z >&2 & GOTO LblBadArgs)

echo Don't forget to manually archive the LargeFiles folder as well.
pause

IF EXIST %CA_PathToDestinationZipFile% (
   ECHO Error: The destination zip file already exists.>&2
   GOTO LblDoneWithError
)

CALL :SubSetSParam %CC_PathToScriptFolder%\ArchiveP.TXT
IF ERRORLEVEL 1 GOTO LblDoneWithError

SET CA_TempCopyPath=%CC_Temp%\Archive
SET CA_PathToTempZipFile=%CC_Temp%\Archive.ZIP

RMDIR /S /Q %CA_TempCopyPath% >nul 2>&1
IF EXIST %CA_TempCopyPath% (
   ECHO Error: Unable to delete %CA_TempCopyPath% >&2
   GOTO LblDoneWithError
)

DEL /F /Q "%CA_PathToTempZipFile%" >nul 2>&1
IF EXIST "%CA_PathToTempZipFile%" (
   ECHO Error: Unable to delete %CA_PathToTempZipFile% >&2
   GOTO LblDoneWithError
)

ECHO Copying to %CA_TempCopyPath%...
CALL :SubCopy %CA_TempCopyPath%
IF ERRORLEVEL 1 (
   ECHO Error: Cannot Copy the data to "%CA_TempCopyPath%" >&2
   GOTO LblDoneWithError
)

ECHO Create ZIP file: %CA_PathToTempZipFile%
"%CA_WinZipPath%" -whs -r -p "%CA_PathToTempZipFile%" "%CA_TempCopyPath%\*.*" >"%CA_Output%" 2>&1
IF ERRORLEVEL 1 (
   ECHO Error running WZZIP: >&2
   TYPE "%CA_Output%" >&2
   GOTO LblDoneWithError
)

ECHO Create ZIP file: %CA_PathToDestinationZipFile%

"%CA_WinZipPath%" %CA_SParam% %CA_PathToDestinationZipFile% %CA_PathToTempZipFile% >"%CA_Output%" 2>&1
IF ERRORLEVEL 1 (
   ECHO Error running WZZIP: >&2
   TYPE "%CA_Output%" >&2
   GOTO LblDoneWithError
)

DEL /Q %CA_PathToTempZipFile% 

GOTO LblDoneOK

:LblDoneOK
ECHO.
ECHO Archive.BAT ended successfully.

:LblExitOK
SET CC_ExitCode=0

:LblExit
cmd /C EXIT %CC_ExitCode%
ENDLOCAL
GOTO :EOF

:LblDoneWithError
ECHO.>&2
ECHO Archive.BAT done with errors! >&2
SET CC_ExitCode=1
GOTO LblExit

REM ==============================================================
REM Performs the Copy
REM ==============================================================
:SubCopy

SET SA_PathToCopyFolder=%~1

REM Makes sure that the SVN repository exists
IF NOT EXIST %CA_SVNRepositoryPath% (
   ECHO Error: Cannot find the SVN Repository at: "%CA_SVNRepositoryPath%" >&2
   GOTO LblCopyDoneWithError
)

REM Makes sure that the destination folder does not exist
IF EXIST %SA_PathToCopyFolder% (
   ECHO Error: The destination folder already exists>&2
   GOTO LblCopyDoneWithError
)

CALL %CC_PathToScriptFolder%\GetBuildInfo.bat %CC_SVNTrunk%
IF ERRORLEVEL 1 GOTO LblCopyDoneWithError

MKDIR %SA_PathToCopyFolder%
IF NOT EXIST %SA_PathToCopyFolder% (
   ECHO Error: Unable to create the folder "%SA_PathToCopyFolder%" >&2
   GOTO LblCopyDoneWithError
)

ECHO Date: %DATE% %TIME% > %SA_PathToCopyFolder%\info.txt
ECHO SVN Revision Nr: %CC_SvnRevisionNr% >> %SA_PathToCopyFolder%\info.txt
ECHO SVN Open State: %CC_SvnOpenState% >> %SA_PathToCopyFolder%\info.txt

ECHO Copying the project from %CC_SVNTrunk% ...
REM Copy the entire project from the SVN trunk excluding a specified set of files.
XCOPY %CC_SVNTrunk% %SA_PathToCopyFolder%\trunk /E /I /H /Q /EXCLUDE:NoArchive.txt

ECHO Copying the SVN repository from %CA_SVNRepositoryPath% ...
XCOPY %CA_SVNRepositoryPath% %SA_PathToCopyFolder%\SVNRepos /E /I /H /Q

cmd /c exit 0
GOTO :EOF

:LblCopyDoneWithError
cmd /c exit 1
GOTO :EOF

REM ==============================================================
REM Sets the /s parameter for WZZIP.EXE/WZUNZIP.EXE
REM ==============================================================
:SubSetSParam

SET CA_PathToPFile=%~1

FOR /F "usebackq tokens=*" %%a in ("%CA_PathToPFile%") do (
   SET CA_SParam=/s%%a
   GOTO LblSParamSet
)

:LblSParamSet
IF "%CA_SParam%" == "" (
   ECHO Unable to set the password from file %CA_PathToPFile%.>&2
   GOTO LblSParamDoneWithError
)

GOTO :EOF

:LblSParamDoneWithError
cmd /c exit 1
GOTO :EOF


REM ==============================================================
REM Prints a help page to the output
REM ==============================================================
:SubHelp

ECHO.
ECHO Archive.BAT - Will archive all the files in the trunk or
ECHO               current tag version.
ECHO Remember to install both the winzip150.exe (or newer) 
ECHO and wzcline32.exe on your system.
ECHO.
ECHO Usage: Archive.BAT /? ^| /C PathToDestinationFolder ^| 
ECHO                         /Z PathToDestinationZipFile
ECHO.
ECHO.    /?                         Will display this help page.
ECHO.
ECHO     /C                         A Copy will be performed.
ECHO     PathToDestinationFolder    Indicates the path of the destination folder.
ECHO                                The destination folder must NOT exist.
ECHO     /Z                         A WinZip will be performed.
ECHO     PathToDestinationZipFile   Indicates the path of the destination ZIP file.
ECHO                                The destination ZIP file must NOT exist.
ECHO.
ECHO Exit Code:
ECHO     0 - Script completed successfully.
ECHO     1 - There were errors completing the script.

GOTO :EOF
