using MIWebService.Controllers;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests
{
    public class TestClaimsControllerBase: TestControllerBase
    {
        protected ClaimsController ClaimsController { get; private set; }

        public TestClaimsControllerBase()
        {
            ClaimsController = ControllerHelper.GenerateClaimsController();
        }
    }
}
