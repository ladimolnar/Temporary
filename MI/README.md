# Mitchell International Coding Exercise

##Building the solution

All the projects in the solution are self contained. All dependencies are included via NuGet packages and should be retrieved by Visual Studio automatically.
The solution was built and tested with Visual Studio 2015 (Update 1) Community edition.

##Source code

The web service is a simple ASP.NET Web API. The most relevant sources are: 
- **Models**: See project [MIModels](Sources/MIModels) (Portable Class Library)
- **Controllers**: See [ClaimsController.cs](Sources/MIWebService/Controllers) and [VehiclesController.cs](Sources/MIWebService/VehiclesController.cs)
- **Test automation**: Implemented using Visual Studio tests. See project [MIWebService.Tests](Sources/MIWebService.Tests). The test classes are under the folders [Tests](Sources/MIWebService.Tests/Tests) and [IntegrationTests](Sources/MIWebService.Tests/IntegrationTests)

##Testing the solution

###Test Automation

The solution includes a test project: **MIWebService.Tests**. All test methods that are part of this projects can be run via Visual Studio. Go to *menu / TEST / Run / All Tests*. When you do this Visual Studio will show a test pane listing all tests and their status. If the test pane does not appear go to *menu / TEST / Windows / Test Explorer*. 

There is one test that has dependencies on the web service actually running locally. This test is **IntegrationTestBasicScenario**. Before running this test you need to start the web service. Right click on the MIWebService project and select *Debug / Start new instance*. You will see a page showing an error: *HTTP Error 403.14 - Forbidden*. That is OK, at this point Visual Studio will have started IIS Express and added to it your service. That will allow *IntegrationTestBasicScenario* to invoke the web services.

###Manual Tests 

You can use various tools like Fiddler once the web service is running on the local server. Unless you change the project settings for the project MIWebService, the base URL for the REST API provided is http://localhost:57732/api. For example to retrieve all the claims in the system you will have to access: http://localhost:57732/api/claims  
The document [Sources/Docs/Fiddler.txt](Sources/Docs/Fiddler.txt) contains more examples regarding how to access any of the APIs provided.  

Before using Fiddler or another tool make sure that the web service is running.

Note that the DEBUG build will generate a number of test claims automatically so simply accessing http://localhost:57732/api/claims should provide you with some results.
