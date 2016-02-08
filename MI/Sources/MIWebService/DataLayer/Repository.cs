using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using MIModels;
using MIModels.Utilities;

namespace MIWebService.DataLayer
{
    /// <summary>
    /// The Repository used for the MIWebService. 
    /// In a production environment this would be some code that allows persistence (for example something based on EF or ADO.NET).
    /// For our purposes this will be a crude in-memory repository.
    /// </summary>
    public class Repository : IRepository
    {
        /// <summary>
        /// Stores all the claims in the system.
        /// KEY: the Claim Number
        /// VALUE: The claim
        /// </summary>
        private readonly Dictionary<string, MitchellClaim> _claims;

        public Repository()
        {
            _claims = new Dictionary<string, MitchellClaim>();
        }

        public bool ContainsClaim(string claimNumber)
        {
            return _claims.ContainsKey(claimNumber);
        }

        public IEnumerable<MitchellClaim> GetClaims()
        {
            return _claims.Values;
        }

        public bool TryGetClaim(string claimNumber, out MitchellClaim claim)
        {
            return _claims.TryGetValue(claimNumber, out claim);
        }

        public IEnumerable<MitchellClaim> GetClaimsInLossDateRange(DateTime minLossDate, DateTime maxLossDate)
        {
            return _claims.Values.Where(c => c.LossDate >= minLossDate && c.LossDate <= maxLossDate);
        }

        public void AddClaim(MitchellClaim claim)
        {
            if (claim.ValidateRequiredFields() == false)
            {
                throw new InvalidApiUsageException(ApiUsageError.RequiredFieldNotSpecified);
            }

            if (_claims.ContainsKey(claim.ClaimNumber))
            {
                throw new InvalidApiUsageException(ApiUsageError.ItemAlreadyExists);
            }

            if (claim.Vehicles.GroupBy(v => v.Vin).Any(g => g.Count() > 1))
            {
                throw new InvalidApiUsageException(ApiUsageError.DuplicateVehicles);
            }

            _claims.Add(claim.ClaimNumber, claim);
        }

        public bool TryRemoveClaim(string claimNumber)
        {
            return _claims.Remove(claimNumber);
        }

        public void UpdateClaim(MitchellClaim updater)
        {
            if (string.IsNullOrWhiteSpace(updater.ClaimNumber))
            {
                throw new InvalidApiUsageException(ApiUsageError.ClaimNumberNotSpecified);
            }

            MitchellClaim existingClaim;
            if (_claims.TryGetValue(updater.ClaimNumber, out existingClaim))
            {
                // Before updating the claim let's make sure we will not end up with an invalid claim.
                // We are going to create a clone, update the clone and only if everything looks fine then we'll 
                // persist the clone.
                MitchellClaim newClaim = existingClaim.DeepClone();
                newClaim.Update(updater);

                if (newClaim.ValidateRequiredFields() == false)
                {
                    throw new InvalidApiUsageException(ApiUsageError.RequiredFieldNotSpecified);
                }

                // Now that we know everything is OK, persist the updated claim.
                _claims[updater.ClaimNumber] = newClaim;
            }
            else
            {
                // This method is used incorrectly. The client may attempt to update a claim that does not exist but 
                // that attempt should not propagate to this level. 
                // As far as this method is concerned, this is an invalid call.
                throw new InvalidApiUsageException(ApiUsageError.ItemNotFound);
            }
        }

        [Conditional("DEBUG")]
        public void InitializeWithTestData()
        {
            GenerateTestClaims().ForEach(c => _claims.Add(c.ClaimNumber, c));
        }

        private List<MitchellClaim> GenerateTestClaims()
        {
            return new List<MitchellClaim>()
            {
                new MitchellClaim()
                {
                    ClaimNumber = "22c9c23bac142856018ce14a26b6c001",
                    Status = ClaimStatus.Closed,
                    ClaimantFirstName = "F1",
                    ClaimantLastName = "L1",
                    LossDate = DateTime.Now.Date.AddDays(-1),
                    LossInfo = new LossInfo()
                    {
                        CauseOfLoss = CauseOfLoss.Collision,
                        ReportedDate = DateTime.Now.Date,
                        LossDescription = "Hit from behind at a stop sign",
                    },
                    AssignedAdjusterId = 1000,
                    Vehicles = new List<VehicleDetails>()
                    {
                        new VehicleDetails()
                        {
                            Vin = "1M8GDM9AXKP042780",
                            ModelYear = 2015,
                            MakeDescription = "Ford",
                            ModelDescription = "Mustang",
                            EngineDescription = "EcoBoost",
                            ExteriorColor = "Blue",
                            LicPlate = "NO1PRES",
                            LicPlateState = "VA",
                            LicPlateExpDate = new DateTime(2010,1,1),
                            DamageDescription = "Bumper cracked",
                            Mileage = 100500,
                        },
                    },
                },
                new MitchellClaim()
                {
                    ClaimNumber = "Claim-1",
                    Status = ClaimStatus.Open,
                    ClaimantFirstName = "F2",
                    ClaimantLastName = "L2",
                    LossDate = DateTime.Now.Date.AddDays(-2),
                    LossInfo = new LossInfo()
                    {
                        CauseOfLoss = CauseOfLoss.MechanicalBreakdown,
                        ReportedDate = DateTime.Now.Date,
                        LossDescription = "Hit a telephone post",
                    },
                    AssignedAdjusterId = 1001,
                    Vehicles = new List<VehicleDetails>()
                    {
                        new VehicleDetails()
                        {
                            Vin = "1M8GDM9AXKP042780",
                            ModelYear = 2015,
                            MakeDescription = "Ford",
                            ModelDescription = "Mustang",
                            EngineDescription = "EcoBoost",
                            ExteriorColor = "Blue",
                            LicPlate = "NO1PRES",
                            LicPlateState = "VA",
                            LicPlateExpDate = new DateTime(2010,1,1),
                            DamageDescription = "Bumper cracked",
                            Mileage = 100500,
                        },
                        new VehicleDetails()
                        {
                            Vin = "1M8GDM9AXKP040001",
                            ModelYear = 2015,
                            MakeDescription = "Nissan",
                            ModelDescription = "Altima 2009",
                            EngineDescription = "2.5 L",
                            ExteriorColor = "Gray",
                            LicPlate = "7ABC123",
                            LicPlateState = "CA",
                            LicPlateExpDate = new DateTime(2010,1,1),
                            DamageDescription = "driver door dented",
                            Mileage = 100123,
                        },
                    },
                },
                new MitchellClaim()
                {
                    ClaimNumber = "Claim-2",
                    Status = ClaimStatus.Open,
                    ClaimantFirstName = "F3",
                    ClaimantLastName = "L3",
                    LossDate = DateTime.Now.Date.AddDays(-3),
                    LossInfo = new LossInfo()
                    {
                        CauseOfLoss = CauseOfLoss.Collision,
                        ReportedDate = DateTime.Now.Date,
                        LossDescription = "Hit a tree",
                    },
                    AssignedAdjusterId = 1002,
                    Vehicles = new List<VehicleDetails>()
                    {
                        new VehicleDetails()
                        {
                            Vin = "1M8GDM9AXKP040001",
                            ModelYear = 2015,
                            MakeDescription = "Nissan",
                            ModelDescription = "Altima 2009",
                            EngineDescription = "2.5 L",
                            ExteriorColor = "Gray",
                            LicPlate = "7ABC123",
                            LicPlateState = "CA",
                            LicPlateExpDate = new DateTime(2010,1,1),
                            DamageDescription = "driver door dented",
                            Mileage = 100123,
                        },
                    },
                },
            };
        }
    }
}
