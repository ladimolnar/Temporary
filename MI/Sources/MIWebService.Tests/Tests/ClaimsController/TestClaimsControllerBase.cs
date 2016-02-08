using MIWebService.Controllers;
using MIWebService.DataLayer;
using MIWebService.Infrastructure;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests.Tests
{
    public class TestClaimsControllerBase
    {
        protected ClaimsController ClaimsController { get; private set; }

        static TestClaimsControllerBase()
        {
            // We can choose here to use a mock repository or the actual repository.
            // Using a mock repository will push the test automation more towards a unit test approach.
            // Using the actual repository will push the test automation more towards an integration test approach.
            // For now we'll use the actual repository (which BTW, at this point, is a dummy in-memory version).
            // In a real project we'd need to decide our test automation investment, how much we invest in
            // integration tests and how much we invest in unit tests. The pros and cons for 
            // both approaches are quite different. Those pros and cons also depend on the nature of the project 
            // so this is worth discussing and planning in advance.
            ServiceLocator.RegisterRepository(new Repository());
        }

        public TestClaimsControllerBase()
        {
            ClaimsController = ControllerHelper.GenerateClaimsController();
        }
    }
}
