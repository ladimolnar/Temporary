using System.Runtime.Serialization;

namespace MIModels
{
    /// <summary>
    /// Specifies the cause of loss for a claim.
    /// </summary>
    [DataContract]
    public enum CauseOfLoss
    {
        [EnumMember]
        Collision,

        [EnumMember]
        Explosion,

        [EnumMember]
        Fire,

        [EnumMember]
        Hail,

        [EnumMember(Value = "Mechanical Breakdown")]
        MechanicalBreakdown,

        [EnumMember]
        Other,
    }
}