using System.Runtime.Serialization;

namespace MIModels
{
    /// <summary>
    /// Specifies the claim status.
    /// </summary>
    [DataContract]
    public enum ClaimStatus
    {
        [EnumMember(Value = "OPEN")]
        Open,

        [EnumMember(Value = "CLOSED")]
        Closed,
    }
}
