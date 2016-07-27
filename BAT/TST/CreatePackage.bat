@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM ===================================================
REM FILE CreatePackage.bat
REM Used to copy all the files that must be deployed in  a package
REM ===================================================
SETLOCAL

SET CP_ExitCode=1
SET CP_TSTOutput="%Temp%\CreateTSTPackageOutput.txt"
SET CP_DestinationFolder=
SET CP_SourceFolder=E:\Sources\SVNClient\TST\trunk

IF /I "%1"=="/?" (CALL :SubHelpPage & SET CP_ExitCode=0& GOTO LblDone)

SET CP_DestinationFolder=%~1
IF /I "%CP_DestinationFolder%"=="" (
   ECHO Error: Invalid command line parameters. Please specify the path to the destination folder. >&2
   SET CP_ExitCode=1
   GOTO LblDone
)
   
IF /I NOT "%~2"=="" (
   ECHO Error: Invalid command line parameters. Too many parameters. >&2
   SET CP_ExitCode=1
   GOTO LblDone
)

IF NOT EXIST "%CP_DestinationFolder%" (
   ECHO Error: Folder %CP_DestinationFolder% does not exists. >&2
   SET CP_ExitCode=1
   GOTO LblDone
)   

CALL :SubShowCheckList
IF ERRORLEVEL 1 (
   ECHO Error during the package checklist >&2
   SET CP_ExitCode=1
   GOTO LblDone
)   

ECHO.
ECHO Deleting the content of the destination folder.

DEL /Q /S /F "%CP_DestinationFolder%\*.*"
IF ERRORLEVEL 1 (
   ECHO Error when deleting the content of %CP_DestinationFolder% >&2
   SET CP_ExitCode=1
   GOTO LblDone
)   

ECHO.
ECHO Copying files to the destination folder.

CALL :SubPackageFile "SetTSTDatabase.sql"                                           & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "TST.bat"                                                      & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "DOC\SetTSTQuickStart.sql"                                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "DOC\TST.docx"                                                 & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "DOC\TST.mht"                                                  & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "DOC\TST.pdf"                                                  & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\TSTCheck.bat"                                            & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheck.sql"                                         & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckError.sql"                                    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckMaster.sql"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckNoTests.sql"                                  & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckSchema.sql"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTableEmptyOrNot.sql"                          & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckCustomPrefix.sql"                             & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckSimple.sql"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckSessionLevelOutput.sql"                       & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckIgnore.sql"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTable.sql"                                    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTran.sql"                                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTransactionErrors.sql"                        & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\TSTErrorHandling.bat"                                    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckView_TSTResultsEx.sql"                        & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTestSession.sql"                              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTestSession2.sql"                             & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\SetTSTCheckTestSessionErr.sql"                           & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\ErrorHandling.txt"                              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\HelpPage.txt"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\PreserveTSTVariables.txt"                       & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\QuickStart.txt"                                 & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\QuickStart.xml"                                 & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelErrorOutputVerbose.txt"             & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelErrorOutputVerbose.xml"             & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelFailureOutputVerbose.txt"           & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelFailureOutputVerbose.xml"           & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelIgnoreOutputVerbose.txt"            & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelIgnoreOutputVerbose.xml"            & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelOutput.txt"                         & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelOutputVerbose.txt"                  & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionLevelOutputVerbose.xml"                  & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionOnlyTeardownFailureOutputVerbose.txt"    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionOnlyTeardownFailureOutputVerbose.xml"    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionSetupFailureOutputVerbose.txt"           & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionSetupFailureOutputVerbose.xml"           & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionTeardownFailureOutputVerbose.txt"        & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SessionTeardownFailureOutputVerbose.xml"        & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDb.txt"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDb.xml"                                   & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteFailed.txt"                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteFailed.xml"                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteFailedVerbose.txt"              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteFailedVerbose.xml"              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteIgnored.txt"                    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteIgnored.xml"                    & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteIgnoredVerbose.txt"             & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuiteIgnoredVerbose.xml"             & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuitePassed.txt"                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuitePassed.xml"                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuitePassedVerbose.txt"              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunSuitePassedVerbose.xml"              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestFailed.txt"                      & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestFailed.xml"                      & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestFailedVerbose.txt"               & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestFailedVerbose.xml"               & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestIgnored.txt"                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestIgnored.xml"                     & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestIgnoredVerbose.txt"              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestIgnoredVerbose.xml"              & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestPassed.txt"                      & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestPassed.xml"                      & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestPassedVerbose.txt"               & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbRunTestPassedVerbose.xml"               & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbVerbose.txt"                            & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)
CALL :SubPackageFile "Test\Baseline\SimpleDbVerbose.xml"                            & IF ERRORLEVEL 1 (GOTO LblPackageFileFailed)

ECHO.
ECHO Package created at %CP_DestinationFolder%

ECHO.
ECHO Running TSTCheck in %CP_DestinationFolder% ...

CALL "%CP_DestinationFolder%\Test\TSTCheck.bat" >%CP_TSTOutput% 2>&1
IF ERRORLEVEL 1 (
   ECHO TSTCheck failed. See %CP_TSTOutput%>&2
   SET CP_ExitCode=1
   GOTO LblDone
)   

ECHO TSTCheck passed.

ECHO.
ECHO Do not forget to create a new tag in SVN if you deploy a new release.
PAUSE 

SET CP_ExitCode=0
GOTO LblDone

:LblPackageFileFailed
SET CP_ExitCode=1
GOTO LblDone

:LblDone
EXIT /B %CP_ExitCode%

ENDLOCAL
GOTO :EOF


REM ==============================================================
REM Copies a given file to the destination folder.
REM Types an error in case of failure
REM Return code: 
REM   0 - OK
REM   1 - A failure occured. An error message was already displayed.
REM ==============================================================
:SubPackageFile

SET CP_PackageFileExitCode=0
SET CP_SourceFile=%~1

ECHO F | XCOPY "%CP_SourceFolder%\%CP_SourceFile%" "%CP_DestinationFolder%\%CP_SourceFile%" >nul
IF ERRORLEVEL 1 (
   ECHO Error when copying file %CP_SourceFile% to %CP_DestinationFolder% >&2
   SET CP_PackageFileExitCode=1
   GOTO LblPackageFileDone
)   
ECHO File %CP_SourceFolder%\%CP_SourceFile% copied

:LblPackageFileDone

EXIT /B %CP_PackageFileExitCode%
GOTO :EOF


REM ==============================================================
REM Shows the checklist that must be performed when creating a package
REM Return code: 
REM   0 - OK
REM   1 - User aborted the process.
REM ==============================================================
:SubShowCheckList

SET CP_ChecklistExitCode=0

SET CP_SVNChanges=0
SVN stat %CP_SourceFolder% > %CP_TSTOutput% 2>&1
FOR /F "usebackq tokens=* delims=." %%a in (%CP_TSTOutput%) do (SET CP_SVNChanges=1)

IF "%CP_SVNChanges%"=="1" (ECHO. & ECHO Error: It seems that there are open/modified files in SVN under %CP_SourceFolder% & GOTO LblChecklistError)

ECHO.
ECHO Go in SQL Server Management Studio, refresh the list of databases 
ECHO and delete all TST related databases including the TST database.
PAUSE 

GOTO LblChecklistDone

:LblChecklistError
SET CP_ChecklistExitCode=1
GOTO LblChecklistDone

:LblChecklistDone

EXIT /B %CP_ChecklistExitCode%
GOTO :EOF


REM ==============================================================
REM Prints a help page to the output
REM ==============================================================
:SubHelpPage

ECHO.
ECHO CreatePackage.bat - Creates a deployment package for TST.
ECHO Usage: CreatePackage.bat [/?] ^| DestinationFolder
ECHO.                /?    Will display this help page.
ECHO  DestinationFolder    Path to the destination folder where the 
ECHO                       package is created.
ECHO.
ECHO CreatePackage.bat will run the test automation (TSTCheck) that validates the
ECHO TST framework directly in the package folder to make sure all necessary files
ECHO are transfered.
ECHO.

GOTO :EOF
