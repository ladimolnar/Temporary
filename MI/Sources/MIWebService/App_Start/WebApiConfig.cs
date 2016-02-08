using System.Web.Http;

namespace MIWebService
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services

            // Web API routes
            config.MapHttpAttributeRoutes();

            // http://localhost:57732/api/claims/c-002/vehicles/1M8GDM9AXKP000002
            config.Routes.MapHttpRoute(
                name: "VehiclesApi",
                routeTemplate: "api/claims/{claimNumber}/{controller}/{vin}"
            );

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{claimNumber}",
                defaults: new { claimNumber = RouteParameter.Optional }
            );
        }
    }
}
