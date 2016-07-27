@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File SetCoreEnvVars.bat
REM Sets some core environment variables needed by the 
REM scripts used for the "CodeCrowd" web application.
REM =================================================================

SET CC_StartFolder=%~pd0
PUSHD "%CC_StartFolder%"
CD ..
REM Set the root location for the build system. For example: E:\Sources\SVNClient\CodeCrowd\trunk\CodeCrowd
FOR /F "tokens=*" %%a IN ('CD') DO (SET CC_SrcRoot=%%a)
CD ..
REM Set the SVN trunk/version location for the build system. 
REM For example: E:\Sources\SVNClient\CodeCrowd\trunk or E:\Sources\SVNClient\CodeCrowd\tags\Version_1_0
FOR /F "tokens=*" %%a IN ('CD') DO (SET CC_SVNArea=%%a)
CD ..
REM Set the SVN root location. For example: E:\Sources\SVNClient\CodeCrowd
FOR /F "tokens=*" %%a IN ('CD') DO (SET CC_SVNRoot=%%a)
POPD

SET CC_SVNTrunk=%CC_SVNArea%

SET CC_MajorVersion=1
SET CC_MinorVersion=3

SET CC_Bin=%CC_SrcRoot%\Scripts\Binaries
SET CC_Scripts=%CC_SrcRoot%\Scripts
SET CC_SQLSources=%CC_SrcRoot%\SQL
SET CC_ProjectSources=%CC_SrcRoot%\CodeCrowd
SET CC_SqlTarget=%CC_SQLSources%\Target

SET CC_Temp=%Temp%\CodeCrowd
DEL /S /Q /F %CC_Temp% >nul 2>&1
RMDIR /S /Q %CC_Temp% >nul 2>&1
IF NOT EXIST %CC_Temp% MKDIR %CC_Temp% >nul 2>&1

