using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests
{
    [TestClass]
    public class TestClaimsDelete: TestClaimsControllerBase
    {
        /// <summary>
        /// A test that validates the simple delete scenario.
        /// </summary>
        [TestMethod]
        public void TestDeleteSimple()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);
            Assert.AreEqual(testClaim, retrievedClaim, "The posted and retrieved claim should have the same values.");

            response = ClaimsController.Delete(newClaimNumber);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "Deleting an existing claim should succeed.");

            try
            {
                retrievedClaim = ClaimsController.Get(newClaimNumber);
                Assert.Fail("An attempt to retrieve a claim that was deleted should result in an error.");
            }
            catch (HttpResponseException ex) when(ex.Response.StatusCode == HttpStatusCode.NotFound)
            {
                // This is the expected behavior
            }
        }

        /// <summary>
        /// A test that validates the scenario where a delete is applied twice.
        /// The second delete should return a status of "Not Found".
        /// </summary>
        [TestMethod]
        public void TestDeleteNotExistentClaim()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim testClaim = TestDataGenerator.GetTestClaim(newClaimNumber);

            HttpResponseMessage response = ClaimsController.Post(testClaim);
            Assert.AreEqual(HttpStatusCode.Created, response.StatusCode, "A POST of a new claim should succeed.");

            MitchellClaim retrievedClaim = ClaimsController.Get(newClaimNumber);
            Assert.AreEqual(testClaim, retrievedClaim, "The posted and retrieved claim should have the same values.");

            response = ClaimsController.Delete(newClaimNumber);
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "Deleting an existing claim should succeed.");

            try
            {
                response = ClaimsController.Delete(newClaimNumber);
                Assert.Fail("An attempt to delete a claim that does not exist should result in an error.");
            }
            catch (HttpResponseException ex) when (ex.Response.StatusCode == HttpStatusCode.NotFound)
            {
                // This is the expected behavior
            }
        }
    }
}
