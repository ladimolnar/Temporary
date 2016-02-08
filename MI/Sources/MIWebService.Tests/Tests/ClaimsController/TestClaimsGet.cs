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
    public class TestClaimsGet: TestClaimsControllerBase
    {
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
    }
}
