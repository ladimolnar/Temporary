using System.Runtime.Serialization;

[DataContract]
public enum ClaimStatus
{
    [EnumMember(Value = "OPEN")]
    Open,

    [EnumMember(Value = "CLOSED")]
    Closed,
}
