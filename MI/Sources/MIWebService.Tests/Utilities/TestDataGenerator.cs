using System;
using System.Collections.Generic;
using System.Linq;
using MIModels;

namespace MIWebService.Tests.Utilities
{
    public static class TestDataGenerator
    {
        public static string GenerateUniqueClaimNumber()
        {
            // In real life there will be some business rules regarding the format of the claim number. 
            // For now a GUID will do just fine.
            return Guid.NewGuid().ToString();
        }

        public static string GenerateUniqueVinNumber()
        {
            // In real life there will be some business rules regarding the format of the VIN number. 
            // For now a GUID will do just fine.
            return Guid.NewGuid().ToString().Replace("-", "");
        }

        /// <summary>
        /// A method that will return an instance of type <see cref="MitchellClaim"/> based on a claim number.
        /// This method will return a claim filled with the same values every time when called with the same claim number.
        /// </summary>
        /// <remarks>
        /// Note that GetTestClaim and GetTestClaimInXmlFormat must be in sync (see remarks for GetTestClaimInXmlFormat).
        /// </remarks>
        public static MitchellClaim GetTestClaim(string claimNumber)
        {
            return new MitchellClaim()
            {
                ClaimNumber = claimNumber,
                ClaimantFirstName = "F1",
                ClaimantLastName = "L1",
                Status = ClaimStatus.Closed,
                LossDate = new DateTime(2016, 1, 2, 3, 4, 5, 6, DateTimeKind.Utc),
                LossInfo = new LossInfo()
                {
                    CauseOfLoss = CauseOfLoss.MechanicalBreakdown,
                    ReportedDate = new DateTime(2016, 1, 3, 10, 11, 12, 13, DateTimeKind.Utc),
                    LossDescription = "Hit a telephone post.",
                },
                AssignedAdjusterId = 12345,
                Vehicles = new List<VehicleDetails>()
                {
                    new VehicleDetails()
                    {
                        Vin = "1M8GDM9AXKP000001",
                        ModelYear = 2015,
                        MakeDescription = "Ford",
                        ModelDescription = "Mustang",
                        EngineDescription = "EcoBoost",
                        ExteriorColor = "Deep Impact Blue",
                        LicPlate = "NO1PRES",
                        LicPlateState = "VA",
                        LicPlateExpDate = new DateTime(2017, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                        DamageDescription = "Front end smashed in. Apple dents in roof.",
                        Mileage = 100500,
                    },
                    new VehicleDetails()
                    {
                        Vin = "1M8GDM9AXKP000002",
                        ModelYear = 2015,
                        MakeDescription = "Nissan",
                        ModelDescription = "Altima 2009",
                        EngineDescription = "2.5 L",
                        ExteriorColor = "Gray",
                        LicPlate = "7ABC123",
                        LicPlateState = "CA",
                        LicPlateExpDate = new DateTime(2016, 9, 10, 0, 0, 0, DateTimeKind.Utc),
                        DamageDescription = "Driver door dented",
                        Mileage = 100123,
                    },
                },
            };
        }

        /// <summary>
        /// A method that will return the string representation of a claim in XML format.
        /// This method will return a claim filled with the same values every time when called with the same claim number.
        /// </summary>
        /// <remarks>
        /// Note that GetTestClaim and GetTestClaimInXmlFormat return claims with the same values just in different format.
        /// Client code relies on this. Unfortunately, the methods GetTestClaim and GetTestClaimInXmlFormat are at this point 
        /// synced up manually and the redundant aspect is not enforced automatically. We could refactor GetTestClaimInXmlFormat
        /// so that it invokes GetTestClaim and serializes the claim to XML. However that presents risks: if the serialization 
        /// is done based on DataContractSerializer which is also used by the framework then we could mask bugs in the way we use 
        /// the serialization. For example if we have a bug where we use the wrong Order parameter when decorating properties with DataMemberAttribute.
        /// The point is that if we ever implement the code so that it enforces the relation between GetTestClaim and GetTestClaimInXmlFormat 
        /// we cannot do so based on a serialization that uses DataContractSerializer.
        /// </remarks>
        public static string GetTestClaimInXmlFormat(string claimNumber)
        {
            return $@"
<cla:MitchellClaim xmlns:cla=""http://www.mitchell.com/examples/claim"">
  <cla:ClaimNumber>{claimNumber}</cla:ClaimNumber>
  <cla:ClaimantFirstName>F1</cla:ClaimantFirstName>
  <cla:ClaimantLastName>L1</cla:ClaimantLastName>
  <cla:Status>CLOSED</cla:Status>
  <cla:LossDate>2016-01-02T03:04:05.006+00:00</cla:LossDate>
  <cla:LossInfo>
    <cla:CauseOfLoss>Mechanical Breakdown</cla:CauseOfLoss>
    <cla:ReportedDate>2016-01-03T10:11:12.013+00:00</cla:ReportedDate>
    <cla:LossDescription>Hit a telephone post.</cla:LossDescription>
  </cla:LossInfo>
  <cla:AssignedAdjusterID>12345</cla:AssignedAdjusterID>
  <cla:Vehicles>
    <cla:VehicleDetails>
      <cla:Vin>1M8GDM9AXKP000001</cla:Vin>
      <cla:ModelYear>2015</cla:ModelYear>
      <cla:MakeDescription>Ford</cla:MakeDescription>
      <cla:ModelDescription>Mustang</cla:ModelDescription>
      <cla:EngineDescription>EcoBoost</cla:EngineDescription>
      <cla:ExteriorColor>Deep Impact Blue</cla:ExteriorColor>
      <cla:LicPlate>NO1PRES</cla:LicPlate>
      <cla:LicPlateState>VA</cla:LicPlateState>
      <cla:LicPlateExpDate>2017-01-02T00:00:00.000+00:00</cla:LicPlateExpDate>
      <cla:DamageDescription>Front end smashed in. Apple dents in roof.</cla:DamageDescription>
      <cla:Mileage>100500</cla:Mileage>
    </cla:VehicleDetails>
    <cla:VehicleDetails>
      <cla:Vin>1M8GDM9AXKP000002</cla:Vin>
      <cla:ModelYear>2015</cla:ModelYear>
      <cla:MakeDescription>Nissan</cla:MakeDescription>
      <cla:ModelDescription>Altima 2009</cla:ModelDescription>
      <cla:EngineDescription>2.5 L</cla:EngineDescription>
      <cla:ExteriorColor>Gray</cla:ExteriorColor>
      <cla:LicPlate>7ABC123</cla:LicPlate>
      <cla:LicPlateState>CA</cla:LicPlateState>
      <cla:LicPlateExpDate>2016-09-10T00:00:00.000+00:00</cla:LicPlateExpDate>
      <cla:DamageDescription>Driver door dented</cla:DamageDescription>
      <cla:Mileage>100123</cla:Mileage>
    </cla:VehicleDetails>
  </cla:Vehicles>
</cla:MitchellClaim>";
        }

        /// <summary>
        /// Updates the given claim changing a few fields. 
        /// At this point, those fields are not parameterizable.
        /// </summary>
        /// <remarks>
        /// Note that UpdateClaim and GetTestClaimUpdateInXmlFormat must be kept in sync.
        /// </remarks>
        public static void UpdateClaim(MitchellClaim claim)
        {
            claim.ClaimantLastName = "NewLastName";
            claim.Status = ClaimStatus.Open;
            claim.LossDate = new DateTime(2016, 1, 2, 13, 14, 15, 700, DateTimeKind.Utc);

            claim.LossInfo.CauseOfLoss = CauseOfLoss.Collision;

            VehicleDetails vehicleDetails = claim.Vehicles.Single(v => v.Vin == "1M8GDM9AXKP000001");
            vehicleDetails.ModelYear = 2014;
            vehicleDetails.LicPlateExpDate = new DateTime(2017, 1, 3, 0, 0, 0, DateTimeKind.Utc);
        }

        /// <summary>
        /// A method that will return the string representation of a update claim request REST API in XML format.
        /// </summary>
        /// <remarks>
        /// Note that UpdateClaim and GetTestClaimUpdateInXmlFormat must be kept in sync.
        /// </remarks>
        public static string GetTestClaimUpdateInXmlFormat(string claimNumber)
        {
            return $@"
<cla:MitchellClaim xmlns:cla=""http://www.mitchell.com/examples/claim"">
  <cla:ClaimNumber>{claimNumber}</cla:ClaimNumber>
  <cla:ClaimantLastName>NewLastName</cla:ClaimantLastName>
  <cla:Status>OPEN</cla:Status>
  <cla:LossDate>2016-01-02T13:14:15.700+00:00</cla:LossDate>
  <cla:LossInfo>
    <cla:CauseOfLoss>Collision</cla:CauseOfLoss>
  </cla:LossInfo>
  <cla:Vehicles>
    <cla:VehicleDetails>
      <cla:Vin>1M8GDM9AXKP000001</cla:Vin>
      <cla:ModelYear>2014</cla:ModelYear>
      <cla:LicPlateExpDate>2017-01-03T00:00:00.000+00:00</cla:LicPlateExpDate>
    </cla:VehicleDetails>
    <cla:VehicleDetails>
      <cla:Vin>1M8GDM9AXKP000002</cla:Vin>
    </cla:VehicleDetails>
  </cla:Vehicles>
</cla:MitchellClaim>";
        }

        public static VehicleDetails GetTestVehicle(string vin)
        {
            return new VehicleDetails()
            {
                Vin = vin,
                ModelYear = 2015,
                MakeDescription = "Ford",
                ModelDescription = "Mustang",
                EngineDescription = "EcoBoost",
                ExteriorColor = "Deep Impact Blue",
                LicPlate = "NO1PRES",
                LicPlateState = "VA",
                LicPlateExpDate = new DateTime(2017, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                DamageDescription = "Bumper cracked.",
                Mileage = 100500,
            };
        }
    }
}
