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

        /// <summary>
        /// Retrieves a vehicle details for a specified claim and vehicle as identified by the VIN number.
        /// </summary>
        /// <remarks>
        /// GET api/claims/22c9c23bac142856018ce14a26b6c299/vehicles/1M8GDM9AXKP000002
        /// </remarks>
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
