using Microsoft.VisualStudio.TestTools.UnitTesting;
using MIModels;
using MIWebService.Tests.Utilities;

namespace MIWebService.Tests
{
    [TestClass]
    public class TestModels
    {
        /// <summary>
        /// Test that the deep clone functionality implemented on type <see cref="MitchellClaim "/> works correctly.
        /// </summary>
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
