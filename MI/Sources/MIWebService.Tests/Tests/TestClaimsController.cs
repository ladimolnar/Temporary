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

            updater.Vehicles = new List<VehicleDetails>();
            VehicleDetails updatedVehicle = expectedClaim.Vehicles[1];
            updater.Vehicles.Add(new VehicleDetails() { Vin = updatedVehicle.Vin, Mileage = updatedVehicle.Mileage + 100 });
            updatedVehicle.Mileage = updater.Vehicles[0].Mileage;

            // Update the claim.
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "A PUT of an existing claim should succeed.");

            // Retrieved the updated claim and compare it with the expected value.
            MitchellClaim retrievedClaim = _claimsController.Get(newClaimNumber);

            Assert.AreEqual(expectedClaim, retrievedClaim, "The claim that was created, updated and retrieved should have the expected values.");
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
            updater.Vehicles.Add(new VehicleDetails() { Vin = TestDataGenerator.GenerateUniqueVinNumber(), Mileage = 100 });

            // Update the claim. The updater has required fields intentionally missing.
            response = _claimsController.Put(newClaimNumber, updater);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "An update of a claim that would results in required fields that are not specified should fail with a specific status.");
        }

        [TestMethod]
        public void TestCreateViaPut()
        {
            // TODO: implement this.
            //       Test the scenario of a create via PUT.
        }

        [TestMethod]
        public void TestUpdateWithConflicts()
        {
            // TODO: implement this.
            //       Test the scenario of an update from two clients. The second update should be rejected because of a conflict.
            //       When we get to implement this feature we'll have to use ETags as a mechanism to detect conflicts.
        }

        [TestMethod]
        public void TestGetByLossDateRange()
        {
            // TODO: implement this.
            //       Test the retrieval of claims by the date range applied to the LossDate field.
        }

        [TestMethod]
        public void TestGetVehicleByClaimAndVin()
        {
            // TODO: implement this.
            //       Test the retrieval of claims by the date range applied to the LossDate field.
        }

        [TestMethod]
        public void TestDeleteSimple()
        {
            // TODO: implement this.
            //       Test the simple delete scenario.
        }

        [TestMethod]
        public void TestDeleteNotExistentClaim()
        {
            // TODO: implement this.
            //       Test the scenario where a claim is deleted twice. The second delete should return a status of "Not Found".
        }
    }
}
