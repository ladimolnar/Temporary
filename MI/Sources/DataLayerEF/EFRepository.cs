using System;
using System.Collections;
using System.Collections.Generic;
using MIModels;

namespace DataLayerEF
{
    public class EFRepository : IRepository
    {
        public bool ContainsClaim(string claimNumber)
        {
            throw new System.NotImplementedException();
        }

        public IEnumerable<MitchellClaim> GetClaims()
        {
            throw new System.NotImplementedException();
        }

        public bool TryGetClaim(string claimNumber, out MitchellClaim claim)
        {
            throw new System.NotImplementedException();
        }

        public void AddClaim(MitchellClaim claim)
        {
            throw new System.NotImplementedException();
        }

        public void UpdateClaim(MitchellClaim updater)
        {
            throw new System.NotImplementedException();
        }

        public bool TryRemoveClaim(string claimNumber)
        {
            throw new System.NotImplementedException();
        }

        public IEnumerable<MitchellClaim> GetClaimsInLossDateRange(DateTime minLossDate, DateTime maxLossDate)
        {
            throw new System.NotImplementedException();
        }
    }
}
