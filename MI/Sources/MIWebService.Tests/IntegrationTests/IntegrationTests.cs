using System;
using System.Net;
using System.Net.Http.Formatting;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests.IntegrationTests
{
    [TestClass]
    public class IntegrationTests
    {
        [TestMethod]
        public void IntegrationTestBasicScenario()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            string postBody = TestDataGenerator.GetTestClaimInXmlFormat(newClaimNumber);

            // =========================================
            // Create a new claim.
            HttpWebResponse httpWebResponse = WebServiceHelpers.PostClaim(postBody);

            Assert.AreEqual(HttpStatusCode.Created, httpWebResponse.StatusCode, "Posting a new claim should succeed.");

            string expectedClaimUrl = WebServiceHelpers.GetClaimUrl(newClaimNumber);
            Assert.AreEqual(expectedClaimUrl, httpWebResponse.Headers["Location"],
                "Posting a new claim should return the correct location.");

            // =========================================
            // Read the same claim back and validate the result.
            string getRresponse = WebServiceHelpers.GetClaim(newClaimNumber);

            MitchellClaim retrievedClaim = SerializerHelper.DeserializeFromXml<MitchellClaim>(getRresponse);

            MitchellClaim expectedClaim = TestDataGenerator.GetTestClaim(newClaimNumber);
            Assert.AreEqual(expectedClaim, retrievedClaim,
                "A claim before being posted and after being retrieved should contain the same data.");

            // =========================================
            // Update the same claim.
            string putBody = TestDataGenerator.GetTestClaimUpdateInXmlFormat(newClaimNumber);
            httpWebResponse = WebServiceHelpers.PutClaim(newClaimNumber, putBody);

            Assert.AreEqual(HttpStatusCode.OK, httpWebResponse.StatusCode, "Updating a claim should succeed.");

            // =========================================
            // Read the same claim back and validate the result.
            getRresponse = WebServiceHelpers.GetClaim(newClaimNumber);
            retrievedClaim = SerializerHelper.DeserializeFromXml<MitchellClaim>(getRresponse);

            TestDataGenerator.UpdateClaim(expectedClaim);
            Assert.AreEqual(expectedClaim, retrievedClaim,
                "The claim update operation did not update the claim data as expected.");

            // =========================================
            // Delete the same claim.
            httpWebResponse = WebServiceHelpers.DeleteClaim(newClaimNumber);
            Assert.AreEqual(HttpStatusCode.OK, httpWebResponse.StatusCode, "Deleting a claim should succeed.");

            // =========================================
            // Read the same claim back and validate the "Not Found" result.

            try
            {
                getRresponse = WebServiceHelpers.GetClaim(newClaimNumber);
                Assert.Fail("An attempt to retrieve a claim that was deleted should result in an error.");
            }
            catch (WebException wex)
                when (
                    wex.Response is System.Net.HttpWebResponse &&
                    ((System.Net.HttpWebResponse) wex.Response).StatusCode == HttpStatusCode.NotFound)
            {
                // This is what we expect.
            }
        }

        /// <summary>
        /// This test will generate a claim where all the string properties are set to maximum lengths for that particular property.
        /// This test will make sure that aspects like the web service settings or database schema will not cause strings to be truncated inappropriately.
        /// </summary>
        [TestMethod]
        public void IntegrationTestVeryLargeStrings()
        {
            // TODO: implement this. Not yet implemented. Present for documentation purposes.
        }

        /// <summary>
        /// A test that validates the retrieval of vehicles by claim number and VIN number.
        /// Note: Even though we have a similar method in class TestVehiclesController it is worth having this here as well to make sure that the routing is setup correctly.
        /// </summary>
        [TestMethod]
        public void TestGetVehicleByClaimAndVin()
        {
            // TODO: implement this. Not yet implemented. Present for documentation purposes.
        }
    }
}
