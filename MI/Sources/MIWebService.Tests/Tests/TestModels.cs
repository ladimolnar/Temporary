using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests.Tests
{
    [TestClass]
    public class TestModels
    {
        [TestMethod]
        public void TestClaimDeepClone()
        {
            string newClaimNumber = TestDataGenerator.GenerateUniqueClaimNumber();
            MitchellClaim claim = TestDataGenerator.GetTestClaim(newClaimNumber);

            MitchellClaim anotherClaim = claim.DeepClone();

            Assert.AreEqual(claim, anotherClaim, "A deep cloned claim must have the same values as the original.");
        }
    }
}
