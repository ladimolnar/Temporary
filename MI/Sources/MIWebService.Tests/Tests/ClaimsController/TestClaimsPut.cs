using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Controllers;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests
{
    [TestClass]
    public class TestClaimsPut : TestClaimsControllerBase
    {
        [TestMethod]
        public void TestPutSimple()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = ClaimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            updater.LossDate = expectedClaim.LossDate.Value.AddDays(1);
            expectedClaim.LossDate = updater.LossDate;

            // Note:  The updater will have to include both vehicles that are changed and those who are not changed.
            //        The vehicles that are not changed will only have the Vin field set.
            //        This system enables us to delete vehicles with the update request. The tread-off is that when we 
            //        specify a list of vehicles then that list must include vehicles that are not changed.
            updater.Vehicles = new List<VehicleDetails>();

            updater.Vehicles.Add(new VehicleDetails() { Vin = expectedClaim.Vehicles[0].Vin });

            VehicleDetails sourceVehicle = expectedClaim.Vehicles[1];
            VehicleDetails updaterVehicle = new VehicleDetails()
            {
                Vin = sourceVehicle.Vin,
                Mileage = sourceVehicle.Mileage + 100
            };
            updater.Vehicles.Add(updaterVehicle);
            sourceVehicle.Mileage = updaterVehicle.Mileage;

            // Update the claim.
            response = ClaimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        [TestMethod]
        public void TestPutClaimAndAddNewVehicle()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = ClaimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            // Note:  The updater will have to include both vehicles that are changed and those who are not changed.
            //        The vehicles that are not changed will only have the Vin field set.
            //        This system enables us to delete vehicles with the update request. The tread-off is that when we 
            //        specify a list of vehicles then that list must include vehicles that are not changed.
            updater.Vehicles = new List<VehicleDetails>();

            updater.Vehicles.Add(new VehicleDetails() { Vin = expectedClaim.Vehicles[0].Vin });
            updater.Vehicles.Add(new VehicleDetails() { Vin = expectedClaim.Vehicles[1].Vin });

            // We'll request a new vehicle to be added. However, this vehicle has required parameters that are not specified.
            VehicleDetails newVehicle = new VehicleDetails()
            {
                Vin = TestDataGenerator.GenerateUniqueVinNumber(),
                ModelYear = 2015,
                Mileage = 200
            };
            updater.Vehicles.Add(newVehicle);
            expectedClaim.Vehicles.Add(newVehicle.DeepClone());

            // Update the claim.
            response = ClaimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim.Vehicles.Count, 3, "Defensive check - making sure that the expected claim was setup correctly.");
            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        [TestMethod]
        public void TestPutClaimAndDeleteVehicle()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = ClaimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            // Note:  The updater will have to include both vehicles that are changed and those who are not changed.
            //        The vehicles that are not changed will only have the Vin field set.
            //        This system enables us to delete vehicles with the update request. The tread-off is that when we 
            //        specify a list of vehicles then that list must include vehicles that are not changed.
            updater.Vehicles = new List<VehicleDetails>();

            // We'll request a vehicle to be deleted. Simply skip the second vehicle in the updater and it will be deleted.
            updater.Vehicles.Add(new VehicleDetails() { Vin = expectedClaim.Vehicles[0].Vin });

            expectedClaim.Vehicles.RemoveAt(1);

            // Update the claim.
            response = ClaimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim.Vehicles.Count, 1, "Defensive check - making sure that the expected claim was setup correctly.");
            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        /// <summary>
        /// An update where the updater has no vehicles are specified is legal. All vehicles will be preserved unchanged.
        /// </summary>
        [TestMethod]
        public void TestPutClaimWithNoVehicleList()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = ClaimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            // Update the claim.
            response = ClaimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim.Vehicles.Count, 2, "Defensive check - making sure that the expected claim was setup correctly.");
            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        /// <summary>
        /// An update where the updater has an empty vehicle list would lead to deleting all
        /// vehicle information from the claim being updated. That is considered an illegal request.
        /// </summary>
        [TestMethod]
        public void TestPutClaimWithEmptyVehicleList()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = ClaimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            updater.Vehicles = new List<VehicleDetails>();

            // Update the claim.
            response = ClaimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "An update request where the updater has an empty vehicle list is not legal.");

            // Retrieved the claim we attempted to update and make sure it did not change.
            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was subject to a failed update should not have changed.");
        }

        [TestMethod]
        public void TestPutWithRequiredParametersNotSpecified()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = ClaimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";

            updater.Vehicles = new List<VehicleDetails>();

            // We'll request a new vehicle to be added. However, this vehicle has required parameters that are not specified.
            updater.Vehicles.Add(new VehicleDetails() { Vin = TestDataGenerator.GenerateUniqueVinNumber(), Mileage = 100 });

            // Update the claim. 
            response = ClaimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "An update of a claim that would results in required fields that are not specified should fail with a specific status.");

            // Retrieved the claim we attempted to update and make sure it did not change.
            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was subject to a failed update should not have changed.");
        }

        /// <summary>
        /// A test that validates creating a new claim via the PUT command.
        /// </summary>
        [TestMethod]
        public void TestPutAndCreate()
        {
            // TODO: implement this.
        }

        /// <summary>
        /// A test that validates the behavior of an update with conflict. 
        /// An update is executed by two clients. The second update should be rejected because of a conflict is detected.
        /// When we get to implement this part we'll have to use ETags as a mechanism to detect conflicts.
        /// </summary>
        [TestMethod]
        public void TestPutWithConflicts()
        {
            // TODO: implement this.
        }
    }
}
