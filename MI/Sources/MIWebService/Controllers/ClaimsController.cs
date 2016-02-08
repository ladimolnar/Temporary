using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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

        // GET api/<controller>
        public IEnumerable<MitchellClaim> Get()
        {
            return _repository.GetClaims();
        }

        // GET api/<controller>/22c9c23bac142856018ce14a26b6c299
        public MitchellClaim Get(string claimNumber)
        {
            MitchellClaim claim;
            if (_repository.TryGetClaim(claimNumber, out claim))
            {
                return claim;
            }

            throw new HttpResponseException(HttpStatusCode.NotFound);
        }

        // GET api/<controller>?minLossDate=...&maxLossDate=...
        public IEnumerable<MitchellClaim> Get(DateTime minLossDate, DateTime maxLossDate)
        {
            return _repository.GetClaimsInLossDateRange(minLossDate, maxLossDate);
        }

        // POST api/<controller>
        public HttpResponseMessage Post([FromBody]MitchellClaim claim)
        {
            return AddClaim(claim);
        }

        // PUT api/<controller>/22c9c23bac142856018ce14a26b6c299
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

        // DELETE api/<controller>/22c9c23bac142856018ce14a26b6c299
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

