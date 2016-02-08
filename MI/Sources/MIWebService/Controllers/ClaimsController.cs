using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using MIModels;
using MIModels.Utilities;
using MIWebService.DataLayer;
using MIWebService.Infrastructure;

namespace MIWebService.Controllers
{
    public class ClaimsController : ApiController
    {
        private readonly IRepository _repository;

        public ClaimsController()
        {
            _repository = ServiceLocator.GetRepository();
        }

        /// <summary>
        /// Retrieves all claims from the system.
        /// </summary>
        /// <remarks>
        /// GET api/<controller>
        /// </remarks>
        public IEnumerable<MitchellClaim> Get()
        {
            return _repository.GetClaims();
        }

        /// <summary>
        /// Retrieves the specified claim from the system.
        /// </summary>
        /// <remarks>
        /// GET api/<controller>/22c9c23bac142856018ce14a26b6c299
        /// </remarks>
        public MitchellClaim Get(string claimNumber)
        {
            MitchellClaim claim;
            if (_repository.TryGetClaim(claimNumber, out claim))
            {
                return claim;
            }

            throw new HttpResponseException(HttpStatusCode.NotFound);
        }

        /// <summary>
        /// Retrieves all claims that have the loss date in the specified time range.
        /// </summary>
        /// <remarks>
        /// GET api/<controller>?minLossDate=...&maxLossDate=...
        /// </remarks>
        public IEnumerable<MitchellClaim> Get(DateTime minLossDate, DateTime maxLossDate)
        {
            return _repository.GetClaimsInLossDateRange(minLossDate, maxLossDate);
        }

        /// <summary>
        /// Creates a new claim.
        /// </summary>
        /// <remarks>
        /// POST api/<controller>
        /// </remarks>
        public HttpResponseMessage Post([FromBody]MitchellClaim claim)
        {
            return AddClaim(claim);
        }

        /// <summary>
        /// Update an existing claim or creates a new claim.
        /// Rules regarding updating vehicles:
        ///     - If the <paramref name="updater"/> does not have a list of vehicles then no vehicle is updated.
        ///     - If the <paramref name="updater"/> contains a new vehicle (new based on its VIN number)
        ///       then that vehicle is added to the claim being updated.
        ///     - If the <paramref name="updater"/> contains a vehicle also found in the claim being updated 
        ///       (based on its VIN number) then that vehicle is updated. 
        ///     - If the <paramref name="updater"/> contains a vehicle also found in the claim being updated 
        ///       (based on its VIN number) but the vehicle in the updater only has its VIN number specified then 
        ///       then that vehicle is not changed in the claim being updated.
        ///     - If the <paramref name="updater"/> does not contain a vehicle that is found in the claim being updated
        ///       (based on its VIN number) then that vehicle is deleted from the claim being updated. 
        /// </summary>
        /// <remarks>
        /// PUT api/<controller>/22c9c23bac142856018ce14a26b6c299
        /// </remarks>
        public HttpResponseMessage Put(string claimNumber, [FromBody]MitchellClaim updater)
        {
            if (updater.ClaimNumber != null && claimNumber != updater.ClaimNumber)
            {
                return new HttpResponseMessage(HttpStatusCode.Forbidden) { ReasonPhrase = "Inconsistent claim number." };
            }

            // In case the updater does not specify the claim number.
            updater.ClaimNumber = claimNumber;

            if (_repository.ContainsClaim(claimNumber))
            {
                return UpdateClaim(updater);
            }
            else
            {
                return AddClaim(updater);
            }
        }

        /// <summary>
        /// Deletes an existing claim.
        /// </summary>
        /// <remarks>
        /// DELETE api/<controller>/22c9c23bac142856018ce14a26b6c299
        /// </remarks>
        public HttpResponseMessage Delete(string claimNumber)
        {
            if (_repository.TryRemoveClaim(claimNumber))
            {
                return new HttpResponseMessage(HttpStatusCode.OK);
            }
            else
            {
                throw new HttpResponseException(HttpStatusCode.NotFound);
            }
        }

        private HttpResponseMessage AddClaim(MitchellClaim claim)
        {
            HttpResponseMessage response;

            try
            {
                _repository.AddClaim(claim);

                response = new HttpResponseMessage(HttpStatusCode.Created);
                response.Headers.Location = new Uri(Url.Link("DefaultApi", new { claimNumber = claim.ClaimNumber }));
            }
            catch (InvalidApiUsageException ex) when (ex.UsageError == ApiUsageError.ItemAlreadyExists)
            {
                response = new HttpResponseMessage(HttpStatusCode.Conflict) { ReasonPhrase = "Resource already exists." };
            }
            catch (InvalidApiUsageException ex) when (ex.UsageError == ApiUsageError.RequiredFieldNotSpecified)
            {
                response = new HttpResponseMessage(HttpStatusCode.Forbidden) { ReasonPhrase = "A required field is missing." };
            }
            catch (InvalidApiUsageException ex) when (ex.UsageError == ApiUsageError.DuplicateVehicles)
            {
                response = new HttpResponseMessage(HttpStatusCode.Forbidden) { ReasonPhrase = "Duplicate vehicles are not allowed." };
            }
            catch (InvalidApiUsageException)
            {
                response = new HttpResponseMessage(HttpStatusCode.Forbidden);
            }

            return response;
        }

        private HttpResponseMessage UpdateClaim(MitchellClaim updater)
        {
            HttpResponseMessage response;

            try
            {
                _repository.UpdateClaim(updater);
                response = new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (InvalidApiUsageException ex) when (ex.UsageError == ApiUsageError.RequiredFieldNotSpecified)
            {
                response = new HttpResponseMessage(HttpStatusCode.Forbidden) { ReasonPhrase = "A required field is missing." };
            }
            catch (InvalidApiUsageException ex) when (ex.UsageError == ApiUsageError.DuplicateVehicles)
            {
                response = new HttpResponseMessage(HttpStatusCode.Forbidden) { ReasonPhrase = "Duplicate vehicles are not allowed." };
            }

            return response;
        }
    }
}

