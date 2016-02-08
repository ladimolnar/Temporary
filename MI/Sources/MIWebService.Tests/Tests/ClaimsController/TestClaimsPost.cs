using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests.Tests
{
    [TestClass]
    public class TestClaimsPost: TestClaimsControllerBase
    {
        [TestMethod]
        public void TestPostSimple()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);

            Assert.AreEqual(testClaim, retrievedClaim, "The posted and retrieved claim should have the same values.");
        }

        [TestMethod]
        public void TestPostDuplicateClaim()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Conflict, response.StatusCode, "A POST of a duplicate should fail with a specific status.");
        }

        [TestMethod]
        public void TestPostClaimWithNoVehicles()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            testClaim.Vehicles.Clear();

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that contains no vehicle information should fail with a specific status.");
        }

        [TestMethod]
        public void TestPostClaimWithNoClaimNumber()
        {
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(null);

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that contains no claim number should fail with a specific status.");
        }

        [TestMethod]
        public void TestPostClaimWithRequiredParametersNotSpecified()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);
            testClaim.Vehicles[0].ModelYear = null;

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that has required fields that are not specified should fail with a specific status.");
        }

        // TODO: in a real application we'd have to confirm the desired behavior for this scenario.
        [TestMethod]
        public void TestPostClaimWithDuplicateVehicles()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            testClaim.Vehicles.Clear();
            VehicleDetails vehicleDetails = TestDataGenerator.GetTestVehicle("1M8GDM9AXKP000001");
            testClaim.Vehicles.Add(vehicleDetails);
            testClaim.Vehicles.Add(vehicleDetails);

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Forbidden, response.StatusCode, "A POST of a claim that contains duplicate vehicles should fail with a specific status.");
        }
    }
}
