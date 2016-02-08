using System.Web.Http;
using MIWebService.DataLayer;
using MIWebService.Infrastructure;

namespace MIWebService
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            Repository repository = new Repository();
            repository.InitializeWithTestData();
            ServiceLocator.RegisterRepository(repository);

            GlobalConfiguration.Configure(WebApiConfig.Register);
        }
    }
}
