@ECHO OFF
IF "%useverbose%"=="1" ECHO ON
REM =================================================================
REM File SetConfigVars.bat
REM Sets some environment variables needed by the 
REM scripts used for the "CodeCrowd" web application
REM and that connect to DB.
REM =================================================================

SET CC_WebConfigName_Dev=WebConfig_Dev.xml
SET CC_WebConfigName_Local=WebConfig_Local.xml
SET CC_WebConfigName_Prod=WebConfig_Prod.xml
SET CC_WebConfigName_T001=WebConfig_T001.xml
SET CC_WebConfigName_Test=WebConfig_Test.xml

SET CC_UtilsConfigName_Dev=AppConfig_Dev.xml
SET CC_UtilsConfigName_Local=AppConfig_Local.xml
SET CC_UtilsConfigName_Prod=AppConfig_Prod.xml
SET CC_UtilsConfigName_T001=AppConfig_T001.xml
SET CC_UtilsConfigName_Test=AppConfig_Test.xml

IF /I "%1" == ""              GOTO LblInvalidArgs
IF /I "%1" == "/Dev"          GOTO LblSetConfigVars_Development
IF /I "%1" == "/Local"        GOTO LblSetConfigVars_Local
IF /I "%1" == "/Prod"         GOTO LblSetConfigVars_Production
IF /I "%1" == "/T001"         GOTO LblSetConfigVars_T001
IF /I "%1" == "/Test"         GOTO LblSetConfigVars_Test

:LblInvalidArgs

ECHO Invalid command line arguments for SetConfigVars.bat>&2
ECHO The Configuration is incorrect.>&2
GOTO LblDoneWithError

REM ==================================================
:LblSetConfigVars_Development

SET CC_DBOwnerUserName=CCDevDBOwner
SET CC_DBOwnerUserPwd=Replace_With_Pwd

SET CC_AdminUserName=CCDevAdmin
SET CC_AdminUserPwd=Replace_With_Pwd

SET CC_LoggedUserName=CCDevLogged
SET CC_LoggedUserPwd=Replace_With_Pwd

SET CC_SqlServerName=localhost
SET CC_SqlServerDatabaseName=CodeCrowd_Dev_0100

SET CC_WebConfigFileName=%CC_WebConfigName_Dev%
SET CC_AppConfigFileName=%CC_UtilsConfigName_Dev%

GOTO LblDoneOK

REM ==================================================
:LblSetConfigVars_Local

SET CC_DBOwnerUserName=CCLocalDBOwner
SET CC_DBOwnerUserPwd=Replace_With_Pwd

SET CC_AdminUserName=CCLocalAdmin
SET CC_AdminUserPwd=Replace_With_Pwd

SET CC_LoggedUserName=CCLocalLogged
SET CC_LoggedUserPwd=Replace_With_Pwd

SET CC_SqlServerName=localhost
SET CC_SqlServerDatabaseName=CodeCrowd_Local_0100

SET CC_WebConfigFileName=%CC_WebConfigName_Local%
SET CC_AppConfigFileName=%CC_UtilsConfigName_Local%

GOTO LblDoneOK

REM ==================================================
:LblSetConfigVars_Production

SET CC_DBOwnerUserName=CCPDBOwner
SET CC_DBOwnerUserPwd=Replace_With_Pwd

SET CC_AdminUserName=CCPAdmin
SET CC_AdminUserPwd=Replace_With_Pwd

SET CC_LoggedUserName=CCPLogged
SET CC_LoggedUserPwd=Replace_With_Pwd

SET CC_SqlServerName=sqlserver8.loosefoot.com
SET CC_SqlServerDatabaseName=ccp_0101

SET CC_WebConfigFileName=%CC_WebConfigName_Prod%
SET CC_AppConfigFileName=%CC_UtilsConfigName_Prod%

GOTO LblDoneOK

REM ==================================================
:LblSetConfigVars_T001

SET CC_DBOwnerUserName=CCPDBOwner
SET CC_DBOwnerUserPwd=Replace_With_Pwd

SET CC_AdminUserName=CCPAdmin
SET CC_AdminUserPwd=Replace_With_Pwd

SET CC_LoggedUserName=CCPLogged
SET CC_LoggedUserPwd=Replace_With_Pwd

SET CC_SqlServerName=sqlserver8.loosefoot.com
SET CC_SqlServerDatabaseName=ccp_0101

SET CC_WebConfigFileName=%CC_WebConfigName_T001%
SET CC_AppConfigFileName=%CC_UtilsConfigName_T001%

GOTO LblDoneOK

REM ==================================================
:LblSetConfigVars_Test

SET CC_DBOwnerUserName=CCTADBOwner
SET CC_DBOwnerUserPwd=Replace_With_Pwd

SET CC_AdminUserName=CCTAAdmin
SET CC_AdminUserPwd=Replace_With_Pwd

SET CC_LoggedUserName=CCTALogged
SET CC_LoggedUserPwd=Replace_With_Pwd

SET CC_SqlServerName=sqlserver8.loosefoot.com
SET CC_SqlServerDatabaseName=ccta0101

SET CC_WebConfigFileName=%CC_WebConfigName_Test%
SET CC_AppConfigFileName=%CC_UtilsConfigName_Test%

GOTO LblDoneOK

REM ==================================================
:LblDoneOK

SET CC_SqlServerLoginDbOwnerUser=-U %CC_DBOwnerUserName% -P %CC_DBOwnerUserPwd%
SET CC_SqlServerLoginAdminUser=-U %CC_AdminUserName% -P %CC_AdminUserPwd%
SET CC_SqlServerLoginLoggedUser=-U %CC_LoggedUserName% -P %CC_LoggedUserPwd%

cmd /C EXIT 0
GOTO :EOF

:LblDoneWithError

cmd /C EXIT 1
GOTO :EOF
