using System;

namespace MIModels.Utilities
{
    /// <summary>
    /// The exception type used when an API method is used incorrectly. 
    /// Depending on where this exception is raised, this may indicate an error 
    /// from the part of the client of the REST API of from the part of an internal component.
    /// </summary>
    public class InvalidApiUsageException : Exception
    {
        public ApiUsageError UsageError { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="InvalidApiUsageException"/> class.
        /// </summary>
        public InvalidApiUsageException()
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="InvalidApiUsageException"/> class.
        /// </summary>
        /// <param name="usageError">The usage error associated with this exception.</param>
        public InvalidApiUsageException(ApiUsageError usageError) : this(usageError, null)
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="InvalidApiUsageException"/> class.
        /// </summary>
        /// <param name="usageError">The usage error associated with this exception.</param>
        /// <param name="message">The message that describes the error.</param>
        public InvalidApiUsageException(ApiUsageError usageError, string message)
            : base(message)
        {
            UsageError = usageError;
        }
    }
}
