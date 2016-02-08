using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Controllers;
using MIWebService.DataLayer;
using MIWebService.Infrastructure;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests.Tests
{
    [TestClass]
    public class TestClaimsController
    {
        readonly ClaimsController _claimsController;

        static TestClaimsController()
        {
            // We can choose here to use a mock repository or the actual repository.
            // Using a mock repository will push the test automation more towards a unit test approach.
            // Using the actual repository will push the test automation more towards an integration test approach.
            // For now we'll use the actual repository (which BTW, at this point, is a dummy in-memory version).
            // In a real project we'd need to decide our test automation investment, how much we invest in
            // integration tests and how much we invest in unit tests. The pros and cons for 
            // both approaches are quite different. Those pros and cons also depend on the nature of the project 
            // so this is worth discussing and planning in advance.
            ServiceLocator.RegisterRepository(new Repository());
        }

        public TestClaimsController()
        {
            _claimsController = ControllerHelper.GenerateClaimsController();
        }

        [TestMethod]
        public void TestCreateSimple()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            HttpResponseMessage response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(testClaim, retrievedClaim, "The posted and retrieved claim should have the same values.");
        }

        [TestMethod]
        public void TestCreateDuplicateClaim()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            HttpResponseMessage response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Conflict, response.StatusCode, "A POST of a duplicate should fail with a specific status.");
        }

        [TestMethod]
        public void TestCreateClaimWithNoVehicles()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            testClaim.Vehicles.Clear();

            HttpResponseMessage response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that contains no vehicle information should fail with a specific status.");
        }

        [TestMethod]
        public void TestCreateClaimWithNoClaimNumber()
        {
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(null);

            HttpResponseMessage response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that contains no claim number should fail with a specific status.");
        }

        [TestMethod]
        public void TestCreateClaimWithRequiredParametersNotSpecified()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);
            testClaim.Vehicles[0].ModelYear = null;

            HttpResponseMessage response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that has required fields that are not specified should fail with a specific status.");
        }

        // TODO: in a real application we'd have to confirm the desired behavior for this scenario.
        [TestMethod]
        public void TestCreateClaimWithDuplicateVehicles()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            testClaim.Vehicles.Clear();
            VehicleDetails vehicleDetails = TestDataGenerator.GetTestVehicle("1M8GDM9AXKP000001");
            testClaim.Vehicles.Add(vehicleDetails);
            testClaim.Vehicles.Add(vehicleDetails);

            HttpResponseMessage response = _claimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that contains duplicate vehicles should fail with a specific status.");
        }

        [TestMethod]
        public void TestUpdateSimple()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
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
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        [TestMethod]
        public void TestUpdateClaimAndAddNewVehicle()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
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
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim.Vehicles.Count, 3, "Defensive check - making sure that the expected claim was setup correctly.");
            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        [TestMethod]
        public void TestUpdateClaimAndDeleteVehicle()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
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
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim.Vehicles.Count, 1, "Defensive check - making sure that the expected claim was setup correctly.");
            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        /// <summary>
        /// An update where the updater has no vehicles are specified is legal. All vehicles will be preserved unchanged.
        /// </summary>
        [TestMethod]
        public void TestUpdateClaimWithNoVehicleList()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            // Update the claim.
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim.Vehicles.Count, 2, "Defensive check - making sure that the expected claim was setup correctly.");
            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
        }

        /// <summary>
        /// An update where the updater has an empty vehicle list would lead to deleting all
        /// vehicle information from the claim being updated. That is considered an illegal request.
        /// </summary>
        [TestMethod]
        public void TestUpdateClaimWithEmptyVehicleList()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";
            expectedClaim.ClaimantLastName = updater.ClaimantLastName;

            updater.Vehicles = new List<VehicleDetails>();

            // Update the claim.
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "An update request where the updater has an empty vehicle list is not legal.");

            // Retrieved the claim we attempted to update and make sure it did not change.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was subject to a failed update should not have changed.");
        }

        [TestMethod]
        public void TestUpdateWithRequiredParametersNotSpecified()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            // Prepare a claim "updater".
            MitchellClaim updater = new MitchellClaim();

            updater.ClaimantLastName = "NewLastName";

            updater.Vehicles = new List<VehicleDetails>();

            // We'll request a new vehicle to be added. However, this vehicle has required parameters that are not specified.
            updater.Vehicles.Add(new VehicleDetails() { Vin = TestDataGenerator.GenerateUniqueVinNumber(), Mileage = 100 });

            // Update the claim. 
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "An update of a claim that would results in required fields that are not specified should fail with a specific status.");

            // Retrieved the claim we attempted to update and make sure it did not change.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was subject to a failed update should not have changed.");
        }

        /// <summary>
        /// A test that validates creating a new claim via the PUT command.
        /// </summary>
        [TestMethod]
        public void TestCreateViaPut()
        {
            // TODO: implement this.
        }

        /// <summary>
        /// A test that validates the behavior of an update with conflict. 
        /// An update is executed by two clients. The second update should be rejected because of a conflict is detected.
        /// When we get to implement this part we'll have to use ETags as a mechanism to detect conflicts.
        /// </summary>
        [TestMethod]
        public void TestUpdateWithConflicts()
        {
            // TODO: implement this.
        }

        /// <summary>
        /// A test that validates the retrieval of claims by the date range applied to the LossDate field.
        /// </summary>
        [TestMethod]
        public void TestGetByLossDateRange()
        {
            // TODO: implement this.
        }

        /// <summary>
        /// A test that validates the retrieval of vehicles by claim number and VIN number.
        /// </summary>
        [TestMethod]
        public void TestGetVehicleByClaimAndVin()
        {
            // TODO: implement this.
        }

        /// <summary>
        /// A test that validates the simple delete scenario.
        /// </summary>
        [TestMethod]
        public void TestDeleteSimple()
        {
            // TODO: implement this.
        }

        /// <summary>
        /// A test that validates the scenario where a delete is applied twice.
        /// The second delete should return a status of "Not Found".
        /// </summary>
        [TestMethod]
        public void TestDeleteNotExistentClaim()
        {
            // TODO: implement this.
        }
    }
}
