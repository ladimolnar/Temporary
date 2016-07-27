using System;
using System.Collections.Generic;
using MIModels.Utilities;

namespace MIModels
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
        /// The <paramref name="updater"/> parameter may have any field set to null except for ClaimNumber.
        /// The fields that have a null value will be ignored during the update operation.
        /// Rules regarding updating vehicles:
        ///     - If the <paramref name="updater"/> does not have a list of vehicles then no vehicle is updated.
        ///     - If the <paramref name="updater"/> contains a new vehicle (new based on its VIN number)
        ///       then that vehicle is added to the claim being updated.
        ///     - If the <paramref name="updater"/> contains a vehicle also found in the claim being updated 
        ///       (based on its VIN number) then that vehicle is updated. 
        ///     - If the <paramref name="updater"/> contains a vehicle also found in the claim being updated 
        ///       (based on its VIN number) but the vehicle in the updater only has its VIN number specified then 
        ///       then that vehicle is not changed in the claim being updated.
        ///     - If the <paramref name="updater"/> does not contain a vehicle that is found in the claim being updated
        ///       (based on its VIN number) then that vehicle is deleted from the claim being updated. 
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
