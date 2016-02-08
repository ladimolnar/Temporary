using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Hosting;
using System.Web.Http.Routing;
using MIWebService.Controllers;

namespace MIWebService.Tests.Utilities
{
    /// <summary>
    /// A helper class containing methods related to setting up controllers 
    /// so that they can be used in the context of test automations.
    /// </summary>
    public static class ControllerHelper
    {
        /// <summary>
        /// Generates and returns an instance of type <see cref="ClaimsController"/> 
        /// that can be used in the context of test automation.
        /// </summary>
        public static ClaimsController GenerateClaimsController()
        {
            var claimsController = new ClaimsController();
            SetupControllerForTests(claimsController);
            return claimsController;
        }

        /// <summary>
        /// Generates and returns an instance of type <see cref="VehiclesController"/> 
        /// that can be used in the context of test automation.
        /// </summary>
        public static VehiclesController GenerateVehiclesController()
        {
            return new VehiclesController();
        }

        private static void SetupControllerForTests(ApiController controller)
        {

            var config = new HttpConfiguration();
            var request = new HttpRequestMessage(HttpMethod.Post, WebServiceHelpers.BaseUrl);
            var route = config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{claimNumber}");
            var routeData = new HttpRouteData(route, new HttpRouteValueDictionary
            {
                {"claimNumber", string.Empty},
                {"controller", "claims"}
            });

            controller.ControllerContext = new HttpControllerContext(config, routeData, request);
            controller.Request = request;
            controller.Request.Properties[HttpPropertyKeys.HttpConfigurationKey] = config;
            controller.Request.Properties[HttpPropertyKeys.HttpRouteDataKey] = routeData;
            controller.Url = new UrlHelper(request);
        }
    }
}
