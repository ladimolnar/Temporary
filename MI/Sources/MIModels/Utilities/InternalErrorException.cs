using System;

namespace MIModels.Utilities
{
    /// <summary>
    /// The exception type used when an internal error is encountered. Typically this indicates a bug in our code.
    /// </summary>
    public class InternalErrorException : Exception
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="InternalErrorException"/> class.
        /// </summary>
        public InternalErrorException()
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="InternalErrorException"/> class.
        /// </summary>
        /// <param name="message">The message that describes the error.</param>
        public InternalErrorException(string message)
            : base(message)
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="InternalErrorException"/> class.
        /// </summary>
        /// <param name="message">The message that describes the error.</param>
        /// <param name="innerException">
        /// The exception that is the cause of the current exception,
        /// or a null reference if no inner exception is specified.
        /// </param>
        public InternalErrorException(string message, Exception innerException)
            : base(message, innerException)
        { }
    }
}
