@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File SetDBVars.bat
REM Sets some environment variables needed by the 
REM scripts used for "Fractalia" web application
REM and that connect to DB.
REM =================================================================

SET FRCT_DBOwnerUserName=FractDBOwner
SET FRCT_DBOwnerUserPwd=Tyru-3345-y-rR
SET FRCT_SqlServerLoginDbOwnerUser=-U %FRCT_DBOwnerUserName% -P %FRCT_DBOwnerUserPwd%

SET FRCT_AdminUserName=FractAdminUser
SET FRCT_AdminUserPwd=Uieu45-392i-TE
SET FRCT_SqlServerLoginAdminUser=-U %FRCT_AdminUserName% -P %FRCT_AdminUserPwd%

SET FRCT_AnonymousUserName=FractAnonUser
SET FRCT_AnonymousUserPwd=Huei3TT-35-ahW
SET FRCT_SqlServerLoginAnonymousUser=-U %FRCT_AnonymousUserName% -P %FRCT_AnonymousUserPwd%

SET FRCT_ProductionSqlServerName=sqlserver9.loosefoot.com
SET FRCT_SqlServerDatabaseName=Fractalia_0224
