using System;
using System.Collections.Generic;
using MIModels;
using MIModels.Utilities;

namespace MIWebService.DataLayer
{
    /// <summary>
    /// An interface that abstracts the access to a repository containing claim data.
    /// </summary>
    public interface IRepository
    {
        /// <summary>
        /// Determines whether the repository contains the specified claim or not.
        /// </summary>
        bool ContainsClaim(string claimNumber);

        /// <summary>
        /// Gets all claims stored in the repository.
        /// </summary>
        /// <returns></returns>
        IEnumerable<MitchellClaim> GetClaims();

        /// <summary>
        /// Attempts to retrieve a claim given by the claim number.
        /// </summary>
        /// <returns>
        /// True - the claim was found and retrieved.
        /// False - the claim was not found. <paramref name="claim"/> will be null when this method returns.
        /// </returns>
        bool TryGetClaim(string claimNumber, out MitchellClaim claim);

        /// <summary>
        /// Retrieves all claims that have the loss date in the specified time range.
        /// </summary>
        IEnumerable<MitchellClaim> GetClaimsInLossDateRange(DateTime minLossDate, DateTime maxLossDate);

        /// <summary>
        /// Adds the specified claim to the repository.
        /// </summary>
        /// <exception cref="InvalidApiUsageException">
        /// Thrown if the claim already exists or if the claim data is in some way invalid.
        /// See InvalidApiUsageException.UsageError to determine the precise type of error.
        /// </exception>
        void AddClaim(MitchellClaim claim);

        /// <summary>
        /// Update the given claim.
        /// The <paramref name="updater"/> parameter may have any field set to null except for the ClaimNumber.
        /// The fields that have a null value will be ignored during the update operation.
        /// </summary>
        /// <exception cref="InvalidApiUsageException">
        /// Thrown if the claim was not found or if the claim once updated would get into an invalid state.
        /// See InvalidApiUsageException.UsageError to determine the precise type of error.
        /// If this exception was thrown then the repository was not changed.
        /// </exception>
        void UpdateClaim(MitchellClaim updater);

        /// <summary>
        /// Attempt to remove a claim as given by its claim number.
        /// </summary>
        /// <returns>
        /// True - the claim was found and removed.
        /// False - the claim was not found. Nothing was changed in the repository.
        /// </returns>
        bool TryRemoveClaim(string claimNumber);
    }
}
