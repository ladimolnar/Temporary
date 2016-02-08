using System.Linq;
using System.Net;
using System.Web.Http;
using MIModels;
using MIWebService.DataLayer;
using MIWebService.Infrastructure;

namespace MIWebService.Controllers
{
    public class VehiclesController : ApiController
    {
        private readonly IRepository _repository;

        public VehiclesController()
        {
            _repository = ServiceLocator.GetRepository();
        }

        // GET api/claims/c-002/vehicles/1M8GDM9AXKP000002
        public VehicleDetails Get(string claimNumber, [FromUri]string vin)
        {
            MitchellClaim claim;

            if (_repository.TryGetClaim(claimNumber, out claim))
            {
                VehicleDetails vehicleDetails = claim.Vehicles.FirstOrDefault(v => v.Vin == vin);
                if (vehicleDetails != null)
                {
                    return vehicleDetails;
                }
            }

            throw new HttpResponseException(HttpStatusCode.NotFound);
        }
    }
}
