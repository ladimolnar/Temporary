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
    public class TestClaimsDelete: TestClaimsControllerBase
    {
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
