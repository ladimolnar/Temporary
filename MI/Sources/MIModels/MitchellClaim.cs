using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using MIModels.Utilities;

namespace MIModels
{
    [DataContract(Namespace = "http://www.mitchell.com/examples/claim")]
    public class MitchellClaim
    {
        [DataMember(Order = 1)]
        public string ClaimNumber { get; set; }

        [DataMember(Order = 2)]
        public string ClaimantFirstName { get; set; }

        [DataMember(Order = 3)]
        public string ClaimantLastName { get; set; }

        [DataMember(Order = 4)]
        public ClaimStatus? Status { get; set; }

        [DataMember(Order = 5)]
        public DateTime? LossDate { get; set; }

        [DataMember(Order = 6)]
        public LossInfo LossInfo { get; set; }

        [DataMember(Order = 7, Name = "AssignedAdjusterID")]
        public long? AssignedAdjusterId { get; set; }

        [DataMember(Order = 8)]
        public List<VehicleDetails> Vehicles { get; set; }

        public override int GetHashCode()
        {
            // Unless we find a really good reason to implement GetHashCode we will throw NotSupportedException.
            // Typically, GetHashCode is implemented so that instances of a class can be used as keys in 
            // some form of a hash table or dictionary. This class being mutable should never be used 
            // in that way. Throwing will consistently break any such usage which is better than allowing 
            // obscure and unpredictable bugs to be generated.
            throw new NotSupportedException("Do not use GetHashCode. MitchellClaim is a mutable class");
        }

        public override bool Equals(object obj)
        {
            MitchellClaim claim = obj as MitchellClaim;
            if ((object)claim == null) return false;

            return this == claim;
        }

        public static bool operator ==(MitchellClaim claim1, MitchellClaim claim2)
        {
            // If both are null or both are same instance then return true.
            if (System.Object.ReferenceEquals(claim1, claim2)) return true;

            // If one is null then return false.
            if ((object)claim1 == null || (object)claim2 == null) return false;

            if (claim1.ClaimNumber != claim2.ClaimNumber) return false;
            if (claim1.ClaimantFirstName != claim2.ClaimantFirstName) return false;
            if (claim1.ClaimantLastName != claim2.ClaimantLastName) return false;
            if (claim1.Status != claim2.Status) return false;
            if (claim1.LossDate.IsSameDate(claim2.LossDate) == false) return false;
            if (claim1.LossInfo != claim2.LossInfo) return false;
            if (claim1.AssignedAdjusterId != claim2.AssignedAdjusterId) return false;

            if ((claim1.Vehicles != null && claim2.Vehicles == null) ||
                (claim1.Vehicles == null && claim2.Vehicles != null))
            {
                return false;
            }

            if (claim1.Vehicles != null && claim2.Vehicles != null)
            {
                if (claim1.Vehicles.Count != claim2.Vehicles.Count) return false;
                for (int i = 0; i < claim1.Vehicles.Count; i++)
                {
                    if (claim1.Vehicles[i] != claim2.Vehicles[i]) return false;
                }
            }

            return true;
        }

        public static bool operator !=(MitchellClaim claim1, MitchellClaim claim2)
        {
            return !(claim1 == claim2);
        }

        public MitchellClaim DeepClone()
        {
            MitchellClaim newClaim = new MitchellClaim()
            {
                ClaimNumber = this.ClaimNumber,
                ClaimantFirstName = this.ClaimantFirstName,
                ClaimantLastName = this.ClaimantLastName,
                Status = this.Status,
                LossDate = this.LossDate,
                LossInfo = this.LossInfo.DeepClone(),
                AssignedAdjusterId = this.AssignedAdjusterId,
            };

            if (this.Vehicles != null)
            {
                newClaim.Vehicles = new List<VehicleDetails>();
                for (int i = 0; i < this.Vehicles.Count; i++)
                {
                    newClaim.Vehicles.Add(this.Vehicles[i].DeepClone());
                }
            }

            return newClaim;
        }

        public void Update(MitchellClaim updater)
        {
            if (updater.ClaimNumber != null && this.ClaimNumber != updater.ClaimNumber)
            {
                throw new InternalErrorException("MitchellClaim.Update can only be invoked with a claim that has the same claim number as the target claim.");
            }

            this.ClaimantFirstName = updater.ClaimantFirstName ?? this.ClaimantFirstName;
            this.ClaimantLastName = updater.ClaimantLastName ?? this.ClaimantLastName;
            this.Status = updater.Status ?? this.Status;
            this.LossDate = updater.LossDate ?? this.LossDate;
            this.AssignedAdjusterId = updater.AssignedAdjusterId ?? this.AssignedAdjusterId;

            if (updater.LossInfo != null)
            {
                this.LossInfo.Update(updater.LossInfo);
            }

            // Update or add vehicles present in the updater.
            if (updater.Vehicles != null)
            {
                foreach (VehicleDetails updaterVehicleDetails in updater.Vehicles)
                {
                    VehicleDetails existingVehicle =
                        this.Vehicles.FirstOrDefault(v => v.Vin == updaterVehicleDetails.Vin);
                    if (existingVehicle != null)
                    {
                        existingVehicle.Update(updaterVehicleDetails);
                    }
                    else
                    {
                        this.Vehicles.Add(updaterVehicleDetails.DeepClone());
                    }
                }

                // Now handle vehicle deletion.
                // Vehicles that are present in the current claim but absent in the updater will be deleted.
                List<VehicleDetails> vehiclesToDelete = new List<VehicleDetails>();
                foreach (VehicleDetails existingVehicleDetails in this.Vehicles)
                {
                    if (updater.Vehicles.FirstOrDefault(v => v.Vin == existingVehicleDetails.Vin) == null)
                    {
                        // A vehicle that was found in this claim is absent from the updater.
                        // This is an indication that the existing vehicle should be deleted.
                        vehiclesToDelete.Add(existingVehicleDetails);
                    }
                }

                foreach (VehicleDetails vehicleToDelete in vehiclesToDelete)
                {
                    this.Vehicles.Remove(vehicleToDelete);
                }
            }
        }

        /// <summary>
        /// Determines if all required fields were set.
        /// </summary>
        /// <returns>
        /// True    - all required fields were set.
        /// False   - one or more required fields were NOT set.
        /// </returns>
        public bool ValidateRequiredFields()
        {
            return
                ClaimNumber != null &&
                LossInfo.ValidateRequiredFields() &&
                Vehicles != null &&
                Vehicles.Count > 0 &&
                Vehicles.All(v => v.ValidateRequiredFields());
        }
    }
}
