@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File SetCoreEnvVars.bat
REM Sets some core environment variables needed by the 
REM scripts used for "Fractalia" web application.
REM =================================================================

SET FRCT_StartFolder=%~pd0
PUSHD "%FRCT_StartFolder%"
CD ..
REM Set the root location for the build system. For example: E:\Sources\SVNClient\Fractalia\trunk\Fractalia
FOR /F "tokens=*" %%a IN ('CD') DO (SET FRCT_SrcRoot=%%a)
CD ..
REM Set the trunk location for the build system. For example: E:\Sources\SVNClient\Fractalia\trunk
FOR /F "tokens=*" %%a IN ('CD') DO (SET FRCT_SrcTrunk=%%a)
POPD

SET FRCT_MajorVersion=2
SET FRCT_MinorVersion=5

SET FRCT_Bin=%FRCT_SrcRoot%\Scripts\Bin
SET FRCT_SQLSources=%FRCT_SrcRoot%\SQL
SET FRCT_Target=%FRCT_SQLSources%\Target

IF NOT EXIST %Temp%\Fractalia MKDIR %Temp%\Fractalia >nul 2>&1
SET FRCT_Temp=%Temp%\Fractalia
DEL /S /Q %FRCT_Temp% >nul 2>&1
