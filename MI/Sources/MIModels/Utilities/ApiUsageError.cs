
namespace MIModels.Utilities
{
    /// <summary>
    /// Specifies the specific type of API usage error.
    /// See <see cref="InvalidApiUsageException"/> class.
    /// </summary>
    public enum ApiUsageError
    {
        /// <summary>
        /// The API was invoked assuming that an item should be present. That item was not found.
        /// </summary>
        ItemAlreadyExists,

        /// <summary>
        /// The API was invoked assuming that an item should not exist. That item already exists.
        /// </summary>
        ItemNotFound,

        /// <summary>
        /// An attempt was made to create a claim without one or more vehicles with the same VIN number.
        /// TODO: We should verify the business rules around this. Is this really an error?
        /// </summary>
        DuplicateVehicles,

        /// <summary>
        /// The claim number was not specified.
        /// </summary>
        ClaimNumberNotSpecified,

        /// <summary>
        /// A required field was not specified.
        /// </summary>
        RequiredFieldNotSpecified,
    }
}
