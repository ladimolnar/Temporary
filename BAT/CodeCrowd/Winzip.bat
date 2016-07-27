@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File Winzip.BAT
REM Compresse/uncompress an archive file
REM =================================================================
SETLOCAL

SET WZ_Mode=Unknown
SET WZ_PathToPasswordFile=
SET WZ_Output=%CC_Temp%\WinzipOutput.txt
SET WZ_SParam=

:StartArgLoop
IF "%1" == "" (GOTO LblDoneArgs)
IF "%1" == "/?" (CALL :SubHelp & GOTO LblExitOK)

IF /I "%1" == "/Zip"             (SET WZ_Mode=Zip& SET WZ_PathToSourceFolder=%~2& SET WZ_PathToZipFile=%~3& GOTO LblNextArg3)
IF /I "%1" == "/Unzip"           (SET WZ_Mode=Unzip& SET WZ_PathToZipFile=%~2& SET WZ_PathToDestinationFolder=%~3& GOTO LblNextArg3)
IF /I "%1" == "/P"               (SET WZ_PathToPasswordFile=%~2& GOTO LblNextArg2)

ECHO Error. Unknown argument %1>&2
GOTO LblBadArgs

:LblNextArg3
SHIFT 

:LblNextArg2
SHIFT 

:LblNextArg
SHIFT 
GOTO StartArgLoop

:LblBadArgs

ECHO Invalid command line arguments. Use Winzip.BAT /? >&2
GOTO LblDoneWithError

:LblDoneArgs

CALL :SubSetSParam
IF ERRORLEVEL 1 GOTO LblDoneWithError

IF "%WZ_Mode%" == "Zip" GOTO LblZip
IF "%WZ_Mode%" == "Unzip" GOTO LblUnzip

ECHO You must specify the /Zip or /Unzip parameter >&2
GOTO LblBadArgs

:LblZip

IF "%WZ_PathToSourceFolder%" == "" (ECHO You must provide the PathToSourceFolder argument for the parameter /Zip >&2 & GOTO LblBadArgs)
IF "%WZ_PathToZipFile%" == "" (ECHO You must provide the PathToZipFile argument for the parameter /Zip >&2 & GOTO LblBadArgs)

IF EXIST %WZ_PathToZipFile% (
   ECHO Error: The destination zip file already exists.>&2
   GOTO LblDoneWithError
)

WZZIP.EXE -whs -r -p %WZ_SParam% %WZ_PathToZipFile% %WZ_PathToSourceFolder%\*.* >"%WZ_Output%" 2>&1
IF ERRORLEVEL 1 (
   ECHO Error running WZZIP: >&2
   TYPE "%WZ_Output%" >&2
   GOTO LblDoneWithError
)

GOTO LblDoneOK

:LblUnzip

IF "%WZ_PathToZipFile%" == "" (ECHO You must provide the PathToZipFile argument for the parameter /Unzip >&2 & GOTO LblBadArgs)
IF "%WZ_PathToDestinationFolder%" == "" (ECHO You must provide the PathToDestinationFolder argument for the parameter /Unzip >&2 & GOTO LblBadArgs)

IF EXIST %WZ_PathToDestinationFolder% (
   ECHO Error: The destination folder already exists.>&2
   GOTO LblDoneWithError
)

WZUNZIP.EXE -d %WZ_SParam% %WZ_PathToZipFile% %WZ_PathToDestinationFolder% >"%WZ_Output%" 2>&1
IF ERRORLEVEL 1 (
   ECHO Error running WZUNZIP: >&2
   TYPE "%WZ_Output%" >&2
   GOTO LblDoneWithError
)

GOTO LblDoneOK

:LblDoneOK
ECHO.
ECHO Winzip.BAT ended successfully.

:LblExitOK
SET WZ_ExitCode=0

:LblExit
cmd /C EXIT %WZ_ExitCode%
ENDLOCAL
GOTO :EOF

:LblDoneWithError
ECHO.>&2
ECHO Winzip.BAT done with errors! >&2
SET WZ_ExitCode=1
GOTO LblExit

REM ==============================================================
REM Sets the /s parameter for WZZIP.EXE/WZUNZIP.EXE
REM ==============================================================
:SubSetSParam

IF "%WZ_PathToPasswordFile%" == "" GOTO :EOF

FOR /F "usebackq tokens=*" %%a in ("%WZ_PathToPasswordFile%") do (
   SET WZ_SParam=/s%%a
   GOTO LblSParamSet
)

:LblSParamSet
IF "%WZ_SParam%" == "" (
   ECHO Unable to set the password from file %WZ_PathToPasswordFile%.>&2
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
ECHO Winzip.BAT - Compresse/uncompress an archive.
ECHO.
ECHO Usage: Winzip.BAT /? ^| 
ECHO                   (/Zip PathToSourceFolder PathToZipFile ^|
ECHO                    /Unzip PathToZipFile PathToDestinationFolder)
ECHO                   [/P PathToPasswordFile]
ECHO.
ECHO.    /?                   Will display this help page.
ECHO     PathToSourceFolder   Indicates the path to the folder that 
ECHO                          will be compressed.
ECHO     PathToZipFile        Indicates the path to the file that is produced 
ECHO                          or extracted from.
ECHO     PathToDestinationFolder
ECHO                          Indicates the path to the folder where the 
ECHO                          content of the ZIP file is extracted.
ECHO     PathToPasswordFile   Indicates the path to the file that contains a 
ECHO                          password.
ECHO.
ECHO Exit Code:
ECHO     0 - Script completed successfully.
ECHO     1 - There were errors completing the script.

GOTO :EOF
