# Mitchell International Coding Exercise

**Building the solution

The sources are self contained. All dependencies are included via NuGet packages and should be retrieved by Visual Studio automatically.
The solution was built and tested with Visual Studio 2015 (Update 1) Community edition.

##Testing the solution

###Test Automation

The solution includes a test project: MIWebService.Tests. All test methods that are part of this projects can be run via Visual Studio. Go to *menu / TEST / Run / All Tests*. When you do this Visual Studio will show a test pane listing all tests and their status. If the test pane does not appear go to *menu / TEST / Windows / Test Explorer*. 

There is one test that has dependencies on the web service actually running locally. This test is *IntegrationTestBasicScenario*. Before running this test you need to execute the MIWebService project once. Go to  *menu / DEBUG / Start Without Debugging* to test the project once. You will see a page showing an error: *HTTP Error 403.14 - Forbidden*. That is OK, at this point Visual Studio will have started IIS Express with your service and that will allow *IntegrationTestBasicScenario* to invoke the web services.

###Manual Tests 

You can use various tools like Fiddler against the local server. Unless you change the project settings for the project MIWebService, the base URL for the REST API provided is at http://localhost:57732/api. For example to obtain all the claims in the system you will have to access: http://localhost:57732/api/claims  
The document [Docs/Fiddler.txt](Fiddler.txt) contains more examples about accessing all the APIs provided.


