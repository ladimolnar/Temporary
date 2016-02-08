using System;
using System.Runtime.Serialization;
using MIModels.Utilities;

namespace MIModels
{
    /// <summary>
    /// Contains information about a vehicle.
    /// Model class: this class is used to serialized and deserialize information exchanged via the MIWebService.
    /// </summary>
    [DataContract(Namespace = "http://www.mitchell.com/examples/claim")]
    public class VehicleDetails
    {
        [DataMember(Order = 1, EmitDefaultValue = false)]
        public string Vin { get; set; }

        [DataMember(Order = 2, EmitDefaultValue = false)]
        public int? ModelYear { get; set; }

        [DataMember(Order = 3, EmitDefaultValue = false)]
        public string MakeDescription { get; set; }

        [DataMember(Order = 4, EmitDefaultValue = false)]
        public string ModelDescription { get; set; }

        [DataMember(Order = 5, EmitDefaultValue = false)]
        public string EngineDescription { get; set; }

        [DataMember(Order = 6, EmitDefaultValue = false)]
        public string ExteriorColor { get; set; }

        [DataMember(Order = 7, EmitDefaultValue = false)]
        public string LicPlate { get; set; }

        [DataMember(Order = 8, EmitDefaultValue = false)]
        public string LicPlateState { get; set; }

        [DataMember(Order = 9, EmitDefaultValue = false)]
        public DateTime? LicPlateExpDate { get; set; }

        [DataMember(Order = 10, EmitDefaultValue = false)]
        public string DamageDescription { get; set; }

        [DataMember(Order = 11, EmitDefaultValue = false)]
        public int? Mileage { get; set; }

        public override int GetHashCode()
        {
            // Unless we find a really good reason to implement GetHashCode we will throw NotSupportedException.
            // Typically, GetHashCode is implemented so that instances of a class can be used as keys in 
            // some form of a hash table or dictionary. This class being mutable should never be used 
            // in that way. Throwing will consistently break any such usage which is better than allowing 
            // obscure and unpredictable bugs to be generated.
            throw new NotSupportedException("Do not use GetHashCode. VehicleDetails is a mutable class");
        }

        public override bool Equals(object obj)
        {
            VehicleDetails vehicleDetails = obj as VehicleDetails;
            if ((object)vehicleDetails == null) return false;

            return this == vehicleDetails;
        }

        public static bool operator ==(VehicleDetails vehicleDetails1, VehicleDetails vehicleDetails2)
        {
            // If both are null or both are same instance then return true.
            if (System.Object.ReferenceEquals(vehicleDetails1, vehicleDetails2)) return true;

            // If one is null then return false.
            if ((object)vehicleDetails1 == null || (object)vehicleDetails2 == null) return false;

            return
                vehicleDetails1.Vin == vehicleDetails2.Vin &&
                vehicleDetails1.ModelYear == vehicleDetails2.ModelYear &&
                vehicleDetails1.MakeDescription == vehicleDetails2.MakeDescription &&
                vehicleDetails1.ModelDescription == vehicleDetails2.ModelDescription &&
                vehicleDetails1.EngineDescription == vehicleDetails2.EngineDescription &&
                vehicleDetails1.ExteriorColor == vehicleDetails2.ExteriorColor &&
                vehicleDetails1.LicPlate == vehicleDetails2.LicPlate &&
                vehicleDetails1.LicPlateState == vehicleDetails2.LicPlateState &&
                vehicleDetails1.LicPlateExpDate.IsSameDate(vehicleDetails2.LicPlateExpDate) &&
                vehicleDetails1.DamageDescription == vehicleDetails2.DamageDescription &&
                vehicleDetails1.Mileage == vehicleDetails2.Mileage;
        }

        public static bool operator !=(VehicleDetails vehicleDetails1, VehicleDetails vehicleDetails2)
        {
            return !(vehicleDetails1 == vehicleDetails2);
        }

        public VehicleDetails DeepClone()
        {
            VehicleDetails newVehicleDetails = new VehicleDetails()
            {
                Vin = Vin,
                ModelYear = ModelYear,
                MakeDescription = MakeDescription,
                ModelDescription = ModelDescription,
                EngineDescription = EngineDescription,
                ExteriorColor = ExteriorColor,
                LicPlate = LicPlate,
                LicPlateState = LicPlateState,
                LicPlateExpDate = LicPlateExpDate,
                DamageDescription = DamageDescription,
                Mileage = Mileage,
            };

            return newVehicleDetails;
        }

        public void Update(VehicleDetails updater)
        {
            this.Vin = updater.Vin ?? this.Vin;
            this.ModelYear = updater.ModelYear ?? this.ModelYear;
            this.MakeDescription = updater.MakeDescription ?? this.MakeDescription;
            this.ModelDescription = updater.ModelDescription ?? this.ModelDescription;
            this.EngineDescription = updater.EngineDescription ?? this.EngineDescription;
            this.ExteriorColor = updater.ExteriorColor ?? this.ExteriorColor;
            this.LicPlate = updater.LicPlate ?? this.LicPlate;
            this.LicPlateState = updater.LicPlateState ?? this.LicPlateState;
            this.LicPlateExpDate = updater.LicPlateExpDate ?? this.LicPlateExpDate;
            this.DamageDescription = updater.DamageDescription ?? this.DamageDescription;
            this.Mileage = updater.Mileage ?? this.Mileage;
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
            return this.ModelYear != null;
        }
    }
}
