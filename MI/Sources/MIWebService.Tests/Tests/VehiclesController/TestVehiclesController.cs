using System.Net;
using System.Net.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Controllers;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests
{
    [TestClass]
    public class TestVehiclesController: TestControllerBase
    {
        private readonly ClaimsController _claimsController;
        private readonly VehiclesController _vehiclesController;

        public TestVehiclesController()
        {
            _claimsController = ControllerHelper.GenerateClaimsController();
            _vehiclesController = ControllerHelper.GenerateVehiclesController();
        }

        /// <summary>
        /// A test that validates the retrieval of vehicles by claim number and VIN number.
        /// </summary>
        [TestMethod]
        public void TestGetVehicleByClaimAndVin()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            // Create a new claim
            HttpResponseMessage response = _claimsController.Post(expectedClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            VehicleDetails vehicleDetails0 = _vehiclesController.Get(newClaimNumber, expectedClaim.Vehicles[0].Vin);
            Assert.AreEqual(expectedClaim.Vehicles[0], vehicleDetails0, "GET of vehicle[0] of a claim should succeed.");

            VehicleDetails vehicleDetails1 = _vehiclesController.Get(newClaimNumber, expectedClaim.Vehicles[1].Vin);
            Assert.AreEqual(expectedClaim.Vehicles[1], vehicleDetails1, "GET of vehicle[1] of a claim should succeed.");
        }
    }
}
